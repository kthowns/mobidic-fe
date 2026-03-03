import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/dto/def_dto.dart';
import 'package:mobidic_flutter/model/definition.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/model/word.dart';
import 'package:mobidic_flutter/repository/statistic_repository.dart';
import 'package:mobidic_flutter/repository/word_repository.dart';
import 'package:mobidic_flutter/type/part_of_speech.dart';
import 'package:mobidic_flutter/viewmodel/vocab_view_model.dart';

final wordViewModelProvider =
    StateNotifierProvider.autoDispose<WordViewModel, WordListState>((ref) {
      final wordRepository = ref.read(wordRepositoryProvider);
      final statisticRepository = ref.read(statisticRepositoryProvider);
      final vocabListState = ref.watch(vocabListViewModelProvider);

      return WordViewModel(
        wordRepository,
        statisticRepository,
        vocabListState.currentVocab,
      );
    });

class WordViewModel extends StateNotifier<WordListState> {
  final WordRepository _wordRepository;
  final StatisticRepository _rateRepository;

  WordViewModel(this._wordRepository, this._rateRepository, Vocab? currentVocab)
    : super(WordListState(currentVocab: currentVocab)) {
    init();
  }

  Future<void> init() async {
    await loadData();
  }

  Future<void> loadData() async {
    startLoading();
    final currentVocab = state.currentVocab;
    if (currentVocab == null) {
      state = state.copyWith(words: [], showingWords: []);
      stopLoading();
      return;
    }
    final words = await _wordRepository.getWords(currentVocab.id);
    state = state.copyWith(words: words);
    sort();
    fetchStatistics();
    stopLoading();
  }

  Future<void> fetchStatistics() async {
    final accuracy = await getQuizAccuracy();
    final learningRate = await getLearningRate();
    state = state.copyWith(accuracy: accuracy, learningRate: learningRate);
  }

  final List<String> sortOptions = ['최신순', '난이도순', '알파벳순'];
  int currentSortIndex = 0;

  void cycleSortOption() {
    currentSortIndex = (currentSortIndex + 1) % sortOptions.length;
    switch (sortOptions[currentSortIndex]) {
      case '알파벳순':
        comparator = (b, a) => a.expression.compareTo(b.expression);
        break;
      case '난이도순':
        comparator = (b, a) => a.difficulty.compareTo(b.difficulty);
        break;
      case '최신순':
        comparator = (b, a) => a.createdAt!.compareTo(b.createdAt!);
        break;
    }
    sort();
  }

  void toggleEditMode() {
    state = state.copyWith(editMode: !state.editMode);
  }

  Comparator<Word> comparator =
      (w2, w1) => w1.createdAt!.compareTo(w2.createdAt!);

  void searchWords() {
    if (state.keyword.isEmpty) {
      state = state.copyWith(showingWords: state.words);
      return;
    }
    final query = state.keyword.toLowerCase();
    state = state.copyWith(
      showingWords: state.words.where(
        (w) =>
            w.expression.toLowerCase().contains(query) ||
            w.definitions.any(
              (def) => def.definition.toLowerCase().contains(query),
            ),
      ).toList());
  }

  void setAddingErrorMessage(String message) {
    _addingErrorMessage = message;
    notifyListeners();
  }

  void setEditingErrorMessage(String message) {
    _addingErrorMessage = message;
    notifyListeners();
  }

  Future<double> getQuizAccuracy() async {
    return await _rateRepository.getAccuracy(_vocabViewModel.currentVocab?.id);
  }

  Future<double> getLearningRate() async {
    return await _rateRepository.getLearningRate(
      _vocabViewModel.currentVocab?.id,
    );
  }

  Future<void> addWord(String expression, List<AddWordRequest> defs) async {
    await _wordRepository.addWord(
      _vocabViewModel.currentVocab,
      expression,
      defs,
    );
    await loadData();
  }

  Future<void> updateWord(Word word, String exp, List<Definition> defs) async {
    await _wordRepository.updateWord(word, exp, defs);
    if (removingDefs.isNotEmpty) {
      for (Definition def in removingDefs) {
        await _wordRepository.deleteDef(def);
      }
    }
    await loadData();
  }

  Future<void> toggleWordIsLearned(Word word) async {
    await _rateRepository.toggleWordLearned(word);
    await loadData();
  }

  Future<void> deleteWord(Word word) async {
    await _wordRepository.deleteWord(word);
    await loadData();
  }

  void sort() {
    searchWords();
    _words.sort(comparator);
    notifyListeners();
  }

  void startLoading() {
    state = state.copyWith(isLoading: true);
  }

  void stopLoading() {
    state = state.copyWith(isLoading: false);
  }
}

class WordListState {
  final List<Word> words;
  final List<Word> showingWords;
  final List<AddDefRequestDto> addingDefs;
  final String addingErrorMessage;
  final String editingErrorMessage;
  final String keyword;
  final bool isLoading;
  final bool editMode;
  final double accuracy;
  final double learningRate;
  final Vocab? currentVocab;

  WordListState({
    this.words = const [],
    this.showingWords = const [],
    this.addingDefs = const [],
    this.addingErrorMessage = '',
    this.editingErrorMessage = '',
    this.keyword = '',
    this.isLoading = false,
    this.editMode = false,
    this.accuracy = 0.0,
    this.learningRate = 0.0,
    this.currentVocab,
  });

  WordListState copyWith({
    List<Word>? words,
    List<Word>? showingWords,
    List<AddDefRequestDto>? addingDefs,
    String? addingErrorMessage,
    String? editingErrorMessage,
    String? keyword,
    bool? isLoading,
    bool? editMode,
    double? accuracy,
    double? learningRate,
    Vocab? currentVocab,
  }) {
    return WordListState(
      words: words ?? this.words,
      showingWords: showingWords ?? this.showingWords,
      addingDefs: addingDefs ?? this.addingDefs,
      addingErrorMessage: addingErrorMessage ?? this.addingErrorMessage,
      editingErrorMessage: editingErrorMessage ?? this.editingErrorMessage,
      keyword: keyword ?? this.keyword,
      isLoading: isLoading ?? this.isLoading,
      editMode: editMode ?? this.editMode,
      accuracy: accuracy ?? this.accuracy,
      learningRate: learningRate ?? this.learningRate,
      currentVocab: currentVocab ?? this.currentVocab,
    );
  }
}
