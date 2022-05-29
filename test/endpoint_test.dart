import 'package:altogic_dart/altogic_dart.dart';
import 'package:test/test.dart';

import 'utils/test_utils.dart';

void main() {
  setUp(() async {
    await createClientAndSignIn();
  });

  /// Test GET method and arguments
  test(skip: false, 'get', () async {
    var arg = '6291293d89d9d8c0ac12a7cf';

    var res = await client.endpoint.get('/test/get/$arg').asMap();

    expect(res.errors, isNull);
    expect(res.data, isNotNull);
    expect(res.data!['argument'], arg);
  });

  /// Test POST method and request body
  test(skip: false, 'post', () async {
    var res = await client.endpoint.post('/test/post', body: {
      'string_field': 'string',
      'bool_field': true,
      'int_field': 10
    }).asMap();

    expect(res.errors, isNull);
    expect(res.data, isNotNull);
    expect(res.data!['data'], isA<Map<String, dynamic>>());

    var data = res.data!['data'] as JsonMap;

    expect(data['string_field'], 'string');
    expect(data['bool_field'], true);
    expect(data['int_field'], 10);
  });

  /// Test PUT method and query_parameters
  test(skip: false, 'put', () async {
    var res = await client.endpoint.put('/test/put', queryParams: {
      'param1': 'string',
      'param2': true,
      'param3': 10
    }).asMap();

    expect(res.errors, isNull);
    expect(res.data, isNotNull);

    expect(res.data!['query'], isA<Map<String, dynamic>>());

    var data = res.data!['query'] as JsonMap;

    expect(data['param1'], 'string');
    expect(data['param2'], true);
    expect(data['param3'], 10);
  });

  /// Test DELETE method and headers
  test(skip: false, 'delete', () async {
    var res = await client.endpoint.delete('/test/delete',
        headers: {'testheader': 'string', 'testheader2': 10}).asMap();

    expect(res.errors, isNull);
    expect(res.data, isNotNull);

    expect(res.data!['headers'], isA<Map<String, dynamic>>());

    var data = res.data!['headers'] as JsonMap;

    expect(data['testheader'], 'string');
    expect(data['testheader2'], 10);
  });
}
