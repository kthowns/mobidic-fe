import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobidic_flutter/mixin/LoadingMixin.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/model/word.dart';
import 'package:mobidic_flutter/repository/word_repository.dart';
import 'package:mobidic_flutter/viewmodel/vocab_view_model.dart';

class DictationQuizViewModel extends ChangeNotifier with LoadingMixin {
  final WordRepository _wordRepository;
  final VocabViewModel _vocabViewModel;
  final TextEditingController _userAnswerController = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();

  TextEditingController get userAnswerController => _userAnswerController;

  DictationQuizViewModel(this._wordRepository, this._vocabViewModel) {
    init();
  }

  Future<void> init() async {
    await loadData();
    await _initTts();
    await flutterTts.setLanguage('en-US');
  }

  Future<void> loadData() async {
    startLoading();
    _words = await _wordRepository.getWords(_currentVocab?.id);
    if(_words.isNotEmpty){
      _secondsLeft = _words.length * 15;
      startTimer();
    }
    stopLoading();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US"); // 한국어: "ko-KR"
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5); // 속도 조절 (0.0 ~ 1.0)
  }

  @override
  void dispose() {
    _timer?.cancel();
    _userAnswerController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Vocab? get _currentVocab => _vocabViewModel.currentVocab;

  List<Word> _words = [];

  List<Word> get words => _words;

  Word get currentWord => _words[currentWordIndex];

  int _currentWordIndex = 0;

  int get currentWordIndex => _currentWordIndex;

  bool get isButtonAvailable =>
      words.isNotEmpty && currentWordIndex >= 0 && !isDone && !isSolved;

  bool _isSolved = false;

  bool get isSolved => _isSolved;

  int _correctCount = 0;

  int get correctCount => _correctCount;

  int _incorrectCount = 0;

  int get incorrectCount => _incorrectCount;

  String get currentAnswer => _userAnswerController.text;

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
        if (secondsLeft == 0) {
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

  Future<void> speak() async {
    if (words.isNotEmpty) {
      await flutterTts.speak(words[currentWordIndex].expression);
    }
  }

  Future<void> checkAnswer(String userAnswer) async {
    resultMessage = "";
    _isSolved = true;
    notifyListeners();

    if (currentWord.expression.toLowerCase() == userAnswer.toLowerCase()) {
      resultMessage = "정답입니다!";
      _correctCount += 1;
    } else {
      resultMessage = "틀렸습니다! 답 : ${currentWord.expression}";
      _incorrectCount += 1;
    }
    notifyListeners();

    await Future.delayed(Duration(seconds: 2));
    if (currentWordIndex >= words.length - 1) {
      _isDone = true;
      notifyListeners();
    }
    _isSolved = false;
    _userAnswerController.text = "";
    toNextWord();
  }

  void toNextWord() {
    if (!isDone) {
      _currentWordIndex += 1;
      notifyListeners();
    }
  }

  void toPrevWord() {
    if (_currentWordIndex > 0) {
      _currentWordIndex -= 1;
      notifyListeners();
    }
  }
}
