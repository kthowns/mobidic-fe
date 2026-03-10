import 'dart:io';

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

  Future<void> init() async {
    await loadData();
    await _initTts();
    await _flutterTts.setLanguage('en-US');
  }

  Future<void> loadData() async {
    startLoading();
    await fetchWords();
    stopLoading();
  }

  Future<void> fetchWords() async {
    final currentVocab = _vocabListState.currentVocab;

    if (currentVocab == null) return;

    final words = await _wordRepository.getWords(currentVocab.id);

    state = state.copyWith(words: words);
  }

  @override
  void dispose() {
    _flutterTts.stop();
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
      print("NO Permission!!");
    }
  }

  Future<void> stopRecordingAndUpload() async {
    final path = await _recorder.stop();

    await Future.delayed(Duration(milliseconds: 300));
    state = state.copyWith(isRating: true);

    if (path != null) {
      final File file = File(path);

      // 파일 존재 확인
      if (await file.exists()) {
        final bytes = await file.readAsBytes(); // 정확한 byte[]
        final size = bytes.length;
        print("byte 크기: $size");

        try {
          final score = await _pronunciationRepository.checkPronunciation(
            file.path,
            state.currentWord.id,
          );
          final resultMessage = "${(score * 100).ceil().toStringAsFixed(0)}점";
          state = state.copyWith(resultMessage: resultMessage);
          print("resultMessage : $resultMessage");
          file.delete();
        } on ApiException catch (e) {
          print(e);
          state = state.copyWith(resultMessage: "${e.message} 다시 한 번 말해보세요.");
        } on Exception catch (e) {
          print(e);
          state = state.copyWith(resultMessage: "오류 발생");
        } finally {
          state = state.copyWith(isRating: false);
        }
      }
    }
  }

  void toNextWord() {
    if (!mounted) {
      return;
    }
    state = state.copyWith(resultMessage: '');
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

  bool get isButtonAvailable =>
      words.isNotEmpty && !isDone && !isRating && !isLoading;
  Word get currentWord => words[currentWordIndex];

  PronunciationState({
    this.words = const [],
    this.currentWordIndex = 0,
    this.resultMessage = '',
    this.isRating = false,
    this.isDone = false,
    this.isLoading = false,
    this.score = 0,
  });

  PronunciationState copyWith({
    List<Word>? words,
    int? currentWordIndex,
    String? resultMessage,
    double? score,
    bool? isRating,
    bool? isDone,
    bool? isLoading,
  }) {
    return PronunciationState(
      words: words ?? this.words,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      resultMessage: resultMessage ?? this.resultMessage,
      score: score ?? this.score,
      isRating: isRating ?? this.isRating,
      isDone: isDone ?? this.isDone,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
