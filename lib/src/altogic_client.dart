part of altogic_dart;

ClientOptions _defaultOptions = ClientOptions();

class AltogicClient {
  AltogicClient(
      {required String envUrl,
      required String clientKey,
      ClientOptions? settings}) {
    if (!(envUrl.trim().startsWith('http://') ||
        envUrl.trim().startsWith('https://'))) {
      throw ClientError('missing_required_value',
          'envUrl is a required parameter and needs to start with https://');
    }
    this.settings = _defaultOptions._merge(settings);

    // Set the default headers
    var headers = <String, String>{
      'X-Client': 'altogic-js',
      'X-Client-Key': clientKey,
    };

    // If apiKey is provided, add it to the default headers
    if (this.settings.apiKey != null) {
      headers['Authorization'] = this.settings.apiKey!;
    }
    // Create the http client to manage RESTful API calls
    fetcher = Fetcher(this, normalizeUrl(envUrl), headers);
  }

  Future<void> restoreLocalAuthSession() async {
    var session = await auth.getSession();
    if (session != null) {
      fetcher.setSession(session);
    }
  }

  late Fetcher fetcher;

  late final ClientOptions settings;

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
