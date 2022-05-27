// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'dart:convert';

import 'byte_stream.dart';
import 'multipart_request.dart';
import 'utils.dart';

/// A file to be uploaded as part of a [MultipartRequest].
///
/// This doesn't need to correspond to a physical file.
class MultipartFile {
  /// The name of the form field for the file.
  final String field;

  final int length;

  /// The basename of the file.
  ///
  /// May be `null`.
  final String? filename;

  /// The content-type of the file.
  ///
  /// Defaults to `application/octet-stream`.
  final MediaType contentType;

  /// The stream that will emit the file's contents.
  final ByteStream _stream;

  /// Whether [finalize] has been called.
  bool get isFinalized => _isFinalized;
  bool _isFinalized = false;

  /// Creates a new [MultipartFile] from a chunked [Stream] of bytes.
  ///
  /// The length of the file in bytes must be known in advance. If it's not,
  /// read the data from the stream and use [MultipartFile.fromBytes] instead.
  ///
  /// [contentType] currently defaults to `application/octet-stream`, but in the
  /// future may be inferred from [filename].
  MultipartFile(this.field, Stream<List<int>> stream, this.length,
      {this.filename, MediaType? contentType})
      : _stream = toByteStream(stream),
        contentType = contentType ?? MediaType('application', 'octet-stream');

  /// Creates a new [MultipartFile] from a byte array.
  ///
  /// [contentType] currently defaults to `application/octet-stream`, but in the
  /// future may be inferred from [filename].
  factory MultipartFile.fromBytes(String field, List<int> value,
      {String? filename, MediaType? contentType}) {
    var stream = ByteStream.fromBytes(value);
    return MultipartFile(field, stream, value.length,
        filename: filename, contentType: contentType);
  }

  /// Creates a new [MultipartFile] from a string.
  ///
  /// The encoding to use when translating [value] into bytes is taken from
  /// [contentType] if it has a charset set. Otherwise, it defaults to UTF-8.
  /// [contentType] currently defaults to `text/plain; charset=utf-8`, but in
  /// the future may be inferred from [filename].
  factory MultipartFile.fromString(String field, String value,
      {String? filename, MediaType? contentType}) {
    contentType ??= MediaType('text', 'plain');
    var encoding = encodingForCharset(contentType.parameters['charset'], utf8);
    contentType = contentType.change(parameters: {'charset': encoding.name});

    return MultipartFile.fromBytes(field, encoding.encode(value),
        filename: filename, contentType: contentType);
  }

  // Finalizes the file in preparation for it being sent as part of a
  // [MultipartRequest]. This returns a [ByteStream] that should emit the body
  // of the file. The stream may be closed to indicate an empty file.
  ByteStream finalize() {
    if (isFinalized) {
      throw StateError("Can't finalize a finalized MultipartFile.");
    }
    _isFinalized = true;
    return _stream;
  }
}

final _escapedChar = RegExp(r'["\x00-\x1F\x7F]');

class MediaType {
  /// The primary identifier of the MIME type.
  ///
  /// This is always lowercase.
  final String type;

  /// The secondary identifier of the MIME type.
  ///
  /// This is always lowercase.
  final String subtype;

  /// The parameters to the media type.
  ///
  /// This map is immutable and the keys are case-insensitive.
  final Map<String, String> parameters;

  /// The media type's MIME type.
  String get mimeType => '$type/$subtype';

  MediaType(String type, String subtype, [Map<String, String>? parameters])
      : type = type.toLowerCase(),
        subtype = subtype.toLowerCase(),
        parameters = UnmodifiableMapView(
            parameters == null ? {} : CaseInsensitiveMap.from(parameters));

  factory MediaType.parse(String mediaType) =>
      // This parsing is based on sections 3.6 and 3.7 of the HTTP spec:
      // http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html.
      wrapFormatException('media type', mediaType, () {
        final scanner = StringScanner(mediaType)
          ..scan(whitespace)
          ..expect(token);
        final type = scanner.lastMatch![0]!;
        scanner
          ..expect('/')
          ..expect(token);
        final subtype = scanner.lastMatch![0]!;
        scanner.scan(whitespace);

        final parameters = <String, String>{};
        while (scanner.scan(';')) {
          scanner
            ..scan(whitespace)
            ..expect(token);
          final attribute = scanner.lastMatch![0]!;
          scanner.expect('=');

          String value;
          if (scanner.scan(token)) {
            value = scanner.lastMatch![0]!;
          } else {
            value = expectQuotedString(scanner);
          }

          scanner.scan(whitespace);
          parameters[attribute] = value;
        }

        scanner.expectDone();
        return MediaType(type, subtype, parameters);
      });

