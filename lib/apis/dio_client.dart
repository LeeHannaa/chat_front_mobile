import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiAddress = dotenv.get('API_ANDROID_ADDRESS');

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiAddress, // 공통 base URL
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // options.headers["Authorization"] = "Bearer your_token_here";
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log('[RES] ${response.statusCode} ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        log('[ERR] ${e.response?.statusCode} ${e.message}');
        return handler.next(e);
      },
    ));

  static Dio get dio => _dio;
}
