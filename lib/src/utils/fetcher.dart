import '../../altogic_dart.dart';
import 'platform_fetcher/stub_fetcher.dart'
    if (dart.library.html) 'platform_fetcher/web_fetcher.dart'
    if (dart.library.io) 'platform_fetcher/io_fetcher.dart'
    show handlePlatformRequest, handlePlatformUpload;

//ignore_for_file: constant_identifier_names
const INVALID_SESSION_TOKEN = 'invalid_session_token';
const MISSING_SESSION_TOKEN = 'missing_session_token';

/// HTTP client for the browser, Node or React Native. Created by
/// [AltogicClient] during initialization. The client library uses
/// [cross-fetch](https://www.npmjs.com/package/cross-fetch) under the hood to
/// make requests to you app's execution environment.
///
/// When creating the client if `apiKey` is specified in [ClientOptions],
/// Fetcher adds the provided apiKey to an **Authorization** header and sends
/// it in all RESTful API requests to your backend app.
///
/// Similarly, if there is an active user session, Fetcher also adds the session
/// token to a **Session** header and sends it in all RESTful API requests to
/// your backend app.
class Fetcher {

  /// Reference to the Altogic client object
  AltogicClient apiClient;

  /// The base URL that will be prepended to all RESTful API calls
  String restUrl;

  /// The default headers that will be sent in each RESTful API request to
  /// the execution environment
  Map<String, String> headers;

  /// The user session information. After the user is signed in using its app
  /// credentials or any Oauth2 provider credentials and if the session is
  /// created for this sign in then the user session information is stored in
  /// this field. If a session is available then the session token is added to
  /// the default headers of the Fetcher
  Session? session;

  /// Creates an instance of Fetcher.
  ///
  /// [restUrl] The base URL that will be prepended to all
  /// RESTful API calls
  ///
  /// [headers] The default headers that will be
  /// sent in each RESTful API request to the app's execution environment
  Fetcher(this.apiClient, this.restUrl, this.headers);


  /// Internal method to handle all public request methods (get, post, put and
  /// delete). If the request response is an invalid session token error,
  /// invalidates the current user session.
  ///
  /// [method] The request method
  ///
  /// [path] The path of the request, needs to start with a slash 'character'
  /// e.g., `/users`,
  ///
  /// [query] The query string parameters that will be sent to your app backend.
  /// This is a simple JSON object with key and value pairs.
  ///
  /// [headers] Additional request headers which will be merged with default
  /// headers
  ///
  /// [body] Request body if any. If provided can be a **JSON**. For file
  /// uploads you can use [upload].
  ///
  /// [resolveType] Type of data to return as a response of the request.
  /// By default response data is parsed to JSON. Possible values are json,
  /// text, blob and arraybuffer.
  ///
  /// Returns a Future. The returned response includes two components *data*
  /// and *errors*. If errors occured during the execution of the request
  /// then errors object is returned and tha data is marked as `null`. If no
  /// errors occured then depending on the type of the request the data object
  /// holds a *single JSON object*, an *array of json objects*, *plain text*,
  /// *Blob* or *ArrayBuffer* and the errors object is marked as `null`. If
  /// the response returns no data back then both erros and data marked as
  /// `null`.
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

  /// Makes a GET request to backend app execution environment.
  ///
  /// [path] The path of the request that will be appended to the {restUrl}
  ///
  /// [query] Query string parameters as key:value pair object
  ///
  /// [headers] Additional request headers that will be sent with the request
  ///
  /// [resolveType] Type of data to return as a response of the request.
  /// By default response data is parsed to JSON. Possible values are json,
  /// text, blob and arraybuffer.
  ///
  /// Returns a promise. The returned response includes two components *data*
  /// and *errors*. If errors occured during the execution of the request
  /// then errors object is returned and tha data is marked as `null`. If no
  /// errors occured then depending on the type of the request the data object
  /// holds a *single JSON object*, an *array of json objects*, *plain text*,
  /// *Blob* or *ArrayBuffer* and the errors object is marked as `null`. If the
  /// response returns no data back then both erros and data marked as `null`.
  Future<APIResponse<T>> get<T>(String path,
      {Map<String, dynamic>? query = const {},
        Map<String, dynamic>? headers = const {},
        ResolveType resolveType = ResolveType.json}) =>
      _handleRequest<T>(Method.GET, path,
          resolveType: resolveType, query: query, headers: headers);

