part of altogic_dart;

// ///
// typedef Map<String,dynamic> = Map<String, dynamic>;

/// Provides info about a user.
/// @export
/// @interface User
class User {
  User(this._id,
      {required this.email,
      required this.provider,
      required this.providerUserId,
      required this.lastLoginAt,
      required this.signUpAt,
      this.password,
      this.name,
      this.profilePicture});

  factory User.fromJson(Map<String, dynamic> json) => User(
        json['_id'] as String,
        provider: json['provider'] as String,
        providerUserId: json['providerUserId'] as String,
        email: json['email'] as String,
        password: json['password'] as String?,
        profilePicture: json['profilePicture'] as String?,
        name: json['name'] as String?,
        lastLoginAt: json['lastLoginAt'] as String,
        signUpAt: json['signUpAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        '_id': _id,
        'provider': provider,
        'providerUserId': providerUserId,
        'email': email,
        if (password != null) 'password': password,
        if (profilePicture != null) 'profilePicture': profilePicture,
        if (name != null) 'name': name,
        'lastLoginAt': lastLoginAt,
        'signUpAt': signUpAt
      };

  /// The unique identifier of the user
  /// @type {string}
  final String _id;

  /// The authentication provider name, can be either Altogic, Google, Faceboo,
  /// Twitter etc.
  /// @type {string}
  String provider;

  /// The user id value that is retrieved from the provider after successful
  /// user authentication. The format of this field value can be different for
  /// each provider. If the provider is Altogic, providerUserId and _id values
  /// are the same.
  /// @type {string}
  String providerUserId;

  /// Users email address
  /// @type {string}
  String email;

  /// Users password, valid only if Altogic is used as the authentication
  /// provider.
  /// @type {string}
  String? password;

  /// Users password, valid only if Altogic is used as the authentication
  /// provider. Should be at least 6 characters long.
  /// @type {string}
  String? profilePicture;

  /// The name of the user
  /// @type {string}
  String? name;

  /// The last login date and time of the user. For each successful sign-in,
  /// this field is updated in the database.
  /// @type {string}
  String lastLoginAt;

  /// The sign up date and time of the user
  /// @type {string}
  String signUpAt;
}

enum Provider { google, facebook, twitter, discord, github }

/// Keeps session information of a specific user
/// @export
/// @interface Session
class Session {
  Session(
      {required this.accessGroupKeys,
      required this.creationDtm,
      required this.token,
      required this.userAgent,
      required this.userId});

  factory Session.fromJson(Map<String, dynamic> json) => Session(
      accessGroupKeys: (json['accessGroupKeys'] as List).cast<String>(),
      creationDtm: json['creationDtm'] as String,
      token: json['token'] as String,
      userAgent: UserAgent.fromJson(json['userAgent'] as Map<String, dynamic>),
      userId: json['userId'] as String);

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'token': token,
        'creationDtm': creationDtm,
        'accessGroupKeys': accessGroupKeys,
        'userAgent': userAgent.toJson()
      };

  /// The id of the application end user this session is associated with
  /// @type {string}
  String userId;

  /// Unique session token string
  /// @type {string}
  String token;

  /// Creation date and time of the session token
  /// @type {string}
  String creationDtm;

  /// Access group keys associated with this user session. With access groups
  /// you can assign roles to users and their sessions and enabled role based
  /// access control to your app endpoints
  /// @type {string[]}
  List<String> accessGroupKeys;

  /// The user-agent (device) information of the user's session
  /// @type {object}
  UserAgent userAgent;
}

class Agent {
  Agent(
      {required this.family,
      required this.major,
      required this.minor,
      required this.patch});

  Agent.fromJson(Map<String, dynamic> json)
      : family = json['family'] as String,
        major = json['major'] as String,
        minor = json['minor'] as String,
        patch = json['patch'] as String;

  Map<String, dynamic> toJson() =>
      {'family': family, 'major': major, 'minor': minor, 'patch': patch};

  String family, major, minor, patch;
}

class UserAgent extends Agent {
  UserAgent(
      {required String family,
      required String major,
      required String minor,
      required String patch,
      required this.device,
      required this.os})
      : super(family: family, major: major, minor: minor, patch: patch);

