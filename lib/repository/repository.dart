import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobidic_flutter/exception/api_exception.dart';

class Repository {
  @protected
  Future<List<T>> dioRequestToList<T>({
    required String url,
    required Future<Response> Function() action,
    required T Function(Map<String, dynamic>) fromJson, // 개별 요소 변환 함수
  }) async {
    try {
      final response = await action();
      debugPrint('success $url ${response.data}');

      final list = response.data['data'] as List;
      return list.map((v) => fromJson(v as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw handleApiException(e);
    } catch (e) {
      debugPrint('$url unknown error: $e');
      throw handleUnknownException(e);
    }
  }

  @protected
  Future<T> dioRequest<T>({
    required String url,
    required Future<Response> Function() action,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await action();
      debugPrint('success $url ${response.data}');

      // 반환값이 없는(void) 경우를 처리
      if (fromJson == null) {
        if (response.data.toString().isEmpty) {
          return null as T;
        } else {
          return response.data['data'];
        }
      }

      // GeneralResponse 구조에 맞춰 'data' 필드 추출
      return fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleApiException(e);
    } catch (e) {
      debugPrint('$url unknown error: $e');
      throw handleUnknownException(e);
    }
  }

  @protected
  ApiException handleApiException(DioException e) {
    // 반환 타입 안정성 체크
    final data = e.response?.data;
    final Map<String, dynamic> mapData =
        data is Map<String, dynamic> ? data : {};

    debugPrint('[${e.response?.statusCode}] DioException: $data $e');

    if (mapData.isEmpty) {
      mapData['message'] = '서버에 알 수 없는 문제가 발생했습니다.';
    }

    return ApiException(
      message: mapData['message'] ?? '알 수 없는 오류가 발생했습니다.',
      status: mapData['status'] ?? 500,
      errors: mapData['errors'] ?? {},
    );
  }

  @protected
  ApiException handleUnknownException(Object e) {
    debugPrint('Unknown exception: $e');
    return ApiException(message: '알 수 없는 오류가 발생했습니다.', status: 500, errors: {});
  }
}
