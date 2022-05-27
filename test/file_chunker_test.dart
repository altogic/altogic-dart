import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:test/test.dart';

const equality = ListEquality<int>();

void main() {
  testWithLength(10);
  testWithLength(100);
  testWithLength(1000);
  testWithLength(10000);
  testWithLength(100000);
  testWithLength(1000000);
  testWithLength(10000000);
  testWithLength(100000000);
}

void testWithLength(int length) {
  test('$length eq', () async {
    var bytes = generateRandomBytes(length);
    var stream = splitToStream(bytes);
    var read = await readStream(stream);
    expect(equality.equals(bytes, read), true);
  });
}

Uint8List generateRandomBytes(int length) =>
    Uint8List.fromList(List.generate(length, (index) => Random().nextInt(255)));

Stream<List<int>> splitToStream(Uint8List bytes) {
  var chunk = 32 * 1024;
  var number = (bytes.length / chunk).ceil();
  return Stream.fromIterable(List.generate(
      number,
      (index) => bytes.sublist(index * chunk,
          index != number - 1 ? ((index + 1) * chunk) : null)));
}

Future<Uint8List> readStream(Stream<List<int>> stream) async {
  var l = await stream.toList();
  var list = <int>[];
  for (var il in l) {
    list.addAll(il);
  }
  return Uint8List.fromList(list);
}
