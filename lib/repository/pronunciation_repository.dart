import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    MultipartFile file;
    if (kIsWeb) {
      // 1. 웹 환경: filePath는 사실 blob URL입니다.
      // Dio를 통해 해당 URL에서 바이트 데이터를 직접 긁어옵니다.
      final response = await Dio().get<List<int>>(
        filePath,
        options: Options(responseType: ResponseType.bytes),
      );

      file = MultipartFile.fromBytes(
        response.data!,
        filename: 'temp_audio.mp4',
        contentType: DioMediaType('audio', 'mp4'), // 오디오 타입 명시
      );
    } else {
      // 2. 모바일 환경: 실제 파일 경로에서 가져옵니다.
      file = await MultipartFile.fromFile(
        filePath,
        filename: 'temp_audio.mp4',
        contentType: DioMediaType('audio', 'mp4'),
      );
    }
    final formData = FormData.fromMap({'wordId': wordId, 'file': file});
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
