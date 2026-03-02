import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/repository/statistic_repository.dart';
import 'package:mobidic_flutter/repository/vocab_repository.dart';

final vocabListViewModelProvider =
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
    sort();
    fetchStatistics();
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
    state = state.copyWith(currentVocab: state.vocabs[index]);
  }

  final List<String> sortOptions = ['최신순', '알파벳순', '학습률순', '정답률순'];
  int currentSortIndex = 0;

  void cycleSortOption() {
    currentSortIndex = (currentSortIndex + 1) % sortOptions.length;
    switch (sortOptions[currentSortIndex]) {
      case '알파벳순':
        comparator = (b, a) => a.title.compareTo(b.title);
        break;
      case '학습률순':
        comparator = (b, a) => a.learningRate.compareTo(b.learningRate);
        break;
      case '최신순':
        comparator = (b, a) => a.createdAt!.compareTo(b.createdAt!);
        break;
      case '정답률순':
        comparator = (b, a) => a.accuracy.compareTo(b.accuracy);
        print("Accuracies : ${state.vocabs.map((v) => v.accuracy).toList()}");
        break;
    }
    sort();
  }

  void toggleEditMode() {
    state = state.copyWith(editMode: !state.editMode);
  }

  Comparator<Vocab> comparator =
      (v2, v1) => v1.createdAt!.compareTo(v2.createdAt!);

  int selectedCardIndex = -1;

  void searchVocabs() {
    if (state.keyword.isEmpty) {
      state = state.copyWith(showingVocabs: state.vocabs);
    }
    final query = state.keyword.toLowerCase();
    state = state.copyWith(
      showingVocabs:
          state.vocabs
              .where(
                (v) =>
                    v.title.toLowerCase().contains(query) ||
                    v.description.toLowerCase().contains(query),
              )
              .toList(),
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(keyword: query);
    searchVocabs();
  }

  Future<double> getAvgAccuracy() async {
    return await _rateRepository.getAccuracyOfAll();
  }

  double getAvgLearningRate() {
    double result = 0;
    for (Vocab vocab in state.vocabs) {
      result += vocab.learningRate;
    }
    return result / state.vocabs.length;
  }

  Future<void> addVocab(String title, String description) async {
    await _vocabRepository.addVocab(title, description);
    await loadData();
  }

  Future<void> updateVocab(
    Vocab vocab,
    String title,
    String description,
  ) async {
    await _vocabRepository.updateVocab(vocab.id, title, description);
    await loadData();
  }

  Future<void> deleteVocab(Vocab vocab) async {
    await _vocabRepository.deleteVocab(vocab.id);
    await loadData();
  }

  void sort() {
    searchVocabs();
    state = state.copyWith(vocabs: state.vocabs..sort(comparator));
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

  VocabListState({
    this.currentVocab,
    this.vocabs = const [],
    this.showingVocabs = const [],
    this.editMode = false,
    this.avgAccuracy = 0.0,
    this.avgLearningRate = 0.0,
    this.isLoading = false,
    this.keyword = '',
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
    );
  }
}
