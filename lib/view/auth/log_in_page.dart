import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic/view/component/specify_terms.dart';
import 'package:mobidic/viewmodel/auth_view_model.dart';
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
      if (next.currentUser != null) {
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
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_self',
        );
      } else {
        throw Exception('Could not launch $kakaoLoginUrl');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 로고 섹션: 군더더기 없이 로고 이미지와 텍스트만 강조
                      Image.asset(
                        'assets/images/mobidic_icon.png',
                        height: 100,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'MOBIDIC',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF01579B),
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '영단어 학습, MOBIDIC과 함께 시작하세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 88, 88, 88),
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 56),

                      // 입력창 섹션
                      _buildTextField(
                        controller: emailController,
                        hint: '사용자 이메일 (Email)',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: passwordController,
                        hint: '비밀번호',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                      ),

                      // 에러 메시지
                      if (authState.loginErrorMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          authState.loginErrorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),

                      // 로그인 버튼 섹션
                      _buildActionButton(
                        onPressed: authState.isLoading ? null : handleLogin,
                        label: '로그인',
                        color: const Color(0xFF01579B),
                        textColor: Colors.white,
                        isLoading: authState.isLoading,
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        onPressed: authState.isLoading
                            ? null
                            : handleKakaoLogin,
                        label: '카카오 로그인',
                        color: const Color(0xFFFEE500),
                        textColor: Colors.black87,
                        isLoading: authState.isLoading,
                      ),

                      const SizedBox(height: 24),

                      // 약관 및 정책 문구 추가
                      const AgreementTerms(),

                      const SizedBox(height: 40),

                      // 하단 링크 섹션
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '아직 회원이 아니신가요?',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/signup'),
                            child: const Text(
                              '회원가입',
                              style: TextStyle(
                                color: Color(0xFF01579B),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blueGrey.shade300, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required String label,
    required Color color,
    required Color textColor,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
