import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic_flutter/viewmodel/auth_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.currentUser != null && previous?.currentUser == null) {
        context.go('/vocabularies');
      }
    });

    void handleLogin() async {
      await authViewModel.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    }

    void handleKakaoLogin() async {
      final kakaoLoginUrl = Uri.parse(await authViewModel.getKakaoLoginUrl());

      if (await canLaunchUrl(kakaoLoginUrl)) {
        await launchUrl(
          kakaoLoginUrl,
          // 웹에서 현재 브라우저 탭의 주소를 바로 바꿉니다.
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_self',
        );
      } else {
        throw Exception('Could not launch $kakaoLoginUrl');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('로그인', style: TextStyle(color: Colors.black)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset('assets/images/mobidic_icon.png', height: 100),
            ),
            const SizedBox(height: 20),
            const Text(
              '안녕하세요\nMOBIDIC 입니다.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '회원 서비스 이용을 위해 로그인 해주세요.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: '아이디를 입력해주세요',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: '비밀번호를 입력해주세요',
                border: UnderlineInputBorder(),
              ),
            ),
            Visibility(
              visible: authState.loginErrorMessage.isNotEmpty,
              replacement: SizedBox.shrink(),
              child: Text(
                authState.loginErrorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: authState.isLoading ? null : handleKakaoLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFEE500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '카카오 로그인',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: authState.isLoading ? null : handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child:
                    authState.isLoading
                        ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                        : const Text(
                          '로그인',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  context.push('/signup');
                },
                child: const Text(
                  '회원가입',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
