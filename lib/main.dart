import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/view/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //usePathUrlStrategy();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router, title: 'Mobidic');
  }
}
