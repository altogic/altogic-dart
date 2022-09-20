part of altogic_dart;

/// Provides info about a user.
class User {
  /// Creates a instance of [User]
  User(this.id,
      {required this.mailOrPhone,
      required this.provider,
      required this.providerUserId,
      required this.lastLoginAt,
      required this.signUpAt,
      this.password,
      this.name,
      this.profilePicture});

  /// Creates a instance of [User] from [JsonMap].
  factory User.fromJson(Map<String, dynamic> json) => User(
        json['_id'] as String,
        provider: json['provider'] as String,
        providerUserId: json['providerUserId'] as String,
        mailOrPhone: (json['email'] as String?) ?? (json['phone'] as String),
        password: json['password'] as String?,
        profilePicture: json['profilePicture'] as String?,
        name: json['name'] as String?,
        lastLoginAt: json['lastLoginAt'] as String,
        signUpAt: json['signUpAt'] as String,
      );

  /// Convert instance to [JsonMap].
  Map<String, dynamic> toJson() => {
        '_id': id,
        'provider': provider,
        'providerUserId': providerUserId,
        'email': mailOrPhone,
        if (password != null) 'password': password,
        if (profilePicture != null) 'profilePicture': profilePicture,
        if (name != null) 'name': name,
        'lastLoginAt': lastLoginAt,
        'signUpAt': signUpAt
      };

  /// The unique identifier of the user
  String id;

  /// The authentication provider name, can be either Altogic, Google, Facebook,
  /// Twitter etc.
  String provider;

  /// The user id value that is retrieved from the provider after successful
  /// user authentication. The format of this field value can be different for
  /// each provider. If the provider is Altogic, providerUserId and _id values
  /// are the same.
  String providerUserId;

  /// Users email address
  String mailOrPhone;

  /// Users password, valid only if Altogic is used as the authentication
  /// provider.
  String? password;

  /// Users password, valid only if Altogic is used as the authentication
  /// provider. Should be at least 6 characters long.
  String? profilePicture;

  /// The name of the user
  String? name;

  /// The last login date and time of the user. For each successful sign-in,
  /// this field is updated in the database.
  String lastLoginAt;

  /// The sign up date and time of the user
  String signUpAt;
}

/// Keeps session information of a specific user
class Session {
  /// Creates a instance of [Session]
  Session(
      {required this.accessGroupKeys,
      required this.creationDtm,
      required this.token,
      required this.userAgent,
      required this.userId});

  /// Creates a instance of [Session] from [JsonMap].
  factory Session.fromJson(Map<String, dynamic> json) => Session(
      accessGroupKeys: (json['accessGroupKeys'] as List).cast<String>(),
      creationDtm: json['creationDtm'] as String,
      token: json['token'] as String,
      userAgent: UserAgent.fromJson(json['userAgent'] as Map<String, dynamic>),
      userId: json['userId'] as String);

  /// Convert instance to [JsonMap].
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'token': token,
        'creationDtm': creationDtm,
        'accessGroupKeys': accessGroupKeys,
        'userAgent': userAgent.toJson()
      };

  /// The id of the application end user this session is associated with
  String userId;

  /// Unique session token string
  String token;

  /// Creation date and time of the session token
  String creationDtm;

  /// Access group keys associated with this user session. With access groups
  /// you can assign roles to users and their sessions and enabled role based
  /// access control to your app endpoints
  List<String> accessGroupKeys;

  /// The user-agent (device) information of the user's session
  UserAgent userAgent;
}

/// The user-agent (device) information of the user's session.
class Agent {
  /// Creates a instance of [Agent]
  Agent(
      {required this.family,
      required this.major,
      required this.minor,
      required this.patch});

  /// Creates a instance of [Agent] from [JsonMap].
  Agent.fromJson(Map<String, dynamic> json)
      : family = json['family'] as String,
        major = json['major'] as String,
        minor = json['minor'] as String,
        patch = json['patch'] as String;

  /// Convert instance to [JsonMap].
  Map<String, dynamic> toJson() =>
      {'family': family, 'major': major, 'minor': minor, 'patch': patch};

  String family, major, minor, patch;
}

