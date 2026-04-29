import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobidic/model/definition.dart';
import 'package:mobidic/model/quiz.dart';
import 'package:mobidic/model/word.dart';
import 'package:mobidic/repository/word_repository.dart';
import 'package:mobidic/viewmodel/vocab_view_model.dart';

final dictationQuizStateProvider =
    StateNotifierProvider.autoDispose<
      DictationQuizViewModel,
      DictationQuizState
    >((ref) {
      final flutterTts = FlutterTts();
      final vocabListState = ref.read(vocabListStateProvider);
      final wordRepository = ref.read(wordRepositoryProvider);

      return DictationQuizViewModel(flutterTts, vocabListState, wordRepository);
    });

class DictationQuizViewModel extends StateNotifier<DictationQuizState> {
  final FlutterTts _flutterTts;
  final Stopwatch _stopwatch = Stopwatch();
  final VocabListState _vocabListState;
  final WordRepository _wordRepository;
  Timer? _timer;

  DictationQuizViewModel(
    this._flutterTts,
    this._vocabListState,
    this._wordRepository,
  ) : super(DictationQuizState()) {
    init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> init() async {
    await _initTts();
    await _loadData();
  }

  Future<void> _loadData() async {
    _startLoading();

    await _fetchQuizzes();
    if (state.quizzes.isNotEmpty) {
      _initGlobalTimer();
    }
    _stopLoading();
  }

  Future<void> _fetchQuizzes() async {
    final currentVocab = _vocabListState.currentVocab;
    if (currentVocab == null) {
      _stopLoading();
      return;
    }
    try {
      List<Word> allWords = await _wordRepository.getWords(currentVocab.id);
      List<Word> words = allWords.where((word) => !word.isLearned).toList();

      List<Quiz> quizzes = words.map((word) {
        Definition def = word.definitions.first;

        return Quiz(
          expMil: 15000 * words.length, // 전체 제한 시간
          stem: word.expression,
          options: ['${def.meaning} (${def.part.label})'],
          token: '',
        );
      }).toList();

      state = state.copyWith(quizzes: quizzes);
    } catch (e) {
      state = state.copyWith(quizzes: []);
    }
  }

  void _initGlobalTimer() {
    final totalExpireSeconds = state.quizzes[0].expMil ~/ 1000;

    state = state.copyWith(
      remainingSeconds: totalExpireSeconds,
      expireSeconds: totalExpireSeconds,
    );

    startTimer();
  }

  void startTimer() {
    _stopwatch.reset();
    _timer?.cancel();

    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (state.isDone) {
        timer.cancel();
        _stopwatch.stop();
        return;
      }

      final currentRemaining =
          state.expireSeconds - _stopwatch.elapsed.inSeconds;
      state = state.copyWith(remainingSeconds: currentRemaining);

      if (state.remainingSeconds < 1) {
        timer.cancel();
        _stopwatch.stop();
        _handleGlobalTimeout();
      }
    });
  }

  void _handleGlobalTimeout() {
    state = state.copyWith(isDone: true, resultMessage: "시간 초과!");
  }

  Future<void> speak() async {
    if (state.quizzes.isNotEmpty) {
      await _flutterTts.speak(state.currentQuiz.stem);
    }
  }

  Future<void> checkAnswer(String userAnswer) async {
    if (state.currentQuiz.isSolved || state.isDone) return;

    final newList = [...state.quizzes];
    newList[state.currentQuizIndex] = state.currentQuiz.copyWith(
      isSolved: true,
    );

    state = state.copyWith(resultMessage: "", quizzes: newList);

    if (state.currentQuiz.stem.toLowerCase() ==
        userAnswer.trim().toLowerCase()) {
      state = state.copyWith(
        resultMessage: "정답입니다!",
        correctCount: state.correctCount + 1,
      );
    } else {
      state = state.copyWith(
        resultMessage: "틀렸습니다! 답 : ${state.currentQuiz.stem}",
        incorrectCount: state.incorrectCount + 1,
      );
    }

    await Future.delayed(const Duration(seconds: 1));
    toNextWord();
  }

  void toNextWord() {
    if (!mounted || state.isDone) return;

    state = state.copyWith(resultMessage: '');

    if (state.currentQuizIndex >= state.quizzes.length - 1) {
      state = state.copyWith(isDone: true);
    } else {
      state = state.copyWith(currentQuizIndex: state.currentQuizIndex + 1);
    }
  }

  void _startLoading() {
    state = state.copyWith(isLoading: true);
  }

  void _stopLoading() {
    state = state.copyWith(isLoading: false);
  }
}

class DictationQuizState {
  List<Quiz> quizzes;
  int currentQuizIndex;
  int correctCount;
  int incorrectCount;
  bool isDone;
  bool isLoading;
  String resultMessage;
  int remainingSeconds;
  int expireSeconds;

  Quiz get currentQuiz => quizzes[currentQuizIndex];
  bool get isButtonAvailable =>
      quizzes.isNotEmpty &&
      currentQuizIndex >= 0 &&
      !isDone &&
      !currentQuiz.isSolved;

  DictationQuizState({
    this.quizzes = const [],
    this.currentQuizIndex = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.isDone = false,
    this.isLoading = false,
    this.resultMessage = '',
    this.remainingSeconds = 0,
    this.expireSeconds = 0,
  });

  DictationQuizState copyWith({
    List<Quiz>? quizzes,
    int? currentQuizIndex,
    int? correctCount,
    int? incorrectCount,
    bool? isDone,
    bool? isLoading,
    String? resultMessage,
    int? remainingSeconds,
    int? expireSeconds,
  }) {
    return DictationQuizState(
      quizzes: quizzes ?? this.quizzes,
      currentQuizIndex: currentQuizIndex ?? this.currentQuizIndex,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      isDone: isDone ?? this.isDone,
      isLoading: isLoading ?? this.isLoading,
      resultMessage: resultMessage ?? this.resultMessage,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      expireSeconds: expireSeconds ?? this.expireSeconds,
    );
  }
}
