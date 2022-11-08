part of altogic_dart;

/// The cache manager provides simple key-value storage at a high-speed
/// data storage layer (Redis) speeding up data set and get operations.
///
/// The values stored can be a single JSON object, an array of objects or
/// primitive values (e.g., numbers, text, boolean). Values can be stored with
/// an optional time-to-live (TTL) to automatically expire entries.
///
/// You can directly store primitive values such as integers, strings, etc.,
/// however, when you try to get them Altogic returns them wrapped in a simple
/// object with a key named `value`. As an example if you store a text field
/// "Hello world!" at a key named 'welcome', when you try to get the value of
/// this key using the [get] method, you will receive the following
/// response: { value: "Hello world"}.
class CacheManager extends APIBase {
  /// Creates an instance of CacheManager to make caching requests to your
  /// backend app.
  /// @param {Fetcher} fetcher The http client to make RESTful API calls to
  /// the application's execution engine
  CacheManager(super.fetcher);

  /// Gets an item from the cache by key. If key is not found, then `null`
  /// is returned as data.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [key] The key to retrieve
  FutureApiResponse get(String key) => FutureApiResponse._(_fetcher
      .get<Map<String, dynamic>>('/_api/rest/v1/cache?key=$key')
      .then((value) =>
          APIResponse(errors: value.errors, data: value.data?['value'])));

  /// Sets an item in the cache. Overwrites any existing value already set.
  /// If **ttl** specified, sets the stored entry to automatically expire
  /// in specified seconds. Any previous time to live associated with the
  /// key is discarded on successful set operation.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [key] The key to update
  ///
  /// [value] The value to set
  ///
  /// [ttl] Time to live in seconds
  Future<APIError?> set(String key, Object value, [int? ttl]) async =>
      (await _fetcher.post<dynamic>('/_api/rest/v1/cache',
              body: {'key': key, 'value': value, if (ttl != null) 'ttl': ttl}))
          .errors;

  /// Removes the specified key(s) from the cache. Irrespective of whether
  /// the key is found or not, success response is returned.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [keys] A single string key or an array of keys (string)
  /// to delete
  Future<APIError?> delete(dynamic keys) async {
    if (!(keys is String || keys is List<String>)) {
      throw Exception('[keys] must be string or List<String>');
    }

    return (await _fetcher.delete<dynamic>('/_api/rest/v1/cache', body: {
      'keys': keys is List ? keys : [keys.toString()],
    }))
        .errors;
  }

  /// Increments the value of the number stored at the key by the increment
  /// amount. If increment amount not specified, increments the number stored
  /// at key by one. If the key does not exist, it is set to 0 before
  /// performing the operation. If **ttl** specified, sets the stored entry
  /// to automatically expire in specified seconds. Any previous time to live
  /// associated with the key is discarded on successful increment operation.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [key] The key to increment
  ///
  /// [increment] The amount to increment the value by. Default 1.
  ///
  /// [ttl] Time to live in seconds
  ///
  /// Returns the value of key after the increment
  Future<APIResponse<Map<String, dynamic>>> increment(String key,
          {int increment = 1, int? ttl}) =>
      _fetcher.post<Map<String, dynamic>>('/_api/rest/v1/cache/increment',
          body: {
            'key': key,
            'increment': increment,
            if (ttl != null) 'ttl': ttl
          });

  /// Decrements the value of the number stored at the key by the decrement
  /// amount. If decrement amount not specified, decrements the number stored
  /// at key by one. If the key does not exist, it is set to 0 before
  /// performing the operation. If **ttl** specified, sets the stored entry
  /// to automatically expire in specified seconds. Any previous time to live
  /// associated with the key is discarded on successful decrement operation.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [key] The key to decrement
  ///
  /// [decrement] The amount to decrement the value by. Default 1
  ///
  /// [ttl] Time to live in seconds
  ///
  /// Returns the value of key after the decrement
  Future<APIResponse<Map<String, dynamic>>> decrement(String key,
          {int decrement = 1, int? ttl}) =>
      _fetcher.post<Map<String, dynamic>>('/_api/rest/v1/cache/decrement',
          body: {
            'key': key,
            'decrement': decrement,
            if (ttl != null) 'ttl': ttl
          });

  /// Sets a timeout on key. After the timeout has expired, the key will
  /// automatically be deleted.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [key] The key to set its expiry duration
  ///
  /// [ttl] Time to live in seconds
  Future<APIError?> expire(String key, int ttl) async =>
      (await _fetcher.post<dynamic>('/_api/rest/v1/cache/expire',
              body: {'key': key, 'ttl': ttl}))
          .errors;

  /// Returns the overall information about your apps cache including total
  /// number of keys and total storage size (bytes), daily and monthly ingress
  /// and egress volumes (bytes).
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// Returns information about your app's cache storage
  Future<APIResponse<Map<String, dynamic>>> getStats() =>
      _fetcher.get<Map<String, dynamic>>('/_api/rest/v1/cache/stats');

  //ignore_for_file:comment_references

  /// Gets the list of keys in your app cache storage. If `pattern` is
  /// specified, it runs the pattern match to narrow down returned results,
  /// otherwise, returns all keys contained in your app's cache storage.
  /// See below examples how to specify filtering pattern:
  ///
  /// - h?llo matches hello, hallo and hxllo
  /// - h*llo matches hllo and heeeello
  /// - h[ae]llo matches hello and hallo, but not hillo
  /// - h[^e]llo matches hallo, hbllo, ... but not hello
  /// - h[a-b]llo matches hallo and hbllo
  ///
  /// You can paginate through your cache keys using the `next` cursor.
  /// In your first call to `listKeys`, specify the `next` value as null.
  /// This will start pagination of your cache keys. In the return result of
  /// the method you can get the list of keys matching your pattern and also
  /// the `next` value that you can use in your next call to `listKeys` method
  /// to move to the next page. If the returned `next` value is null this means
  /// that you have paginated all your keys and there is no additional keys
  /// to paginate.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call this
  /// method.*
  ///
  /// [pattern] The pattern string that will be used to filter
  /// cache keys
  ///
  /// [next] The next page position cursor to paginate to the
  /// next page. If set as `null`, starts the pagination from
  /// the beginning.
  ///
  /// Returns the array of matching keys, their values and the next
  /// cursor if there are remaining items to paginate.
  Future<KeyListResult> listKeys(String? pattern, String? next) async {
    var res = await _fetcher.post<Map<String, dynamic>>(
        '/_api/rest/v1/cache/list-keys',
        body: {'pattern': pattern, 'next': next});

    if (res.errors != null) {
      return KeyListResult(errors: res.errors);
    } else {
      return KeyListResult(
          data: ((res.data!)['data'] as List)
              .cast<Map<dynamic, dynamic>>()
              .map((e) => e.cast<String, dynamic>())
              .toList(),
          next: (res.data!)['next'] as String?);
    }
  }
}
