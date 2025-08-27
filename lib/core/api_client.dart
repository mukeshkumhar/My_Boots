// lib/core/api_client.dart
import 'package:dio/dio.dart';
import 'token_store.dart';
import 'constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  bool _refreshing = false;
  List<QueuedRequest> _queue = [];

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: '${Constants.baseUrl}/api',
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    //   final client = HttpClient();
    //   client.badCertificateCallback =
    //       (cert, host, port) => false; // keep strict
    //   return client;
    // };

    // 🔎 Simple logger
    // dio.interceptors.add(
    //   LogInterceptor(
    //     request: true,
    //     requestBody: true,
    //     responseBody: true,
    //     responseHeader: false,
    //     error: true,
    //   ),
    // );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final access = await TokenStore.accessToken;
          if (access != null) {
            options.headers['Authorization'] = 'Bearer $access';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401 &&
              !_isAuthEndpoint(e.requestOptions.path)) {
            _queue.add(QueuedRequest(e.requestOptions, handler));
            await _attemptRefreshAndReplay();
            return;
          }
          handler.next(e);
        },
      ),
    );
  }

  bool _isAuthEndpoint(String path) =>
      path.contains('/user/login') ||
      path.contains('/user/register') ||
      path.contains('/user/me') ||
      path.contains('/user/home');

  Future<void> _attemptRefreshAndReplay() async {
    if (_refreshing) return;
    _refreshing = true;

    try {
      final refresh = await TokenStore.refreshToken;
      if (refresh == null || refresh.isEmpty) throw 'No refresh token';
      final resp = await dio.post(
        '/user/refresh',
        data: {'refreshToken': refresh},
      );
      final tokens = resp.data['tokens'];
      await TokenStore.saveTokens(
        tokens['accessToken'],
        tokens['refreshToken'],
      );

      // Replay queued
      final queued = [..._queue];
      _queue.clear();
      for (final q in queued) {
        try {
          final newReq = await _recreateRequest(q.requestOptions);
          final res = await dio.fetch(newReq);
          q.handler.resolve(res);
        } catch (err) {
          q.handler.next(err as DioError);
        }
      }
    } catch (_) {
      // Failed refresh: clear and bubble up errors
      await TokenStore.clear();
      for (final q in _queue) {
        q.handler.next(q.asUnauthorized());
      }
      _queue.clear();
    } finally {
      _refreshing = false;
    }
  }

  Future<RequestOptions> _recreateRequest(RequestOptions ro) async {
    final access = await TokenStore.accessToken;
    final headers = Map<String, dynamic>.from(ro.headers);
    if (access != null) headers['Authorization'] = 'Bearer $access';

    return RequestOptions(
      path: ro.path,
      method: ro.method,
      data: ro.data,
      queryParameters: ro.queryParameters,
      baseUrl: dio.options.baseUrl,
      headers: headers,
      sendTimeout: ro.sendTimeout,
      receiveTimeout: ro.receiveTimeout,
      contentType: ro.contentType,
      responseType: ro.responseType,
    );
  }
}

class QueuedRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;
  QueuedRequest(this.requestOptions, this.handler);

  DioError asUnauthorized() => DioError(
    requestOptions: requestOptions,
    response: Response(requestOptions: requestOptions, statusCode: 401),
    type: DioErrorType.badResponse,
  );
}
