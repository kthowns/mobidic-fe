import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:mobidic_flutter/dto/api_response_dto.dart';
import 'package:mobidic_flutter/exception/api_exception.dart';

class ApiClient {
  final String _baseUrl;

  ApiClient(this._baseUrl);

  Future<GeneralResponseDto> post({
    required String url,
    Object? body,
    Map<String, String>? headers,
  }) async {
    print("Request uri : POST $_baseUrl$url");
    print("body : $body");
    print("headers : $headers");

    final http.Response response = await http.post(
      Uri.parse('$_baseUrl$url'),
      headers: {'Content-Type': 'application/json', ...?headers},
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleHttpResponse(response, GeneralResponseDto.fromJson);
  }

  Future<GeneralResponseDto> patch({
    required String url,
    Object? body,
    Map<String, String>? headers,
  }) async {
    print("Request uri : PATCH $_baseUrl$url");
    print("body : $body");
    print("headers : $headers");

    final http.Response response = await http.patch(
      Uri.parse('$_baseUrl$url'),
      headers: {'Content-Type': 'application/json', ...?headers},
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleHttpResponse(response, GeneralResponseDto.fromJson);
  }

  Future<GeneralResponseDto> get({
    required String url,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$url').replace(
      queryParameters: params?.map((k, v) => MapEntry(k, v.toString())),
    );
    print("Request uri : GET $_baseUrl$url");
    print("params : $params");
    print("headers : $headers");

    final http.Response response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json', ...?headers},
    );

    return _handleHttpResponse(response, GeneralResponseDto.fromJson);
  }

  Future<GeneralResponseDto> delete({
    required String url,
    Object? body,
    Map<String, String>? headers,
  }) async {
    print("Request uri : DELETE $_baseUrl$url");
    print("body : $body");
    print("headers : $headers");

    final http.Response response = await http.delete(
      Uri.parse('$_baseUrl$url'),
      headers: {'Content-Type': 'application/json', ...?headers},
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleHttpResponse(response, GeneralResponseDto.fromJson);
  }

  Future<GeneralResponseDto> multiPartPost({
    required String url,
    FormData? formData,
    Map<String, dynamic>? headers,
  }) async {
    print("Request uri : POST $_baseUrl$url");
    print("headers : $headers");

    Dio dio = Dio();
    Response response = await dio.post(
      '$_baseUrl$url',
      data: formData,
      options: Options(
        headers: headers,
        validateStatus: (status) => true, // 모든 Status code 허용
      ),
    );

    return _handleDioResponse(response, GeneralResponseDto.fromJson);
  }

  Future<T> _handleHttpResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final Map<String, dynamic> bodyJson = jsonDecode(response.body);

    print(bodyJson);

    if (response.statusCode != 200) {
      final errorBody = ErrorResponseDto.fromJson(bodyJson);
      throw ApiException(
        response.statusCode,
        errorBody.message,
        errors: errorBody.errors,
      );
    }

    return fromJson(bodyJson);
  }

  Future<T> _handleDioResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    print(response);

    if (response.statusCode != 200) {
      final errorBody = ErrorResponseDto.fromJson(response.data);
      throw ApiException(
        response.statusCode ?? 500,
        errorBody.message,
        errors: errorBody.errors,
      );
    }

    return fromJson(response.data);
  }
}
