import 'package:go_router/go_router.dart';
import 'package:mobidic_flutter/view/auth/kakao_login_page.dart';
import 'package:mobidic_flutter/view/auth/log_in_page.dart';
import 'package:mobidic_flutter/view/auth/sign_up_page.dart';
import 'package:mobidic_flutter/view/learning/phonics_page.dart';
import 'package:mobidic_flutter/view/learning/pronunciation_page.dart';
import 'package:mobidic_flutter/view/list/vocab_list_page.dart';
import 'package:mobidic_flutter/view/list/word_list_page.dart';
import 'package:mobidic_flutter/view/quiz/blank_quiz_page.dart';
import 'package:mobidic_flutter/view/quiz/dictation_quiz_page.dart';
import 'package:mobidic_flutter/view/quiz/flash_card_page.dart';
import 'package:mobidic_flutter/view/quiz/ox_quiz_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
    GoRoute(
      path: '/vocabularies',
      builder: (context, state) => const VocabListPage(),
    ),
    GoRoute(path: '/words', builder: (context, state) => const WordListPage()),
    GoRoute(
      path: '/v1/oauth2/kakao',
      builder: (context, state) {
        final authCode = state.uri.queryParameters['code'] ?? '';
        return KakaoLoginPage(authCode: authCode);
      },
    ),
    GoRoute(path: '/phonics', builder: (context, state) => const PhonicsPage()),
    GoRoute(path: '/ox', builder: (context, state) => const OxQuizPage()),
    GoRoute(path: '/blank', builder: (context, state) => const BlankQuizPage()),
    GoRoute(
      path: '/flashcard',
      builder: (context, state) => const FlashCardPage(),
    ),
    GoRoute(
      path: '/dictation',
      builder: (context, state) => const DictationQuizPage(),
    ),
    GoRoute(
      path: '/pronunciation',
      builder: (context, state) => const PronunciationPage(),
    ),
  ],
);
