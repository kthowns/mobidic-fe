import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic_flutter/view/component/common_app_bar.dart';
import 'package:mobidic_flutter/viewmodel/vocab_view_model.dart';

class VocabListPage extends ConsumerStatefulWidget {
  const VocabListPage({super.key});

  @override
  ConsumerState<VocabListPage> createState() => _VocabListPageState();
}

class _VocabListPageState extends ConsumerState<VocabListPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // 1. 퀴즈 옵션 위젯 (하단 시트용)
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 2. 단어장 카드 내 액션 태그 버튼
  Widget _buildActionTag({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. 통계 카드 위젯
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

  // 4. 상단 소형 버튼 위젯 (정렬, 편집)
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
          color: isActive ? Colors.blue.shade100 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.blue.shade300 : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.blue.shade800 : Colors.blue.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.blue.shade800 : Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 1,
                    shrinkWrap: true,
                    mainAxisSpacing: 12,
                    childAspectRatio: 5,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
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
                    ],
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

    Widget buildVocabCard(int index) {
      final vocab = vocabListState.showingVocabs[index];
      final progress = vocab.learningRate;
      final color = Colors.blue.shade600;

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
                Container(width: 6, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                vocab.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                            Text(
                              "${vocab.wordCount} words",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        if (vocab.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            vocab.description,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildActionTag(
                              label: '카드',
                              icon: Icons.style_rounded,
                              color: Colors.blue.shade700,
                              onTap: () => handleTagAction('플래시카드', index),
                            ),
                            _buildActionTag(
                              label: '발음',
                              icon: Icons.mic_rounded,
                              color: Colors.purple.shade600,
                              onTap: () => handleTagAction('발음 체크', index),
                            ),
                            _buildActionTag(
                              label: '퀴즈',
                              icon: Icons.extension_rounded,
                              color: Colors.orange.shade700,
                              onTap: () => handleTagAction('퀴즈', index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        '학습 달성도',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '${(progress * 100).toInt()}%',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: progress.clamp(0.0, 1.0),
                                      backgroundColor: color.withOpacity(0.1),
                                      color: color,
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (vocabListState.editMode) ...[
                              const SizedBox(width: 12),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.grey),
                                onPressed: () => _showEditVocabDialog(index, vocabListState, vocabListViewModel),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                onPressed: () => _showDeleteDialog(index, vocabListState, vocabListViewModel),
                              ),
                            ],
                          ],
                        ),
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
          appBar: const CommonAppBar(showHome: false),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: '단어장 이름을 검색하세요',
                        prefixIcon: const Icon(Icons.search, color: Colors.blue),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        _buildStatCard(
                          label: '학습 진행률',
                          value: vocabListState.avgLearningRate,
                          icon: Icons.trending_up,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          label: '퀴즈 정답률',
                          value: vocabListState.avgAccuracy,
                          icon: Icons.check_circle_outline,
                          color: Colors.orange.shade700,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          '총 ${vocabListState.vocabs.length}개의 단어장',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                        ),
                        const Spacer(),
                        _buildCompactButton(
                          onPressed: vocabListViewModel.cycleSortOption,
                          icon: Icons.sort_rounded,
                          label: vocabListViewModel.sortOptions[vocabListViewModel.currentSortIndex],
                        ),
                        const SizedBox(width: 8),
                        _buildCompactButton(
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
                      child: vocabListState.vocabs.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              itemCount: vocabListState.showingVocabs.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  child: buildVocabCard(index),
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
  // 다이얼로그 헬퍼 메서드들
  // ---------------------------------------------------------------------------

  void _showAddVocabDialog(VocabListViewModel vocabListViewModel) {
    showDialog(
      context: context,
      builder: (context) => Stack(
        children: [
          AlertDialog(
            title: const Text('단어장 추가'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: '새 단어장 이름'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(hintText: '세부 설명을 입력해주세요'),
                  style: const TextStyle(fontSize: 13),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(vocabListStateProvider);
                    return Text(state.addingErrorMessage, style: const TextStyle(color: Colors.red));
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  titleController.text = '';
                  descController.text = '';
                },
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) {
                    vocabListViewModel.setAddingErrorMessage('단어장 이름은 필수입니다.');
                    return;
                  }
                  try {
                    await vocabListViewModel.addVocab(titleController.text, descController.text);
                  } catch (e) {
                    return;
                  }
                  Navigator.pop(context);
                  titleController.text = '';
                  descController.text = '';
                },
                child: const Text('추가'),
              ),
            ],
          ),
          Consumer(
            builder: (context, ref, child) {
              if (ref.watch(vocabListStateProvider).isLoading) {
                return Container(
                  color: const Color.fromARGB(128, 91, 91, 91),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _showEditVocabDialog(int index, VocabListState vocabListState, VocabListViewModel vocabListViewModel) {
    final titleEditController = TextEditingController(text: vocabListState.showingVocabs[index].title);
    final descEditController = TextEditingController(text: vocabListState.showingVocabs[index].description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('단어장 편집'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleEditController, decoration: const InputDecoration(hintText: '단어장 이름')),
            const SizedBox(height: 10),
            TextField(controller: descEditController, decoration: const InputDecoration(hintText: '세부 설명'), style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              if (titleEditController.text.trim().isNotEmpty) {
                vocabListViewModel.updateVocab(
                  vocabListState.showingVocabs[index],
                  titleEditController.text.trim(),
                  descEditController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int index, VocabListState vocabListState, VocabListViewModel vocabListViewModel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('단어장 삭제'),
        content: const Text('이 단어장을 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('아니오')),
          TextButton(
            onPressed: () {
              vocabListViewModel.deleteVocab(vocabListState.showingVocabs[index]);
              Navigator.pop(context);
            },
            child: const Text('예'),
          ),
        ],
      ),
    );
  }
}
