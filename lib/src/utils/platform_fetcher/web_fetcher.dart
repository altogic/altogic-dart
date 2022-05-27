import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import '../../altogic_dart_base.dart';
import '../../api_response.dart';
import '../fetcher.dart';
import '../helpers.dart';
import '../http_package/client_exception.dart';

Future<APIResponse<dynamic>> handlePlatformRequest(Method method, String path,
    {required Map<String, dynamic> query,
    required Map<String, dynamic> headers,
    Object? body,
    ResolveType resolveType = ResolveType.json,
    required Fetcher fetcher}) async {
  Object? requestBody;

  if (body != null) {
    var isFormDataBody = false;

    if (body is html.FormData && html.FormData.supported) {
      requestBody = body;
      isFormDataBody = true;
    } else if ((body is html.Blob || body is html.File) &&
        html.FormData.supported) {
      requestBody = html.FormData();
      (requestBody as html.FormData).appendBlob('file', body as html.Blob);
      isFormDataBody = true;
    } else if ((body is Uint8List) && html.FormData.supported) {
      requestBody = html.FormData();
      (requestBody as html.FormData).appendBlob('file', html.Blob(body));
      isFormDataBody = true;
    } else {
      try {
        requestBody = json.encode(body);
        headers['content-type'] = 'application/json';
      } on Exception {
        requestBody = body;
      }
    }
    if (isFormDataBody) {
      headers.remove('content-type');
    }
    // if (onUploadProgress != null) {
    //   xhr.upload.onLoad.listen((event) {
    //     if (event.lengthComputable) {
    //       onUploadProgress(event.total!, event.loaded!);
    //     }
    //   });
    // }
  }

  var queryString = encodeUriParameters(query);

  String resolveTypeStr;
  switch (resolveType) {
    case ResolveType.json:
      resolveTypeStr = 'json';
      break;
    case ResolveType.text:
      resolveTypeStr = 'text';
      break;
    case ResolveType.blob:
      resolveTypeStr = 'blob';
      break;
    case ResolveType.arraybuffer:
      resolveTypeStr = 'arraybuffer';
      break;
  }

  var xhr = html.HttpRequest()
    ..open(method.name, '$path$queryString', async: true)
    ..responseType = resolveTypeStr
    ..withCredentials = true;

  headers
      .map((k, v) => MapEntry(k, v.toString()))
      .forEach(xhr.setRequestHeader);

  var completer = Completer<APIResponse<dynamic>>();

  // if (onUploadProgress != null) {
  //   xhr.upload.onLoad.listen((event) {
  //     if (event.lengthComputable) {
  //       onUploadProgress(event.total!, event.loaded!);
  //     }
  //   });
  // }

  unawaited(xhr.onLoad.first.then((_) {
    if (_responseIsOk(xhr.status)) {
      switch (resolveType) {
        case ResolveType.json:
          var body = xhr.response as Map<String, dynamic>;
          completer.complete(APIResponse(data: body));
          break;
        case ResolveType.text:
          var body = xhr.response;
          completer.complete(APIResponse(data: body));
          break;
        case ResolveType.blob:
          resolveTypeStr = 'blob';
          throw UnimplementedError('');
        case ResolveType.arraybuffer:
          resolveTypeStr = 'arraybuffer';
          var body = (xhr.response as ByteBuffer).asUint8List();
          completer.complete(APIResponse(data: body));
          break;
      }
    } else {
      var body = xhr.response;
      var errResponse = (body is String
          ? json.decode(body)
          : (body as Map<String, dynamic>)) as Map<String, dynamic>;
      var errors = errResponse['errors'];

      var invalidateCompleter = Completer<void>();

      if (errors != null &&
          errors is List &&
          errors
              .where((element) =>
                  element is Map<String, dynamic> &&
                  (element['code'] == INVALID_SESSION_TOKEN ||
                      element['code'] == MISSING_SESSION_TOKEN))
              .isNotEmpty) {
        fetcher.apiClient.auth.invalidateSession().then((value) {
          invalidateCompleter.complete();
        }).onError((error, stackTrace) {
          invalidateCompleter
              .completeError(error ?? Exception('unknown_error'));
        });
      } else {
        invalidateCompleter.complete();
      }

      invalidateCompleter.future.then((value) {
        completer.complete(APIResponse(
            errors: APIError(
                status: xhr.status!,
                statusText: xhr.statusText!,
                items: ((errors is List) ? errors : [errors])
                    .map((e) => ErrorEntry.fromJson(e as Map<String, dynamic>))
                    .toList())));
      }).onError((error, stackTrace) {
        completer.completeError(error!);
      });
    }
  }));

  unawaited(xhr.onError.first.then((_) {
    completer.completeError(
        ClientException('XMLHttpRequest error.'), StackTrace.current);
  }));

  xhr.send(requestBody);

  try {
    return await completer.future;
  } on Exception {
    rethrow;
  }
}

