import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/dto/def_dto.dart';
import 'package:mobidic_flutter/dto/word_dto.dart';
import 'package:mobidic_flutter/exception/api_exception.dart';
import 'package:mobidic_flutter/model/definition.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/model/word.dart';
import 'package:mobidic_flutter/repository/statistic_repository.dart';
import 'package:mobidic_flutter/repository/word_repository.dart';
import 'package:mobidic_flutter/viewmodel/vocab_view_model.dart';

final wordListStateProvider =
    StateNotifierProvider.autoDispose<WordListViewModel, WordListState>((ref) {
      final wordRepository = ref.read(wordRepositoryProvider);
      final statisticRepository = ref.read(statisticRepositoryProvider);
      final vocabListState = ref.watch(vocabListStateProvider);

      return WordListViewModel(
        wordRepository,
        statisticRepository,
        vocabListState.currentVocab,
      );
    });

class WordListViewModel extends StateNotifier<WordListState> {
  final WordRepository _wordRepository;
  final StatisticRepository _statisticRepository;

  WordListViewModel(
    this._wordRepository,
    this._statisticRepository,
    Vocab? currentVocab,
  ) : super(WordListState(currentVocab: currentVocab)) {
    init();
  }

  Future<void> init() async {
    await loadData();
  }

  Future<void> loadData() async {
    startLoading();
    await fetchWords();
    searchWords();
    await fetchStatistics();
    stopLoading();
  }

  Future<void> fetchWords() async {
    final currentVocab = state.currentVocab;
    if (currentVocab == null) return;

    try {
      final words = await _wordRepository.getWords(currentVocab.id);
      print('Fetched ${words.length} words for vocab ${currentVocab.title}');
      state = state.copyWith(words: words);
    } catch (e) {
      print('Error fetching words: $e');
      stopLoading();
    }
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

  void setEditingWord(Word word) {
    state = state.copyWith(editingWord: word);
  }

  void setAddingErrorMessage(String message) {
    state = state.copyWith(addingErrorMessage: message);
  }

  void setEditingErrorMessage(String message) {
    state = state.copyWith(editingErrorMessage: message);
  }

  Future<double> getQuizAccuracy() async {
    final currentVocab = state.currentVocab;
    if (currentVocab == null) return 0.0;
    return await _statisticRepository.getAccuracy(currentVocab.id);
  }

  Future<double> getLearningRate() async {
    final currentVocab = state.currentVocab;
    if (currentVocab == null) return 0.0;
    return await _statisticRepository.getLearningRate(currentVocab.id);
  }

  Future<bool> addWord(String expression, List<AddDefRequestDto> defs) async {
    setAddingErrorMessage('');

    try {
      final currentVocab = state.currentVocab;
      if (currentVocab == null) return false;

      await _wordRepository.addWord(currentVocab, expression, defs);
      await loadData();
      return false;
    } on ApiException catch (e) {
      print("addWord() Error : ${e.message}");
      if (e.errors.isNotEmpty) {
        setAddingErrorMessage(e.errors.values.first);
      } else {
        setAddingErrorMessage(e.message);
      }
      stopLoading();
      return true;
    } catch (e) {
      print("addWord() Extra Error : $e");
      setAddingErrorMessage('알 수 없는 오류 발생');
      stopLoading();
      return true;
    }
  }

  Future<bool> updateWord(
    String wordId,
    AddWordRequestDto word,
    List<Definition> defs,
    List<Definition> removingDefs,
  ) async {
    setEditingErrorMessage('');

    try {
      if (removingDefs.isNotEmpty) {
        for (Definition def in removingDefs) {
          await _wordRepository.deleteDef(def);
        }
      }

      await _wordRepository.updateWord(wordId, word, defs);

      await loadData();
      return false;
    } on ApiException catch (e) {
      print("updateWord() Error : ${e.message}");
      if (e.errors.isNotEmpty) {
        setEditingErrorMessage(e.errors.values.first);
      } else {
        setEditingErrorMessage(e.message);
      }
      stopLoading();
      return true;
    } catch (e) {
      print("updateWord() Extra Error : $e");
      setEditingErrorMessage('알 수 없는 오류 발생');
      stopLoading();
      return true;
    }
  }

  Future<void> toggleWordIsLearned(Word word) async {
    await _statisticRepository.toggleWordLearned(word);
    await loadData();
  }

  Future<void> deleteWord(Word word) async {
    await _wordRepository.deleteWord(word);
    await loadData();
  }

  void searchWords() {
    if (state.keyword.isEmpty) {
      state = state.copyWith(showingWords: state.words);
      return;
    }
    final query = state.keyword.toLowerCase();
    state = state.copyWith(
      showingWords:
          state.words
              .where(
                (w) =>
                    w.expression.toLowerCase().contains(query) ||
                    w.definitions.any(
                      (def) => def.meaning.toLowerCase().contains(query),
                    ),
              )
              .toList(),
    );
    sort();
  }

  void sort() {
    state = state.copyWith(showingWords: state.showingWords..sort(comparator));
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
  final Word? editingWord;
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
    this.editingWord,
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
    Word? editingWord,
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
      editingWord: editingWord ?? this.editingWord,
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
