import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/model/word.dart';
import 'package:mobidic_flutter/view/component/add_word_dialog.dart';
import 'package:mobidic_flutter/view/component/edit_word_dialog.dart';
import 'package:mobidic_flutter/view/component/common_app_bar.dart';
import 'package:mobidic_flutter/viewmodel/word_view_model.dart';

class WordListPage extends ConsumerStatefulWidget {
  const WordListPage({super.key});

  @override
  ConsumerState<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends ConsumerState<WordListPage> {
  final addingExpController = TextEditingController();
  final editingExpController = TextEditingController();
  final searchController = TextEditingController();

  @override
  void dispose() {
    addingExpController.dispose();
    editingExpController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordListViewModel = ref.read(wordListStateProvider.notifier);
    final wordListState = ref.watch(wordListStateProvider);

    searchController.addListener(() {
      wordListViewModel.setSearchKeyword(searchController.text);
    });

    void showDeleteDialog(int index) {
      Word word = wordListState.showingWords[index];
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('단어 삭제'),
              content: const Text('이 단어를 삭제할까요?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('아니오'),
                ),
                TextButton(
                  onPressed: () {
                    wordListViewModel.deleteWord(word);
                    Navigator.pop(context);
                  },
                  child: const Text('예'),
                ),
              ],
            ),
      );
    }

    Color getWordBoxColor(Word word) {
      double difficulty = word.difficulty;
      difficulty = difficulty.clamp(0.0, 1.0);

      if (difficulty < 0.5) {
        // 0.0 ~ 0.5 → 파랑 → 노랑
        double t = difficulty / 0.5; // 0~1
        return Color.lerp(Colors.green, Colors.yellow, t)!;
      } else {
        // 0.5 ~ 1.0 → 노랑 → 빨강
        double t = (difficulty - 0.5) / 0.5; // 0~1
        return Color.lerp(Colors.yellow, Colors.red, t)!;
      }
    }

    Widget buildVocabularyCard(int index) {
      final word = wordListState.showingWords[index];
      final difficultyColor = getWordBoxColor(word);

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // 난이도 포인트 바
                Container(
                  width: 6,
                  color: difficultyColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                word.expression,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                            // 암기 완료 체크 (커스텀 아이콘 사용)
                            InkWell(
                              onTap: () => wordListViewModel.toggleWordIsLearned(word),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: word.isLearned ? Colors.green.shade50 : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: word.isLearned ? Colors.green.shade200 : Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      word.isLearned ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                      size: 14,
                                      color: word.isLearned ? Colors.green.shade700 : Colors.grey.shade400,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      word.isLearned ? '암기완료' : '미암기',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: word.isLearned ? Colors.green.shade700 : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // 뜻 목록
                        ...word.definitions.map((d) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                        children: [
                                          TextSpan(
                                            text: '[${d.part.label}] ',
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          TextSpan(text: d.meaning),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        if (wordListState.editMode) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit_rounded, size: 16),
                                label: const Text('수정'),
                                onPressed: () {
                                  wordListViewModel.setEditingWord(word);
                                  showDialog(
                                    context: context,
                                    builder: (context) => const EditWordDialog(),
                                  );
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                label: const Text('삭제', style: TextStyle(color: Colors.red)),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                onPressed: () => showDeleteDialog(index),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: CommonAppBar(
            title: wordListState.currentVocab?.title ?? '-',
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 검색창
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: '단어를 검색하세요',
                        prefixIcon: const Icon(Icons.search, color: Colors.green),
                        filled: true,
                        fillColor: Colors.green[50],
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  // 통계 대시보드
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        _buildStatCard(
                          label: '단어 암기율',
                          value: wordListState.learningRate,
                          icon: Icons.psychology_rounded,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          label: '퀴즈 정답률',
                          value: wordListState.accuracy,
                          icon: Icons.spellcheck_rounded,
                          color: Colors.orange.shade700,
                        ),
                      ],
                    ),
                  ),

                  // 제어 바
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          '총 ${wordListState.words.length}개의 단어',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const Spacer(),
                        _buildCompactButton(
                          onPressed: wordListViewModel.cycleSortOption,
                          icon: Icons.sort_rounded,
                          label: wordListViewModel.sortOptions[wordListViewModel.currentSortIndex],
                        ),
                        const SizedBox(width: 8),
                        _buildCompactButton(
                          onPressed: wordListViewModel.toggleEditMode,
                          icon: Icons.edit_note_rounded,
                          label: '편집',
                          isActive: wordListState.editMode,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: wordListViewModel.loadData,
                      child:
                          wordListState.words.isNotEmpty
                              ? ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                itemCount: wordListState.showingWords.length,
                                itemBuilder: (context, index) {
                                  return buildVocabularyCard(index);
                                },
                              )
                              : const Center(
                                child: Text(
                                  "단어를 추가해주세요.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddWordDialog(),
              );
            },
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.add_rounded, size: 30),
          ),
        ),
        if (wordListState.isLoading)
          Container(
            color: const Color(0x80000000), // 배경 어둡게
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  // 통계 카드 위젯
  Widget _buildStatCard({
    required String label,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: value.clamp(0.0, 1.0),
                      backgroundColor: color.withOpacity(0.1),
                      color: color,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(value * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 상단 소형 버튼 위젯
  Widget _buildCompactButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade100 : Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.green.shade300 : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.green.shade800 : Colors.green.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.green.shade800 : Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
