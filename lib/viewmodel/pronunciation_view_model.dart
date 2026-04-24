import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobidic_flutter/model/word.dart';
import 'package:mobidic_flutter/repository/pronunciation_repository.dart';
import 'package:mobidic_flutter/repository/word_repository.dart';
import 'package:mobidic_flutter/viewmodel/vocab_view_model.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../exception/api_exception.dart';

final pronunciationStateProvider = StateNotifierProvider.autoDispose<
  PronunciationViewModel,
  PronunciationState
>((ref) {
  final vocabListState = ref.read(vocabListStateProvider);
  final wordRepository = ref.read(wordRepositoryProvider);
  final pronunciationRepository = ref.read(pronunciationRepositoryProvider);
  return PronunciationViewModel(
    pronunciationRepository,
    vocabListState,
    wordRepository,
  );
});

class PronunciationViewModel extends StateNotifier<PronunciationState> {
  final PronunciationRepository _pronunciationRepository;
  final VocabListState _vocabListState;
  final WordRepository _wordRepository;
  final _flutterTts = FlutterTts();
  final _recorder = AudioRecorder();

  PronunciationViewModel(
    this._pronunciationRepository,
    this._vocabListState,
    this._wordRepository,
  ) : super(PronunciationState()) {
    init();
  }

  Future<void> checkMicPermission() async {
    final hasPermission = await _recorder.hasPermission();
    state = state.copyWith(hasPermission: hasPermission);
  }

  Future<void> init() async {
    debugPrint("init");
    await loadData();
    await _initTts();
    await _flutterTts.setLanguage('en-US');
    await checkMicPermission();
    debugPrint("init done.");
  }

  Future<void> loadData() async {
    startLoading();
    await fetchWords();
    stopLoading();
  }

  Future<void> fetchWords() async {
    final currentVocab = _vocabListState.currentVocab;
    if (currentVocab == null) return;

    debugPrint("fetching words...");
    final words = await _wordRepository.getWords(currentVocab.id);
    state = state.copyWith(words: words);
    debugPrint("words : ${state.words}");
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US"); // 한국어: "ko-KR"
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5); // 속도 조절 (0.0 ~ 1.0)
  }

  Future<void> speak() async {
    if (state.words.isNotEmpty) {
      await _flutterTts.speak(state.currentWord.expression);
    }
  }

  Future<void> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (kIsWeb) {
      if (hasPermission) {
        // 웹은 path를 빈 문자열로 주면 브라우저 Blob으로 처리함
        await _recorder.start(const RecordConfig(), path: '');
        debugPrint("Web recording started...");
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final recordFilePath = '${dir.path}/temp_audio.mp4';
    if (await _recorder.hasPermission()) {
      final config = RecordConfig(
        encoder: AudioEncoder.aacLc, // aacADTS도 가능
        bitRate: 128000,
        sampleRate: 44100,
      );

      await _recorder.start(config, path: recordFilePath);
    } else {
      debugPrint("NO Permission!!");
    }
  }

  Future<void> stopRecordingAndUpload() async {
    final path = await _recorder.stop();

    if (path == null) {
      state = state.copyWith(resultMessage: "녹음된 데이터가 없습니다.", score: 0.01);
      return;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(isRating: true, score: 0, resultMessage: '');

    try {
      double score = 0;
      if (kIsWeb) {
        debugPrint("Web Upload Path: $path");
        score = await _pronunciationRepository.checkPronunciation(
          path,
          state.currentWord.id,
        );
      } else {
        final File file = File(path);
        if (await file.exists()) {
          final size = await file.length();
          debugPrint("녹음 파일 크기: $size bytes");

          if (size < 100) {
            // 너무 작은 파일은 녹음 실패로 간주
            throw Exception("녹음된 소리가 너무 작습니다.");
          }

          score = await _pronunciationRepository.checkPronunciation(
            file.path,
            state.currentWord.id,
          );
          file.delete();
        } else {
          throw Exception("녹음 파일을 찾을 수 없습니다.");
        }
      }

      final scorePercentage = (score * 100).ceilToDouble();
      String resultMessage = "";

      if (scorePercentage >= 80) {
        resultMessage = "완벽해요! 원어민 같은 발음입니다.";
      } else if (scorePercentage >= 60) {
        resultMessage = "좋은 발음이에요! 조금만 더 명확하게 발음해 보세요.";
      } else if (scorePercentage >= 40) {
        resultMessage = "괜찮아요. 억양과 강세에 조금 더 신경 써볼까요?";
      } else if (scorePercentage > 0) {
        resultMessage = "잘 들리지 않아요. 다시 한 번 또박또박 말해볼까요?";
      } else {
        resultMessage = "발음을 인식하지 못했습니다. 다시 시도해 주세요.";
      }

      state = state.copyWith(
        resultMessage: resultMessage,
        score: scorePercentage <= 0 ? 0.01 : scorePercentage,
      );
      debugPrint("score: $scorePercentage, resultMessage : $resultMessage");
    } on ApiException catch (e) {
      debugPrint("ApiException: ${e.message}");
      state = state.copyWith(
        resultMessage: e.message,
        score: 0.01,
      );
    } catch (e) {
      debugPrint("Error: $e");
      state = state.copyWith(
        resultMessage: "잘 들리지 않아요. 다시 한 번 말해볼까요?",
        score: 0.01,
      );
    } finally {
      state = state.copyWith(isRating: false);
    }
  }

  void toNextWord() {
    if (!mounted) {
      return;
    }
    state = state.copyWith(resultMessage: '', score: 0);
    if (state.currentWordIndex >= state.words.length - 1) {
      state = state.copyWith(isDone: true);
      //showResult();
    }
    if (!state.isDone) {
      state = state.copyWith(currentWordIndex: state.currentWordIndex + 1);
    }
  }

  void toPrevWord() {
    final currentWordIndex = state.currentWordIndex;
    if (currentWordIndex > 0) {
      state = state.copyWith(currentWordIndex: currentWordIndex - 1);
    }
  }

  void startLoading() {
    state = state.copyWith(isLoading: true);
  }

  void stopLoading() {
    state = state.copyWith(isLoading: false);
  }
}

class PronunciationState {
  List<Word> words;
  int currentWordIndex;
  String resultMessage;
  double score;
  bool isRating;
  bool isDone;
  bool isLoading;
  bool hasPermission;

  bool get isButtonAvailable =>
      words.isNotEmpty && !isDone && !isRating && !isLoading;
  Word get currentWord => words[currentWordIndex];

  PronunciationState({
    this.words = const [],
    this.currentWordIndex = 0,
    this.resultMessage = '',
    this.score = 0,
    this.isRating = false,
    this.isDone = false,
    this.isLoading = false,
    this.hasPermission = false,
  });

  PronunciationState copyWith({
    List<Word>? words,
    int? currentWordIndex,
    String? resultMessage,
    double? score,
    bool? isRating,
    bool? isDone,
    bool? isLoading,
    bool? hasPermission,
  }) {
    return PronunciationState(
      words: words ?? this.words,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      resultMessage: resultMessage ?? this.resultMessage,
      score: score ?? this.score,
      isRating: isRating ?? this.isRating,
      isDone: isDone ?? this.isDone,
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}
