import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../altogic_dart_base.dart';
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
  ByteStream? requestBody;

  if (body != null) {
    if (body is File) {
      var multiPart = MultipartRequest();
      multiPart.files
          .add(MultipartFile.fromBytes('file', await body.readAsBytes()));
      var result = multiPart.finalize();
      requestBody = result[0] as ByteStream;
      headers['content-type'] = 'multipart/form-data; boundary=${result[1]}';
    } else if (body is Uint8List) {
      var multiPart = MultipartRequest();
      multiPart.files.add(MultipartFile.fromBytes('file', body));
      var result = multiPart.finalize();
      requestBody = result[0] as ByteStream;
      headers['content-type'] = 'multipart/form-data; boundary=${result[1]}';
    } else {
      try {
        requestBody = ByteStream.fromBytes(utf8.encode(json.encode(body)));
        headers['content-type'] = 'application/json';
      } on Exception {
        requestBody = ByteStream.fromBytes(utf8.encode(body.toString()));
      }
    }
  }

  var queryString = encodeUriParameters(query);

  var platforms = {
    if (Platform.isIOS) 'os': 'iOS',
    if (Platform.isAndroid) 'os': 'Android',
    if (Platform.isFuchsia) 'os': 'Fuchsia',
    if (Platform.isLinux) 'os': 'Linux',
    if (Platform.isMacOS) 'os': 'MacOS',
    if (Platform.isWindows) 'os': 'Windows',
    'v': Platform.version
  };

  var client = HttpClient()..userAgent = '${platforms['os']}/${platforms['v']}';

  var ioRequest =
      await client.openUrl(method.name, Uri.parse(path + queryString));

  headers
      .map((k, v) => MapEntry(k, v.toString()))
      .forEach((k, v) => ioRequest.headers.set(k, v));

  var response = await (requestBody ?? ByteStream.fromBytes(Uint8List(0)))
      .pipe(ioRequest) as HttpClientResponse;

  var responseHeaders = <String, String>{};
  response.headers.forEach((key, values) {
    responseHeaders[key] = values.join(',');
  });

  var responseBodyStream = ByteStream(response.handleError((Object error) {
    final httpException = error as HttpException;
    throw ClientException(httpException.message);
  }, test: (error) => error is HttpException));

  var responseBody = await responseBodyStream.toBytes();

  // if (onUploadProgress != null) {
  //   xhr.upload.onLoad.listen((event) {
  //     if (event.lengthComputable) {
  //       onUploadProgress(event.total!, event.loaded!);
  //     }
  //   });
  // }

  if (_responseIsOk(response.statusCode)) {
    switch (resolveType) {
      case ResolveType.json:
        if (responseBody.isEmpty) return APIResponse();
        return APIResponse(data: json.decode(utf8.decode(responseBody)));
      case ResolveType.text:
        return APIResponse(data: utf8.decode(responseBody));
      case ResolveType.blob:
        return APIResponse(data: responseBody);
      case ResolveType.arraybuffer:
        return APIResponse(data: body);
    }
  } else {
    var errorBody = responseBody.isEmpty
        ? <Map<String, dynamic>>[]
        : json.decode(utf8.decode(responseBody));

    var errors = errorBody is List
        ? errorBody.cast<Map<String, dynamic>>()
        : (errorBody as Map<String, dynamic>)['errors'] ?? errorBody;

    if (errors != null &&
        errors is List &&
        errors
            .where((element) =>
                element is Map<String, dynamic> &&
                (element['code'] == INVALID_SESSION_TOKEN ||
                    element['code'] == MISSING_SESSION_TOKEN))
            .isNotEmpty) {
      await fetcher.apiClient.auth.invalidateSession();
    }

    return APIResponse(
        errors: APIError(
            status: response.statusCode,
            statusText: response.reasonPhrase,
            items: ((errors is List) ? errors : [errors])
                .map((e) => ErrorEntry.fromJson(e as Map<String, dynamic>))
                .toList()));
  }
}

int _chunk = 32768;

Future<APIResponse<dynamic>> handlePlatformUpload(
    String path, Object body, String fileName, String contentType,
    {required Map<String, dynamic> query,
    required Map<String, dynamic> headers,
    void Function(int loaded, int total, double percent)? onProgress,
    required Fetcher fetcher}) async {
  ByteStream? requestStream;

  Uint8List fileBytes;
  if (body is File) {
    fileBytes = await body.readAsBytes();
  } else if (body is Uint8List) {
    fileBytes = body;
  } else {
    fileBytes = utf8.encode(body.toString()) as Uint8List;
  }

  var number = (fileBytes.length / _chunk).ceil();

  var fileStream = Stream.fromIterable(List.generate(
      number,
      (index) => fileBytes.sublist(index * _chunk,
          index != number - 1 ? ((index + 1) * _chunk) : null)));

  var multiPart = MultipartRequest()
    ..files.add(MultipartFile('file', fileStream, fileBytes.length,
        filename: fileName, contentType: MediaType.parse(contentType)));

  var result = multiPart.finalize();
  requestStream = result[0] as ByteStream;

  ByteStream? stream2;

  var contentLength = multiPart.contentLength;
  if (onProgress != null) {
    var load = 0;
    stream2 = ByteStream(
        requestStream.transform(StreamTransformer.fromBind((d) async* {
      await for (var data in d) {
        load += data.length;
        onProgress(contentLength, load,
            (((load / contentLength) * 100) * 100).floor() / 100);
        yield data;
      }
    })));
  }

  headers['content-type'] = 'multipart/form-data; boundary=${result[1]}';

  var queryString = encodeUriParameters(query);
  var ioRequest =
      await HttpClient().openUrl('POST', Uri.parse(path + queryString));

  headers
      .map((k, v) => MapEntry(k, v.toString()))
      .forEach((k, v) => ioRequest.headers.set(k, v));

  var response =
      await (stream2 ?? requestStream).pipe(ioRequest) as HttpClientResponse;

  var responseHeaders = <String, String>{};
  response.headers.forEach((key, values) {
    responseHeaders[key] = values.join(',');
  });

  var responseBodyStream = ByteStream(response.handleError((Object error) {
    final httpException = error as HttpException;
    throw ClientException(httpException.message);
  }, test: (error) => error is HttpException));

  var responseBody = await responseBodyStream.toBytes();

  if (_responseIsOk(response.statusCode)) {
    return APIResponse(data: json.decode(utf8.decode(responseBody)));
  } else {
    var errResponse =
        json.decode(utf8.decode(responseBody)) as Map<String, dynamic>;
    var errors = errResponse['errors'];

    if (errors != null &&
        errors is List &&
        errors
            .where((element) =>
                element is Map<String, dynamic> &&
                (element['code'] == INVALID_SESSION_TOKEN ||
                    element['code'] == MISSING_SESSION_TOKEN))
            .isNotEmpty) {
      await fetcher.apiClient.auth.invalidateSession();
    }

    return APIResponse(
        errors: APIError(
            status: response.statusCode,
            statusText: response.reasonPhrase,
            items: ((errors is List) ? errors : [errors])
                .map((e) => ErrorEntry.fromJson(e as Map<String, dynamic>))
                .toList()));
  }
}

//ignore_for_file: constant_identifier_names
const INVALID_SESSION_TOKEN = 'invalid_session_token';
const MISSING_SESSION_TOKEN = 'missing_session_token';

bool _responseIsOk(int? status) => status != null && status < 300;
