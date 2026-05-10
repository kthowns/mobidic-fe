import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic/data/secure_storage_data_source.dart';
import 'package:mobidic/dto/login_dto.dart';
import 'package:mobidic/exception/api_exception.dart';
import 'package:mobidic/provider/auth_status_provider.dart';
import 'package:mobidic/repository/auth_repository.dart';
import 'package:mobidic/repository/user_repository.dart';

import 'package:mobidic/model/user.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
      final authRepository = ref.read(authRepositoryProvider);
      final userRepository = ref.read(userRepositoryProvider);
      final secureStorageDataSource = ref.read(secureStorageDataSourceProvider);

      return AuthViewModel(
        ref,
        authRepository,
        userRepository,
        secureStorageDataSource,
      );
    });

class AuthViewModel extends StateNotifier<AuthState> {
  final Ref _ref;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final SecureStorageDataSource _secureStorageDataSource;

  AuthViewModel(
    this._ref,
    this._authRepository,
    this._userRepository,
    this._secureStorageDataSource,
  ) : super(AuthState()) {
    _listenToAuthSignals();
    loadInitialData();
  }

  void _listenToAuthSignals() {
    _ref.listen(authSignalProvider, (previous, next) {
      if (next == AuthSignal.unauthorized) {
        clientLogout();
        // 신호를 처리했으므로 초기화합니다.
        _ref.read(authSignalProvider.notifier).state = null;
      }
    });
  }

  Future<void> loadInitialData() async {
    startLoading();

    try {
      final isGuest = await _secureStorageDataSource.readGuestMode();
      final currentUser = await _userRepository.getMe();
      state = state.copyWith(currentUser: currentUser, isGuestMode: isGuest);
    } catch (_) {
      final isGuest = await _secureStorageDataSource.readGuestMode();
      state = state.copyWith(currentUser: null, isGuestMode: isGuest);
    } finally {
      state = state.copyWith(isAutoLoginDone: true);
      stopLoading();
    }
  }

  Future<void> setGuestMode(bool isGuest) async {
    await _secureStorageDataSource.saveGuestMode(isGuest);
    state = state.copyWith(isGuestMode: isGuest);
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
      debugPrint('Attempting login with username: $username');
      final response = await _authRepository.login(
        LoginRequest(email: username, password: password),
      );
      debugPrint('Login successful: ${response.accessToken}');
      _secureStorageDataSource.saveToken(response.accessToken);
      state = state.copyWith(
        currentUser: await _userRepository.getMe(),
        loginErrorMessage: '',
        isAutoLoginDone: true,
      );
      stopLoading();
    } on ApiException catch (e) {
      if (e.errors.isNotEmpty) {
        state = state.copyWith(loginErrorMessage: e.errors.values.join('\n'));
      } else {
        state = state.copyWith(loginErrorMessage: e.message);
      }
      stopLoading();
    } catch (e) {
      state = state.copyWith(loginErrorMessage: "로그인 실패");
      rethrow;
    } finally {
      stopLoading();
    }
  }

  Future<void> loginWithAccessToken(String accessToken) async {
    startLoading();
    state = state.copyWith(loginErrorMessage: '');
    try {
      debugPrint('Attempting login with accessToken: $accessToken');
      await _secureStorageDataSource.saveToken(accessToken);
      state = state.copyWith(
        currentUser: await _userRepository.getMe(),
        loginErrorMessage: '',
        isAutoLoginDone: true,
      );
      stopLoading();
    } on ApiException catch (e) {
      if (e.errors.isNotEmpty) {
        state = state.copyWith(loginErrorMessage: e.errors.values.join('\n'));
      } else {
        state = state.copyWith(loginErrorMessage: e.message);
      }
      stopLoading();
    } catch (e) {
      state = state.copyWith(loginErrorMessage: "로그인 실패");
      rethrow;
    } finally {
      stopLoading();
    }
  }

  Future<String> getKakaoLoginUrl() async {
    return await _authRepository.getKakaoLoginUrl();
  }

  Future<void> logout() async {
    startLoading();
    await _authRepository.logout();
    clientLogout();
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
  final bool isAutoLoginDone;
  final bool isGuestMode;

  const AuthState({
    this.currentUser,
    this.loginErrorMessage = '',
    this.isLoading = false,
    this.isAutoLoginDone = false,
    this.isGuestMode = false,
  });

  AuthState copyWith({
    User? currentUser,
    String? loginErrorMessage,
    bool? isLoading,
    bool? isAutoLoginDone,
    bool? isGuestMode,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      loginErrorMessage: loginErrorMessage ?? this.loginErrorMessage,
      isLoading: isLoading ?? this.isLoading,
      isAutoLoginDone: isAutoLoginDone ?? this.isAutoLoginDone,
      isGuestMode: isGuestMode ?? this.isGuestMode,
    );
  }
}
