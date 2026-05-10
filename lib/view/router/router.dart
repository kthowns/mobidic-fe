import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic/view/auth/kakao_login_page.dart';
import 'package:mobidic/view/auth/log_in_page.dart';
import 'package:mobidic/view/auth/sign_up_page.dart';
import 'package:mobidic/view/auth/splash_page.dart';
import 'package:mobidic/view/auth/welcome_page.dart';
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
  // AuthViewModel의 상태를 GoRouter가 인식할 수 있는 Listenable로 변환
  final listenable = ValueNotifier<AuthState>(ref.read(authViewModelProvider));

  // 상태 변경 감시 및 Listenable 업데이트
  ref.listen(authViewModelProvider, (previous, next) {
    listenable.value = next;
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authViewModelProvider);
      final location = state.uri.path;

      // 카카오 로그인 콜백 경로는 초기화 여부와 관계없이 진입 허용
      if (location == '/v1/oauth2/kakao') {
        return null;
      }

      // 1. 초기화(자동 로그인 체크)가 완료되지 않았으면 스플래시 화면 유지
      if (!authState.isAutoLoginDone) {
        return '/splash';
      }

      // 2. 스플래시 완료 후 분기 로직
      if (location == '/splash') {
        // 로그인된 사용자 -> 메인으로
        if (authState.currentUser != null) {
          return '/vocabularies';
        }
        // 로그인되지 않은 모든 사용자 -> 웰컴 페이지로
        return '/welcome';
      }

      // 3. 루트(/) 진입 시 처리
      if (location == '/') {
        return authState.currentUser != null ? '/vocabularies' : '/welcome';
      }

      final whiteList = ['/welcome', '/login', '/signup', '/v1/oauth2/kakao'];
      final isWhiteList = whiteList.contains(location);
      final isLoggedIn = authState.currentUser != null;

      // 4. 로그인 상태에서 로그인/웰컴 페이지 접근 시 메인으로 리다이렉트
      if (isLoggedIn && (location == '/login' || location == '/welcome')) {
        return '/vocabularies';
      }

      // 화이트리스트나 메인 콘텐츠는 로그인 여부와 상관없이 허용
      if (isWhiteList || location.startsWith('/vocabularies')) {
        // vocab guard
        if (location.startsWith('/vocabularies')) {
          if (location != '/vocabularies') {
            final currentVocab = ref.read(vocabListStateProvider).currentVocab;
            if (currentVocab == null) return '/vocabularies';
            return null;
          }
        }
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/welcome', builder: (context, state) => const WelcomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
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
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/phonics',
        builder: (context, state) => const PhonicsPage(),
      ),
      GoRoute(
        path: '/vocabularies',
        builder: (context, state) => const VocabListPage(),
        routes: [
          GoRoute(
            path: 'words',
            builder: (context, state) => const WordListPage(),
          ),
          GoRoute(
            path: 'ox',
            builder: (context, state) => const OxQuizPage(),
          ),
          GoRoute(
            path: 'blank',
            builder: (context, state) => const BlankQuizPage(),
          ),
          GoRoute(
            path: 'flashcard',
            builder: (context, state) => const FlashCardPage(),
          ),
          GoRoute(
            path: 'dictation',
            builder: (context, state) => const DictationQuizPage(),
          ),
          GoRoute(
            path: 'pronunciation',
            builder: (context, state) => const PronunciationPage(),
          ),
        ],
      ),
    ],
  );
});
