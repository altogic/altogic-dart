import '../../altogic_dart.dart';
import 'platform_fetcher/stub_fetcher.dart'
    if (dart.library.html) 'platform_fetcher/web_fetcher.dart'
    if (dart.library.io) 'platform_fetcher/io_fetcher.dart'
    show handlePlatformRequest, handlePlatformUpload;

//ignore_for_file: constant_identifier_names
const INVALID_SESSION_TOKEN = 'invalid_session_token';
const MISSING_SESSION_TOKEN = 'missing_session_token';

/// HTTP client for the browser, Node or React Native. Created by
/// {@link AltogicClient} during initialization. The client library uses
/// [cross-fetch](https://www.npmjs.com/package/cross-fetch) under the hood to
/// make requests to you app's execution environment.
///
/// When creating the client if `apiKey` is specified in {@link ClientOptions},
/// Fetcher adds the provided apiKey to an **Authorization** header and sends
/// it in all RESTful API requests to your backend app.
///
/// Similarly, if there is an active user session, Fetcher also adds the session
/// token to a **Session** header and sends it in all RESTful API requests to
/// your backend app.
/// @export
/// @class Fetcher
class Fetcher {
  /// Reference to the Altogic client object
  /// @protected
  /// @type {AltogicClient}
  AltogicClient apiClient;

  /// The base URL that will be prepended to all RESTful API calls
  /// @protected
  /// @type {string}
  String restUrl;

  /// The default headers that will be sent in each RESTful API request to
  /// the execution environment
  /// @protected
  /// @type {string}
  Map<String, String> headers;

  /// The user session information. After the user is signed in using its app
  /// credentials or any Oauth2 provider credentials and if the session is
  /// created for this sign in then the user session information is stored in
  /// this field. If a session is available then the session token is added to
  /// the default headers of the Fetcher
  ///
  /// @protected
  /// @type {(Session | null)}
  Session? session;

  /// Creates an instance of Fetcher.
  /// @param {string} restUrl The base URL that will be prepended to all
  /// RESTful API calls
  /// @param {Map<String,dynamic>} headers The default headers that will be
  /// sent in each RESTful API request to the app's execution environment
  Fetcher(this.apiClient, this.restUrl, this.headers);

  Future<APIResponse<T>> _handleRequest<T>(Method method, String path,
      {Map<String, dynamic>? query,
      Map<String, dynamic>? headers,
      Object? body,
      ResolveType resolveType = ResolveType.json}) async {
    if (!path.trim().startsWith('/')) {
      throw ClientError('invalid_request_path',
          "A valid request path with a leading slash '/' needs to be specified e.g., /path");
    }

    var res = await handlePlatformRequest(method, restUrl + path,
        headers: {...this.headers, ...headers ?? {}},
        body: body,
        query: query ?? {},
        resolveType: resolveType,
        fetcher: this);

    return APIResponse(errors: res.errors, data: res.data as T?);
  }

  Future<APIResponse<T>> post<T>(String path,
          {Object? body,
          Map<String, dynamic>? query,
          Map<String, dynamic>? headers,
          ResolveType resolveType = ResolveType.json}) async =>
      _handleRequest<T>(Method.POST, path,
          query: query, headers: headers, body: body, resolveType: resolveType);

  Future<APIResponse<T>> put<T>(String path,
          {Object? body,
          Map<String, dynamic>? query,
          Map<String, dynamic>? headers,
          ResolveType resolveType = ResolveType.json}) async =>
      _handleRequest<T>(Method.PUT, path,
          query: query, headers: headers, body: body, resolveType: resolveType);

  Future<APIResponse<T>> delete<T>(String path,
          {Object? body,
          Map<String, dynamic>? query,
          Map<String, dynamic>? headers,
          ResolveType resolveType = ResolveType.json}) async =>
      _handleRequest<T>(Method.DELETE, path,
          query: query, headers: headers, body: body, resolveType: resolveType);

  void clearSession() {
    session = null;
    headers.remove('Session');
  }

  void setSession(Session session) {
    this.session = session;
    headers['Session'] = session.token;
  }

  /// Returns the api base url string.
  /// @returns string
  String getBaseUrl() => restUrl;

  Future<APIResponse<T>> get<T>(String path,
          {Map<String, dynamic>? query = const {},
          Map<String, dynamic>? headers = const {},
          ResolveType resolveType = ResolveType.json}) =>
      _handleRequest<T>(Method.GET, path,
          resolveType: resolveType, query: query, headers: headers);

  Future<APIResponse<T>> upload<T>(
    String path,
    Object body,
    String fileName,
    String contentType, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    void Function(int loaded, int total, double percent)? onProgress,
  }) async {
    if (!path.trim().startsWith('/')) {
      throw ClientError('invalid_request_path',
          "A valid request path with a leading slash '/' needs to be specified e.g., /path");
    }
    var res = await handlePlatformUpload(
        restUrl + path, body, fileName, contentType,
        headers: {...this.headers, ...headers ?? {}},
        query: query ?? {},
        fetcher: this,
        onProgress: onProgress);
    return APIResponse(errors: res.errors, data: res.data as T?);
  }
}