  UserAgent.fromJson(Map<String, dynamic> json)
      : device = Agent.fromJson(json['device'] as Map<String, dynamic>),
        os = Agent.fromJson(json['os'] as Map<String, dynamic>),
        super.fromJson(json);

  Agent device, os;

  @override
  Map<String, dynamic> toJson() =>
      {...super.toJson(), 'device': device.toJson(), 'os': os.toJson()};
}

/// The options that can be passed to the Altogic client instance
///
/// @export
/// @interface ClientOptions
class ClientOptions {
  ClientOptions({this.apiKey, this.localStorage, this.signInRedirect});

  /// The unique app environment API Key which needs to be created using the
  /// Altogic app designer. The `apiKey`is passed in *Authorization Header*
  /// when making RESTful API calls to your app endpoints. This key is different
  /// than the `clientKey` used when creating an instance of Altogic client
  /// library. `clientKey` is primarily used to manage access rigths of the
  /// client library whereas `apiKey` is used to manage access to your app
  /// endpoints.
  /// @type {string}
  String? apiKey;

  /// Client storage handler to store user and session data. By default uses
  /// Window.localStorage of the browser. If client is not a browser then you
  /// need to provide an object with setItem(key:string, data:object),
  /// getItem(key:string) and removeItem(key:string) methods to manage user
  /// and session data storage.
  /// @type Storage
  ClientStorage? localStorage;

  /// The sign in page URL to redirect the user when user's session becomes
  /// invalid. Altogic client library observes the responses of the requests
  /// made to your app backend. If it detects a response with an error code of
  /// missing or invalid session token, it can redirect the users to
  /// this signin url.
  /// @type {string}
  String? signInRedirect;

  ClientOptions _merge(ClientOptions? other) => ClientOptions(
      apiKey: other?.apiKey ?? apiKey,
      localStorage: other?.localStorage ?? localStorage,
      signInRedirect: other?.signInRedirect ?? signInRedirect);
}

/// Client lcoal storage handler definition. By default Atlogic client library
/// uses Window.localStorage of the browser.
///
/// If you prefer to use a different storage handler besides Window.localStorage
/// or if you are using the Altogic client library at the server (not browser)
/// then you need to provide your storage implementation.
/// This implementation needs to support mainly three methods, getItem, setItem
/// and removeItem
///
/// @interface ClientStorage
abstract class ClientStorage {
  Future<String?> getItem(String key);

  Future<void> setItem(String key, String value);

  Future<void> removeItem(String key);
}

/// Provides information about the errors happened during execution of the
/// requests
/// @export
/// @interface APIError
class APIError implements Exception {
  APIError(
      {required this.status, required this.statusText, required this.items});

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
  /// @type {number}
  int status;

  /// Status text as reported by the server, e.g. "Unauthorized"
  /// @type {string}
  String statusText;

  /// Array of error entries that provide detailed information about the errors
  /// occured during excution of the request
  /// @type {ErrorEntry[]}
  List<ErrorEntry> items;
}

/// Provides info about an error.
/// @export
/// @interface ErrorEntry
class ErrorEntry {
  ErrorEntry({this.origin, this.code, this.message, this.details});

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
  /// @type {string}
  String? origin;

  /// Specific short code of the error message (e.g., validation_error,
  /// content_type_error)
  /// @type {string}
  String? code;

  /// Short description of the error
  /// @type {string}
  String? message;

  /// Any additional details about the error. Details is a JSON object and can
  /// have a different structure for different error types.
  /// @type {object}
  Map<String, dynamic>? details;
}

/// Provides info about the status of a message that is submitted to a queue.
/// @export
/// @interface MessageInfo
class MessageInfo {
  MessageInfo(
      {required this.messageId,
      required this.queueId,
      required this.queueName,
      required this.submittedAt,
      required this.completedAt,
      required this.startedAt,
      required this.status,
      required this.errors});

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

  ///
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
  /// @type {string}
  String messageId;

  /// The id of the queue this message is submitted to
  /// @type {string}
  String queueId;

  /// The name of the queue this message is submitted to
  /// @type {string}
  String queueName;

  /// The message submit date-time
  /// @type {string}
  String submittedAt;

  /// The message processing start date-time
  /// @type {string}
  String? startedAt;

