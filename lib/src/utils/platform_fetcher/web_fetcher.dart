import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import '../../altogic_dart_base.dart';
import '../../api_response.dart';
import '../fetcher.dart';
import '../helpers.dart';
import '../http_package/byte_stream.dart';
import '../http_package/client_exception.dart';
import '../http_package/multipart_file.dart';
import '../http_package/multipart_request.dart';

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
      resolveTypeStr = 'arraybuffer';
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
          var body = xhr.response is List<dynamic>
              ? (xhr.response as List<dynamic>)
                  .map((e) => e is Map ? _adjustJson(e) : e)
                  .toList()
              : xhr.response is Map
                  ? _adjustJson(xhr.response as Map<dynamic, dynamic>)
                  : xhr.response;
          completer.complete(APIResponse(data: body));
          break;
        case ResolveType.text:
          var body = xhr.response;
          completer.complete(APIResponse(data: body));
          break;
        case ResolveType.blob:
          var body = (xhr.response as ByteBuffer).asUint8List();
          completer.complete(APIResponse(data: body));
          break;
        case ResolveType.arraybuffer:
          var body = (xhr.response as ByteBuffer).asUint8List();
          completer.complete(APIResponse(data: body));
          break;
      }
    } else {
      var body = xhr.response;

      dynamic errorBody;

      if (body is String) {
        errorBody = json.encode(body);
      } else if (body is List) {
        errorBody = body.map((e) => e is Map ? _adjustJson(e) : e).toList();
      } else if (body is Map<dynamic, dynamic>) {
        errorBody = _adjustJson(body);
      } else {
        throw Exception('Body not parsed : ${body.runtimeType} $body');
      }

      var errors = errorBody is List
          ? errorBody.cast<Map<String, dynamic>>()
          : (errorBody as Map<String, dynamic>)['errors'] ?? errorBody;

      if (errors is List) {
        errors = errors
            .cast<Map<dynamic, dynamic>>()
            .map<Map<String, dynamic>>(_adjustJson)
            .toList();
      } else if (errors is Map) {
        errors = _adjustJson(errors);
      }

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
    completer.completeError(ClientException('XMLHttpRequest error.'));
  }));

  xhr.send(requestBody);

  try {
    return await completer.future;
  } on Exception {
    rethrow;
  }
}

Map<String, dynamic> _adjustJson(Map<dynamic, dynamic> map) =>
    map.cast<String, dynamic>().map((key, value) => MapEntry(
        key, value is Map<dynamic, dynamic> ? _adjustJson(value) : value));

Future<APIResponse<dynamic>> handlePlatformUpload(
    String path, Object body, String fileName, String contentType,
    {required Map<String, dynamic> query,
    required Map<String, dynamic> headers,
    void Function(int loaded, int total, double percent)? onProgress,
    required Fetcher fetcher}) async {
  ByteStream? requestStream;

  Uint8List fileBytes;
  if (body is Uint8List) {
    fileBytes = body;
  } else {
    fileBytes = utf8.encode(body.toString()) as Uint8List;
  }

  var multiPart = MultipartRequest()
    ..files.add(MultipartFile.fromBytes('file', fileBytes,
        filename: fileName, contentType: MediaType.parse(contentType)));

  var result = multiPart.finalize();
  requestStream = result[0] as ByteStream;
  var requestBytes = await requestStream.toBytes();
  headers['content-type'] = 'multipart/form-data; boundary=${result[1]}';

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
    xhr.upload.onProgress.listen((event) {
      if (event.lengthComputable) {
        onProgress(event.total!, event.loaded!,
            (((event.loaded! / event.total!) * 100) * 100).floor() / 100);
      }
    });
  }

  unawaited(xhr.onLoad.first.then((_) {
    if (_responseIsOk(xhr.status)) {
      var body =
          (xhr.response as Map<dynamic, dynamic>).cast<String, dynamic>();
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

  xhr.send(requestBytes);

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