  /// Returns a copy of this [MediaType] with some fields altered.
  ///
  /// [type] and [subtype] alter the corresponding fields. [mimeType] is parsed
  /// and alters both the [type] and [subtype] fields; it cannot be passed along
  /// with [type] or [subtype].
  ///
  /// [parameters] overwrites and adds to the corresponding field. If
  /// [clearParameters] is passed, it replaces the corresponding field entirely
  /// instead.
  MediaType change(
      {String? type,
      String? subtype,
      String? mimeType,
      Map<String, String>? parameters,
      bool clearParameters = false}) {
    if (mimeType != null) {
      if (type != null) {
        throw ArgumentError('You may not pass both [type] and [mimeType].');
      } else if (subtype != null) {
        throw ArgumentError('You may not pass both [subtype] and '
            '[mimeType].');
      }

      final segments = mimeType.split('/');
      if (segments.length != 2) {
        throw FormatException('Invalid mime type "$mimeType".');
      }

      type = segments[0];
      subtype = segments[1];
    }

    type ??= this.type;
    subtype ??= this.subtype;
    parameters ??= {};

    if (!clearParameters) {
      final newParameters = parameters;
      parameters = Map.from(this.parameters)..addAll(newParameters);
    }

    return MediaType(type, subtype, parameters);
  }

  /// Converts the media type to a string.
  ///
  /// This will produce a valid HTTP media type.
  @override
  String toString() {
    final buffer = StringBuffer()
      ..write(type)
      ..write('/')
      ..write(subtype);

    parameters.forEach((attribute, value) {
      buffer.write('; $attribute=');
      if (nonToken.hasMatch(value)) {
        buffer
          ..write('"')
          ..write(
              value.replaceAllMapped(_escapedChar, (match) => '\\${match[0]}'))
          ..write('"');
      } else {
        buffer.write(value);
      }
    });

    return buffer.toString();
  }
}

List<T> parseList<T>(StringScanner scanner, T Function() parseElement) {
  final result = <T>[];

  // Consume initial empty values.
  while (scanner.scan(',')) {
    scanner.scan(whitespace);
  }

  result.add(parseElement());
  scanner.scan(whitespace);

  while (scanner.scan(',')) {
    scanner.scan(whitespace);

    // Empty elements are allowed, but excluded from the results.
    if (scanner.matches(',') || scanner.isDone) continue;

    result.add(parseElement());
    scanner.scan(whitespace);
  }

  return result;
}

/// A quoted string.
final _quotedString = RegExp(r'"(?:[^"\x00-\x1F\x7F]|\\.)*"');

/// A quoted pair.
final _quotedPair = RegExp(r'\\(.)');

/// Parses a single quoted string, and returns its contents.
///
/// If [name] is passed, it's used to describe the expected value if it's not
/// found.
String expectQuotedString(
  StringScanner scanner, {
  String name = 'quoted string',
}) {
  scanner.expect(_quotedString, name: name);
  final string = scanner.lastMatch![0]!;
  return string
      .substring(1, string.length - 1)
      .replaceAllMapped(_quotedPair, (match) => match[1]!);
}

class StringScanner {
  /// The string being scanned through.
  final String string;

  /// The current position of the scanner in the string, in characters.
  int get position => _position;
  set position(int position) {
    if (position < 0 || position > string.length) {
      throw ArgumentError('Invalid position $position');
    }

    _position = position;
    _lastMatch = null;
  }

  int _position = 0;

  /// The data about the previous match made by the scanner.
  ///
  /// If the last match failed, this will be `null`.
  Match? get lastMatch {
    // Lazily unset [_lastMatch] so that we avoid extra assignments in
    // character-by-character methods that are used in core loops.
    if (_position != _lastMatchPosition) _lastMatch = null;
    return _lastMatch;
  }

  Match? _lastMatch;
  int? _lastMatchPosition;

  /// The portion of the string that hasn't yet been scanned.
  String get rest => string.substring(position);

  /// Whether the scanner has completely consumed [string].
  bool get isDone => position == string.length;

  StringScanner(this.string, {int? position}) {
    if (position != null) this.position = position;
  }

  /// Returns the character code of the character [offset] away from [position].
  ///
  /// [offset] defaults to zero, and may be negative to inspect already-consumed
  /// characters.
  ///
  /// This returns `null` if [offset] points outside the string. It doesn't
  /// affect [lastMatch].
  int? peekChar([int? offset]) {
    offset ??= 0;
    final index = position + offset;
    if (index < 0 || index >= string.length) return null;
    return string.codeUnitAt(index);
  }

  /// If the next character in the string is [character], consumes it.
  ///
  /// Returns whether or not [character] was consumed.
  bool scanChar(int character) {
    if (isDone) return false;
    if (string.codeUnitAt(_position) != character) return false;
    _position++;
    return true;
  }

