import 'package:mobidic_flutter/repository/auth_repository.dart';
import 'package:mobidic_flutter/repository/member_repository.dart';
import 'package:mobidic_flutter/repository/pronunciation_repository.dart';
import 'package:mobidic_flutter/repository/question_repository.dart';
import 'package:mobidic_flutter/repository/rate_repository.dart';
import 'package:mobidic_flutter/repository/vocab_repository.dart';
import 'package:mobidic_flutter/repository/word_repository.dart';
import 'package:mobidic_flutter/viewmodel/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/api_client.dart';
import '../data/secure_storage_data_source.dart';

List<SingleChildWidget> getProviders(String apiBaseUrl) => [
  Provider(create: (_) => ApiClient(apiBaseUrl)),
  Provider(create: (_) => SecureStorageDataSource()),
  Provider(
    create:
        (context) => AuthRepository(
          context.read<SecureStorageDataSource>(),
          context.read<ApiClient>(),
        ),
  ),
  Provider(
    create:
        (context) => MemberRepository(
          context.read<ApiClient>(),
          context.read<AuthRepository>(),
        ),
  ),
  Provider(
    create:
        (context) => VocabRepository(
          context.read<ApiClient>(),
          context.read<AuthRepository>(),
        ),
  ),
  Provider(
    create:
        (context) => WordRepository(
          context.read<ApiClient>(),
          context.read<AuthRepository>(),
        ),
  ),
  Provider(
    create:
        (context) => RateRepository(
          context.read<ApiClient>(),
          context.read<AuthRepository>(),
        ),
  ),
  Provider(
    create:
        (context) => PronunciationRepository(
          context.read<ApiClient>(),
          context.read<AuthRepository>(),
        ),
  ),
  Provider(
    create:
        (context) => QuestionRepository(
          context.read<ApiClient>(),
          context.read<AuthRepository>(),
        ),
  ),
  ChangeNotifierProvider(
    create:
        (context) => AuthViewModel(
          context.read<AuthRepository>(),
          context.read<MemberRepository>(),
        ),
  ),
];
