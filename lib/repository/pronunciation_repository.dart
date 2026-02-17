import 'package:dio/dio.dart';
import 'package:mobidic_flutter/data/api_client.dart';
import 'package:mobidic_flutter/dto/api_response_dto.dart';
import 'package:mobidic_flutter/repository/auth_repository.dart';

class PronunciationRepository {
  final ApiClient _apiClient;
  final AuthRepository _authRepository;

  PronunciationRepository(this._apiClient, this._authRepository);

  Future<double> checkPronunciation(String filePath, String wordId) async {
    String? token = await _authRepository.getToken();
    String? memberId = await _authRepository.getCurrentMemberId();

    final formData = FormData.fromMap({
      'wordId': wordId,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: 'temp_audio.mp4',
      ),
    });

    try {
      final headers = {'Authorization': 'Bearer $token'};
      GeneralResponseDto response = await _apiClient.multiPartPost(
        url: '/pron/rate',
        formData: formData,
        headers: headers,
      );

      return response.data;
    } on DioException catch (e) {
      print("error : ${e.error}");
      print("message : ${e.message}");
      print("response : ${e.response}");
      rethrow;
    } catch (e){
      print(e);
      rethrow;
    }
  }
}
