import 'package:flutter/cupertino.dart';
import 'package:mobidic_flutter/exception/api_exception.dart';
import 'package:mobidic_flutter/repository/auth_repository.dart';

class JoinViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  String? emailErrorText;
  String? nicknameErrorText;
  String? passwordErrorText;
  String? confirmPasswordErrorText;
  String? globalErrorText;

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isGlobalErrorVisible = false;

  JoinViewModel(this._authRepository);

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  Future<bool> join(
    String email,
    String nickname,
    String password,
    String confirmPassword,
  ) async {
    bool hasError = validate(email, nickname, password, confirmPassword);

    try {
      await _authRepository.join(email, nickname, confirmPassword);
    } on ApiException catch (e) {
      print("ApiException!! : $e");
      if (e.message == 'Email is duplicated') {
        emailErrorText = '중복된 이메일 입니다.';
      } else if (e.message == 'Nickname is duplicated') {
        nicknameErrorText = '중복된 닉네임 입니다.';
      }
      hasError = true;
    } catch (e) {
      print("Just Exception!! : $e");
      globalErrorText = '회원 가입 오류 (Error code: 500)';
      isGlobalErrorVisible = true;
      hasError = true;
    }

    notifyListeners();
    return hasError;
  }

  bool validate(
    String email,
    String nickname,
    String password,
    String confirmPassword,
  ) {
    emailErrorText = null;
    nicknameErrorText = null;
    passwordErrorText = null;
    confirmPasswordErrorText = null;
    globalErrorText = null;

    bool hasError = false;

    if (!RegExp(
      r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,100}$",
    ).hasMatch(email)) {
      emailErrorText = '올바른 이메일을 입력해주세요.';
      hasError = true;
    }

    if (!RegExp(r"^[ㄱ-ㅎ가-힣a-z0-9-_]{2,16}$").hasMatch(nickname)) {
      nicknameErrorText = '특수문자 제외한 2~16자 닉네임을 입력해주세요.';
      hasError = true;
    }

    if (!RegExp(
      r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,128}$",
    ).hasMatch(password)) {
      passwordErrorText = '비밀번호 조건이 맞지 않습니다.';
      hasError = true;
    }

    if (password != confirmPassword) {
      confirmPasswordErrorText = '비밀번호가 일치하지 않습니다.';
      hasError = true;
    }

    notifyListeners();
    return hasError;
  }
}
