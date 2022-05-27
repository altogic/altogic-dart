import 'dart:async';

import 'package:test/test.dart';

import 'utils/test_utils.dart';

void main() {
  setUp(() async {
    await createClientAndSignIn();
  });

  var taskCompleted = Completer<void>();

  var clearCompleter = Completer<void>();

  test('clear_db', () async {
    var res = await client.db
        .model('test')
        .filter('STARTSWITH(name , "test")')
        .delete();

    expect(res.errors, isNull);
    expect(res.data, isNotNull);

    clearCompleter.complete();
  });

  String? messageID;

  var submitCompleter = Completer<void>();

  test('submit', () async {
    await clearCompleter.future;

    var res = await client.queue.submitMessage('test_queue', {
      'test_instance': {'name': 'test2000', 'order': 2000}
    });

    expect(res.errors, isNull);
    expect(res.data, isNotNull);
    expect(res.data!.queueName, 'test_queue');
    messageID = res.data!.messageId;
    submitCompleter.complete();
  });

  test('status', () async {
    await submitCompleter.future;
    var res = await client.queue.getMessageStatus(messageID!);

    expect(res.data, isNotNull);
    expect(res.errors, isNull);

    taskCompleted.complete();
  });

  test('db_added', () async {
    await taskCompleted.future;
    var res = await client.db.model('test').filter('order == 2000').get();
    expect(res.data, isNotNull);
    expect(res.data, isA<List<dynamic>>());
    expect(res.data as List<dynamic>, isNotEmpty);
  });
}
