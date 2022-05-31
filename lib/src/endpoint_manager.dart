import '../altogic_dart.dart';

/// A Map<String,dynamic> type.
typedef JsonMap = Map<String, dynamic>;

/// A List<Map<String,dynamic>> type.
typedef JsonList = List<Map<String, dynamic>>;

/// All methods of [EndpointManager] return [FutureApiResponse].
///
/// ``as*`` methods perform casting on the data of an [APIResponse].
class FutureApiResponse {
  FutureApiResponse._(this._future);

  ///
  final Future<APIResponse<dynamic>> _future;

  /// Get response as ``APIResponse<Map<String,dynamic>>``.
  ///
  /// If the response isn't a ``Map<String,dynamic>`` throws an error.
  Future<APIResponse<JsonMap>> asMap() async => (await _future).cast<JsonMap>();

  /// Get response as ``APIResponse<List<Map<String,dynamic>>>``.
  ///
  /// If the response isn't a ``List<Map<String,dynamic>>`` throws an error.
  Future<APIResponse<JsonList>> asList() async {
    var res = (await _future).cast<List<dynamic>>();
    return APIResponse(data: res.data?.cast<JsonMap>(), errors: res.errors);
  }

  /// Get response as ``APIResponse<bool>``.
  ///
  /// If the response isn't a ``bool`` throws an error.
  Future<APIResponse<bool>> asBool() async => (await _future).cast<bool>();

  /// Get response as ``APIResponse<int>``.
  ///
  /// If the response isn't a ``int`` throws an error.
  Future<APIResponse<int>> asInt() async => (await _future).cast<int>();

  /// Get response as ``APIResponse<double>``.
  ///
  /// If the response isn't a ``double`` throws an error.
  Future<APIResponse<double>> asDouble() async =>
      (await _future).cast<double>();

  /// Get response as ``APIResponse<dynamic>``.
  Future<APIResponse<dynamic>> asDynamic() async =>
      (await _future).cast<dynamic>();
}

/// Provides the methods to execute your app backend services by making http
/// request to your app endpoints.
///
/// If your endpoints require an **API key**, you can set it in two ways either
/// as the **apiKey** input parameter of [ClientOptions] to the [createClient]
/// function or as an input header with the name **Authorization**
/// (e.g., Authorization: \<your api key\>) in specific methods.
///
/// Additionally, if your endpoints require a **Session** token, you can also
/// set it in two ways either calling the [AuthManager.setSession] method with
/// a valid session object or as an input header with the name **Session**
/// (e.g., Session: \<your session token\>) in specific methods.
class EndpointManager extends APIBase {


  /// Creates an instance of [EndpointManager] to make http requests to your
  /// app endpoints.
  ///
  /// [fetcher] The http client to make RESTful API calls to the application's
  /// execution engine
  EndpointManager(super.fetcher);

  /// Makes a GET request to the endpoint path. Optionally, you can provide
  /// query string parameters or headers in this request.
  ///
  /// > *Depending on the configuration of the endpoint, an active user session
  /// might be required (e.g., user needs to be logged in) to call this method.*
  ///
  /// [path] The path of the endpoint. The endpoint path needs to start with a
  /// slash '/' character e.g., /users/profile
  ///
  /// [queryParams] Query string parameters as a "key":"value" pair object
  ///
  /// [headers] Additional request headers as a "key":"value" pair object
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
  /// or *Uint8List* and the errors object is marked as `null`. If the
  /// response returns no data back then both erros and data marked as `null`.
  FutureApiResponse get(String path,
          {Map<String, dynamic>? queryParams,
          Map<String, dynamic>? headers,
          ResolveType resolveType = ResolveType.json}) =>
      FutureApiResponse._(fetcher.get(path,
          resolveType: resolveType, headers: headers, query: queryParams));