  /// The message processing complete date-time
  /// @type {string}
  String? completedAt;

  /// The status of the message. When the message is submitted to the queue, it
  /// is in `pending` status. When the message is being processed, its status
  /// changes to `processing`. If message is successfully completed its status
  /// becomes `complete`otherwiese it becomes `errors`.
  /// @type {string}
  MessageStatus status;

  /// Provides information about the errors occurred during processing of the
  /// message
  /// @type {object}
  dynamic errors;
}

enum MessageStatus { pending, processing, completed, errors }

/// Provides info about the status of a task that is triggered for execution.
/// @export
/// @interface TaskInfo
class TaskInfo {
  TaskInfo(
      {required this.status,
      required this.startedAt,
      required this.completedAt,
      required this.errors,
      required this.scheduledTaskId,
      required this.scheduledTaskName,
      required this.taskId,
      required this.triggeredAt});

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
  /// @type {string}
  String taskId;

  /// The id of the scheduled task that is triggered
  /// @type {string}
  String? scheduledTaskId;

  /// The name of the scheduled task that is triggered
  /// @type {string}
  String scheduledTaskName;

  /// The task trigger date-time
  /// @type {string}
  String triggeredAt;

  /// The task execution start date-time
  /// @type {string}
  String? startedAt;

  /// The task execution complete date-time
  /// @type {string}
  String? completedAt;

  /// The status of the task. When the task is firts triggered, it is in
  /// `pending` status. When the task is being processed, its status changes to
  /// `processing`. If task is successfully completed its status becomes
  /// `complete`otherwiese it becomes `errors`.
  /// @type {string}
  MessageStatus status;

  /// Provides information about the errors occurred during execution
  /// of the task
  /// @type {object}
  Map<String, dynamic>? errors;
}

abstract class DbOperationOptions<T> {
  const DbOperationOptions();

  DbOperationOptions<T> merge(T? other);

  Map<String, dynamic> toJson();
}

/// Defines the options for an object read operation
/// @export
/// @interface GetOptions
class GetOptions extends DbOperationOptions<GetOptions> {
  const GetOptions({required this.cache});

  @override
  Map<String, dynamic> toJson() => {'cache': cache.cacheName};

  /// Specify whether to cache the retrieved object using its id as the cache
  /// key or not. If the object is cached and the timeout has expired, the
  /// cached object will automatically be removed from the cache.
  /// @type {enum}
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

  final String cacheName;
}

abstract class Lookup {
  Map<String, dynamic> toJson();
}

/// Defines the structure of a simple lookup
/// @export
/// @interface SimpleLookup
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
  /// @type {string}
  String field;
}

/// Defines the structure of a complex lookup
/// @export
/// @interface ComplexLookup
class ComplexLookup extends Lookup {
  ComplexLookup(
      {required this.name, required this.modelName, required this.query});

  @override
  Map<String, dynamic> toJson() =>
      {'name': name, 'modelName': modelName, 'query': query};

  /// The name of the lookup. This will become a field of the retrieved object
  /// which will hold the looked up value. The specified name needs to be
  /// **unique** among the fields of the model.
  /// @type {string}
  String name;

  /// The name of the target model which will be joined with the current model
  /// @type {string}
  String modelName;

  /// The query expression that will be used in joining the models
  /// @type {string}
  String query;
}

/// Defines the options for an object create operation
/// @export
/// @interface CreateOptions
class CreateOptions extends DbOperationOptions<CreateOptions> {
  const CreateOptions({required this.cache});

  @override
  Map<String, dynamic> toJson() => {'cache': cache.cacheName};

  /// Specify whether to cache the created object using its id as the cache key
  /// or not. If the object is cached and the timeout has expired, the cached
  /// object will automatically be removed from the cache.
  /// @type {string}
  final Cache cache;

  @override
  CreateOptions merge(CreateOptions? other) =>
      CreateOptions(cache: other?.cache ?? cache);
}

/// Defines the options for an object set operation
/// @export
/// @interface SetOptions
class SetOptions extends DbOperationOptions<SetOptions> {
  const SetOptions({required this.cache, required this.returnTop});

  @override
  Map<String, dynamic> toJson() =>
      {'cache': cache.cacheName, 'returnTop': returnTop};

