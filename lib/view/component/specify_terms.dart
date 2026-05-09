import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobidic/api/api_url.dart';
import 'package:mobidic/util/url_util.dart';

class AgreementTerms extends StatelessWidget {
  const AgreementTerms({super.key});

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
              recognizer: TapGestureRecognizer()
                ..onTap = () => UrlUtil.openInAppWebView(ApiUrl.termsService.url),
            ),
            const TextSpan(text: ' 및 '),
            TextSpan(
              text: '개인정보처리방침',
              style: const TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => UrlUtil.openInAppWebView(ApiUrl.termsPrivacy.url),
            ),
            const TextSpan(text: '에 동의합니다.'),
          ],
        ),
      ),
    );
  }
}