Future<APIResponse<dynamic>> handlePlatformUpload(
    String path, Object body, String fileName,
    {required Map<String, dynamic> query,
    required Map<String, dynamic> headers,
    void Function(int loaded, int total, double percent)? onProgress,
    required Fetcher fetcher}) async {
  Object? requestBody;

  var isFormDataBody = false;

  if (body is html.FormData && html.FormData.supported) {
    requestBody = body;
    isFormDataBody = true;
  } else if ((body is html.Blob || body is html.File) &&
      html.FormData.supported) {
    requestBody = html.FormData();
    (requestBody as html.FormData).appendBlob('file', body as html.Blob);
    isFormDataBody = true;
  } else if ((body is Uint8List) && html.FormData.supported) {
    requestBody = html.FormData();
    (requestBody as html.FormData).appendBlob('file', html.Blob(body));
    isFormDataBody = true;
  } else {
    requestBody = html.FormData();
    (requestBody as html.FormData).appendBlob('file', html.Blob(body as List));
    isFormDataBody = true;
  }
  if (isFormDataBody) {
    headers.remove('content-type');
  }

  var queryString = encodeUriParameters(query);

  var xhr = html.HttpRequest()
    ..open('POST', '$path$queryString', async: true)
    ..responseType = 'json'
    ..withCredentials = true;

  headers
      .map((k, v) => MapEntry(k, v.toString()))
      .forEach(xhr.setRequestHeader);

  var completer = Completer<APIResponse<dynamic>>();

  if (onProgress != null) {
    xhr.upload.onLoad.listen((event) {
      if (event.lengthComputable) {
        onProgress(event.total!, event.loaded!,
            (((event.loaded! / event.total!) * 100) * 100).floor() / 100);
      }
    });
  }

  unawaited(xhr.onLoad.first.then((_) {
    if (_responseIsOk(xhr.status)) {
      var body = xhr.response as Map<String, dynamic>;
      completer.complete(APIResponse(data: body));
    } else {
      var errResponse = xhr.response as Map<String, dynamic>;
      var errors = errResponse['errors'];

      var invalidateCompleter = Completer<void>();

      if (errors != null &&
          errors is List &&
          errors
              .where((element) =>
                  element is Map<String, dynamic> &&
                  (element['code'] == INVALID_SESSION_TOKEN ||
                      element['code'] == MISSING_SESSION_TOKEN))
              .isNotEmpty) {
        fetcher.apiClient.auth.invalidateSession().then((value) {
          invalidateCompleter.complete();
        }).onError((error, stackTrace) {
          invalidateCompleter
              .completeError(error ?? Exception('unknown_error'));
        });
      } else {
        invalidateCompleter.complete();
      }

      invalidateCompleter.future.then((value) {
        completer.complete(APIResponse(
            errors: APIError(
                status: xhr.status!,
                statusText: xhr.statusText!,
                items: ((errors is List) ? errors : [errors])
                    .map((e) => ErrorEntry.fromJson(e as Map<String, dynamic>))
                    .toList())));
      }).onError((error, stackTrace) {
        completer.completeError(error!);
      });
    }
  }));

  unawaited(xhr.onError.first.then((_) {
    completer.completeError(
        ClientException('XMLHttpRequest error.'), StackTrace.current);
  }));

  xhr.send(requestBody);

  try {
    return await completer.future;
  } on Exception {
    rethrow;
  }
}

//ignore_for_file: constant_identifier_names
const INVALID_SESSION_TOKEN = 'invalid_session_token';
const MISSING_SESSION_TOKEN = 'missing_session_token';

bool _responseIsOk(int? status) => status != null && status < 300;
