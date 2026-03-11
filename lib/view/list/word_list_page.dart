import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic_flutter/model/word.dart';
import 'package:mobidic_flutter/view/component/add_word_dialog.dart';
import 'package:mobidic_flutter/view/component/edit_word_dialog.dart';
import 'package:mobidic_flutter/viewmodel/auth_view_model.dart';
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
        return Color.lerp(Colors.blue, Colors.yellow, t)!;
      } else {
        // 0.5 ~ 1.0 → 노랑 → 빨강
        double t = (difficulty - 0.5) / 0.5; // 0~1
        return Color.lerp(Colors.yellow, Colors.red, t)!;
      }
    }

    Widget buildVocabularyCard(int index) {
      final word = wordListState.showingWords[index];

      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: getWordBoxColor(word),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.expression,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        word.definitions
                            .map((d) => "${d.meaning}(${d.part.label})")
                            .join(', '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Switch(
                      value: word.isLearned,
                      onChanged: (val) {
                        wordListViewModel.toggleWordIsLearned(word);
                      },
                      activeTrackColor: Colors.blue[300],
                    ),
                  ],
                ),
                if (wordListState.editMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          wordListViewModel.setEditingWord(word);
                          showDialog(
                            context: context,
                            builder: (context) => const EditWordDialog(),
                          );
                        },
                        child: const Text('수정'),
                      ),
                      TextButton(
                        onPressed: () => showDeleteDialog(index),
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                //_tagButton('퀴즈', index), _tagButton('발음 체크', index)
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    Color getRateColor(double value) {
      value = value.clamp(0.0, 1.0);

      if (value < 0.5) {
        // 0.0 ~ 0.5 → 파랑 → 노랑
        double t = value / 0.5; // 0~1
        return Color.lerp(Colors.blue, Colors.yellow, t)!;
      } else {
        // 0.5 ~ 1.0 → 노랑 → 빨강
        double t = (value - 0.5) / 0.5; // 0~1
        return Color.lerp(Colors.yellow, Colors.red, t)!;
      }
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            title: Row(
              children: [
                SizedBox(width: 8),
                Text(
                  wordListState.currentVocab?.title ?? 'some',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu, color: Colors.black),
                onSelected: (value) async {
                  if (value == '파닉스') {
                    context.push('/phonics');
                  } else if (value == '로그아웃') {
                    await ref.read(authViewModelProvider.notifier).logout();

                    // 💡 핵심: 이동하기 전에 현재 사용 중인 Provider들을 다 초기화해서 찌꺼기를 없앱니다.
                    ref.invalidate(authViewModelProvider);

                    if (!mounted) return;

                    context.go('/');
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: '파닉스',
                        child: Text('파닉스'),
                      ),
                      const PopupMenuItem<String>(
                        value: '로그아웃',
                        child: Text('로그아웃'),
                      ),
                    ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: const Icon(Icons.home, color: Colors.black),
                  onPressed: () {
                    context.go('/vocabularies');
                  },
                ),
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 20,
                      left: 20,
                      top: 10,
                      bottom: 4,
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: '검색어를 입력하세요',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.blue[100],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('단어장 학습률'),
                                  SizedBox(width: 8), // 텍스트와 프로그레스 바 사이 간격
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: wordListState.learningRate.clamp(
                                        0.0,
                                        1.0,
                                      ),
                                      backgroundColor: Colors.grey[300],
                                      color: getRateColor(
                                        wordListState
                                                .currentVocab
                                                ?.learningRate ??
                                            0.0,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('퀴즈 정답률'),
                                  SizedBox(width: 8), // 텍스트와 프로그레스 바 사이 간격
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: wordListState.accuracy.clamp(
                                        0.0,
                                        1.0,
                                      ),
                                      backgroundColor: Colors.grey[300],
                                      color: getRateColor(
                                        wordListState.accuracy,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                              Text('단어 개수 : ${wordListState.words.length}'),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: wordListViewModel.cycleSortOption,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[100],
                            foregroundColor: Colors.black,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            wordListViewModel.sortOptions[wordListViewModel
                                .currentSortIndex],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: wordListViewModel.toggleEditMode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                wordListState.editMode
                                    ? Colors.blue[300]
                                    : Colors.blue[100],
                            foregroundColor: Colors.black,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            '편집',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 8)),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: wordListViewModel.loadData,
                      child:
                          wordListState.words.isNotEmpty
                              ? ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: wordListState.showingWords.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: buildVocabularyCard(index),
                                    onTap: () {},
                                  );
                                },
                              )
                              : Center(
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
            backgroundColor: Colors.blue[100],
            child: const Icon(Icons.add),
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
}
