import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic/api/api_url.dart';
import 'package:mobidic/view/component/common_app_bar.dart';
import 'package:mobidic/viewmodel/auth_view_model.dart';
import 'package:mobidic/viewmodel/version_provider.dart';
import 'package:mobidic/util/url_util.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final versionAsync = ref.watch(appVersionProvider);
    final authState = ref.watch(authViewModelProvider);

    void sendFeedback() async {
      final appVersion = versionAsync.value ?? 'unknown';

      String encodeQueryParameters(Map<String, String> params) {
        return params.entries
            .map(
              (MapEntry<String, String> e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
            )
            .join('&');
      }

      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'pni2396@gmail.com',
        query: encodeQueryParameters(<String, String>{
          'subject': '[MOBIDIC 피드백] ',
          'body':
              '앱 사용 중 불편한 점이나 제안 사항을 적어주세요.\n\n사용자 ID: ${authState.currentUser?.email ?? '비로그인'}\n앱 버전: $appVersion',
        }),
      );

      UrlUtil.openExternalApp(emailLaunchUri.toString());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: '설정'),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            // 계정 섹션
            _buildSectionHeader('계정 정보'),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('현재 계정'),
              subtitle: Text(authState.currentUser?.nickname ?? '비로그인 상태'),
            ),
            if (authState.currentUser != null)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  '로그아웃',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () async {
                  await ref.read(authViewModelProvider.notifier).logout();
                  ref.invalidate(authViewModelProvider);
                  if (context.mounted) {
                    context.go('/welcome');
                  }
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.login, color: Colors.blueAccent),
                title: const Text(
                  '로그인',
                  style: TextStyle(color: Colors.blueAccent),
                ),
                onTap: () {
                  context.push('/login');
                },
              ),

            const Divider(height: 40),

            // 지원 및 약관 섹션
            _buildSectionHeader('고객 지원 및 약관'),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('의견 보내기'),
              subtitle: const Text('불편한 점이나 제안 사항을 보내주세요.'),
              onTap: versionAsync.hasValue ? sendFeedback : null,
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('서비스 이용약관'),
              onTap: () => UrlUtil.openInAppWebView(ApiUrl.termsService.url),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('개인정보처리방침'),
              onTap: () => UrlUtil.openInAppWebView(ApiUrl.termsPrivacy.url),
            ),

            const Divider(height: 40),

            // 앱 정보 섹션
            _buildSectionHeader('앱 정보'),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('앱 버전'),
              // versionAsync.when을 사용하여 상태별 UI 분기
              trailing: versionAsync.when(
                data: (version) =>
                    Text(version, style: const TextStyle(color: Colors.grey)),
                loading: () => const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (err, stack) =>
                    const Text('로드 실패', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF01579B),
        ),
      ),
    );
  }
}