/// The user-agent (device) information of the user's session.
class UserAgent extends Agent {
  /// Creates a instance of [UserAgent]
  UserAgent(
      {required String family,
      required String major,
      required String minor,
      required String patch,
      required this.device,
      required this.os})
      : super(family: family, major: major, minor: minor, patch: patch);

  /// Creates a instance of [UserAgent] from [JsonMap].
  UserAgent.fromJson(Map<String, dynamic> json)
      : device = Agent.fromJson(json['device'] as Map<String, dynamic>),
        os = Agent.fromJson(json['os'] as Map<String, dynamic>),
        super.fromJson(json);

  /// Device and os information's
  Agent device, os;

  @override
  Map<String, dynamic> toJson() =>
      {...super.toJson(), 'device': device.toJson(), 'os': os.toJson()};
}

/// The options that can be passed to the Altogic client instance
class ClientOptions {
  /// Creates a instance of [ClientOptions]
  ClientOptions(
      {this.apiKey, this.localStorage, this.signInRedirect, this.realtime});

  /// The unique app environment API Key which needs to be created using the
  /// Altogic app designer. The [apiKey] is passed in *Authorization Header*
  /// when making RESTful API calls to your app endpoints. This key is different
  /// than the `clientKey` used when creating an instance of Altogic client
  /// library. `clientKey` is primarily used to manage access rigths of the
  /// client library whereas `apiKey` is used to manage access to your app
  /// endpoints.
  String? apiKey;

  /// Client storage handler to store user and session data. By default uses
  /// shared_preferences. If client is not a browser then you
  /// need to provide an object with setItem(String key,String data),
  /// getItem(String key) and removeItem(String key) methods to manage user and
  /// session data storage.
  ClientStorage? localStorage;

  /// The sign in page URL to redirect the user when user's session becomes
  /// invalid. Altogic client library observes the responses of the requests
  /// made to your app backend. If it detects a response with an error code of
  /// missing or invalid session token, it can redirect the users to
  /// this signin url.
  String? signInRedirect;

  /// The configuration parameters for websocket connections
  RealtimeOptions? realtime;

  ClientOptions _merge(ClientOptions? other) => ClientOptions(
      apiKey: other?.apiKey ?? apiKey,
      localStorage: other?.localStorage ?? localStorage,
      signInRedirect: other?.signInRedirect ?? signInRedirect,
      realtime: other?.realtime ?? realtime);
}

/// The options that can be passed to the client instance realtime module
class RealtimeOptions {
  /// The flag to enable or prevent automatic join to channels already
  /// subscribed in case of websocket reconnection. When websocket is
  /// disconnected, it automatically leaves subscribed channels.
  /// This parameter helps re-joining to already joined channels when
  /// the connection is restored.
  bool? autoJoinChannels;

  /// The flag to enable or prevent realtime messages originating from
  /// this connection being echoed back on the same connection.
  bool? echoMessages;

  /// The initial delay before realtime reconnection in milliseconds.
  /// @type {number}
  int? reconnectionDelay;

  /// The timeout in milliseconds for each realtime connection attempt.
  /// @type {number}
  int? timeout;

  /// By default, any event emitted while the realtime socket is not
  /// connected will be buffered until reconnection. You can turn
  /// on/off the message buffering using this parameter.
  bool? bufferMessages;
}

/// Client local storage handler definition.
///
/// This implementation needs to support mainly three methods, [getItem],
/// [setItem] and [removeItem].
abstract class ClientStorage {
  Future<String?> getItem(String key);

  Future<void> setItem(String key, String value);

  Future<void> removeItem(String key);
}

/// Provides information about the errors happened during execution of the
/// requests
class APIError implements Exception {
  /// Creates a instance of [APIError]
  APIError(
      {required this.status, required this.statusText, required this.items});

  /// Creates a instance of [APIError] from [JsonMap].
  factory APIError.fromJson(Map<String, dynamic> json) => APIError(
      status: json['status'] as int,
      statusText: json['statusText'] as String,
      items: (json['items'] as List)
          .map((e) => ErrorEntry.fromJson(e as Map<String, dynamic>))
          .toList());

