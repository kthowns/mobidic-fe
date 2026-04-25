import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobidic_flutter/api/api_url.dart';
import 'package:url_launcher/url_launcher.dart';

class AgreementTerms extends StatelessWidget {
  const AgreementTerms({super.key});

  void openUrl(String path) async {
    const String apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://mobidic.kthowns.cloud',
    );
    final url = Uri.parse('$apiBaseUrl$path');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: Colors.black54, fontSize: 12),
          children: [
            TextSpan(
              text: '서비스이용약관',
              style: const TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () => openUrl(ApiUrl.termsService.url),
            ),
            const TextSpan(text: ' 및 '),
            TextSpan(
              text: '개인정보처리방침',
              style: const TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () => openUrl(ApiUrl.termsPrivacy.url),
            ),
            const TextSpan(text: '에 동의합니다.'),
          ],
        ),
      ),
    );
  }
}
