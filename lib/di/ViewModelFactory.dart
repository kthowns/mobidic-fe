import 'package:flutter/cupertino.dart';
import 'package:mobidic_flutter/repository/auth_repository.dart';
import 'package:mobidic_flutter/repository/pronunciation_repository.dart';
import 'package:mobidic_flutter/repository/question_repository.dart';
import 'package:mobidic_flutter/repository/rate_repository.dart';
import 'package:mobidic_flutter/repository/vocab_repository.dart';
import 'package:mobidic_flutter/repository/word_repository.dart';
import 'package:mobidic_flutter/viewmodel/auth_view_model.dart';
import 'package:mobidic_flutter/viewmodel/blank_quiz_view_model.dart';
import 'package:mobidic_flutter/viewmodel/dictation_quiz_view_model.dart';
import 'package:mobidic_flutter/viewmodel/flash_card_view_model.dart';
import 'package:mobidic_flutter/viewmodel/join_view_model.dart';
import 'package:mobidic_flutter/viewmodel/ox_quiz_view_model.dart';
import 'package:mobidic_flutter/viewmodel/pronunciation_view_model.dart';
import 'package:mobidic_flutter/viewmodel/vocab_view_model.dart';
import 'package:mobidic_flutter/viewmodel/word_view_model.dart';
import 'package:provider/provider.dart';

class ViewModelFactory {
  static JoinViewModel getJoinViewModel(BuildContext context) {
    return JoinViewModel(context.read<AuthRepository>());
  }

  static VocabViewModel getVocabViewModel(
    BuildContext context,
    AuthViewModel authViewModel,
  ) {
    return VocabViewModel(
      context.read<VocabRepository>(),
      context.read<RateRepository>(),
      authViewModel,
    );
  }

  static WordViewModel getWordViewModel(
    BuildContext context,
    VocabViewModel vocabViewModel,
  ) {
    return WordViewModel(
      context.read<WordRepository>(),
      context.read<RateRepository>(),
      vocabViewModel,
    );
  }

  static PronunciationViewModel getPronunciationViewModel(
    BuildContext context,
    VocabViewModel vocabViewModel,
  ) {
    return PronunciationViewModel(
      context.read<PronunciationRepository>(),
      context.read<WordRepository>(),
      context.read<RateRepository>(),
      vocabViewModel,
    );
  }

  static FlashCardViewModel getFlashCardViewModel(
    BuildContext context,
    VocabViewModel vocabViewModel,
  ) {
    return FlashCardViewModel(context.read<WordRepository>(), vocabViewModel);
  }

  static OxQuizViewModel getOxQuizViewModel(
    BuildContext context,
    VocabViewModel vocabViewModel,
  ) {
    return OxQuizViewModel(context.read<QuestionRepository>(), vocabViewModel);
  }

  static BlankQuizViewModel getBlankQuizViewModel(
    BuildContext context,
    VocabViewModel vocabViewModel,
  ) {
    return BlankQuizViewModel(
      context.read<QuestionRepository>(),
      vocabViewModel,
    );
  }

  static DictationQuizViewModel getDictationQuizViewModel(
    BuildContext context,
    VocabViewModel vocabViewModel,
  ) {
    return DictationQuizViewModel(
      context.read<WordRepository>(),
      vocabViewModel,
    );
  }
}
