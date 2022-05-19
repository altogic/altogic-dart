import 'dart:convert';

import 'client_error.dart';
import 'platform_helper/stub_helper.dart'
    if (dart.library.html) 'platform_helper/web_helper.dart'
    if (dart.library.io) 'platform_helper/io_helper.dart' as pl;

/// Removes trailing slash character from input url string.
/// @export
/// @param {string} url  The url string to revove trailing slach
/// @returns Trailed url string
String removeTrailingSlash(String uri) => uri.replaceAll(r'/\/$/', '');

/// Normalizes the input url string by trimming spaces and removing any
/// trailing slash character.
/// @export
/// @param {string} url The url string to normalize
/// @returns Normalized url string
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

void arrayRequired(String fieldName, List<dynamic> fieldValue,
    {bool checkEmptyArray = false}) {
  if (checkEmptyArray && fieldValue.isEmpty) {
    throw ClientError('emtpy_array',
        '$fieldName needs to be an array with at least one entry');
  }
}

/// Checks whether the input field value is an integer or not
/// @export
/// @param {string} fieldName Field name to check for a value
/// @param {any} fieldValue Field value
/// @param {any} checkPositive Flag to check whether the number is positive or
/// not
/// @throws Throws an exception if `fieldValue` is not an integer.
/// If `checkPositive=true`, throws an exception if `fieldValue<=0`.
void integerRequired(String fieldName, dynamic fieldValue,
    {bool checkPositive = true}) {
  checkRequired(fieldName, fieldValue, checkEmptyString: false);

  if (fieldValue is! int) {
    throw ClientError('invalid_value', '$fieldName needs to be an integer');
  }

  if (checkPositive && fieldValue <= 0) {
    throw ClientError(
        'invalid_value', '$fieldName needs to be a positive integer');
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