  /// Specify whether to cache the set object using its id as the cache key or
  /// not. If the object is cached and the timeout has expired, the cached
  /// object will automatically be removed from the cache.
  /// @type {string}
  final Cache cache;

  /// When you create a submodel object (a child object of a top-level object),
  /// you can specify whether to return the newly created child object or the
  /// updated top-level object.
  /// @type {boolean}
  final bool returnTop;

  @override
  SetOptions merge(SetOptions? other) => SetOptions(
      cache: other?.cache ?? cache, returnTop: other?.returnTop ?? returnTop);
}

/// Defines the options for an object append operation
/// @export
/// @interface AppendOptions
class AppendOptions extends DbOperationOptions<AppendOptions> {
  const AppendOptions({required this.returnTop, required this.cache});

  @override
  Map<String, dynamic> toJson() =>
      {'cache': cache.cacheName, 'returnTop': returnTop};

  /// Specify whether to cache the appended object using its id as the cache
  /// key or not. If the object is cached and the timeout has expired, the
  /// cached object will automatically be removed from the cache.
  /// @type {string}
  final Cache cache;

  /// When you create a submodel object (a child object of a top-level object),
  /// you can specify whether to return the newly created child object or the
  /// updated top-level object.
  /// @type {boolean}
  final bool returnTop;

  @override
  AppendOptions merge(AppendOptions? other) => AppendOptions(
      cache: other?.cache ?? cache, returnTop: other?.returnTop ?? returnTop);
}

/// Defines the options for an object delete operation
/// @export
/// @interface DeleteOptions
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
  /// @type {string}
  final bool removeFromCache;

  /// In case if you delete a submodel object (a child object of a top-level
  /// object), you can specify whether to return the updated top-level object.
  /// @type {boolean}
  final bool returnTop;
}

/// Defines the options for an object update operation
/// @export
/// @interface UpdateOptions
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
  /// @type {string}
  final Cache cache;

  /// In case if you update a submodel object (a child object of a top-level
  /// object), you can specify whether to return the newly updated child object
  /// or the updated top-level object.
  /// @type {boolean}
  final bool returnTop;
}

/// Defines the structure of a db action that is built by a {@link QueryBuilder}
/// @export
/// @interface DBAction
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
  /// @type {string | null}
  String? expression;

  /// The list of lookups to make (left outer join) while getting the object
  /// from the database
  /// @type {([SimpleLookup | ComplexLookup]| null | undefined)}
  List<Lookup>? lookups;

  /// A positive integer that specifies the page number to paginate query
  /// results. Page numbers start from 1.
  /// @type {(number | null | undefined)}
  int? page;

  /// A positive integer that specifies the max number of objects to return
  /// per page
  /// @type {(number | null | undefined)}
  int? limit;

  /// Keeps the list of field names and sort direction for sorting returned
  /// objects
  /// @type {([SortEntry] | null | undefined)}
  List<SortEntry>? sort;

  /// The list of fields that will be omitted in retrieved objects
  /// @type {(string[]| null | undefined)}
  List<String>? omit;

  /// The grouping definition of the query builder. If you want to group the
  /// query results by values of specific fields, then provide the name of the
  /// fields in a string array format e.g., ['field1', 'field2.subField', ...]
  ///
  /// If you prefer to group the query results by an expression then just
  /// provide the expression string.
  ///
  /// @type {(string | string[] | null | undefined)}
  dynamic group;
}

/// Defines the structure of sort entry
/// @export
/// @interface SortEntry
class SortEntry {
  SortEntry(this.field, this.direction);

  Map<String, dynamic> toJson() =>
      {'field': field, 'direction': direction.name};

  /// The name of the field that will be used in sorting the returned objects.
  /// The field name can be in dot-notation to specify sub-object fields
  /// (e.g., field.subField)
  /// @type {string}
  String field;

  /// Sort direction
  /// @type {string}
  Direction direction;
}

enum Direction { asc, desc }

