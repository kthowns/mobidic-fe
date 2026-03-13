import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/dto/word_dto.dart';
import 'package:mobidic_flutter/model/definition.dart';
import 'package:mobidic_flutter/model/word.dart';
import 'package:mobidic_flutter/type/part_of_speech.dart';
import 'package:mobidic_flutter/viewmodel/word_view_model.dart';

class EditWordDialog extends ConsumerStatefulWidget {
  const EditWordDialog({super.key});

  @override
  ConsumerState<EditWordDialog> createState() => _EditWordDialogState();
}

class _EditWordDialogState extends ConsumerState<EditWordDialog> {
  final editingExpController = TextEditingController();
  final List<TextEditingController> editingDefControllers = [];
  final List<Definition> editingDefs = [];
  final List<Definition> removingDefs = [];
  late final String editingWordId;

  void initEditingWord(Word? editingWord) {
    if (editingWord == null) return;
    setState(() {
      editingExpController.text = editingWord.expression;
      editingWordId = editingWord.id;
      for (Definition def in editingWord.definitions) {
        final controller = TextEditingController();
        controller.text = def.meaning;
        editingDefs.add(def);
        editingDefControllers.add(controller);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    final editingWord = ref.read(wordListStateProvider).editingWord;

    initEditingWord(editingWord);
  }

  @override
  void dispose() {
    editingExpController.dispose();
    for (var controller in editingDefControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordListViewModel = ref.read(wordListStateProvider.notifier);
    final wordListState = ref.watch(wordListStateProvider);

    Future<void> submitEditWord() async {
      final word = AddWordRequestDto(
        expression: editingExpController.text.trim(),
      );
      final defs = editingDefs.toList();

      for (Definition def in defs) {
        if (def.meaning.isEmpty) {
          wordListViewModel.setEditingErrorMessage('뜻을 입력하세요.');
          return;
        }
        final meanings = defs.map((d) => d.meaning.trim()).toList();
        if (meanings.length != meanings.toSet().length) {
          wordListViewModel.setAddingErrorMessage('중복된 뜻이 있습니다.');
          return;
        }
      }

      if (word.expression.isNotEmpty && defs.isNotEmpty) {
        // 단어 저장 로직
        bool hasError = await wordListViewModel.updateWord(
          editingWordId,
          word,
          defs,
          removingDefs,
        );
        debugPrint("수정된 단어: $word");
        debugPrint(
          "뜻 목록: ${defs.map((d) => '${d.meaning} (${d.part.label})').join(', ')}",
        );

        debugPrint("editingErrorMessage ${wordListState.editingErrorMessage}");

        if (hasError) return;

        Navigator.pop(context);
      } else {
        if (word.expression.isEmpty) {
          wordListViewModel.setEditingErrorMessage("단어를 입력하세요.");
        } else {
          wordListViewModel.setEditingErrorMessage("뜻을 입력하세요.");
        }
      }
    }

    return AlertDialog(
      title: const Text('단어 수정'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editingExpController,
              decoration: const InputDecoration(hintText: '단어를 입력하세요'),
            ),
            Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(wordListStateProvider);

                return Text(
                  state.editingErrorMessage,
                  style: const TextStyle(color: Colors.red),
                );
              },
            ),
            const SizedBox(height: 10),
            ...editingDefs.asMap().entries.map((entry) {
              final index = entry.key;
              final def = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: editingDefControllers[index],
                        onChanged: (value) {
                          setState(() {
                            editingDefs[index] = Definition(
                              id: def.id,
                              meaning: value,
                              part: def.part,
                            );
                          });
                        },
                        decoration: const InputDecoration(hintText: '뜻을 입력하세요'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<PartOfSpeech>(
                      value: editingDefs[index].part,
                      items:
                          PartOfSpeech.values.map((pos) {
                            return DropdownMenuItem(
                              value: pos,
                              child: Text(pos.label),
                            );
                          }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          editingDefs[index] = Definition(
                            id: def.id,
                            meaning: def.meaning,
                            part: newValue!,
                          );
                        });
                      },
                    ),
                    if (editingDefs.length > 1)
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            if (def.id.isNotEmpty) {
                              removingDefs.add(def);
                            }
                            editingDefs.removeAt(index);
                            editingDefControllers.removeAt(index);
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
                icon: const Icon(Icons.add),
                label: const Text('뜻 추가'),
                onPressed: () {
                  final hasText = editingDefs.every(
                    (d) => d.meaning.trim().isNotEmpty,
                  );
                  if (editingExpController.text.isEmpty) {
                    wordListViewModel.setEditingErrorMessage("단어를 입력해주세요.");
                  } else if (!hasText) {
                    wordListViewModel.setEditingErrorMessage("뜻을 입력해주세요.");
                  } else {
                    wordListViewModel.setEditingErrorMessage("");
                    setState(() {
                      editingDefs.add(
                        Definition(
                          id: '',
                          meaning: '',
                          part: PartOfSpeech.NOUN,
                        ),
                      );
                      editingDefControllers.add(TextEditingController());
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            wordListViewModel.setEditingErrorMessage('');
            Navigator.pop(context);
          },
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: submitEditWord, child: const Text('수정')),
      ],
    );
  }
}