  @override
  String toString() => 'Altogic API Error \n'
      'status: $status\n'
      'statusText: $statusText\n'
      'entries: ${items.join(",\n")}';

  ///  HTTP response code in the 100–599 range
  final int status;

  /// Status text as reported by the server, e.g. "Unauthorized"
  String statusText;

  /// Array of error entries that provide detailed information about the errors
  /// occured during excution of the request
  List<ErrorEntry> items;
}

/// Provides info about an error.
class ErrorEntry {
  /// Creates a instance of [ErrorEntry]
  ErrorEntry({this.origin, this.code, this.message, this.details});

  /// Creates a instance of [ErrorEntry] from [JsonMap].
  factory ErrorEntry.fromJson(Map<String, dynamic> json) {
    try {
      return ErrorEntry(
          origin: json['origin'] as String,
          code: json['code'] as String,
          message: json['message'] as String,
          details: json['details'] as Map<String, dynamic>?);
    } catch (e) {
      print('WARN: error entry is wrong'
          '\n$json\nError: $e');
      rethrow;
    }
  }

  @override
  String toString() => 'origin: $origin\n'
      'code: $code\n'
      'message: $message'
      '${details != null ? '\ndetails: $details' : ''}';

  /// Originator of the error either a client error or an internal server error
  String? origin;

  /// Specific short code of the error message (e.g., validation_error,
  /// content_type_error)
  String? code;

  /// Short description of the error
  String? message;

  /// Any additional details about the error. Details is a JSON object and can
  /// have a different structure for different error types.
  Map<String, dynamic>? details;
}

/// Provides info about the status of a message that is submitted to a queue.
class MessageInfo {
  /// Creates a instance of [MessageInfo]
  MessageInfo(
      {required this.messageId,
      required this.queueId,
      required this.queueName,
      required this.submittedAt,
      required this.completedAt,
      required this.startedAt,
      required this.status,
      required this.errors});

  /// Creates a instance of [MessageInfo] from [JsonMap].
  factory MessageInfo.fromJson(Map<String, dynamic> json) => MessageInfo(
      errors: json['errors'] as Map<String, dynamic>?,
      status: MessageStatus.values
          .where((element) => element.name == (json['status'] as String))
          .first,
      completedAt: json['completedAt'] as String?,
      messageId: json['messageId'] as String,
      queueId: json['queueId'] as String,
      queueName: json['queueName'] as String,
      startedAt: json['startedAt'] as String?,
      submittedAt: json['submittedAt'] as String);

  /// Convert instance to [JsonMap].
  Map<String, dynamic> toJson() => {
        'errors': errors,
        'status': status.name,
        'completedAt': completedAt,
        'messageId': messageId,
        'queueId': queueId,
        'queueName': queueName,
        'startedAt': startedAt,
        'submittedAt': submittedAt
      };

  /// The id of the message
  String messageId;

  /// The id of the queue this message is submitted to
  String queueId;

  /// The name of the queue this message is submitted to
  String queueName;

  /// The message submit date-time
  String submittedAt;

  /// The message processing start date-time
  String? startedAt;

  /// The message processing complete date-time
  String? completedAt;

  /// The status of the message. When the message is submitted to the queue, it
  /// is in `pending` status. When the message is being processed, its status
  /// changes to `processing`. If message is successfully completed its status
  /// becomes `complete`otherwiese it becomes `errors`.
  MessageStatus status;

  /// Provides information about the errors occurred during processing of the
  /// message
  dynamic errors;
}

/// Message Status
enum MessageStatus { pending, processing, completed, errors }

/// Provides info about the status of a task that is triggered for execution.
class TaskInfo {
  /// Creates a instance of [TaskInfo]
  TaskInfo(
      {required this.status,
      required this.startedAt,
      required this.completedAt,
      required this.errors,
      required this.scheduledTaskId,
      required this.scheduledTaskName,
      required this.taskId,
      required this.triggeredAt});

