import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/view/component/vocab_form.dart';
import 'package:mobidic_flutter/viewmodel/vocab_view_model.dart';

class VocabDialog extends ConsumerWidget {
  final Vocab? vocab;

  const VocabDialog({super.key, this.vocab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabListViewModel = ref.read(vocabListStateProvider.notifier);
    final vocabListState = ref.watch(vocabListStateProvider);
    
    final isEdit = vocab != null;

    return VocabForm(
      themeColor: Colors.blue.shade600,
      title: isEdit ? '단어장 편집' : '단어장 추가',
      submitLabel: isEdit ? '저장' : '추가',
      initialTitle: vocab?.title,
      initialDescription: vocab?.description,
      errorMessage: isEdit ? vocabListState.editingErrorMessage : vocabListState.addingErrorMessage,
      isLoading: vocabListState.isLoading,
      onSave: (title, desc) async {
        if (title.isEmpty) {
          if (isEdit) {
            vocabListViewModel.setEditingErrorMessage('이름을 입력하세요.');
          } else {
            vocabListViewModel.setAddingErrorMessage('이름을 입력하세요.');
          }
          return;
        }

        bool hasError;
        if (isEdit) {
          hasError = await vocabListViewModel.updateVocab(vocab!, title, desc);
        } else {
          hasError = await vocabListViewModel.addVocab(title, desc);
        }

        if (!hasError && context.mounted) {
          Navigator.pop(context);
        }
      },
      onCancel: () {
        if (isEdit) {
          vocabListViewModel.setEditingErrorMessage('');
        } else {
          vocabListViewModel.setAddingErrorMessage('');
        }
        Navigator.pop(context);
      },
    );
  }
}