  /// Makes a POST request to backend app execution environment.
  ///
  /// [path] The path of the request that will be appended to the {restUrl}
  ///
  /// [body] The body of the request
  ///
  /// [query] Query string parameters as key:value pair object
  ///
  /// [headers] Additional request headers that will be sent with the request
  ///
  /// [resolveType] Type of data to return as a response of the request.
  /// By default response data is parsed to JSON. Possible values are json,
  /// text, blob and arraybuffer.
  ///
  /// Returns a promise. The returned response includes two components *data*
  /// and *errors*. If errors occured during the execution of the request then
  /// errors object is returned and tha data is marked as `null`. If no errors
  /// occured then depending on the type of the request the data object holds
  /// a *single JSON object*, an *array of json objects*, *plain text*, *Blob*
  /// or *ArrayBuffer* and the errors object is marked as `null`. If the
  /// response returns no data back then both erros and data marked as `null`.
  Future<APIResponse<T>> post<T>(String path,
          {Object? body,
          Map<String, dynamic>? query,
          Map<String, dynamic>? headers,
          ResolveType resolveType = ResolveType.json}) async =>
      _handleRequest<T>(Method.POST, path,
          query: query, headers: headers, body: body, resolveType: resolveType);


  /// Makes a PUT request to backend app execution environment.
  ///
  /// path] The path of the request that will be appended to the {restUrl}
  ///
  /// [body] The body of the request
  ///
  /// [query] Query string parameters as key:value pair object
  ///
  /// [headers] Additional request headers that will be sent with the request
  ///
  /// [resolveType] Type of data to return as a response of the request. By
  /// default response data is parsed to JSON. Possible values are json, text,
  /// blob and arraybuffer.
  ///
  /// Returns a promise. The returned response includes two components *data*
  /// and *errors*. If errors occured during the execution of the request then
  /// errors object is returned and tha data is marked as `null`. If no errors
  /// occured then depending on the type of the request the data object holds
  /// a *single JSON object*, an *array of json objects*, *plain text*, *Blob*
  /// or *ArrayBuffer* and the errors object is marked as `null`. If the
  /// response returns no data back then both erros and data marked as `null`.
  Future<APIResponse<T>> put<T>(String path,
          {Object? body,
          Map<String, dynamic>? query,
          Map<String, dynamic>? headers,
          ResolveType resolveType = ResolveType.json}) async =>
      _handleRequest<T>(Method.PUT, path,
          query: query, headers: headers, body: body, resolveType: resolveType);

  /// Makes a DELETE request to backend app execution environment.
  ///
  /// [path] The path of the request that will be appended to the {restUrl}
  ///
  /// [body] The body of the request
  ///
  /// [query] Query string parameters as key:value pair object
  ///
  /// [headers] Additional request headers that will be sent with the request
  ///
  /// [resolveType] Type of data to return as a response of the request. By
  /// default response data is parsed to JSON. Possible values are json, text,
  /// blob and arraybuffer.
  ///
  /// Returns a promise. The returned response includes two components *data*
  /// and *errors*. If errors occured during the execution of the request then
  /// errors object is returned and tha data is marked as `null`. If no errors
  /// occured then depending on the type of the request the data object holds
  /// a *single JSON object*, an *array of json objects*, *plain text*, *Blob*
  /// or *ArrayBuffer* and the errors object is marked as `null`. If the
  /// response returns no data back then both erros and data marked as `null`.
  Future<APIResponse<T>> delete<T>(String path,
          {Object? body,
          Map<String, dynamic>? query,
          Map<String, dynamic>? headers,
          ResolveType resolveType = ResolveType.json}) async =>
      _handleRequest<T>(Method.DELETE, path,
          query: query, headers: headers, body: body, resolveType: resolveType);


  /// Sets the session of the user that will be used by Fetcher. Adds the new
  /// session token to the **Session** request header.
  ///
  /// [session] Session info object
  void setSession(Session session) {
    this.session = session;
    headers['Session'] = session.token;
  }
  /// Clears the session info of the user from the Fetcher. Basically removes
  /// the **Session** header from the default request headers until a new
  /// session value is provided.
  void clearSession() {
    session = null;
    headers.remove('Session');
  }



  /// Returns the api base url string.
  String getBaseUrl() => restUrl;


  /// Uploads a file object instead of fetcher in order to track upload
  /// progress and call a callback function.
  ///
  /// [path] The path of the request that will be appended to the {restUrl}
  ///
  /// [body] The body of the request
  ///
  /// [query] Query string parameters as key:value pair object
  ///
  /// [headers] Additional request headers that will be sent with the request
  ///
  /// [onProgress] Callback function that will be called during file upload to
  /// inform the progres
  ///
  /// Returns a promise. The returned response includes two components *data*
  /// and *errors*. If errors occured during the execution of the request then
  /// errors object is returned and tha data is marked as `null`. If no errors
  /// occured then a *single JSON object* providing information about the
  /// uploaded file is returned and the *errors* object is marked as `null`.
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
