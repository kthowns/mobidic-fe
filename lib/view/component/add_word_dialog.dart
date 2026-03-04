import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/dto/def_dto.dart';
import 'package:mobidic_flutter/type/part_of_speech.dart';
import 'package:mobidic_flutter/viewmodel/word_view_model.dart';

class AddWordDialog extends ConsumerStatefulWidget {
  const AddWordDialog({super.key});

  @override
  ConsumerState<AddWordDialog> createState() => _AddWordDialogState();
}

class _AddWordDialogState extends ConsumerState<AddWordDialog> {
  final addingExpController = TextEditingController();
  final addingDefControllers = [TextEditingController()];
  final addingDefs = [AddDefRequestDto(meaning: '', part: PartOfSpeech.NOUN)];

  @override
  void dispose() {
    addingExpController.dispose();
    for (var controller in addingDefControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordListViewModel = ref.read(wordListStateProvider.notifier);
    final wordListState = ref.watch(wordListStateProvider);

    Future<void> submitAddWord() async {
      final word = addingExpController.text.trim();
      final defs = addingDefs.toList();

      for (AddDefRequestDto def in defs) {
        if (def.meaning.isEmpty) {
          wordListViewModel.setAddingErrorMessage('뜻을 입력하세요.');
          return;
        }
        final meanings = defs.map((d) => d.meaning.trim()).toList();
        if (meanings.length != meanings.toSet().length) {
          wordListViewModel.setAddingErrorMessage('중복된 뜻이 있습니다.');
          return;
        }
      }

      if (word.isNotEmpty && defs.isNotEmpty) {
        // 단어 저장 로직
        bool hasError = await wordListViewModel.addWord(word, defs);
        print("추가된 단어: $word");
        print(
          "뜻 목록: ${defs.map((d) => '${d.meaning} (${d.part.label})').join(', ')}",
        );

        if (hasError) return;

        print("addingErrorMessage ${wordListState.addingErrorMessage}");

        Navigator.pop(context);
      } else {
        if (word.isEmpty) {
          wordListViewModel.setAddingErrorMessage("단어를 입력하세요.");
        } else {
          wordListViewModel.setAddingErrorMessage("뜻을 입력하세요.");
        }
      }
    }

    return AlertDialog(
      title: const Text('단어 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addingExpController,
              decoration: const InputDecoration(hintText: '단어를 입력하세요'),
            ),
            Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(wordListStateProvider);

                return Text(
                  state.addingErrorMessage,
                  style: const TextStyle(color: Colors.red),
                );
              },
            ),
            const SizedBox(height: 10),
            ...addingDefs.asMap().entries.map((entry) {
              final index = entry.key;
              final def = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: addingDefControllers[index],
                        onChanged: (value) {
                          setState(() {
                            addingDefs[index] = AddDefRequestDto(
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
                      value: addingDefs[index].part,
                      items:
                          PartOfSpeech.values.map((pos) {
                            return DropdownMenuItem(
                              value: pos,
                              child: Text(pos.label),
                            );
                          }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          addingDefs[index] = AddDefRequestDto(
                            meaning: addingDefs[index].meaning,
                            part: newValue!,
                          );
                        });
                      },
                    ),
                    if (addingDefs.length > 1)
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            addingDefs.removeAt(index);
                            addingDefControllers.removeAt(index);
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
                  final hasText = addingDefs.every(
                    (d) => d.meaning.trim().isNotEmpty,
                  );
                  if (addingExpController.text.isEmpty) {
                    wordListViewModel.setAddingErrorMessage("단어를 입력해주세요.");
                  } else if (!hasText) {
                    wordListViewModel.setAddingErrorMessage("뜻을 입력해주세요.");
                  } else {
                    wordListViewModel.setAddingErrorMessage("");
                    setState(() {
                      addingDefs.add(
                        AddDefRequestDto(meaning: '', part: PartOfSpeech.NOUN),
                      );
                      addingDefControllers.add(TextEditingController());
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
            wordListViewModel.setAddingErrorMessage('');
            Navigator.pop(context);
          },
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: submitAddWord, child: const Text('추가')),
      ],
    );
  }
}
