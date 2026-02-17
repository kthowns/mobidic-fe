import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:mobidic_flutter/di/providers.dart';
import 'package:mobidic_flutter/repository/auth_repository.dart';
import 'package:mobidic_flutter/view/auth/join_page.dart';
import 'package:mobidic_flutter/view/auth/log_in_page.dart';
import 'package:mobidic_flutter/view/learning/phonics_page.dart';
import 'package:mobidic_flutter/viewmodel/join_view_model.dart';
import 'package:provider/provider.dart';

late final String apiBaseUrl;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  apiBaseUrl = await loadApiBaseUrl();

  if (!kIsWeb) {
    await initKakaoSdk();
  }

  runApp(
    MultiProvider(providers: getProviders(apiBaseUrl), child: const MyApp()),
  );
}

Future<void> initKakaoSdk() async {
  String kakaoNativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? "";

  if (kakaoNativeAppKey == "") throw Exception('Missing KAKAO_NATIVE_APP_KEY');
  debugPrint('KAKAO_NATIVE_APP_KEY: $kakaoNativeAppKey');

  KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);
}

Future<String> loadApiBaseUrl() async {
  await dotenv.load(fileName: ".env");
  String url = "";

  url = dotenv.env['API_BASE_URL'] ?? "https://api.example.com";

  if (url == "") throw Exception('Missing API_BASE_URL');

  return url;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobidic',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',

      routes: {
        '/': (context) => LoginPage(),
        '/sign_up':
            (context) => ChangeNotifierProvider(
              create: (_) => JoinViewModel(context.read<AuthRepository>()),
              child: JoinPage(),
            ),
        '/phonics': (context) => PhonicsPage(),
      },
    );
  }
}
