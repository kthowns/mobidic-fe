import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/view/auth/log_in_page.dart';
import 'package:mobidic_flutter/view/auth/sign_up_page.dart';
import 'package:mobidic_flutter/view/learning/phonics_page.dart';
import 'package:mobidic_flutter/view/list/vocab_list_page.dart';
import 'package:mobidic_flutter/view/list/word_list_page.dart';
import 'package:mobidic_flutter/view/quiz/flash_card_page.dart';
import 'package:mobidic_flutter/view/quiz/ox_quiz_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 💡 .env 파일 로드 (await 필수)
  await dotenv.load(fileName: ".env");
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      title: 'Mobidic',
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/vocabularies': (context) => VocabListPage(),
        '/words': (context) => WordListPage(),
        '/phonics': (context) => PhonicsPage(),
        '/ox': (context) => OxQuizPage(),
        //'/blank': (context) => FillBlankQuizPage(),
        '/flashcard': (context) => FlashCardPage(),
        //'/dictation': (context) => DictationQuizPage(),
        //'/pronunciation': (context) => PronunciationCheckPage(),
      },
    );
  }
}
