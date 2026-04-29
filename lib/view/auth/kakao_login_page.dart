import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic/viewmodel/auth_view_model.dart';

class KakaoLoginPage extends ConsumerStatefulWidget {
  final String accessToken;
  const KakaoLoginPage({super.key, required this.accessToken});

  @override
  KakaoLoginPageState createState() => KakaoLoginPageState();
}

class KakaoLoginPageState extends ConsumerState<KakaoLoginPage> {
  @override
  void initState() {
    super.initState();

    // UI 렌더링 직후 로그인 로직 실행
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final authViewModel = ref.read(authViewModelProvider.notifier);
        await authViewModel.loginWithAccessToken(widget.accessToken);

        if (mounted) {
          final isError = ref
              .read(authViewModelProvider)
              .loginErrorMessage
              .isNotEmpty;
          if (isError) {
            context.go('/vocabularies');
          } else {
            context.go('/');
          }
        }
      } catch (e) {
        if (mounted) context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              "카카오 로그인 처리 중...",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
