import 'package:flutter/cupertino.dart';
import 'package:mobidic_flutter/mixin/LoadingMixin.dart';
import 'package:mobidic_flutter/model/member.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/repository/rate_repository.dart';
import 'package:mobidic_flutter/repository/vocab_repository.dart';
import 'package:mobidic_flutter/viewmodel/auth_view_model.dart';

class VocabViewModel extends ChangeNotifier with LoadingMixin {
  final VocabRepository _vocabRepository;
  final RateRepository _rateRepository;
  final AuthViewModel _authViewModel;
  final TextEditingController searchController = TextEditingController();

  VocabViewModel(this._vocabRepository, this._rateRepository, this._authViewModel) {
    init();
  }

  Future<void> init() async {
    await loadData();
    searchController.addListener(() {
      searchVocabs();
    });
  }

  Future<void> loadData() async {
    startLoading();
    _vocabs = await _vocabRepository.getVocabs();
    sort();
    searchVocabs();
    updateRates();
    stopLoading();
  }

  Future<void> updateRates() async {
    _avgAccuracy = await getAvgAccuracy();
    _avgLearningRate = getAvgLearningRate();
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
        print("Accuracies : ${vocabs.map((v) => v.accuracy).toList()}");
        break;
    }
    sort();
    searchVocabs();
  }

  Vocab? _currentVocab;

  Vocab? get currentVocab => _currentVocab;

  Member? get currentMember => _authViewModel.currentMember;

  void selectVocabAt(int index) {
    _currentVocab = _vocabs[index];
  }

  List<Vocab> _vocabs = [];

  List<Vocab> get vocabs => _vocabs;

  List<Vocab> _showingVocabs = [];

  List<Vocab> get showingVocabs => _showingVocabs;

  bool _editMode = false;

  bool get editMode => _editMode;

  double _avgAccuracy = 0.0;

  double get avgAccuracy => _avgAccuracy;

  double _avgLearningRate = 0.0;

  double get avgLearningRate => _avgLearningRate;

  void toggleEditMode() {
    _editMode = !_editMode;
    notifyListeners();
  }

  Comparator<Vocab> comparator =
      (v2, v1) => v1.createdAt!.compareTo(v2.createdAt!);

  int selectedCardIndex = -1;

  void searchVocabs() {
    String keyword = searchController.text;

    if (keyword.isEmpty) {
      _showingVocabs = _vocabs;
    }
    final query = searchController.text.toLowerCase();
    _showingVocabs =
        _vocabs
            .where(
              (v) =>
                  v.title.toLowerCase().contains(query) ||
                  v.description.toLowerCase().contains(query),
            )
            .toList();
    notifyListeners();
  }

  Future<double> getAvgAccuracy() async {
    return await _rateRepository.getAccuracyOfAll();
  }

  double getAvgLearningRate() {
    double result = 0;
    for (Vocab vocab in vocabs) {
      result += vocab.learningRate;
    }
    return result / vocabs.length;
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
    _vocabs.sort(comparator);
    notifyListeners();
  }
}