  /// If the next character in the string is [character], consumes it.
  ///
  /// If [character] could not be consumed, throws a [FormatException]
  /// describing the position of the failure. [name] is used in this error as
  /// the expected name of the character being matched; if it's `null`, the
  /// character itself is used instead.
  void expectChar(int character, {String? name}) {
    if (scanChar(character)) return;

    if (name == null) {
      if (character == _backslash) {
        name = r'"\"';
      } else if (character == _doubleQuote) {
        name = r'"\""';
      } else {
        name = '"${String.fromCharCode(character)}"';
      }
    }

    _fail(name);
  }

  Never error(String message, {Match? match, int? position, int? length}) {
    validateErrorArgs(string, match, position, length);

    if (match == null && position == null && length == null) match = lastMatch;
    position ??= match == null ? this.position : match.start;
    length ??= match == null ? 0 : match.end - match.start;

    throw const FormatException();
  }

  /// Throws a [FormatException] describing that [name] is expected at the
  /// current position in the string.
  Never _fail(String name) {
    error('expected $name.', position: position, length: 0);
  }

  /// If [pattern] matches at the current position of the string, scans forward
  /// until the end of the match.
  ///
  /// Returns whether or not [pattern] matched.
  bool scan(Pattern pattern) {
    final success = matches(pattern);
    if (success) {
      _position = _lastMatch!.end;
      _lastMatchPosition = _position;
    }
    return success;
  }

  /// If [pattern] matches at the current position of the string, scans forward
  /// until the end of the match.
  ///
  /// If [pattern] did not match, throws a [FormatException] describing the
  /// position of the failure. [name] is used in this error as the expected name
  /// of the pattern being matched; if it's `null`, the pattern itself is used
  /// instead.
  void expect(Pattern pattern, {String? name}) {
    if (scan(pattern)) return;

    if (name == null) {
      if (pattern is RegExp) {
        final source = pattern.pattern;
        name = '/$source/';
      } else {
        name =
            pattern.toString().replaceAll('\\', '\\\\').replaceAll('"', '\\"');
        name = '"$name"';
      }
    }
    _fail(name);
  }

  /// If the string has not been fully consumed, this throws a
  /// [FormatException].
  void expectDone() {
    if (isDone) return;
    _fail('no more input');
  }

  /// Returns whether or not [pattern] matches at the current position of the
  /// string.
  ///
  /// This doesn't move the scan pointer forward.
  bool matches(Pattern pattern) {
    _lastMatch = pattern.matchAsPrefix(string, position);
    _lastMatchPosition = _position;
    return _lastMatch != null;
  }

  /// Returns the substring of [string] between [start] and [end].
  ///
  /// Unlike [String.substring], [end] defaults to [position] rather than the
  /// end of the string.
  String substring(int start, [int? end]) {
    end ??= position;
    return string.substring(start, end);
  }
}

/// Validates the arguments passed to [StringScanner.error].
void validateErrorArgs(
    String string, Match? match, int? position, int? length) {
  if (match != null && (position != null || length != null)) {
    throw ArgumentError("Can't pass both match and position/length.");
  }

  if (position != null) {
    if (position < 0) {
      throw RangeError('position must be greater than or equal to 0.');
    } else if (position > string.length) {
      throw RangeError('position must be less than or equal to the '
          'string length.');
    }
  }

  if (length != null && length < 0) {
    throw RangeError('length must be greater than or equal to 0.');
  }

  if (position != null && length != null && position + length > string.length) {
    throw RangeError('position plus length must not go beyond the end of '
        'the string.');
  }
}

/// Character `"`.
const int _doubleQuote = 0x22;

/// Character `\`.
const int _backslash = 0x5C;

/// Runs [body] and wraps any format exceptions it produces.
///
/// [name] should describe the type of thing being parsed, and [value] should be
/// its actual value.
T wrapFormatException<T>(String name, String value, T Function() body) {
  try {
    return body();
  } on FormatException catch (error) {
    throw FormatException(
        'Invalid $name "$value": ${error.message}', error.source, error.offset);
  }
}

/// An HTTP token.
final token = RegExp(r'[^()<>@,;:"\\/[\]?={} \t\x00-\x1F\x7F]+');

/// Linear whitespace.
final _lws = RegExp(r'(?:\r\n)?[ \t]+');

/// A character that is *not* a valid HTTP token.
final nonToken = RegExp(r'[()<>@,;:"\\/\[\]?={} \t\x00-\x1F\x7F]');

/// A regular expression matching any number of [_lws] productions in a row.
final whitespace = RegExp('(?:${_lws.pattern})*');

