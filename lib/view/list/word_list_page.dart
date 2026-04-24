import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/model/word.dart';
import 'package:mobidic_flutter/view/component/add_word_dialog.dart';
import 'package:mobidic_flutter/view/component/edit_word_dialog.dart';
import 'package:mobidic_flutter/view/component/common_app_bar.dart';
import 'package:mobidic_flutter/view/component/compact_action_button.dart';
import 'package:mobidic_flutter/view/component/stat_card.dart';
import 'package:mobidic_flutter/view/list/component/word_card.dart';
import 'package:mobidic_flutter/viewmodel/word_view_model.dart';

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

                  // 제어 바
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          '총 ${wordListState.words.length}개의 단어',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                        ),
                        const Spacer(),
                        CompactActionButton(
                          onPressed: wordListViewModel.cycleSortOption,
                          icon: Icons.sort_rounded,
                          label: wordListViewModel.sortOptions[wordListViewModel.currentSortIndex],
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
                      child: wordListState.words.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              itemCount: wordListState.showingWords.length,
                              itemBuilder: (context, index) {
                                final word = wordListState.showingWords[index];
                                return WordCard(
                                  word: word,
                                  editMode: wordListState.editMode,
                                  onToggleLearned: wordListViewModel.toggleWordIsLearned,
                                  onEdit: () {
                                    wordListViewModel.setEditingWord(word);
                                    showDialog(
                                      context: context,
                                      builder: (context) => const EditWordDialog(),
                                    );
                                  },
                                  onDelete: () => _showDeleteDialog(word, wordListViewModel),
                                );
                              },
                            )
                          : const Center(
                              child: Text(
                                "단어를 추가해주세요.",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('아니오')),
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
