import 'package:flutter/cupertino.dart';
import 'package:mobidic_flutter/exception/api_exception.dart';
import 'package:mobidic_flutter/mixin/LoadingMixin.dart';
import 'package:mobidic_flutter/repository/auth_repository.dart';
import 'package:mobidic_flutter/repository/member_repository.dart';

import 'package:mobidic_flutter/model/member.dart';

class AuthViewModel extends ChangeNotifier with LoadingMixin {
  final AuthRepository _authRepository;
  final MemberRepository _memberRepository;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Member? _currentMember;
  Member? get currentMember => _currentMember;

  String? _token;

  bool _loginError = false;
  bool get loginError => _loginError;
  String _loginErrorMessage = '';
  String get loginErrorMessage => _loginErrorMessage;

  AuthViewModel(this._authRepository, this._memberRepository){
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    startLoading();
    try {
      _token = await _authRepository.getToken();
      _currentMember = await _memberRepository.getMemberDetail(
          await _authRepository.getCurrentMemberId());
      _isLoggedIn = _token != null;
    } catch (_) {
      _isLoggedIn = false;
      _token = null;
      _currentMember = null;
    } finally {
      stopLoading();
    }
  }

  Future<void> login(String username, String password) async {
    startLoading();
    _loginErrorMessage = '';

    if(username.isEmpty || password.isEmpty){
      _loginError = true;
      _loginErrorMessage = '이메일 또는 비밀번호를 입력해주세요.';
      stopLoading();
      return;
    }

    try {
      final response = await _authRepository.login(username, password);
      _isLoggedIn = true;
      _token = response.token;
      _currentMember = await _memberRepository.getMemberDetail(response.memberId);
      _loginError = false;
    } on ApiException catch (e) {
      _isLoggedIn = false;
      _loginError = true;
      if(e.statusCode == 500){
        _loginErrorMessage = "서버에 문제가 발생했습니다.";
        return;
      }
      if(e.errors != null && e.errors is Map<String, dynamic> && e.errors!.isNotEmpty) {
        for(var entry in e.errors!.entries){
          _loginErrorMessage += '${entry.value}\n';
        }
      } else {
        _loginErrorMessage = e.message;
      }
    } catch(e){
      _loginError = true;
      _isLoggedIn = false;
      _loginErrorMessage = "로그인 실패";
      rethrow;
    } finally {
      stopLoading();
    }
  }

  Future<void> logout() async {
    _authRepository.logout();
    _isLoggedIn = false;
    _token = null;
    _currentMember = null;
  }
}
