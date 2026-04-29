import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic/model/word.dart';
import 'package:mobidic/view/component/quick_action_tag.dart';
import 'package:mobidic/view/component/word_dialog.dart';
import 'package:mobidic/view/component/common_app_bar.dart';
import 'package:mobidic/view/component/compact_action_button.dart';
import 'package:mobidic/view/component/stat_card.dart';
import 'package:mobidic/view/list/component/word_card.dart';
import 'package:mobidic/viewmodel/word_view_model.dart';

class WordListPage extends ConsumerStatefulWidget {
  const WordListPage({super.key});

  @override
  ConsumerState<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends ConsumerState<WordListPage> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void handleTagAction(String label, WordListViewModel viewModel) async {
    if (label == '퀴즈') {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: Colors.yellow[50],
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    '어떤 퀴즈를 풀어볼까요?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                _buildQuizOption(
                  context,
                  label: 'O/X 퀴즈',
                  icon: Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  onTap: () async {
                    Navigator.pop(context);
                    await context.push('/vocabularies/ox');
                    viewModel.loadData();
                  },
                ),
                const SizedBox(height: 12),
                _buildQuizOption(
                  context,
                  label: '받아쓰기',
                  icon: Icons.edit_note_rounded,
                  color: Colors.blue,
                  onTap: () async {
                    Navigator.pop(context);
                    await context.push('/vocabularies/dictation');
                    viewModel.loadData();
                  },
                ),
                const SizedBox(height: 12),
                _buildQuizOption(
                  context,
                  label: '빈칸 채우기',
                  icon: Icons.space_bar_rounded,
                  color: Colors.orange,
                  onTap: () async {
                    Navigator.pop(context);
                    await context.push('/vocabularies/blank');
                    viewModel.loadData();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    } else if (label == '발음 체크') {
      await context.push('/vocabularies/pronunciation');
      viewModel.loadData();
    } else if (label == '플래시카드') {
      await context.push('/vocabularies/flashcard');
      viewModel.loadData();
    }
  }

  Widget _buildQuizOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordListViewModel = ref.read(wordListStateProvider.notifier);
    final wordListState = ref.watch(wordListStateProvider);

    searchController.addListener(() {
      wordListViewModel.setSearchKeyword(searchController.text);
    });

    return Stack(
      children: [
        Scaffold(
          appBar: CommonAppBar(title: wordListState.currentVocab?.title ?? '-'),
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
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.green,
                        ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        StatCard(
                          label: '단어 암기율',
                          value: wordListState.learningRate,
                          icon: Icons.psychology_rounded,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 12),
                        StatCard(
                          label: '퀴즈 정답률',
                          value: wordListState.accuracy,
                          icon: Icons.spellcheck_rounded,
                          color: Colors.orange.shade700,
                        ),
                      ],
                    ),
                  ),

                  // 퀵 액션 태그
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        QuickActionTag(
                          label: '발음',
                          icon: Icons.mic_rounded,
                          color: Colors.purple.shade600,
                          onTap: () =>
                              handleTagAction('발음 체크', wordListViewModel),
                        ),
                        QuickActionTag(
                          label: '퀴즈',
                          icon: Icons.extension_rounded,
                          color: Colors.orange.shade700,
                          onTap: () => handleTagAction('퀴즈', wordListViewModel),
                        ),
                      ],
                    ),
                  ),

                  // 제어 바
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '총 ${wordListState.showingWords.length}개의 단어',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const Spacer(),
                        CompactActionButton(
                          onPressed: wordListViewModel.cycleSortOption,
                          icon: Icons.sort_rounded,
                          label: wordListViewModel
                              .sortOptions[wordListViewModel.currentSortIndex],
                          themeColor: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        CompactActionButton(
                          onPressed: wordListViewModel.toggleEditMode,
                          icon: Icons.edit_note_rounded,
                          label: '편집',
                          isActive: wordListState.editMode,
                          themeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: wordListViewModel.loadData,
                      child: wordListState.showingWords.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              itemCount: wordListState.showingWords.length,
                              itemBuilder: (context, index) {
                                final word = wordListState.showingWords[index];
                                return WordCard(
                                  word: word,
                                  editMode: wordListState.editMode,
                                  onToggleLearned:
                                      wordListViewModel.toggleWordIsLearned,
                                  onTap: () => handleTagAction(
                                    '플래시카드',
                                    wordListViewModel,
                                  ),
                                  onEdit: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          WordDialog(word: word),
                                    );
                                  },
                                  onDelete: () => _showDeleteDialog(
                                    word,
                                    wordListViewModel,
                                  ),
                                );
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
                builder: (context) => const WordDialog(),
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
            color: const Color(0x80000000),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  void _showDeleteDialog(Word word, WordListViewModel wordListViewModel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
}