  /// Creates a instance of [TaskInfo] from [JsonMap].
  factory TaskInfo.fromJson(Map<String, dynamic> json) => TaskInfo(
        errors: json['errors'] as Map<String, dynamic>?,
        status: MessageStatus.values
            .firstWhere((element) => element.name == json['status']),
        startedAt: json['startedAt'] as String?,
        completedAt: json['completedAt'] as String?,
        scheduledTaskId: json['scheduledTaskId'] as String?,
        scheduledTaskName: json['scheduledTaskName'] as String,
        taskId: json['taskId'] as String,
        triggeredAt: json['triggeredAt'] as String,
      );

  /// Convert instance to [JsonMap].
  Map<String, dynamic> toJson() => {
        'errors': errors,
        'status': status.name,
        'startedAt': startedAt,
        'completedAt': completedAt,
        'scheduledTaskId': scheduledTaskId,
        'scheduledTaskName': scheduledTaskName,
        'taskId': taskId,
        'triggeredAt': triggeredAt
      };

  /// The id of the task
  String taskId;

  /// The id of the scheduled task that is triggered
  String? scheduledTaskId;

  /// The name of the scheduled task that is triggered
  String scheduledTaskName;

  /// The task trigger date-time
  String triggeredAt;

  /// The task execution start date-time
  String? startedAt;

  /// The task execution complete date-time
  String? completedAt;

  /// The status of the task. When the task is firts triggered, it is in
  /// `pending` status. When the task is being processed, its status changes to
  /// `processing`. If task is successfully completed its status becomes
  /// `complete`otherwiese it becomes `errors`.
  MessageStatus status;

  /// Provides information about the errors occurred during execution
  /// of the task
  Map<String, dynamic>? errors;
}

/// DB Operation options abstraction.
abstract class DbOperationOptions<T> {
  const DbOperationOptions();

  /// Merge Options.
  /// this is default, [other] is user defined.
  DbOperationOptions<T> merge(T? other);

  /// Convert to [JsonMap]
  Map<String, dynamic> toJson();
}

/// Defines the options for an object read operation
class GetOptions extends DbOperationOptions<GetOptions> {
  /// Creates a instance of [User]
  const GetOptions({required this.cache});

  /// Convert instance to [JsonMap].
  @override
  Map<String, dynamic> toJson() => {'cache': cache.cacheName};

  /// Specify whether to cache the retrieved object using its id as the cache
  /// key or not. If the object is cached and the timeout has expired, the
  /// cached object will automatically be removed from the cache.
  final Cache cache;

  @override
  GetOptions merge(GetOptions? other) =>
      GetOptions(cache: other?.cache ?? cache);
}

enum Cache {
  /// No cache
  nocache('nocache'),

  /// No expiry date
  noexpiry('noexpiry'),

  /// 30 seconds
  sec30('30sec'),

  /// A minute
  min1('1min'),

  /// 2 Minutes
  min2('2mins'),

  /// 5 Minutes
  min5('5mins'),

  /// 10 Minutes
  min10('10mins'),

  /// 15 Minutes
  min15('15mins'),

  /// 30 Minutes
  min30('30mins'),

  /// A hour
  hour1('1hour'),

  /// 6 hours
  hours6('6hours'),

  /// 12 hours
  hours12('12hours'),

  /// A day
  day1('1day'),

  /// A week
  week1('1week'),

  /// A month
  month1('1month'),

  /// 6 months
  month6('6month'),

  /// A year
  year1('1year');

  const Cache(this.cacheName);

  /// Cache name for server
  final String cacheName;
}

///
abstract class Lookup {
  /// Lookup abstraction.
  Map<String, dynamic> toJson();
}

/// Defines the structure of a simple lookup
class SimpleLookup extends Lookup {
  SimpleLookup({required this.field});

  @override
  Map<String, dynamic> toJson() => {
        'field': field,
      };

  /// The name of the object reference field of the model that will be looked
  /// up. Only the immediate fields of the model can be used in simple lookups.
  /// If you would like to look up for a sub-object field then you need to use
  /// that respective sub-model as the reference point of your lookups.
  /// The simple lookup basically runs the following query:
  /// `this.field == lookup._id`, meaning joins the looked up model with the
  /// current one by matching the value of the field with the _id of
  /// the looked up model.
  String field;
}

/// Defines the structure of a complex lookup
class ComplexLookup extends Lookup {
  ComplexLookup(
      {required this.name, required this.modelName, required this.query});

