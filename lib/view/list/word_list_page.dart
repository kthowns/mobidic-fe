import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobidic_flutter/model/definition.dart';
import 'package:mobidic_flutter/model/word.dart';
import 'package:mobidic_flutter/type/part_of_speech.dart';
import 'package:mobidic_flutter/viewmodel/vocab_view_model.dart';
import 'package:mobidic_flutter/viewmodel/word_view_model.dart';
import 'package:provider/provider.dart';

class WordListPage extends StatelessWidget {
  const WordListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wordViewModel = context.watch<WordViewModel>();

    void showAddWordDialog() {
      showDialog(
        context: context,
        builder:
            (context) => ChangeNotifierProvider.value(
              value: wordViewModel,
              child: StatefulBuilder(
                builder:
                    (context, setDialogState) => AlertDialog(
                      title: const Text('단어 추가'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: wordViewModel.addingExpController,
                              decoration: const InputDecoration(
                                hintText: '단어를 입력하세요',
                              ),
                            ),
                            Consumer<WordViewModel>(
                              builder:
                                  (context, model, child) => Text(
                                    model.addingErrorMessage,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                            ),
                            const SizedBox(height: 10),
                            ...wordViewModel.addingDefs.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final def = entry.value;

                              final controller = TextEditingController(
                                text: def.definition,
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: controller,
                                        onChanged: (value) {
                                          wordViewModel
                                              .addingDefs[index] = DefWithPart(
                                            definition: value,
                                            part: def.part,
                                          );
                                        },
                                        decoration: const InputDecoration(
                                          hintText: '뜻을 입력하세요',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    DropdownButton<PartOfSpeech>(
                                      value: def.part,
                                      items:
                                          PartOfSpeech.values.map((pos) {
                                            return DropdownMenuItem(
                                              value: pos,
                                              child: Text(pos.label),
                                            );
                                          }).toList(),
                                      onChanged: (newValue) {
                                        setDialogState(() {
                                          wordViewModel
                                              .addingDefs[index] = DefWithPart(
                                            definition: def.definition,
                                            part: newValue!,
                                          );
                                        });
                                      },
                                    ),
                                    if (wordViewModel.addingDefs.length > 1)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setDialogState(() {
                                            wordViewModel.addingDefs.removeAt(
                                              index,
                                            );
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              );
                            }),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  final hasText = wordViewModel.addingDefs
                                      .every((d) => d.definition.trim().isNotEmpty);
                                  if (wordViewModel
                                      .addingExpController
                                      .text
                                      .isEmpty) {
                                    wordViewModel.setAddingErrorMessage(
                                      "단어를 입력해주세요.",
                                    );
                                  } else if (!hasText) {
                                    wordViewModel.setAddingErrorMessage(
                                      "뜻을 입력해주세요.",
                                    );
                                  } else {
                                    setDialogState(() {
                                      wordViewModel.setAddingErrorMessage("");
                                      wordViewModel.addingDefs.add(
                                        DefWithPart(
                                          definition: '',
                                          part: PartOfSpeech.NOUN,
                                        ),
                                      );
                                    });
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('뜻 추가'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('취소'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final word =
                                wordViewModel.addingExpController.text.trim();
                            final defs =
                                wordViewModel.addingDefs
                                    .where((d) => d.definition.trim().isNotEmpty)
                                    .toList();

                            if (word.isNotEmpty && defs.isNotEmpty) {
                              // 단어 저장 로직 (예시)
                              wordViewModel.addWord(word, defs);
                              print("추가된 단어: $word");
                              print(
                                "뜻 목록: ${defs.map((d) => '${d.definition} (${d.part.label})').join(', ')}",
                              );

                              // 초기화
                              wordViewModel.addingExpController.clear();
                              wordViewModel.addingDefs
                                ..clear()
                                ..add(
                                  DefWithPart(definition: '', part: PartOfSpeech.NOUN),
                                );

                              Navigator.pop(context);
                            } else {
                              if (word.isEmpty){
                                wordViewModel.setAddingErrorMessage("단어를 입력하세요.");
                              } else {
                                wordViewModel.setAddingErrorMessage("뜻을 입력하세요.");
                              }
                            }
                          },
                          child: const Text('추가'),
                        ),
                      ],
                    ),
              ),
            ),
      );
    }

    void showEditWordDialog(int index) {
      final word = wordViewModel.words[index];

      // 초기값 세팅 (Dialog 열 때마다 초기화 필요)
      wordViewModel.editingExpController.text = word.expression;
      wordViewModel.removingDefs.clear();
      wordViewModel.editingDefs
        ..clear()
        ..addAll(word.defs);

      wordViewModel.setEditingErrorMessage("");

      showDialog(
        context: context,
        builder: (context) => ChangeNotifierProvider.value(
          value: wordViewModel,
          child: StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: const Text('단어 수정'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: wordViewModel.editingExpController,
                      decoration: const InputDecoration(
                        hintText: '단어를 입력하세요',
                      ),
                    ),
                    Consumer<WordViewModel>(
                      builder: (context, model, child) => Text(
                        model.editingErrorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...wordViewModel.editingDefs.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final def = entry.value;

                      final controller = TextEditingController(text: def.definition);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                onChanged: (value) {
                                  wordViewModel.editingDefs[idx] = Definition(
                                    id: wordViewModel.editingDefs[idx].id,
                                    wordId: wordViewModel.editingDefs[idx].wordId,
                                    definition: value,
                                    part: def.part,
                                  );
                                },
                                decoration: const InputDecoration(
                                  hintText: '뜻을 입력하세요',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<PartOfSpeech>(
                              value: def.part,
                              items: PartOfSpeech.values.map((pos) {
                                return DropdownMenuItem(
                                  value: pos,
                                  child: Text(pos.label),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setDialogState(() {
                                  wordViewModel.editingDefs[idx] = Definition(
                                    id: wordViewModel.editingDefs[idx].id,
                                    wordId: wordViewModel.editingDefs[idx].wordId,
                                    definition: def.definition,
                                    part: newValue!,
                                  );
                                });
                              },
                            ),
                            if (wordViewModel.editingDefs.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  setDialogState(() {
                                    wordViewModel.removingDefs.add(
                                        wordViewModel.editingDefs[index]
                                    );
                                    wordViewModel.editingDefs.removeAt(idx);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          final allDefsFilled = wordViewModel.editingDefs
                              .every((d) => d.definition.trim().isNotEmpty);
                          if (wordViewModel.editingExpController.text.isEmpty) {
                            wordViewModel.setEditingErrorMessage("단어를 입력해주세요.");
                          } else if (!allDefsFilled) {
                            wordViewModel.setEditingErrorMessage("뜻을 모두 입력해주세요.");
                          } else {
                            setDialogState(() {
                              wordViewModel.setEditingErrorMessage("");
                              wordViewModel.editingDefs.add(
                                Definition(
                                    id: "",
                                    wordId: "",
                                    definition: '',
                                    part: PartOfSpeech.NOUN),
                              );
                            });
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('뜻 추가'),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String editedExp = wordViewModel.editingExpController.text.trim();
                    final defs = wordViewModel.editingDefs
                        .where((d) => d.definition.trim().isNotEmpty)
                        .toList();

                    if (editedExp.isNotEmpty && defs.isNotEmpty) {
                      // 단어 수정 저장 로직 예시
                      wordViewModel.updateWord(word, editedExp, defs);
                      Navigator.pop(context);
                    } else {
                      wordViewModel.setEditingErrorMessage("단어와 뜻을 모두 입력해주세요.");
                    }
                  },
                  child: const Text('저장'),
                ),
              ],
            ),
          ),
        ),
      );
    }


    void showDeleteDialog(int index) {
      Word word = wordViewModel.words[index];
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
                    wordViewModel.deleteWord(word);
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
      final word = wordViewModel.words[index];

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
                        word.defs
                            .map((d) => "${d.definition}(${d.part.label})")
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
                        wordViewModel.toggleWordIsLearned(word);
                      },
                      activeTrackColor: Colors.blue[300],
                    ),
                  ],
                ),
                if (wordViewModel.editMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => showEditWordDialog(index),
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                // 실제 뒤로 가기
                Navigator.pop(context);
              },
            ),
            title: Row(
              children: [
                SizedBox(width: 8),
                Text(
                  wordViewModel.currentVocab?.title ?? '',
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
                onSelected: (value) {
                  if (value == '파닉스') {
                    Navigator.pushNamed(context, '/phonics');
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: '파닉스',
                        child: Text('파닉스'),
                      ),
                    ],
              ),
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: const Icon(Icons.home, color: Colors.black),
                  onPressed: () {
                    Navigator.popUntil(context, (route) {
                      return route.settings.name == '/vocab_list'; // 특정 route 이름 기준
                    });
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
                                      value: wordViewModel.learningRate.clamp(
                                        0.0,
                                        1.0,
                                      ),
                                      backgroundColor: Colors.grey[300],
                                      color: getRateColor(
                                        wordViewModel.avgLearningRate,
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
                                      value: wordViewModel.accuracy.clamp(
                                        0.0,
                                        1.0,
                                      ),
                                      backgroundColor: Colors.grey[300],
                                      color: getRateColor(
                                        wordViewModel.accuracy,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                              Text('단어 개수 : ${wordViewModel.words.length}'),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: wordViewModel.cycleSortOption,
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
                            wordViewModel.sortOptions[wordViewModel
                                .currentSortIndex],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: wordViewModel.toggleEditMode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                wordViewModel.editMode
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
                      onRefresh: wordViewModel.loadData,
                      child:
                          wordViewModel.words.isNotEmpty
                              ? ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: wordViewModel.words.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: buildVocabularyCard(index),
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
            onPressed: showAddWordDialog,
            backgroundColor: Colors.blue[100],
            child: const Icon(Icons.add),
          ),
        ),
        if (wordViewModel.isLoading)
          Container(
            color: const Color(0x80000000), // 배경 어둡게
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