/// Defines the structure of a field update
/// @export
/// @interface FieldUpdate
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
  /// @type {string}
  String field;

  /// Defines how the field will be updated.
  /// - **set:** Sets (overwrites) the value of a field. Applicable on all
  /// fields, except system managed `_id`, `_parent`, `createdAt`, `updatedAt`
  /// fields.
  ///
  /// - **unset:** Clears the value of a field. Applicable on all fields,
  /// except system managed `_id`, `_parent`, `createdAt`, `updatedAt` fields.
  ///
  /// - **increment:** Increments the value of a numeric field by the specified
  /// amount. Applicable only for integer and decimal fields.
  ///
  /// - **decrement:** Decrements the value of a numeric field by the specified
  /// amount. Applicable only for integer and decimal fields.
  ///
  /// - **min:** Assigns the minimum of the specified value or the field value.
  /// If the specified value is less than the current field value, sets the
  /// field value to the specificied value, otherwise does not make any changes.
  /// Applicable only for integer and decimal fields.
  ///
  /// - **max:** Assigns the maximum of the specified value or the field value.
  /// If the specified value is greater than the current field value, sets the
  /// field value to the specificied value, otherwise does not make any changes.
  /// Applicable only for integer and decimal fields.
  ///
  /// - **multiply:** Multiplies the current value of the field with the
  /// specified amount and sets the field value to teh multiplication result.
  /// Applicable only for integer and decimal fields.
  ///
  /// - **pull:** Removes the specified value from a basic values list.
  /// Applicable only for basic values list fields.
  ///
  /// - **push:** Adds the specified value to a basic values list. Applicable
  /// only for basic values list fields.
  ///
  /// - **pop:** Removes the last element from a basic values list. Applicable
  /// only for basic values list fields.
  ///
  /// - **shift:** Removes the first element from a basic values list.
  /// Applicable only for basic values list fields.
  /// @type {('set'
  ///       | 'unset'
  ///       | 'increment'
  ///       | 'decrement'
  ///       | 'min'
  ///       | 'max'
  ///       | 'multiply'
  ///       | 'pull'
  ///       | 'push'
  ///       | 'pop'
  ///       | 'shift')}

  UpdateType updateType;

// updateType:
// | "set"
// | "unset"
// | "increment"
// | "decrement"
// | "min"
// | "max"
// | "multiply"
// | "pull"
// | "push"
// | "pop"
// | "shift";

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
  /// @type {*}
  dynamic value;
}

//TODO
enum UpdateType { set, unset }

/// Defines the structure of the response of a multi-object update operation
/// in the database
/// @export
/// @interface UpdateInfo
class UpdateInfo {
  UpdateInfo({required this.totalMatch, required this.updated});

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
      totalMatch: json['totalMatch'] as int, updated: json['updated'] as int);

  /// Total number of objects that matched to the filter query
  /// @type {number}
  int totalMatch;

  /// Number of objects updated
  /// @type {number}
  int updated;
}

/// Defines the structure of the response of a multi-object delete operation
/// in the database
/// @export
/// @interface UpdateInfo
class DeleteInfo {
  DeleteInfo({required this.totalMatch, required this.deleted});

  factory DeleteInfo.fromJson(Map<String, dynamic> json) => DeleteInfo(
      totalMatch: json['totalMatch'] as int, deleted: json['deleted'] as int);

  Map<String, dynamic> toJson() =>
      {'totalMatch': totalMatch, 'deleted': deleted};

  /// Total number of objects that matched to the filter query
  /// @type {number}
  int totalMatch;

  /// Number of objects deleted
  /// @type {number}
  int deleted;
}

/// Defines the structure of grouped object computations. Basically, it provides
/// aggregate calculation instructions to {@link QueryBuilder.compute} method
/// @export
/// @interface GroupComputation
abstract class GroupComputation {
  GroupComputation(
      {required this.name, required this.type, required this.expression});

  Map<String, dynamic> toJson() =>
      {'name': name, 'type': type.name, 'expression': expression};

  /// The name of the computation which will be reported in the result of
  /// {@link QueryBuilder.compute} method execution. If you are defining more
  /// than one group computation, then their names need to be unique.
  /// @type {string}
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
  ///
  /// @type {('count' | 'countif' | 'sum' | 'avg' | 'min' | 'max')}
  /// @memberof GroupComputation
  GroupComputationType type;

  /// The computation expression string. Except **count**, expression string is
  /// required for all other computation types.
  /// @type {string}
  /// @memberof GroupComputation
  String expression;
}

//TODO
enum GroupComputationType { count, sum }