  @override
  Map<String, dynamic> toJson() =>
      {'name': name, 'modelName': modelName, 'query': query};

  /// The name of the lookup. This will become a field of the retrieved object
  /// which will hold the looked up value. The specified name needs to be
  /// **unique** among the fields of the model.
  String name;

  /// The name of the target model which will be joined with the current model
  String modelName;

  /// The query expression that will be used in joining the models
  String query;
}

/// Defines the options for an object create operation
class CreateOptions extends DbOperationOptions<CreateOptions> {
  const CreateOptions({required this.cache});

  @override
  Map<String, dynamic> toJson() => {'cache': cache.cacheName};

  /// Specify whether to cache the created object using its id as the cache key
  /// or not. If the object is cached and the timeout has expired, the cached
  /// object will automatically be removed from the cache.
  final Cache cache;

  @override
  CreateOptions merge(CreateOptions? other) =>
      CreateOptions(cache: other?.cache ?? cache);
}

/// Defines the options for an object set operation
class SetOptions extends DbOperationOptions<SetOptions> {
  const SetOptions({required this.cache, required this.returnTop});

  @override
  Map<String, dynamic> toJson() =>
      {'cache': cache.cacheName, 'returnTop': returnTop};

  /// Specify whether to cache the set object using its id as the cache key or
  /// not. If the object is cached and the timeout has expired, the cached
  /// object will automatically be removed from the cache.
  final Cache cache;

  /// When you create a submodel object (a child object of a top-level object),
  /// you can specify whether to return the newly created child object or the
  /// updated top-level object.
  final bool returnTop;

  @override
  SetOptions merge(SetOptions? other) => SetOptions(
      cache: other?.cache ?? cache, returnTop: other?.returnTop ?? returnTop);
}

/// Defines the options for an object append operation
class AppendOptions extends DbOperationOptions<AppendOptions> {
  const AppendOptions({required this.returnTop, required this.cache});

  @override
  Map<String, dynamic> toJson() =>
      {'cache': cache.cacheName, 'returnTop': returnTop};

  /// Specify whether to cache the appended object using its id as the cache
  /// key or not. If the object is cached and the timeout has expired, the
  /// cached object will automatically be removed from the cache.
  final Cache cache;

  /// When you create a submodel object (a child object of a top-level object),
  /// you can specify whether to return the newly created child object or the
  /// updated top-level object.
  final bool returnTop;

  @override
  AppendOptions merge(AppendOptions? other) => AppendOptions(
      cache: other?.cache ?? cache, returnTop: other?.returnTop ?? returnTop);
}

/// Defines the options for an object delete operation
class DeleteOptions extends DbOperationOptions<DeleteOptions> {
  const DeleteOptions({required this.returnTop, required this.removeFromCache});

  @override
  Map<String, dynamic> toJson() =>
      {'removeFromCache': removeFromCache, 'returnTop': returnTop};

  @override
  DeleteOptions merge(DeleteOptions? other) => DeleteOptions(
      returnTop: other?.returnTop ?? returnTop,
      removeFromCache: other?.removeFromCache ?? removeFromCache);

  /// Specify whether to remove deleted object from cache using deleted object
  /// id as the cache key.
  final bool removeFromCache;

  /// In case if you delete a submodel object (a child object of a top-level
  /// object), you can specify whether to return the updated top-level object.
  final bool returnTop;
}

/// Defines the options for an object update operation
class UpdateOptions extends DbOperationOptions<UpdateOptions> {
  const UpdateOptions({required this.cache, required this.returnTop});

  @override
  Map<String, dynamic> toJson() =>
      {'cache': cache.cacheName, 'returnTop': returnTop};

  @override
  UpdateOptions merge(UpdateOptions? other) => UpdateOptions(
      cache: other?.cache ?? cache, returnTop: other?.returnTop ?? returnTop);

  /// Specify whether to cache the updated object using its id as the cache key
  /// or not. If the object is cached and the timeout has expired, the cached
  /// object will automatically be removed from the cache.
  final Cache cache;

