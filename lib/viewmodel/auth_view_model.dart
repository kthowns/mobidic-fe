import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/data/secure_storage_data_source.dart';
import 'package:mobidic_flutter/dto/login_dto.dart';
import 'package:mobidic_flutter/exception/api_exception.dart';
import 'package:mobidic_flutter/repository/auth_repository.dart';
import 'package:mobidic_flutter/repository/user_repository.dart';

import 'package:mobidic_flutter/model/user.dart';

final authViewModelProvider = StateNotifierProvider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final secureStorageDataSource = ref.watch(secureStorageDataSourceProvider);

  return AuthViewModel(authRepository, userRepository, secureStorageDataSource);
});

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final SecureStorageDataSource _secureStorageDataSource;

  AuthViewModel(
    this._authRepository,
    this._userRepository,
    this._secureStorageDataSource,
  ) : super(AuthState()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    startLoading();

    try {
      final currentUser = await _userRepository.getMe();
      state = state.copyWith(currentUser: currentUser);
    } catch (_) {
      state = state.copyWith(currentUser: null);
    } finally {
      stopLoading();
    }
  }

  Future<void> login(String username, String password) async {
    startLoading();
    state = state.copyWith(loginErrorMessage: '');

    if (username.isEmpty || password.isEmpty) {
      state = state.copyWith(loginErrorMessage: '이메일 또는 비밀번호를 입력해주세요.');
      stopLoading();
      return;
    }

    try {
      print('Attempting login with username: $username');
      final response = await _authRepository.login(
        LoginRequest(email: username, password: password),
      );
      print('Login successful: ${response.accessToken}');
      _secureStorageDataSource.saveToken(response.accessToken);
      state = state.copyWith(
        currentUser: await _userRepository.getMe(),
        loginErrorMessage: '',
      );
      stopLoading();
    } on ApiException catch (e) {
      state = state.copyWith(loginErrorMessage: e.message);
      stopLoading();
      if (e.status == 500) {
        state = state.copyWith(loginErrorMessage: "서버에 문제가 발생했습니다.");
        return;
      }
      if (e.errors.isNotEmpty) {
        state = state.copyWith(loginErrorMessage: e.errors.values.join('\n'));
      } else {
        state = state.copyWith(loginErrorMessage: e.message);
      }
    } catch (e) {
      state = state.copyWith(loginErrorMessage: "로그인 실패");
      rethrow;
    } finally {
      stopLoading();
    }
  }

  Future<void> logout() async {
    startLoading();
    await _authRepository.logout();
    await _secureStorageDataSource.deleteToken();
    state = state.copyWith(currentUser: null, loginErrorMessage: '');
    stopLoading();
  }

  Future<void> clientLogout() async {
    startLoading();
    await _secureStorageDataSource.deleteToken();
    state = state.copyWith(currentUser: null, loginErrorMessage: '');
    stopLoading();
  }

  void startLoading() {
    state = state.copyWith(isLoading: true);
  }

  void stopLoading() {
    state = state.copyWith(isLoading: false);
  }
}

class AuthState {
  final User? currentUser;
  final String loginErrorMessage;
  final bool isLoading;

  const AuthState({
    this.currentUser,
    this.loginErrorMessage = '',
    this.isLoading = false,
  });

  AuthState copyWith({
    User? currentUser,
    String? loginErrorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      loginErrorMessage: loginErrorMessage ?? this.loginErrorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
