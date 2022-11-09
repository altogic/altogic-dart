part of altogic_dart;

/// All API responses are wrapped in this class.
///
/// All responses has nullable [errors] property.
abstract class APIResponseBase {
  APIResponseBase({this.errors});

  /// Response [errors].
  ///
  /// If the response has errors, this property will not be null.
  APIError? errors;
}

/// All API request returns a [APIResponse].
///
/// If response is success, [errors] will be null and [data] will not.
///
/// Else, response is error response, [errors] will not be null, and [data] will
/// not.
class APIResponse<T> extends APIResponseBase {
  /// Create [APIResponse] with generic types.
  APIResponse({this.data, super.errors});

  /// Response data.
  T? data;

  /// Type cast for [data]
  APIResponse<R> cast<R>() => APIResponse<R>(data: data as R?, errors: errors);
}

/// Hold [User] and [Session].
/// Same as [APIResponse], If response success, [errors] will be null.
class UserSessionResult extends APIResponseBase {
  ///
  UserSessionResult({this.user, this.session, super.errors});

  /// Response [user].
  User? user;

  /// Response [session].
  Session? session;
}

/// [AuthManager.changeEmail] , [AuthManager.changePhone] and
/// [AuthManager.getUserFromDB] returns this class.
class UserResult extends APIResponseBase {
  UserResult({this.user, super.errors});

  User? user;
}

/// [AuthManager.getAllSessions] response.
///
/// Same as [APIResponse], If response success, [errors] will be null.
class SessionResult extends APIResponseBase {
  SessionResult({this.sessions, super.errors});

  /// Sessions
  List<Session>? sessions;
}

/// Cached keys list response.
/// Same as [APIResponse], If response success, [errors] will be null and
/// [data] will not.
class KeyListResult extends APIResponseBase {
  KeyListResult({super.errors, this.next, this.data});

  /// Cached keys list as object.
  List<Map<String, dynamic>>? data;

  /// next cursor if there are remaining items to paginate.
  String? next;
}
