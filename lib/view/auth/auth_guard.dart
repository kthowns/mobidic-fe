import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic/viewmodel/auth_view_model.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (previous?.currentUser != null && next.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃 되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
        context.go('/'); // 로그아웃 되면 로그인 페이지로 강제 이동
      }
    });

    return child;
  }
}
