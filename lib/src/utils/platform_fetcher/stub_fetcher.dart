import '../../altogic_dart_base.dart';

Future<APIResponse<dynamic>> handlePlatformRequest(Method method, String path,
    {required Map<String, dynamic> query,
    required Map<String, dynamic> headers,
    Object? body,
    ResolveType resolveType = ResolveType.json,
    required Fetcher fetcher}) async {
  throw UnimplementedError();
}

Future<APIResponse<dynamic>> handlePlatformUpload(
    String path, Object body, String fileName, String contentType,
    {required Map<String, dynamic> query,
    required Map<String, dynamic> headers,
    void Function(int loaded, int total, double percent)? onProgress,
    required Fetcher fetcher}) async {
  throw UnimplementedError();
}
