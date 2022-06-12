import '../altogic_dart.dart';

/// All API request returns a [APIResponse].
///
/// If response is success, [errors] will be null and [data] will not.
///
/// Else, response is error response, [errors] will not be null, and [data] will
/// not.
class APIResponse<T> {
  /// Create [APIResponse] with generic types.
  APIResponse({this.data, this.errors});

  /// Response data.
  T? data;

  /// Response errors
  APIError? errors;

  /// Type cast for [data]
  APIResponse<R> cast<R>() => APIResponse<R>(data: data as R?, errors: errors);
}

/// Hold [User] and [Session].
/// Same as [APIResponse], If response success, [errors] will be null.
class UserSessionResult {
  ///
  UserSessionResult({this.user, this.session, this.errors});

  /// Response [user].
  User? user;

  /// Response [session].
  Session? session;

  /// Response [errors].
  APIError? errors;
}

class UserResult {
  UserResult({this.user, this.errors});

  User? user;
  APIError? errors;
}

class SessionResult {
  SessionResult({this.sessions, this.errors});

  List<Session>? sessions;
  APIError? errors;
}

class KeyListResult {
  KeyListResult({this.errors, this.next, this.data});

  List<Map<String, dynamic>>? data;
  String? next;
  APIError? errors;
}
