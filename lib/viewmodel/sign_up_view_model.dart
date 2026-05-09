import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic/dto/signup_dto.dart';
import 'package:mobidic/exception/api_exception.dart';
import 'package:mobidic/model/term.dart';
import 'package:mobidic/repository/auth_repository.dart';

final signUpStateProvider =
    StateNotifierProvider.autoDispose<SignUpViewModel, SignUpState>((ref) {
      final authRepository = ref.read(authRepositoryProvider);
      return SignUpViewModel(authRepository);
    });

class SignUpViewModel extends StateNotifier<SignUpState> {
  final AuthRepository _authRepository;

  SignUpViewModel(this._authRepository) : super(SignUpState()) {
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    try {
      final terms = await _authRepository.getTerms();
      state = state.copyWith(terms: terms);
    } catch (e) {
      debugPrint("Failed to load terms: $e");
    }
  }

  void toggleTermAgreement(int termId) {
    final currentAgreements = List<int>.from(state.agreeTermIds);
    if (currentAgreements.contains(termId)) {
      currentAgreements.remove(termId);
    } else {
      currentAgreements.add(termId);
    }
    state = state.copyWith(agreeTermIds: currentAgreements);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
    );
  }

  bool hasError() {
    return state.confirmPasswordErrorText.isNotEmpty ||
        state.emailErrorText.isNotEmpty ||
        state.nicknameErrorText.isNotEmpty ||
        state.passwordErrorText.isNotEmpty ||
        state.globalErrorText.isNotEmpty;
  }

  Future<void> signUp(
    String email,
    String nickname,
    String password,
    String confirmPassword,
  ) async {
    clearErrors();

    if (validate(email, nickname, password, confirmPassword)) return;

    state = state.copyWith(isLoading: true);
    try {
      await _authRepository.signup(
        SignupRequest(
          email: email,
          nickname: nickname,
          password: password,
          agreeTermIds: state.agreeTermIds,
        ),
      );
    } on ApiException catch (e) {
      debugPrint("ApiException!! : $e");
      state = state.copyWith(globalErrorText: e.message);
    } catch (e) {
      debugPrint("Just Exception!! : $e");
      state = state.copyWith(globalErrorText: '회원 가입 오류 (Error code: 500)');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearErrors() {
    state = state.copyWith(
      emailErrorText: '',
      nicknameErrorText: '',
      passwordErrorText: '',
      confirmPasswordErrorText: '',
      globalErrorText: '',
    );
  }

  bool validate(
    String email,
    String nickname,
    String password,
    String confirmPassword,
  ) {
    if (!RegExp(
      r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,100}$",
    ).hasMatch(email)) {
      state = state.copyWith(emailErrorText: '올바른 이메일을 입력해주세요.');
      return true;
    }

    if (!RegExp(r"^[ㄱ-ㅎ가-힣a-z0-9-_]{2,16}$").hasMatch(nickname)) {
      state = state.copyWith(nicknameErrorText: '특수문자 제외한 2~16자 닉네임을 입력해주세요.');
      return true;
    }

    if (!RegExp(
      r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,128}$",
    ).hasMatch(password)) {
      state = state.copyWith(passwordErrorText: '비밀번호 조건이 맞지 않습니다.');
      return true;
    }

    if (password != confirmPassword) {
      state = state.copyWith(confirmPasswordErrorText: '비밀번호가 일치하지 않습니다.');
      return true;
    }

    // 필수 약관 동의 확인
    final requiredTermIds = state.terms
        .where((t) => t.required)
        .map((t) => t.id)
        .toList();
    for (final id in requiredTermIds) {
      if (!state.agreeTermIds.contains(id)) {
        state = state.copyWith(globalErrorText: '필수 약관에 모두 동의해주세요.');
        return true;
      }
    }

    return false;
  }
}

class SignUpState {
  final String emailErrorText;
  final String nicknameErrorText;
  final String passwordErrorText;
  final String confirmPasswordErrorText;
  final String globalErrorText;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isLoading;
  final List<Term> terms;
  final List<int> agreeTermIds;

  SignUpState({
    this.emailErrorText = '',
    this.nicknameErrorText = '',
    this.passwordErrorText = '',
    this.confirmPasswordErrorText = '',
    this.globalErrorText = '',
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isLoading = false,
    this.terms = const [],
    this.agreeTermIds = const [],
  });

  SignUpState copyWith({
    String? emailErrorText,
    String? nicknameErrorText,
    String? passwordErrorText,
    String? confirmPasswordErrorText,
    String? globalErrorText,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isLoading,
    List<Term>? terms,
    List<int>? agreeTermIds,
  }) {
    return SignUpState(
      emailErrorText: emailErrorText ?? this.emailErrorText,
      nicknameErrorText: nicknameErrorText ?? this.nicknameErrorText,
      passwordErrorText: passwordErrorText ?? this.passwordErrorText,
      confirmPasswordErrorText:
          confirmPasswordErrorText ?? this.confirmPasswordErrorText,
      globalErrorText: globalErrorText ?? this.globalErrorText,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      terms: terms ?? this.terms,
      agreeTermIds: agreeTermIds ?? this.agreeTermIds,
    );
  }
}
