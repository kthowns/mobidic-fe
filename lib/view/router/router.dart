import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic/view/auth/auth_guard.dart';
import 'package:mobidic/view/auth/kakao_login_page.dart';
import 'package:mobidic/view/auth/log_in_page.dart';
import 'package:mobidic/view/auth/sign_up_page.dart';
import 'package:mobidic/view/learning/phonics_page.dart';
import 'package:mobidic/view/learning/pronunciation_page.dart';
import 'package:mobidic/view/list/vocab_list_page.dart';
import 'package:mobidic/view/list/word_list_page.dart';
import 'package:mobidic/view/settings/settings_page.dart';
import 'package:mobidic/view/quiz/blank_quiz_page.dart';
import 'package:mobidic/view/quiz/dictation_quiz_page.dart';
import 'package:mobidic/view/quiz/flash_card_page.dart';
import 'package:mobidic/view/quiz/ox_quiz_page.dart';
import 'package:mobidic/viewmodel/auth_view_model.dart';
import 'package:mobidic/viewmodel/vocab_view_model.dart';

final routerProvider = Provider((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authViewModelProvider);
      final whiteList = ['/', '/signup', '/v1/oauth2/kakao'];
      final location = state.uri.path;

      final isWhiteList = whiteList.contains(location);

      final isLoggedIn = authState.currentUser != null;
      if (!isLoggedIn && !isWhiteList) {
        return '/';
      }
      if (isLoggedIn && isWhiteList) {
        return '/vocabularies';
      }

      // vocab guard
      if (location.startsWith('/vocabularies')) {
        if (location != '/vocabularies') {
          final currentVocab = ref.read(vocabListStateProvider).currentVocab;
          if (currentVocab == null) return '/vocabularies';
          return null;
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
      GoRoute(
        path: '/v1/oauth2/kakao',
        builder: (context, state) {
          final accessToken = state.uri.queryParameters['access_token'] ?? '';
          return KakaoLoginPage(accessToken: accessToken);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const AuthGuard(child: SettingsPage()),
      ),
      GoRoute(
        path: '/phonics',
        builder: (context, state) => const AuthGuard(child: PhonicsPage()),
      ),
      GoRoute(
        path: '/vocabularies',
        builder: (context, state) => const AuthGuard(child: VocabListPage()),
        routes: [
          GoRoute(
            path: 'words',
            builder: (context, state) => const AuthGuard(child: WordListPage()),
          ),
          GoRoute(
            path: 'ox',
            builder: (context, state) => const AuthGuard(child: OxQuizPage()),
          ),
          GoRoute(
            path: 'blank',
            builder: (context, state) =>
                const AuthGuard(child: BlankQuizPage()),
          ),
          GoRoute(
            path: 'flashcard',
            builder: (context, state) =>
                const AuthGuard(child: FlashCardPage()),
          ),
          GoRoute(
            path: 'dictation',
            builder: (context, state) =>
                const AuthGuard(child: DictationQuizPage()),
          ),
          GoRoute(
            path: 'pronunciation',
            builder: (context, state) =>
                const AuthGuard(child: PronunciationPage()),
          ),
        ],
      ),
    ],
  );
});
