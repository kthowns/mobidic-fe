import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic/exception/api_exception.dart';
import 'package:mobidic/model/vocab.dart';
import 'package:mobidic/repository/statistic_repository.dart';
import 'package:mobidic/repository/vocab_repository.dart';

final vocabListStateProvider =
    StateNotifierProvider.autoDispose<VocabListViewModel, VocabListState>((
      ref,
    ) {
      final vocabRepository = ref.watch(vocabRepositoryProvider);
      final statisticRepository = ref.watch(statisticRepositoryProvider);
      return VocabListViewModel(vocabRepository, statisticRepository);
    });

class VocabListViewModel extends StateNotifier<VocabListState> {
  final VocabRepository _vocabRepository;
  final StatisticRepository _rateRepository;

  VocabListViewModel(this._vocabRepository, this._rateRepository)
    : super(VocabListState()) {
    init();
  }

  void startLoading() {
    state = state.copyWith(isLoading: true);
  }

  void stopLoading() {
    state = state.copyWith(isLoading: false);
  }

  Future<void> init() async {
    await loadData();
  }

  Future<void> fetchVocabs() async {
    final vocabs = await _vocabRepository.getVocabs();
    state = state.copyWith(vocabs: vocabs);
  }

  Future<void> loadData() async {
    startLoading();
    await fetchVocabs();
    searchVocabs();
    await fetchStatistics();
    debugPrint("평균 학습률 : ${state.avgLearningRate}");
    stopLoading();
  }

  Future<void> fetchStatistics() async {
    final avgAccuracy = await getAvgAccuracy();
    final avgLearningRate = getAvgLearningRate();
    state = state.copyWith(
      avgAccuracy: avgAccuracy,
      avgLearningRate: avgLearningRate,
    );
  }

  void selectVocabAt(int index) {
    state = state.copyWith(currentVocab: state.showingVocabs[index]);
  }

  final List<String> sortOptions = ['최신순', '이름순', '학습률순', '정답률순'];
  int currentSortIndex = 0;

  void cycleSortOption() {
    currentSortIndex = (currentSortIndex + 1) % sortOptions.length;
    switch (sortOptions[currentSortIndex]) {
      case '이름순':
        comparator = (a, b) => a.title.compareTo(b.title);
        break;
      case '학습률순':
        comparator = (a, b) => b.learningRate.compareTo(a.learningRate);
        break;
      case '최신순':
        comparator = (a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        };
        break;
      case '정답률순':
        comparator = (a, b) => b.accuracy.compareTo(a.accuracy);
        break;
    }
    sort();
  }

  void toggleEditMode() {
    state = state.copyWith(editMode: !state.editMode);
  }

  Comparator<Vocab> comparator = (a, b) {
    if (a.createdAt == null && b.createdAt == null) return 0;
    if (a.createdAt == null) return 1;
    if (b.createdAt == null) return -1;
    return b.createdAt!.compareTo(a.createdAt!);
  };

  int selectedCardIndex = -1;

  void searchVocabs() {
    if (state.keyword.isEmpty) {
      state = state.copyWith(showingVocabs: state.vocabs);
    } else {
      final query = state.keyword.toLowerCase();
      state = state.copyWith(
        showingVocabs: state.vocabs
            .where(
              (v) =>
                  v.title.toLowerCase().contains(query) ||
                  v.description.toLowerCase().contains(query),
            )
            .toList(),
      );
    }
    sort();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(keyword: query);
    searchVocabs();
  }

  Future<double> getAvgAccuracy() async {
    return await _rateRepository.getAccuracyOfAll();
  }

  double getAvgLearningRate() {
    double result = 0.0;
    if (state.vocabs.isEmpty) {
      return 0.0;
    }

    for (Vocab vocab in state.vocabs) {
      result += vocab.learningRate;
    }
    return result / state.vocabs.length;
  }

  Future<bool> addVocab(String title, String description) async {
    setAddingErrorMessage('');
    try {
      startLoading();
      await _vocabRepository.addVocab(title, description);
      await loadData();
      stopLoading();
      return false;
    } on ApiException catch (e) {
      debugPrint("addVocab() Error : ${e.message}");
      if (e.errors.isNotEmpty) {
        setAddingErrorMessage(e.errors.values.first);
      } else {
        setAddingErrorMessage(e.message);
      }
      stopLoading();
      return true;
    } catch (e) {
      debugPrint("addVocab() Extra Error : $e");
      setAddingErrorMessage("알 수 없는 오류가 발생했습니다.");
      stopLoading();
      return true;
    }
  }

  void setAddingErrorMessage(String message) {
    state = state.copyWith(addingErrorMessage: message);
  }

  void setEditingErrorMessage(String message) {
    state = state.copyWith(editingErrorMessage: message);
  }

  Future<bool> updateVocab(
    Vocab vocab,
    String title,
    String description,
  ) async {
    setEditingErrorMessage('');
    try {
      startLoading();
      await _vocabRepository.updateVocab(vocab.id, title, description);
      await loadData();
      stopLoading();
      return false;
    } on ApiException catch (e) {
      debugPrint("updateVocab() Error : ${e.message}");
      if (e.errors.isNotEmpty) {
        setEditingErrorMessage(e.errors.values.first);
      } else {
        setEditingErrorMessage(e.message);
      }
      stopLoading();
      return true;
    } catch (e) {
      debugPrint("updateVocab() Extra Error : $e");
      setEditingErrorMessage("알 수 없는 오류가 발생했습니다.");
      stopLoading();
      return true;
    }
  }

  Future<void> deleteVocab(Vocab vocab) async {
    await _vocabRepository.deleteVocab(vocab.id);
    await loadData();
  }

  void sort() {
    state = state.copyWith(
      showingVocabs: List.from(state.showingVocabs)..sort(comparator),
    );
  }
}

class VocabListState {
  final Vocab? currentVocab;
  final List<Vocab> vocabs;
  final List<Vocab> showingVocabs;
  final bool editMode;
  final double avgAccuracy;
  final double avgLearningRate;
  final bool isLoading;
  final String keyword;
  final String addingErrorMessage;
  final String editingErrorMessage;

  VocabListState({
    this.currentVocab,
    this.vocabs = const [],
    this.showingVocabs = const [],
    this.editMode = false,
    this.avgAccuracy = 0.0,
    this.avgLearningRate = 0.0,
    this.isLoading = false,
    this.keyword = '',
    this.addingErrorMessage = '',
    this.editingErrorMessage = '',
  });

  VocabListState copyWith({
    Vocab? currentVocab,
    List<Vocab>? vocabs,
    List<Vocab>? showingVocabs,
    bool? editMode,
    double? avgAccuracy,
    double? avgLearningRate,
    bool? isLoading,
    String? keyword,
    String? addingErrorMessage,
    String? editingErrorMessage,
  }) {
    return VocabListState(
      currentVocab: currentVocab ?? this.currentVocab,
      vocabs: vocabs ?? this.vocabs,
      showingVocabs: showingVocabs ?? this.showingVocabs,
      editMode: editMode ?? this.editMode,
      avgAccuracy: avgAccuracy ?? this.avgAccuracy,
      avgLearningRate: avgLearningRate ?? this.avgLearningRate,
      isLoading: isLoading ?? this.isLoading,
      keyword: keyword ?? this.keyword,
      addingErrorMessage: addingErrorMessage ?? this.addingErrorMessage,
      editingErrorMessage: editingErrorMessage ?? this.editingErrorMessage,
    );
  }
}
