import 'package:url_launcher/url_launcher.dart';

class UrlUtil {
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mobidic.kthowns.cloud',
  );

  /// 웹 콘텐츠를 인앱 웹뷰로 엽니다.
  /// 상대 경로(/api/...)인 경우 _apiBaseUrl을 접두어로 붙입니다.
  static Future<void> openInAppWebView(String? path) async {
    if (path == null || path.isEmpty) return;

    String finalUrlString = path;
    if (!path.startsWith('http')) {
      final String separator = path.startsWith('/') ? '' : '/';
      finalUrlString = '$_apiBaseUrl$separator$path';
    }

    final Uri url = Uri.parse(finalUrlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  /// 메일(mailto:), 전화(tel:) 등 외부 앱으로 연결합니다.
  static Future<void> openExternalApp(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;

    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }
}
