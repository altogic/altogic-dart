import 'dart:convert';

import 'client_error.dart';
import 'platform_helper/stub_helper.dart'
    if (dart.library.html) 'platform_helper/web_helper.dart'
    if (dart.library.io) 'platform_helper/io_helper.dart' as pl;

/// Removes trailing slash character from input url string.
String removeTrailingSlash(String uri) => uri.replaceAll(r'/\/$/', '');

/// Normalizes the input url string by trimming spaces and removing any
/// trailing slash character.
String normalizeUrl(String url) => removeTrailingSlash(url.trim());

const dynamic Function(String param) getParamValue = pl.platformGetParamValue;

void checkRequired(String fieldName, dynamic fieldValue,
    {bool checkEmptyString = true}) {
  if (fieldValue == null) {
    throw ClientError('missing_required_value',
        '$fieldName is a required parameter, cannot be left empty');
  }

  if (checkEmptyString && fieldValue is String && fieldValue.trim() == '') {
    throw ClientError('missing_required_value',
        '$fieldName is a required parameter, cannot be left empty');
  }
}


String encodeUriParameters(Map<String, dynamic> queryParameters) {
  var queryString = Uri(queryParameters: queryParameters.map((key, value) {
    if (value is Map || value is List) {
      return MapEntry(key, json.encode(value));
    } else {
      return MapEntry(key, value.toString());
    }
  })).query;

  if (queryString.isNotEmpty) {
    queryString = '?$queryString';
  }

  return queryString;
}
