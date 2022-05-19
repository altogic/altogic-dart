part of altogic_dart;

ClientOptions _defaultOptions = ClientOptions();

class AltogicClient {
  AltogicClient._();

  static final AltogicClient _instance = AltogicClient._();

  factory AltogicClient() => _instance;

  bool _initialized = false;

  Future<void>? _initializer;

  static Future<AltogicClient> init(
      {required String envUrl,
      required String clientKey,
      ClientOptions? settings}) async {
    _instance._initializer ??=
        _setClient(envUrl: envUrl, clientKey: clientKey, settings: settings);
    await _instance._initializer;
    return _instance;
  }

  static Future<void> _setClient(
      {required String envUrl,
      required String clientKey,
      ClientOptions? settings}) async {
    if (_instance._initialized) return;
    if (!(envUrl.trim().startsWith('http://') ||
        envUrl.trim().startsWith('https://'))) {
      throw ClientError('missing_required_value',
          'envUrl is a required parameter and needs to start with https://');
    }
    _instance.settings = _defaultOptions._merge(settings);

    // Set the default headers
    var headers = <String, String>{
      'X-Client': 'altogic-js',
      'X-Client-Key': clientKey,
    };

    // If apiKey is provided, add it to the default headers
    if (_instance.settings.apiKey != null) {
      headers['Authorization'] = _instance.settings.apiKey!;
    }
    // Create the http client to manage RESTful API calls
    _instance.fetcher = Fetcher(_instance, normalizeUrl(envUrl), headers);
    _instance._initialized = true;

    var session = await _instance.auth.getSession();
    if (session != null) {
      _instance.fetcher.setSession(session);
    }
  }

  late Fetcher fetcher;

  late ClientOptions settings;

  AuthManager? _authManager;

  EndpointManager? _endpointManager;

  CacheManager? _cacheManager;

  QueueManager? _queueManager;

  TaskManager? _taskManager;

  DatabaseManager? _databaseManager;

  StorageManager? _storageManager;

  AuthManager get auth => _authManager ?? AuthManager(fetcher, settings);

  EndpointManager get endpoint => _endpointManager ?? EndpointManager(fetcher);

  CacheManager get cache => _cacheManager ?? CacheManager(fetcher);

  QueueManager get queue => _queueManager ?? QueueManager(fetcher);

  TaskManager get task => _taskManager ?? TaskManager(fetcher);

  DatabaseManager get db => _databaseManager ?? DatabaseManager(fetcher);

  StorageManager get storage => _storageManager ?? StorageManager(fetcher);
}
