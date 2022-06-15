import '../altogic_dart.dart';

abstract class APIResponseBase {
  APIResponseBase({this.errors});

  /// Response [errors].
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

class UserResult extends APIResponseBase {
  UserResult({this.user, super.errors});

  User? user;
}

class SessionResult extends APIResponseBase {
  SessionResult({this.sessions, super.errors});

  List<Session>? sessions;
}

class KeyListResult extends APIResponseBase {
  KeyListResult({super.errors, this.next, this.data});

  List<Map<String, dynamic>>? data;
  String? next;
}
