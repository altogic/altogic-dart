import '../altogic_dart.dart';

class APIResponse<T> {
  APIResponse({this.data, this.errors});

  T? data;

  APIError? errors;

  APIResponse<R> cast<R>() => APIResponse<R>(data: data as R, errors: errors);
}

class UserSessionResult {
  UserSessionResult({this.user, this.session, this.errors});

  User? user;
  Session? session;
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