  /// In case if you update a submodel object (a child object of a top-level
  /// object), you can specify whether to return the newly updated child object
  /// or the updated top-level object.
  final bool returnTop;
}

/// Defines the structure of a db action that is built by a [QueryBuilder]
class DBAction {
  DBAction();

  Map<String, dynamic> toJson() => {
        'expression': expression,
        'lookups': lookups?.map((e) => e.toJson()).toList(),
        'page': page,
        'limit': limit,
        'sort': sort?.map((e) => e.toJson()).toList(),
        'omit': omit,
        'group': group
      };

  /// The filter query expression string
  String? expression;

  /// The list of lookups to make (left outer join) while getting the object
  List<Lookup>? lookups;

  /// A positive integer that specifies the page number to paginate query
  /// results. Page numbers start from 1.
  int? page;

  /// A positive integer that specifies the max number of objects to return
  /// per page
  int? limit;

  /// Keeps the list of field names and sort direction for sorting returned
  /// objects
  List<SortEntry>? sort;

  /// The list of fields that will be omitted in retrieved objects
  List<String>? omit;

  /// The grouping definition of the query builder. If you want to group the
  /// query results by values of specific fields, then provide the name of the
  /// fields in a string array format e.g., ['field1', 'field2.subField', ...]
  ///
  /// If you prefer to group the query results by an expression then just
  /// provide the expression string.
  ///
  /// [group] can be String or List<String> or null.
  dynamic group;
}

/// Defines the structure of sort entry
class SortEntry {
  SortEntry(this.field, this.direction);

  Map<String, dynamic> toJson() =>
      {'field': field, 'direction': direction.name};

  /// The name of the field that will be used in sorting the returned objects.
  /// The field name can be in dot-notation to specify sub-object fields
  /// (e.g., field.subField)
  String field;

  /// Sort direction
  Direction direction;
}

enum Direction { asc, desc }

/// Defines the structure of a field update
class FieldUpdate {
  FieldUpdate(
      {required this.field, required this.updateType, required this.value});

  Map<String, dynamic> toJson() =>
      {'field': field, 'updateType': updateType.name, 'value': value};

  /// The name of the field whose value will be updated. The field name can be
  /// in dot-notation to specify sub-object fields (e.g., field.subField).
  /// Please note that only sub-model object fields can be accessed through
  /// the dot-notation. You cannot create an update instruction for an
  /// object-list field through the dot-notation.
  String field;

  /// Defines how the field will be updated.
  UpdateType updateType;

  /// The value that will be used during the field update. Depending on
  /// the update type the value will have different meaning.
  /// - **set:** The new value to set
  /// - **unset:** Not applicable, value is not needed
  /// - **increment:** The icrement amount
  /// - **decrement:** The decrement amount
  /// - **min:** The min amount to compare against current field value
  /// - **max:** The max amount to compare against current field value
  /// - **multiply:** The multiplication amount
  /// - **pull:** Basic value list item to remove
  /// - **push:** Basic value list item to add
  /// - **pop:** Not applicable, value is not needed
  /// - **shift:** Not applicable, value is not needed
  dynamic value;
}

/// Defines how the field will be updated.
enum UpdateType {
  /// Sets (overwrites) the value of a field. Applicable on all  fields, except
  /// system managed `_id`, `_parent`, `createdAt`, `updatedAt` fields.
  set,

  /// Clears the value of a field. Applicable on all fields, except system
  /// managed `_id`, `_parent`, `createdAt`, `updatedAt` fields.
  unset,

  /// Increments the value of a numeric field by the specified amount.
  /// Applicable only for integer and decimal fields.
  increment,

  /// Decrements the value of a numeric field by the specified amount.
  /// Applicable only for integer and decimal fields.
  decrement,

  /// Assigns the minimum of the specified value or the field value. If the
  /// specified value is less than the current field value, sets the field value
  /// to the specificied value, otherwise does not make any changes. Applicable
  /// only for integer and decimal fields.
  min,

  /// Assigns the maximum of the specified value or the field value. If the
  /// specified value is greater than the current field value, sets the field
  /// value to the specificied value, otherwise does not make any changes.
  /// Applicable only for integer and decimal fields.
  max,

