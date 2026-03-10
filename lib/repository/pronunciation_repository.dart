import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/api/api_url.dart';
import 'package:mobidic_flutter/api/dio.dart';
import 'package:mobidic_flutter/repository/repository.dart';

final pronunciationRepositoryProvider = Provider<PronunciationRepository>((
  ref,
) {
  final dio = ref.read(dioProvider);

  return PronunciationRepository(dio);
});

class PronunciationRepository extends Repository {
  final Dio _dio;

  PronunciationRepository(this._dio);

  Future<double> checkPronunciation(String filePath, String wordId) async {
    final url = ApiUrl.pronunciation.withId(wordId);

    final formData = FormData.fromMap({
      'wordId': wordId,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: 'temp_audio.mp4',
      ),
    });

    return await dioRequest(
      url: url,
      action:
          () => _dio.post(
            url,
            options: Options(extra: {'auth': true}),
            data: formData,
          ),
    );
  }
}
