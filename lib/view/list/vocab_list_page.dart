import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic_flutter/view/component/common_app_bar.dart';
import 'package:mobidic_flutter/view/component/compact_action_button.dart';
import 'package:mobidic_flutter/view/component/vocab_dialog.dart';
import 'package:mobidic_flutter/view/component/stat_card.dart';
import 'package:mobidic_flutter/view/list/component/vocab_card.dart';
import 'package:mobidic_flutter/viewmodel/vocab_view_model.dart';

class VocabListPage extends ConsumerStatefulWidget {
  const VocabListPage({super.key});

  @override
  ConsumerState<VocabListPage> createState() => _VocabListPageState();
}

class _VocabListPageState extends ConsumerState<VocabListPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocabListViewModel = ref.read(vocabListStateProvider.notifier);
    final vocabListState = ref.watch(vocabListStateProvider);

    searchController.addListener(() {
      vocabListViewModel.setSearchQuery(searchController.text);
    });

    void handleTagAction(String label, int index) async {
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                      vocabListViewModel.selectVocabAt(index);
                      await context.push('/vocabularies/ox');
                      vocabListViewModel.loadData();
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
                      vocabListViewModel.selectVocabAt(index);
                      await context.push('/vocabularies/dictation');
                      vocabListViewModel.loadData();
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
                      vocabListViewModel.selectVocabAt(index);
                      await context.push('/vocabularies/blank');
                      vocabListViewModel.loadData();
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      } else if (label == '발음 체크') {
        vocabListViewModel.selectVocabAt(index);
        await context.push('/vocabularies/pronunciation');
        vocabListViewModel.loadData();
      } else if (label == '플래시카드') {
        vocabListViewModel.selectVocabAt(index);
        await context.push('/vocabularies/flashcard');
        vocabListViewModel.loadData();
      }
    }

    return Stack(
      children: [
        Scaffold(
          appBar: const CommonAppBar(showHome: false),
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
                        hintText: '단어장 이름을 검색하세요',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.blue,
                        ),
                        filled: true,
                        fillColor: Colors.blue[50],
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
                          label: '학습 진행률',
                          value: vocabListState.avgLearningRate,
                          icon: Icons.trending_up,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 12),
                        StatCard(
                          label: '퀴즈 정답률',
                          value: vocabListState.avgAccuracy,
                          icon: Icons.check_circle_outline,
                          color: Colors.orange.shade700,
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
                          '총 ${vocabListState.showingVocabs.length}개의 단어장',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const Spacer(),
                        CompactActionButton(
                          onPressed: vocabListViewModel.cycleSortOption,
                          icon: Icons.sort_rounded,
                          label:
                              vocabListViewModel.sortOptions[vocabListViewModel
                                  .currentSortIndex],
                        ),
                        const SizedBox(width: 8),
                        CompactActionButton(
                          onPressed: vocabListViewModel.toggleEditMode,
                          icon: Icons.edit_note_rounded,
                          label: '편집',
                          isActive: vocabListState.editMode,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: vocabListViewModel.loadData,
                      child:
                          vocabListState.showingVocabs.isNotEmpty
                              ? ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                itemCount: vocabListState.showingVocabs.length,
                                itemBuilder: (context, index) {
                                  return VocabCard(
                                    vocab: vocabListState.showingVocabs[index],
                                    editMode: vocabListState.editMode,
                                    onTagTap:
                                        (tag) => handleTagAction(tag, index),
                                    onEdit:
                                        () => _showEditVocabDialog(
                                          index,
                                          vocabListState,
                                          vocabListViewModel,
                                        ),
                                    onDelete:
                                        () => _showDeleteDialog(
                                          index,
                                          vocabListState,
                                          vocabListViewModel,
                                        ),
                                    onTap: () async {
                                      vocabListViewModel.selectVocabAt(index);
                                      await context.push('/vocabularies/words');
                                      vocabListViewModel.loadData();
                                    },
                                  );
                                },
                              )
                              : const Center(
                                child: Text(
                                  "단어장을 추가해주세요.",
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
            onPressed: () => _showAddVocabDialog(vocabListViewModel),
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.add_rounded, size: 30),
          ),
        ),
        if (vocabListState.isLoading)
          Container(
            color: const Color(0x80000000),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 헬퍼 위젯 및 다이얼로그
  // ---------------------------------------------------------------------------

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

  void _showAddVocabDialog(VocabListViewModel vocabListViewModel) {
    showDialog(context: context, builder: (context) => const VocabDialog());
  }

  void _showEditVocabDialog(
    int index,
    VocabListState vocabListState,
    VocabListViewModel vocabListViewModel,
  ) {
    final vocab = vocabListState.showingVocabs[index];

    showDialog(
      context: context,
      builder: (context) => VocabDialog(vocab: vocab),
    );
  }

  void _showDeleteDialog(
    int index,
    VocabListState vocabListState,
    VocabListViewModel vocabListViewModel,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('단어장 삭제'),
            content: const Text('이 단어장을 삭제할까요?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('아니오'),
              ),
              TextButton(
                onPressed: () {
                  vocabListViewModel.deleteVocab(
                    vocabListState.showingVocabs[index],
                  );
                  Navigator.pop(context);
                },
                child: const Text('예'),
              ),
            ],
          ),
    );
  }
}
