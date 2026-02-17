import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mobidic_flutter/mixin/LoadingMixin.dart';
import 'package:mobidic_flutter/model/question.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/repository/question_repository.dart';
import 'package:mobidic_flutter/type/quiz_type.dart';
import 'package:mobidic_flutter/viewmodel/vocab_view_model.dart';

class OxQuizViewModel extends ChangeNotifier with LoadingMixin {
  final QuestionRepository _questionRepository;
  final VocabViewModel _vocabViewModel;

  OxQuizViewModel(this._questionRepository, this._vocabViewModel) {
    init();
  }

  Future<void> init() async {
    await loadData();
  }

  Future<void> loadData() async {
    startLoading();
    _questions = await _questionRepository.getQuestions(
      currentVocab?.id,
      QuizType.OX,
    );
    if(_questions.isNotEmpty){
      _secondsLeft = questions[0].expMil ~/ 1000;
      startTimer();
    }
    stopLoading();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<Question> _questions = [];

  List<Question> get questions => _questions;

  Question get currentQuestion => _questions[currentQuestionIndex];

  Vocab? get currentVocab => _vocabViewModel.currentVocab;

  int _currentQuestionIndex = 0;

  int get currentQuestionIndex => _currentQuestionIndex;

  bool get isButtonAvailable =>
      questions.isNotEmpty && currentQuestionIndex >= 0 && !isDone && !isSolved;

  bool _isSolved = false;

  bool get isSolved => _isSolved;

  int _correctCount = 0;

  int get correctCount => _correctCount;

  int _incorrectCount = 0;

  int get incorrectCount => _incorrectCount;

  bool _isDone = false;

  bool get isDone => _isDone;

  String resultMessage = "-";

  int _secondsLeft = 1;
  int get secondsLeft => _secondsLeft;

  Timer? _timer;

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsLeft == 0 || isDone) {
        timer.cancel();
        _isDone = true;
        if(secondsLeft == 0) {
          _isSolved = true;
          resultMessage = "시간 초과!";
        }
        notifyListeners();
      } else {
        _secondsLeft--;
        notifyListeners();
      }
    });
  }

  Future<void> checkAnswer(bool userAnswer) async {
    resultMessage = "";
    _isSolved = true;
    notifyListeners();

    final result = await _questionRepository.rateQuestion(
      currentQuestion.token,
      userAnswer ? "1" : "0",
    );

    String correctAnswer = result.correctAnswer == "1" ? "O" : "X";

    if (result.isCorrect) {
      resultMessage = "정답입니다!";
      _correctCount += 1;
    } else {
      resultMessage = "틀렸습니다! 답 : $correctAnswer";
      _incorrectCount += 1;
    }
    notifyListeners();

    await Future.delayed(Duration(seconds: 2));
    if (currentQuestionIndex >= questions.length - 1) {
      _isDone = true;
      notifyListeners();
    }
    _isSolved = false;
    toNextWord();
  }

  void toNextWord() {
    if (!isDone) {
      _currentQuestionIndex += 1;
      notifyListeners();
    }
  }

  void toPrevWord() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex -= 1;
      notifyListeners();
    }
  }
}