/// Defines the structure how to get app buckets
/// @export
/// @interface BucketListOptions
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
  /// @type {(number | null | undefined)}
  int? page;

  /// A positive integer that specifies the max number of buckets to return
  /// per page
  /// @type {(number | null | undefined)}
  int? limit;

  /// Specifies the field name and sort direction for sorting returned buckets
  /// @type {(BucketSortEntry | null | undefined)}
  BucketSortEntry? sort;

  /// Flag to specify whether to return the count and pagination information
  /// such as total number of buckets, page number and page size
  /// @type {boolean}
  bool returnCountInfo;
}

/// Defines the structure of a bucket sort entry
/// @export
/// @interface BucketSortEntry
class BucketSortEntry {
  BucketSortEntry({required this.field, required this.direction});

  Map<String, dynamic> toJson() =>
      {'field': field.name, 'direction': direction.name};

  /// The name of the bucket field that will be used in sorting the returned
  /// objects
  /// @type {string}
  BucketSortField field;

  /// Sort direction
  /// @type {string}
  Direction direction;
}

//TODO
enum BucketSortField { name, isPublic }

/// Defines the structure how to get the files of a bucket
/// @export
/// @interface FileListOptions
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
  /// @type {(number | null | undefined)}
  int? page;

  /// A positive integer that specifies the max number of files to return per
  /// page
  /// @type {(number | null | undefined)}
  int? limit;

  /// Specifies the field name and sort direction for sorting returned files
  /// @type {(FileSortEntry | null | undefined)}
  FileSortEntry? sort;

  /// Flag to specify whether to return the count and pagination information
  /// such as total number of files, page number and page size
  /// @type {boolean}
  bool returnCountInfo;
}

/// Defines the structure of a file sort entry
/// @export
/// @interface FileSortEntry
class FileSortEntry {
  FileSortEntry({required this.field, required this.direction});

  Map<String, dynamic> toJson() =>
      {'field': field.name, 'direction': direction.name};

  /// The name of the file field that will be used in sorting the returned
  /// objects
  /// @type {string}
  FileSortField field;

  /// Sort direction
  /// @type {string}
  Direction direction;
}

enum FileSortField { bucketId, fileName }

/// Defines the options available that can be set during file upload
/// @export
/// @interface FileUploadOptions
class FileUploadOptions extends DbOperationOptions<FileUploadOptions> {
  const FileUploadOptions(
      {this.contentType, this.createBucket, this.isPublic, this.onProgress});

  /// The `Content-Type` header value. This value needs to be specified if
  /// using a `fileBody` that is neither `Blob` nor `File` nor `FormData`,
  /// otherwise will default to `text/plain;charset=UTF-8`.
  /// @type {string}
  final String? contentType;

  /// Specifies whether file is publicy accessible or not. Defaults to the
  /// bucket's privacy setting if not specified.
  /// @type {boolean}
  final bool? isPublic;

  /// Specifies whether to create the bucket while uploading the file. If a
  /// bucket with the provided name does not exists and if `createBucket` is
  /// marked as true then creates a new bucket. Defaults to false.
  /// @type {boolean}
  final bool? createBucket;

  /// Callback function to call during file upload.
  ///
  /// **For the moment, this method can only be used in clients where
  /// `XMLHttpRequest` object is available (e.g., browsers).**
  /// @param uploaded Total bytes uploaded
  /// @param total Total size of file in bytes
  /// @param percentComplete Percent uploaded (an integer between 0-100),
  /// basicly `uploaded/total` rounded to the nearest integer
  final void Function(int total, int uploaded, double percentComplete)?
      onProgress;

  @override
  Map<String, dynamic> toJson() => {
        'createBucket': createBucket,
        'contentType': contentType,
        'isPublic': isPublic
      };

  @override
  FileUploadOptions merge(FileUploadOptions? other) => FileUploadOptions(
      createBucket: other?.createBucket ?? createBucket,
      contentType: other?.contentType ?? contentType,
      onProgress: other?.onProgress ?? onProgress,
      isPublic: other?.isPublic ?? isPublic);
}

//ignore_for_file: constant_identifier_names

/// Http Method
enum Method { GET, POST, PUT, DELETE }

enum ResolveType { json, text, blob, arraybuffer }