  /// Multiplies the current value of the field with the specified amount and
  /// sets the field value to teh multiplication result. Applicable only for
  /// integer and decimal fields.
  multiply,

  /// Removes the specified value from a basic values list. Applicable only for
  /// basic values list fields.
  pull,

  /// Adds the specified value to a basic values list. Applicable only for
  /// basic values list fields.
  push,

  /// Removes the last element from a basic values list. Applicable only for
  /// basic values list fields.
  pop,

  /// Removes the first element from a basic values list. Applicable only for
  /// basic values list fields.
  shift
}

/// Defines the structure of the response of a multi-object update operation
/// in the database
class UpdateInfo {
  UpdateInfo({required this.totalMatch, required this.updated});

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
      totalMatch: json['totalMatch'] as int, updated: json['updated'] as int);

  /// Total number of objects that matched to the filter query
  int totalMatch;

  /// Number of objects updated
  int updated;
}

/// Defines the structure of the response of a multi-object delete operation
/// in the database
class DeleteInfo {
  DeleteInfo({required this.totalMatch, required this.deleted});

  factory DeleteInfo.fromJson(Map<String, dynamic> json) => DeleteInfo(
      totalMatch: json['totalMatch'] as int, deleted: json['deleted'] as int);

  Map<String, dynamic> toJson() =>
      {'totalMatch': totalMatch, 'deleted': deleted};

  /// Total number of objects that matched to the filter query
  int totalMatch;

  /// Number of objects deleted
  int deleted;
}

/// Defines the structure of grouped object computations. Basically, it provides
/// aggregate calculation instructions to [QueryBuilder.compute] method
abstract class GroupComputation {
  GroupComputation(
      {required this.name,
      required this.type,
      required this.expression,
      this.sort});

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.name,
        'expression': expression,
        'sort': sort?.name ?? 'none'
      };

  /// The name of the computation which will be reported in the result of
  /// [QueryBuilder.compute] method execution. If you are defining more
  /// than one group computation, then their names need to be unique.
  String name;

  ///  Defines the type of the computation
  /// - **count:** Counts the number of objects in each group
  ///
  /// - **countif:** Counts the number of objects in each group based on the
  /// result of the specified expression. If the expression evaluates to true
  /// then they are counted otherwise not.
  ///
  /// - **sum:** Sums the evaluated expression values for each group member.
  /// The expression needs to return an integer or decimal value.
  ///
  /// - **avg:** Averages the evaluated expression values for the overall group.
  /// The expression needs to return an integer or decimal value.
  ///
  /// - **min:** Calculates the minimum value of the evaluated expression for
  /// the overall group. The expression needs to return an integer or decimal
  /// value.
  ///
  /// - **max:** Calculates the maximum value of the evaluated expression for
  /// the overall group. The expression needs to return an integer or decimal
  /// value.
  GroupComputationType type;

  /// The computation expression string. Except **count**, expression string is
  /// required for all other computation types.
  String expression;

  ///  Defines the sort direction of computed field. If sort direction is
  ///  specified as either `asc` or `desc`, computed groups will be sorted
  ///  accordingly.
  ///
  ///  If [sort] is null not sorted.
  Direction? sort;
}

enum GroupComputationType { count, sum }

/// Defines the structure how to get app buckets
abstract class BucketListOptions {
  BucketListOptions(
      {required this.returnCountInfo, this.sort, this.limit, this.page});

  Map<String, dynamic> toJson() => {
        'page': page,
        'limit': limit,
        'sort': sort?.toJson(),
        'returnCountInfo': returnCountInfo
      };

  /// A positive integer that specifies the page number to paginate bucket
  /// results. Page numbers start from 1.
  int? page;

  /// A positive integer that specifies the max number of buckets to return
  /// per page
  int? limit;

  /// Specifies the field name and sort direction for sorting returned buckets
  BucketSortEntry? sort;

  /// Flag to specify whether to return the count and pagination information
  /// such as total number of buckets, page number and page size
  bool returnCountInfo;
}

/// Defines the structure of a bucket sort entry
class BucketSortEntry {
  BucketSortEntry({required this.field, required this.direction});

