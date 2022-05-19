import '../altogic_dart.dart';

class EndpointManager extends APIBase {
  EndpointManager(super.fetcher);

  Future<APIResponse<dynamic>> get(String path,
          {Map<String, dynamic>? queryParams,
          Map<String, dynamic>? headers,
          ResolveType resolveType = ResolveType.json}) async =>
      await fetcher.get(path,
          resolveType: resolveType, headers: headers, query: queryParams);

  Future<APIResponse<dynamic>> post(String path,
          {Map<String, dynamic>? queryParams,
          Map<String, dynamic>? headers,
          Object? body,
          ResolveType resolveType = ResolveType.json}) async =>
      await fetcher.post(path,
          body: body,
          resolveType: resolveType,
          headers: headers,
          query: queryParams);

  Future<APIResponse<dynamic>> put(String path,
          {Map<String, dynamic>? queryParams,
          Map<String, dynamic>? headers,
          Object? body,
          ResolveType resolveType = ResolveType.json}) async =>
      await fetcher.put(path,
          body: body,
          resolveType: resolveType,
          headers: headers,
          query: queryParams);

  Future<APIResponse<dynamic>> delete(String path,
          {Map<String, dynamic>? queryParams,
          Map<String, dynamic>? headers,
          Object? body,
          ResolveType resolveType = ResolveType.json}) async =>
      await fetcher.delete(path,
          body: body,
          resolveType: resolveType,
          headers: headers,
          query: queryParams);
}
