import '../altogic_dart.dart';

typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<Map<String, dynamic>>;

class FutureApiResponse {
  FutureApiResponse(this._future);

  ///
  final Future<APIResponse<dynamic>> _future;

  Future<APIResponse<JsonMap>> asMap() async => (await _future).cast<JsonMap>();

  Future<APIResponse<JsonList>> asList() async {
    var res = (await _future).cast<List<dynamic>>();
    return APIResponse(data: res.data?.cast<JsonMap>(), errors: res.errors);
  }

  Future<APIResponse<bool>> asBool() async => (await _future).cast<bool>();

  Future<APIResponse<int>> asInt() async => (await _future).cast<int>();

  Future<APIResponse<double>> asDouble() async =>
      (await _future).cast<double>();

  Future<APIResponse<dynamic>> asDynamic() async =>
      (await _future).cast<dynamic>();
}

class EndpointManager extends APIBase {
  EndpointManager(super.fetcher);

  FutureApiResponse get(String path,
          {Map<String, dynamic>? queryParams,
          Map<String, dynamic>? headers,
          ResolveType resolveType = ResolveType.json}) =>
      FutureApiResponse(fetcher.get(path,
          resolveType: resolveType, headers: headers, query: queryParams));

  FutureApiResponse post(String path,
          {Map<String, dynamic>? queryParams,
          Map<String, dynamic>? headers,
          Object? body,
          ResolveType resolveType = ResolveType.json}) =>
      FutureApiResponse(fetcher.post(path,
          body: body,
          resolveType: resolveType,
          headers: headers,
          query: queryParams));

  FutureApiResponse put(String path,
          {Map<String, dynamic>? queryParams,
          Map<String, dynamic>? headers,
          Object? body,
          ResolveType resolveType = ResolveType.json}) =>
      FutureApiResponse(fetcher.put(path,
          body: body,
          resolveType: resolveType,
          headers: headers,
          query: queryParams));

  FutureApiResponse delete(String path,
          {Map<String, dynamic>? queryParams,
          Map<String, dynamic>? headers,
          Object? body,
          ResolveType resolveType = ResolveType.json}) =>
      FutureApiResponse(fetcher.delete(path,
          body: body,
          resolveType: resolveType,
          headers: headers,
          query: queryParams));
}