  Map<String, dynamic> toJson() =>
      {'field': field.name, 'direction': direction.name};

  /// The name of the bucket field that will be used in sorting the returned
  /// objects
  BucketSortField field;

  /// Sort direction
  Direction direction;
}

//TODO
enum BucketSortField { name, isPublic }

/// Defines the structure how to get the files of a bucket
class FileListOptions {
  FileListOptions(
      {required this.returnCountInfo, this.page, this.limit, this.sort});

  Map<String, dynamic> toJson() => {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        'returnCountInfo': returnCountInfo,
        if (sort != null) 'sort': sort?.toJson(),
      };

  /// A positive integer that specifies the page number to paginate file
  /// results. Page numbers start from 1.
  int? page;

  /// A positive integer that specifies the max number of files to return per
  /// page
  int? limit;

  /// Specifies the field name and sort direction for sorting returned files
  FileSort? sort;

  /// Flag to specify whether to return the count and pagination information
  /// such as total number of files, page number and page size
  bool returnCountInfo;
}

/// Defines the structure of a file sort entry
class FileSort {
  FileSort({required this.field, required this.direction});

  Map<String, dynamic> toJson() =>
      {'field': field.name, 'direction': direction.name};

  /// The name of the file field that will be used in sorting the returned
  /// objects
  FileSortField field;

  /// Sort direction
  Direction direction;
}

enum FileSortField {
  bucketId,
  fileName,
  size,
  encoding,
  mimeType,
  isPublic,
  publicPath,
  uploadedAt,
  updatedAt,
  userId,
  tags
}

/// [uploaded] Total bytes uploaded
/// [total] Total size of file in bytes
/// [percentComplete] Percent uploaded (an integer between 0-100), basically
/// `uploaded/total` rounded to the nearest integer
typedef OnUploadProgress = void Function(
    int total, int uploaded, double percentComplete);

/// Defines the options available that can be set during file upload
class FileUploadOptions extends DbOperationOptions<FileUploadOptions> {
  const FileUploadOptions(
      {this.contentType,
      this.createBucket,
      this.isPublic,
      this.onProgress,
      this.tags});

  /// The `Content-Type` header value. This value needs to be specified if
  /// using a `fileBody` that is neither `Blob` nor `File` nor `FormData`,
  /// otherwise will default to `text/plain;charset=UTF-8`.
  final String? contentType;

  /// Specifies whether file is publicy accessible or not. Defaults to the
  /// bucket's privacy setting if not specified.
  final bool? isPublic;

  /// Specifies whether to create the bucket while uploading the file. If a
  /// bucket with the provided name does not exists and if `createBucket` is
  /// marked as true then creates a new bucket. Defaults to false.
  final bool? createBucket;

  /// Array of string values that will be added to the file metadata.
  final List<String>? tags;

  /// Callback function to call during file upload.
  ///
  /// Look [OnUploadProgress] documentation for more details.
  final OnUploadProgress? onProgress;

  @override
  Map<String, dynamic> toJson() => {
        'createBucket': createBucket,
        'contentType': contentType,
        'isPublic': isPublic,
        'tags': tags
      };

  @override
  FileUploadOptions merge(FileUploadOptions? other) => FileUploadOptions(
      createBucket: other?.createBucket ?? createBucket,
      contentType: other?.contentType ?? contentType,
      onProgress: other?.onProgress ?? onProgress,
      isPublic: other?.isPublic ?? isPublic,
      tags: other?.tags ?? tags);
}

//ignore_for_file: constant_identifier_names

/// Http Method
enum Method { GET, POST, PUT, DELETE }

enum ResolveType { json, text, blob, arraybuffer }

/// Defines the structure of the channel member data.
class MemberData {
  MemberData({required this.id, this.data});

  factory MemberData.fromJson(Map<String, dynamic> map) =>
      MemberData(id: map['id'] as String, data: map['data']);

  /// The unique socket id of the channel member
  String id;

  /// Data payload for the channel member. The supported payload types are
  /// strings, JSON objects and arrays, buffers containing arbitrary binary
  /// data, and null. This data is typically set calling the
  /// [RealtimeManager.updateProfile] method.
  dynamic data;
}