  /// Makes a POST request to the endpoint path. Optionally, you can provide
  /// body, query string parameters or headers in this request.
  ///
  /// > *Depending on the configuration of the endpoint, an active user session
  /// might be required (e.g., user needs to be logged in) to call this method.*
  ///
  /// [path] The path of the endpoint. The endpoint path needs to start with a
  /// slash '/' character e.g., /users/profile
  ///
  /// [body] Request body **JSON** or **Uint8List** object.
  ///
  /// [queryParams] Query string parameters as a key:value pair object
  ///
  /// [headers] Additional request headers as a key:value pair object
  ///
  /// [resolveType] Type of data to return as a response of the request.
  /// By default response data is parsed to JSON. Possible values are json,
  /// text, blob and Uint8List.
  ///
  /// Returns a promise. The returned response includes two components *data*
  /// and *errors*. If errors occured during the execution of the request then
  /// errors object is returned and tha data is marked as `null`. If no errors
  /// occured then depending on the type of the request the data object holds
  /// a *single JSON object*, an *array of json objects*, *plain text*, *Blob*
  /// or *ArrayBuffer* and the errors object is marked as `null`. If the
  /// response returns no data back then both erros and data marked as `null`.
  FutureApiResponse post(String path,
          {Map<String, dynamic>? queryParams,
          Map<String, dynamic>? headers,
          Object? body,
          ResolveType resolveType = ResolveType.json}) =>
      FutureApiResponse._(fetcher.post(path,
          body: body,
          resolveType: resolveType,
          headers: headers,
          query: queryParams));

  /// Makes a PUT request to the endpoint path. Optionally, you can provide
  /// body, query string parameters or headers in this request.
  ///
  /// > *Depending on the configuration of the endpoint, an active user session
  /// might be required (e.g., user needs to be logged in) to call this method.*
  /// [path] The path of the endpoint. The endpoint path needs to start with a
  /// slash '/' character e.g., /users/profile
  ///
  /// [body] Request body **JSON** or **Uint8List** object.
  ///
  /// [queryParams] Query string parameters as a key:value pair object
  ///
  /// [headers] Additional request headers as a key:value pair object
  ///
  /// [resolveType] Type of data to return as a response of the request.
  /// By default response data is parsed to JSON. Possible values are json,
  /// text, blob and arraybuffer.
  ///
  /// Returns a promise. The returned response includes two components *data*
  /// and *errors*. If errors occured during the execution of the request
  /// then errors object is returned and tha data is marked as `null`. If
  /// no errors occured then depending on the type of the request the data
  /// object holds a *single JSON object*, an *array of json objects*,
  /// *plain text*, *Blob* or *ArrayBuffer* and the errors object is marked
  /// as `null`. If the response returns no data back then both erros and
  /// data marked as `null`.
  FutureApiResponse put(String path,
          {Map<String, dynamic>? queryParams,
          Map<String, dynamic>? headers,
          Object? body,
          ResolveType resolveType = ResolveType.json}) =>
      FutureApiResponse._(fetcher.put(path,
          body: body,
          resolveType: resolveType,
          headers: headers,
          query: queryParams));

  /// Makes a DELETE request to the endpoint path. Optionally, you can provide
  /// body, query string parameters or headers in this request.
  ///
  /// > *Depending on the configuration of the endpoint, an active user session
  /// might be required (e.g., user needs to be logged in) to call this method.*
  ///
  /// [path] The path of the endpoint. The endpoint path needs to
  /// start with a slash '/' character e.g., /users/profile
  ///
  /// [body] Request body **JSON** or **Uint8List** object.
  ///
  /// [queryParams] Query string parameters as a key:value pair object
  ///
  /// [headers] Additional request headers as a key:value pair object
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
  FutureApiResponse delete(String path,
          {Map<String, dynamic>? queryParams,
          Map<String, dynamic>? headers,
          Object? body,
          ResolveType resolveType = ResolveType.json}) =>
      FutureApiResponse._(fetcher.delete(path,
          body: body,
          resolveType: resolveType,
          headers: headers,
          query: queryParams));
}
