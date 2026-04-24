import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic_flutter/viewmodel/auth_view_model.dart';

class CommonAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showHome;

  const CommonAppBar({
    super.key,
    this.title,
    this.actions,
    this.showHome = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: false,
      title: InkWell(
        onTap: () => context.go('/vocabularies'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/mobidic_icon.png', height: 36),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title ?? 'MOBIDIC',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF01579B),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ...?actions,
        if (showHome)
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.black87),
            onPressed: () => context.go('/vocabularies'),
          ),
        IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.black87, size: 28),
          onPressed: () => _showCustomMenu(context, ref),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showCustomMenu(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authViewModelProvider);
    final String currentLocation = GoRouterState.of(context).uri.path;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 드래그 핸들
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // 사용자 정보 영역
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        radius: 24,
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.blue.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authState.currentUser?.nickname ?? 'GUEST',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '반갑습니다, 학습자님!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // 메뉴 아이템들
                _buildMenuItem(
                  context,
                  icon: Icons.abc_rounded,
                  title: '파닉스 학습',
                  subtitle: '알파벳 발음의 기초를 배워보세요',
                  color: Colors.green.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    if (currentLocation != '/phonics') context.push('/phonics');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: '설정',
                  subtitle: '앱 환경설정 및 이용약관 확인',
                  color: Colors.blue.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    if (currentLocation != '/settings')
                      context.push('/settings');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: '로그아웃',
                  subtitle: '로그아웃 하고 로그인 페이지로 돌아가기',
                  color: Colors.red.shade600,
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(authViewModelProvider.notifier).logout();
                    ref.invalidate(authViewModelProvider);
                    if (context.mounted) context.go('/');
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
