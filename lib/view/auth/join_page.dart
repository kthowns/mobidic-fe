import 'package:flutter/material.dart';
import 'package:mobidic_flutter/viewmodel/join_view_model.dart';
import 'package:provider/provider.dart';

class JoinPage extends StatelessWidget {
  JoinPage({super.key});

  final TextEditingController newIdController = TextEditingController();
  final TextEditingController newNicknameController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isValidEmail(String email) {
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    if (password.length < 8) return false;
    final forbiddenChars = RegExp(r'[-=]');
    final specialCharRegex = RegExp(
      r'''[!@#\$%^&*()_+{}\[\]:;"'<>,.?/\\|`~]''',
    );

    if (forbiddenChars.hasMatch(password)) return false;
    if (!specialCharRegex.hasMatch(password)) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final JoinViewModel joinViewModel = context.watch<JoinViewModel>();

    return Scaffold(
      backgroundColor: Colors.white, // 배경 흰색
      appBar: AppBar(
        title: const Text('회원가입', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'MOBIDIC',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                '가입을 진심으로 환영합니다!!',
                style: TextStyle(fontSize: 17, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: newIdController,
              decoration: InputDecoration(
                labelText: '가입할 이메일을 입력하세요',
                helperText: 'ex ) example@naver.com',
                errorText: joinViewModel.emailErrorText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: newNicknameController,
              decoration: InputDecoration(
                labelText: '닉네임을 입력하세요',
                helperText: '특수문자 제외 2~12자',
                errorText: joinViewModel.nicknameErrorText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: newPasswordController,
              obscureText: !joinViewModel.isPasswordVisible,
              decoration: InputDecoration(
                labelText: '사용할 비밀번호를 입력하세요.',
                helperText: '8자 이상 + 알파벳 + 숫자 ( - 와 = 제외 )',
                errorText: joinViewModel.passwordErrorText,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    joinViewModel.isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    joinViewModel.togglePasswordVisibility();
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              obscureText: !joinViewModel.isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: '한 번 더 입력하세요.',
                helperText: '동일한 비밀번호를 입력하세요.',
                errorText: joinViewModel.confirmPasswordErrorText,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    joinViewModel.isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    joinViewModel.toggleConfirmPasswordVisibility();
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            Visibility(
              visible: joinViewModel.isGlobalErrorVisible,
              replacement: SizedBox.shrink(),
              child: Text(
                joinViewModel.globalErrorText ?? '',
                style: TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final email = newIdController.text.trim();
                  final nickname = newNicknameController.text;
                  final password = newPasswordController.text;
                  final confirm = confirmPasswordController.text;

                  bool hasError = await joinViewModel.join(
                    email,
                    nickname,
                    password,
                    confirm,
                  );

                  if (hasError) return;

                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder:
                        (dialogContext) => AlertDialog(
                          title: const Text('알림'),
                          content: const Text('회원가입이 완료되었습니다!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                Navigator.pop(context);
                              },
                              child: const Text('닫기'),
                            ),
                          ],
                        ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
