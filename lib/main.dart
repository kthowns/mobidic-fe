import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/view/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //usePathUrlStrategy();
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(routerProvider);
    return MaterialApp.router(routerConfig: router, title: 'Mobidic');
  }
}
