import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:mobidic_flutter/view/util/navigation_helper.dart';
import 'package:mobidic_flutter/viewmodel/auth_view_model.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  clickKakaoLoginButton() async {
    OAuthToken token;
    if (await isKakaoTalkInstalled()) {
      try {
        token = await UserApi.instance.loginWithKakaoTalk();
        debugPrint('카카오톡으로 로그인 성공, token: $token');
      } catch (error) {
        debugPrint('카카오톡으로 로그인 실패 $error');
        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          token = await UserApi.instance.loginWithKakaoAccount();
          debugPrint('카카오계정으로 로그인 성공, token: $token');
        } catch (error) {
          debugPrint('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        token = await UserApi.instance.loginWithKakaoAccount();
        debugPrint('카카오계정으로 로그인 성공, token: $token');
      } catch (error) {
        debugPrint('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    void onLoggedIn() async {
      if (authViewModel.isLoggedIn) {
        NavigationHelper.navigateToVocabList(context, authViewModel);

        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text(
                  '✅ 로그인 성공',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  '환영합니다, ${authViewModel.currentMember?.nickname} 님!',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('확인'),
                  ),
                ],
              ),
        );
      }
    }

    void handleLogin() async {
      await authViewModel.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      onLoggedIn();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
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
              visible: authViewModel.loginError,
              replacement: SizedBox.shrink(),
              child: Text(
                authViewModel.loginErrorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: clickKakaoLoginButton,
              child: Image.asset(
                'assets/images/kakao_login_medium_wide.png',
                height: 100,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: authViewModel.isLoading ? null : handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child:
                    authViewModel.isLoading
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
                  NavigationHelper.navigateToJoin(context);
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
