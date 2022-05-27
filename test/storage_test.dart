import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:altogic_dart/altogic_dart.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

import 'utils/test_utils.dart';

void main() {
  setUp(() async {
    await createClientAndSignIn();
  });

  var createCompleter = Completer<void>();

  var testFileName = 'my_test_file_6.html';

  var fileContent = "${'test _ ' * 10}\n" * 10;
  var fileBytes = utf8.encode(fileContent) as Uint8List;

  test('create', () async {
    var res = await client.storage.root.upload(
        testFileName,
        fileBytes,
        FileUploadOptions(
            isPublic: true,
            contentType: 'text/html;charset=UTF-8',
            onProgress: (total, uploaded, percent) {
              print('up: $uploaded , tot : $total  % : $percent');
            }));

    expect(res.errors, isNull);
    expect(res.data, isNotNull);
    expect(res.data!['publicPath'], isNotNull);

    var publicPath = res.data!['publicPath'] as String;

    var getRes = await get(Uri.parse(publicPath));

    expect(getRes.body, "${'test _ ' * 10}\n" * 10);
    expect(getRes.headers['content-type'], 'text/html');

    createCompleter.complete();
  });

  var existsCompleter = Completer<void>();

  test('exists', () async {
    await createCompleter.future;

    var res = await client.storage.root.file(testFileName).exists();

    expect(res.data, isNotNull);
    expect(res.errors, isNull);
    expect(res.data, true);

    existsCompleter.complete();
  });

  var downloadCompleter = Completer<void>();

  test('download', () async {
    await existsCompleter.future;

    var res = await client.storage.root.file(testFileName).download();

    expect(res.data, isNotNull);
    expect(res.errors, isNull);
    expect(const ListEquality<int>().equals(res.data, fileBytes), true);

    downloadCompleter.complete();
  });

  var listCompleter = Completer<void>();

  test('list_file', () async {
    await downloadCompleter.future;
    var res = await client.storage.root
        .listFiles(expression: 'fileName == "$testFileName"');

    expect(res.data, isNotNull);
    expect(res.errors, isNull);
    expect(res.data, isA<List<dynamic>>());
    expect((res.data as List).first, isA<Map<String, dynamic>>());
    expect(((res.data as List).first as Map<String, dynamic>)['fileName'],
        testFileName);
    listCompleter.complete();
  });
}
