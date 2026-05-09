import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic/util/url_util.dart';
import 'package:mobidic/viewmodel/sign_up_view_model.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController newIdController = TextEditingController();
  final TextEditingController newNicknameController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final signUpViewModel = ref.read(signUpStateProvider.notifier);
    final signUpState = ref.watch(signUpStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '회원가입',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: const Color(0xFF01579B),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildTextField(
                controller: newIdController,
                label: '이메일 주소',
                hint: 'example@naver.com',
                icon: Icons.email_outlined,
                errorText: signUpState.emailErrorText,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: newNicknameController,
                label: '닉네임',
                hint: '2~12자 사이로 입력해주세요',
                icon: Icons.person_outline_rounded,
                errorText: signUpState.nicknameErrorText,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: newPasswordController,
                label: '비밀번호',
                hint: '8자 이상, 문자/숫자 포함',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                isVisible: signUpState.isPasswordVisible,
                onToggleVisibility: signUpViewModel.togglePasswordVisibility,
                errorText: signUpState.passwordErrorText,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: confirmPasswordController,
                label: '비밀번호 확인',
                hint: '비밀번호를 한 번 더 입력해주세요',
                icon: Icons.check_circle_outline_rounded,
                isPassword: true,
                isVisible: signUpState.isConfirmPasswordVisible,
                onToggleVisibility:
                    signUpViewModel.toggleConfirmPasswordVisibility,
                errorText: signUpState.confirmPasswordErrorText,
              ),
              const SizedBox(height: 40),

              // 약관 동의 섹션
              if (signUpState.terms.isNotEmpty) ...[
                Text(
                  '약관 동의',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children:
                        signUpState.terms.map((term) {
                          final isAgreed = signUpState.agreeTermIds.contains(
                            term.id,
                          );
                          return CheckboxListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${term.type.label}${term.required ? ' (필수)' : ' (선택)'}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade800,
                                      fontWeight:
                                          term.required
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => UrlUtil.openInAppWebView(term.contentUri),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      '보기',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            value: isAgreed,
                            onChanged: (_) {
                              signUpViewModel.toggleTermAgreement(term.id);
                            },
                            activeColor: const Color(0xFF01579B),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (signUpState.globalErrorText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    signUpState.globalErrorText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),

              ElevatedButton(
                onPressed:
                    signUpState.isLoading
                        ? null
                        : () async {
                          final email = newIdController.text.trim();
                          final nickname = newNicknameController.text;
                          final password = newPasswordController.text;
                          final confirm = confirmPasswordController.text;

                          await signUpViewModel.signUp(
                            email,
                            nickname,
                            password,
                            confirm,
                          );

                          if (signUpViewModel.hasError()) {
                            return;
                          }
                          if (!mounted) return;

                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder:
                                (dialogContext) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text(
                                    '가입 완료',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF01579B),
                                    ),
                                  ),
                                  content: const Text(
                                    '모비딕의 회원이 되신 것을 축하합니다!\n로그인 후 이용해주세요.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                        context.go('/login');
                                      },
                                      child: const Text(
                                        '로그인하러 가기',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01579B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child:
                    signUpState.isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          '회원가입 완료',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? isVisible,
    VoidCallback? onToggleVisibility,
    String errorText = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: errorText.isNotEmpty ? Colors.redAccent : Colors.transparent,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && (isVisible == false),
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: Colors.blueGrey.shade300, size: 20),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          isVisible! ? Icons.visibility : Icons.visibility_off,
                          color: Colors.blueGrey.shade300,
                          size: 20,
                        ),
                        onPressed: onToggleVisibility,
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        if (errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
