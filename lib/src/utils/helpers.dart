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

/// Parsed environment url components
class RealtimeUrlConfig {
  RealtimeUrlConfig({
    required this.subdomain,
    required this.realtimeUrl,
    required this.envId,
  });

  RealtimeUrlConfig.empty()
      : subdomain = '',
        realtimeUrl = '',
        envId = '';

  /// parsed  subdomain
  String subdomain;

  /// parsed realtime url
  String realtimeUrl;

  /// parsed environment id
  String envId;
}

/// Parses the env url and returns its components
///
/// envUrl Environment url to parse
/// returns Parsed environment url components
RealtimeUrlConfig parseRealtimeEnvUrl(String envUrl) {
  String temp;
  String protocol;
  if (envUrl.startsWith('https://')) {
    temp = envUrl.replaceFirst('https://', '');
    protocol = 'https://';
  } else {
    temp = envUrl.replaceFirst('http://', '');
    protocol = 'http://';
  }

  var items = temp.split('.');

  if (items.length == 4) {
    var info = RealtimeUrlConfig.empty()..subdomain = items[0];

    var posIndex = items[3].indexOf('/');
    if (posIndex != -1) {
      items[3] = items[3].substring(0, posIndex);
    }

    items[0] = 'realtime';
    info.realtimeUrl = protocol + items.join('.');

    return info;
  }

  if (items.length == 3) {
    var posIndex = items[2].indexOf('/');
    if (posIndex != -1) {
      var info = RealtimeUrlConfig.empty();

      var baseUrl = items[2].substring(posIndex);
      items[2] = items[2].substring(0, posIndex);
      if (items[0] == 'engine') {
        items[0] = 'realtime';
      } else {
        items.insert(0, 'realtime');
      }

      info.realtimeUrl = protocol + items.join('.');

      if ((baseUrl.startsWith('/e:')) || baseUrl.startsWith('/E:')) {
        var segments = baseUrl.split('/');
        var envIdStr = segments[1];
        var segments2 = envIdStr.split(':');
        info.envId = segments2[1].trim();
      }

      return info;
    } else {
      items.insert(0, 'realtime');
      return RealtimeUrlConfig.empty()
        ..realtimeUrl = protocol + items.join('.');
    }
  }

  return RealtimeUrlConfig.empty();
}
