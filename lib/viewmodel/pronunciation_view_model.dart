import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobidic_flutter/mixin/LoadingMixin.dart';
import 'package:mobidic_flutter/model/word.dart';
import 'package:mobidic_flutter/repository/pronunciation_repository.dart';
import 'package:mobidic_flutter/repository/rate_repository.dart';
import 'package:mobidic_flutter/repository/word_repository.dart';
import 'package:mobidic_flutter/viewmodel/vocab_view_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../exception/api_exception.dart';

class PronunciationViewModel extends ChangeNotifier with LoadingMixin {
  final PronunciationRepository _pronunciationRepository;
  final WordRepository _wordRepository;
  final RateRepository _rateRepository;
  final VocabViewModel _vocabViewModel;
  final FlutterTts _flutterTts = FlutterTts();

  PronunciationViewModel(
    this._pronunciationRepository,
    this._wordRepository,
    this._rateRepository,
    this._vocabViewModel,
  ) {
    init();
  }

  Future<void> init() async {
    await loadData();
    await _initTts();
    await _flutterTts.setLanguage('en-US');
  }

  Future<void> loadData() async {
    startLoading();
    _words = await _wordRepository.getWords(_vocabViewModel.currentVocab?.id);
    if(_words.length < 2){
      _isEnd = true;
    }
    stopLoading();
  }

  @override
  void dispose(){
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US"); // 한국어: "ko-KR"
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5); // 속도 조절 (0.0 ~ 1.0)
  }

  List<Word> _words = [];

  List<Word> get words => _words;

  int _currentWordIndex = 0;
  int get currentWordIndex => _currentWordIndex;

  Word get currentWord => words[currentWordIndex];

  final _recorder = AudioRecorder();

  bool _isRecording = false;

  bool get isRecording => _isRecording;

  String recordFilePath = "";
  String resultMessage = "";

  bool _isRating = false;
  bool get isRating => _isRating;

  double score = 0.0;

  bool _isEnd = false;
  bool get isEnd => _isEnd;

  bool _isSolved = false;
  bool get isSolved => _isSolved;

  bool _isDone = false;

  bool get isDone => _isDone;

  bool get isButtonAvailable =>
      words.isNotEmpty && !isDone && !isSolved;

  bool get isWeb => kIsWeb;

  Future<void> speak() async {
    if (words.isNotEmpty) {
      await _flutterTts.speak(words[currentWordIndex].expression);
    }
  }

  Future<void> startRecording() async {
    final dir = await getTemporaryDirectory();
    recordFilePath = '${dir.path}/temp_audio.mp4';
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
    _isRecording = true;
    notifyListeners();
  }

  Future<void> stopRecordingAndUpload() async {
    final path = await _recorder.stop();

    await Future.delayed(Duration(milliseconds: 300));
    _isRecording = false;
    _isRating = true;
    notifyListeners();

    if (path != null) {
      final File file = File(path);

      // 파일 존재 확인
      if (await file.exists()) {
        final bytes = await file.readAsBytes(); // 정확한 byte[]
        final size = bytes.length;
        print("확실한 byte 크기: $size");

        try {
          score = await _pronunciationRepository.checkPronunciation(
            file.path,
            words[currentWordIndex].id,
          );
          resultMessage = "${(score * 100).ceil().toStringAsFixed(0)}점";
          print("resultMessage : $resultMessage");
          file.delete();
        } on ApiException catch (e){
          resultMessage = "다시 말해보세요.";
          rethrow;
        } on Exception catch (e){
          resultMessage = "오류 발생";
          rethrow;
        } finally {
          _isRating = false;
          notifyListeners();
        }
      }
    }
  }

  void toNextWord() {
    if (_currentWordIndex < words.length - 1) {
      _currentWordIndex += 1;
      resultMessage = "";
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
