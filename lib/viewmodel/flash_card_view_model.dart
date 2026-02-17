import 'package:flutter/cupertino.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:mobidic_flutter/mixin/LoadingMixin.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/model/word.dart';
import 'package:mobidic_flutter/viewmodel/vocab_view_model.dart';

import '../repository/word_repository.dart';

class FlashCardViewModel extends ChangeNotifier with LoadingMixin {
  final WordRepository _wordRepository;
  final VocabViewModel _vocabViewModel;

  FlashCardViewModel(
      this._wordRepository,
      this._vocabViewModel,
  ){
    init();
  }

  Future<void> init() async {
    await loadData();
  }

  Future<void> loadData() async {
    startLoading();
    _words = await _wordRepository.getWords(_currentVocab?.id);
    stopLoading();
  }

  Vocab? get _currentVocab => _vocabViewModel.currentVocab;

  List<Word> _words = [];
  List<Word> get words => _words;

  Word? get currentWord => _words.isNotEmpty ? _words[currentWordIndex] : null;

  int _currentWordIndex = 0;
  int get currentWordIndex => _currentWordIndex;

  bool _wordVisibility = true;
  bool get wordVisibility => _wordVisibility;

  void toggleWordVisibility(){
    _wordVisibility = !_wordVisibility;
    notifyListeners();
  }

  bool _defVisibility = false;
  bool get defVisibility => _defVisibility;

  void toggleDefVisibility(){
    _defVisibility = !_defVisibility;
    notifyListeners();
  }

  void toNextWord() {
    if(_currentWordIndex < _words.length - 1){
      _currentWordIndex += 1;
      notifyListeners();
    }
  }

  void toPrevWord() {
    if(_currentWordIndex > 0){
      _currentWordIndex -= 1;
      notifyListeners();
    }
  }
}