class CaseInsensitiveMap<V> extends CanonicalizedMap<String, String, V> {
  CaseInsensitiveMap() : super((key) => key.toLowerCase());

  CaseInsensitiveMap.from(Map<String, V> other)
      : super.from(other, (key) => key.toLowerCase());
}

class CanonicalizedMap<C, K, V> implements Map<K, V> {
  final C Function(K) _canonicalize;

  final bool Function(K)? _isValidKeyFn;

  final _base = <C, MapEntry<K, V>>{};

  /// Creates an empty canonicalized map.
  ///
  /// The [canonicalize] function should return the canonical value for the
  /// given key. Keys with the same canonical value are considered equivalent.
  ///
  /// The [isValidKey] function is called before calling [canonicalize] for
  /// methods that take arbitrary objects. It can be used to filter out keys
  /// that can't be canonicalized.
  CanonicalizedMap(C Function(K key) canonicalize,
      {bool Function(K key)? isValidKey})
      : _canonicalize = canonicalize,
        _isValidKeyFn = isValidKey;

  /// Creates a canonicalized map that is initialized with the key/value pairs
  /// of [other].
  ///
  /// The [canonicalize] function should return the canonical value for the
  /// given key. Keys with the same canonical value are considered equivalent.
  ///
  /// The [isValidKey] function is called before calling [canonicalize] for
  /// methods that take arbitrary objects. It can be used to filter out keys
  /// that can't be canonicalized.
  CanonicalizedMap.from(Map<K, V> other, C Function(K key) canonicalize,
      {bool Function(K key)? isValidKey})
      : _canonicalize = canonicalize,
        _isValidKeyFn = isValidKey {
    addAll(other);
  }

  @override
  V? operator [](Object? key) {
    if (!_isValidKey(key)) return null;
    var pair = _base[_canonicalize(key as K)];
    return pair?.value;
  }

  @override
  void operator []=(K key, V value) {
    if (!_isValidKey(key)) return;
    _base[_canonicalize(key)] = MapEntry(key, value);
  }

  @override
  void addAll(Map<K, V> other) {
    other.forEach((key, value) => this[key] = value);
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) => _base.addEntries(entries
      .map((e) => MapEntry(_canonicalize(e.key), MapEntry(e.key, e.value))));

  @override
  Map<K2, V2> cast<K2, V2>() => _base.cast<K2, V2>();

  @override
  void clear() {
    _base.clear();
  }

  @override
  bool containsKey(Object? key) {
    if (!_isValidKey(key)) return false;
    return _base.containsKey(_canonicalize(key as K));
  }

  @override
  bool containsValue(Object? value) =>
      _base.values.any((pair) => pair.value == value);

  @override
  Iterable<MapEntry<K, V>> get entries =>
      _base.entries.map((e) => MapEntry(e.value.key, e.value.value));

  @override
  void forEach(void Function(K, V) f) {
    _base.forEach((key, pair) => f(pair.key, pair.value));
  }

  @override
  bool get isEmpty => _base.isEmpty;

  @override
  bool get isNotEmpty => _base.isNotEmpty;

  @override
  Iterable<K> get keys => _base.values.map((pair) => pair.key);

  @override
  int get length => _base.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K, V) transform) =>
      _base.map((_, pair) => transform(pair.key, pair.value));

  @override
  V putIfAbsent(K key, V Function() ifAbsent) => _base
      .putIfAbsent(_canonicalize(key), () => MapEntry(key, ifAbsent()))
      .value;

  @override
  V? remove(Object? key) {
    if (!_isValidKey(key)) return null;
    var pair = _base.remove(_canonicalize(key as K));
    return pair?.value;
  }

  @override
  void removeWhere(bool Function(K key, V value) test) =>
      _base.removeWhere((_, pair) => test(pair.key, pair.value));

  @override
  V update(K key, V Function(V) update, {V Function()? ifAbsent}) =>
      _base.update(_canonicalize(key), (pair) {
        var value = pair.value;
        var newValue = update(value);
        if (identical(newValue, value)) return pair;
        return MapEntry(key, newValue);
      },
          ifAbsent:
              ifAbsent == null ? null : () => MapEntry(key, ifAbsent())).value;

  @override
  void updateAll(V Function(K key, V value) update) =>
      _base.updateAll((_, pair) {
        var value = pair.value;
        var key = pair.key;
        var newValue = update(key, value);
        if (identical(value, newValue)) return pair;
        return MapEntry(key, newValue);
      });

  @override
  Iterable<V> get values => _base.values.map((pair) => pair.value);

  @override
  String toString() => MapBase.mapToString(this);

  bool _isValidKey(Object? key) =>
      (key is K) && (_isValidKeyFn == null || _isValidKeyFn!(key));
}
