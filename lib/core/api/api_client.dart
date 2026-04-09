import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'endpoints.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient({
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppEndpoints.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            )),
        _storage = storage ?? const FlutterSecureStorage() {
    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = token;
          }
          return handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            // Handle unauthorized (Session Expired)
            // This would typically involve clearing tokens and navigating to login
            await _storage.delete(key: 'accessToken');
            await _storage.delete(key: 'refreshToken');
            // TODO: Emit event or use a stream to trigger navigation
          }
          return handler.next(e);
        },
      ),
    );

    // Add logging in debug mode
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
