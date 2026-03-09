import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/model/quiz.dart';
import 'package:mobidic_flutter/repository/quiz_repository.dart';
import 'package:mobidic_flutter/type/quiz_type.dart';
import 'package:mobidic_flutter/viewmodel/vocab_view_model.dart';

final oxQuizStateProvider =
    StateNotifierProvider.autoDispose<OxQuizViewModel, OxQuizState>((ref) {
      final quizRepository = ref.watch(quizRepositoryProvider);
      final vocabListState = ref.watch(vocabListStateProvider);

      return OxQuizViewModel(quizRepository, vocabListState);
    });

class OxQuizViewModel extends StateNotifier<OxQuizState> {
  final QuizRepository _quizRepository;
  final VocabListState _vocabListState;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  OxQuizViewModel(this._quizRepository, this._vocabListState)
    : super(OxQuizState()) {
    init();
  }

  Future<void> init() async {
    await _loadData();
  }

  Future<void> _loadData() async {
    _startLoading();

    await _fetchQuizzes();
    _initTimer();
    _stopLoading();
  }

  void _initTimer() {
    if (state.quizzes.isNotEmpty) {
      final totalExpireSeconds = state.quizzes[0].expMil ~/ 1000;

      state = state.copyWith(
        remainingSeconds: totalExpireSeconds,
        expireSeconds: totalExpireSeconds,
      );

      startTimer();
    }
  }

  Future<void> _fetchQuizzes() async {
    final currentVocab = _vocabListState.currentVocab;
    if (currentVocab == null) {
      _stopLoading();
      return;
    }
    try {
      print("Fetching quizzes");
      state = state.copyWith(
        quizzes: await _quizRepository.getQuizzes(currentVocab.id, QuizType.OX),
      );
      print("quizzes ${state.quizzes}");
    } catch (e) {
      state = state.copyWith(quizzes: []);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _stopwatch.reset();
    _timer?.cancel();

    _stopwatch.start();
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
      state = state.copyWith(
        remainingSeconds: state.expireSeconds - _stopwatch.elapsed.inSeconds,
      );
      if (state.isDone) {
        timer.cancel();
        _stopwatch.stop();
      }
      if (state.remainingSeconds < 1) {
        timer.cancel();
        _stopwatch.stop();

        final newList = [...state.quizzes];
        newList[state.currentQuizIndex] = state.currentQuiz.copyWith(
          isSolved: true,
        ); // Immutable 유지

        state = state.copyWith(
          isDone: true,
          resultMessage: "시간 초과!",
          quizzes: newList,
        );

        await Future.delayed(Duration(seconds: 2));
        showResult();
      }
    });
  }

  Future<void> checkAnswer(bool userAnswer) async {
    final newList = [...state.quizzes];
    newList[state.currentQuizIndex] = state.currentQuiz.copyWith(
      isSolved: true,
    );

    state = state.copyWith(resultMessage: "", quizzes: newList);

    final result = await _quizRepository.rateQuestion(
      state.currentQuiz.token,
      userAnswer ? "1" : "0",
    );

    String correctAnswer = result.correctAnswer == "1" ? "O" : "X";

    if (result.isCorrect) {
      state = state.copyWith(
        resultMessage: "정답입니다!",
        correctCount: state.correctCount + 1,
      );
      print("correct Count : ${state.correctCount}");
    } else {
      state = state.copyWith(
        resultMessage: "틀렸습니다! 답 : $correctAnswer",
        incorrectCount: state.incorrectCount + 1,
      );
    }

    await Future.delayed(Duration(seconds: 2));
    toNextWord();
  }

  void showResult() {
    if (state.isDone) {
      print("is Done! : ${state.correctCount}");
      state = state.copyWith(
        resultMessage: '정답률: ${state.correctCount}/${state.quizzes.length}',
      );
    }
  }

  void toNextWord() {
    state = state.copyWith(resultMessage: '');
    if (state.currentQuizIndex >= state.quizzes.length - 1) {
      state = state.copyWith(isDone: true,);
      showResult();
    }
    if (!state.isDone) {
      state = state.copyWith(currentQuizIndex: state.currentQuizIndex + 1);
    }
  }

  void toPrevWord() {
    state = state.copyWith(resultMessage: '');
    if (state.currentQuizIndex > 0) {
      state = state.copyWith(currentQuizIndex: state.currentQuizIndex - 1);
    }
  }

  void _startLoading() {
    state = state.copyWith(isLoading: true);
  }

  void _stopLoading() {
    state = state.copyWith(isLoading: false);
  }
}

class OxQuizState {
  List<Quiz> quizzes;
  int currentQuizIndex;
  int correctCount;
  int incorrectCount;
  bool isDone;
  bool isLoading;
  String resultMessage;
  int remainingSeconds;
  int expireSeconds;

  bool get isButtonAvailable =>
      quizzes.isNotEmpty &&
      currentQuizIndex < quizzes.length &&
      currentQuizIndex >= 0 &&
      !isDone &&
      !currentQuiz.isSolved;

  Quiz get currentQuiz =>
      quizzes.isNotEmpty
          ? quizzes[currentQuizIndex]
          : Quiz(token: '', stem: '', options: [], expMil: 100);

  OxQuizState({
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

  OxQuizState copyWith({
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
    return OxQuizState(
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
