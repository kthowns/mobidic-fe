import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/dto/def_dto.dart';
import 'package:mobidic_flutter/dto/word_dto.dart';
import 'package:mobidic_flutter/model/definition.dart';
import 'package:mobidic_flutter/model/word.dart';
import 'package:mobidic_flutter/view/component/word_form.dart';
import 'package:mobidic_flutter/viewmodel/word_view_model.dart';

class WordDialog extends ConsumerWidget {
  final Word? word;

  const WordDialog({super.key, this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordListViewModel = ref.read(wordListStateProvider.notifier);
    final wordListState = ref.watch(wordListStateProvider);
    
    final isEdit = word != null;

    Future<void> handleSave(
      String expression,
      List<Definition> definitions,
      List<Definition> removedDefinitions,
    ) async {
      if (expression.isEmpty) {
        if (isEdit) {
          wordListViewModel.setEditingErrorMessage("단어를 입력하세요.");
        } else {
          wordListViewModel.setAddingErrorMessage("단어를 입력하세요.");
        }
        return;
      }

      if (definitions.isEmpty ||
          definitions.any((d) => d.meaning.trim().isEmpty)) {
        if (isEdit) {
          wordListViewModel.setEditingErrorMessage("뜻을 입력하세요.");
        } else {
          wordListViewModel.setAddingErrorMessage("뜻을 입력하세요.");
        }
        return;
      }

      final meanings = definitions.map((d) => d.meaning.trim()).toList();
      if (meanings.length != meanings.toSet().length) {
        if (isEdit) {
          wordListViewModel.setEditingErrorMessage('중복된 뜻이 있습니다.');
        } else {
          wordListViewModel.setAddingErrorMessage('중복된 뜻이 있습니다.');
        }
        return;
      }

      bool hasError;
      if (isEdit) {
        final wordDto = AddWordRequestDto(expression: expression);
        hasError = await wordListViewModel.updateWord(
          word!.id,
          wordDto,
          definitions,
          removedDefinitions,
        );
      } else {
        final defDtos = definitions
            .map((d) => AddDefRequestDto(meaning: d.meaning.trim(), part: d.part))
            .toList();
        hasError = await wordListViewModel.addWord(expression, defDtos);
      }

      if (!hasError && context.mounted) {
        Navigator.pop(context);
      }
    }

    return WordForm(
      themeColor: Colors.green.shade600,
      title: isEdit ? '단어 수정' : '단어 추가',
      submitLabel: isEdit ? '수정' : '추가',
      initialExpression: word?.expression,
      initialDefinitions: word?.definitions,
      errorMessage: isEdit ? wordListState.editingErrorMessage : wordListState.addingErrorMessage,
      isLoading: wordListState.isLoading,
      onSave: handleSave,
      onCancel: () {
        if (isEdit) {
          wordListViewModel.setEditingErrorMessage('');
        } else {
          wordListViewModel.setAddingErrorMessage('');
        }
        Navigator.pop(context);
      },
    );
  }
}
