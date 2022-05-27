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

  test(skip: true, 'task_stat', () async {
    await clearCompleter.future;

    var res = await client.task.getTaskStatus('628e0252554db618f045c398');

    print(res.data?.toJson());
    print(res.errors);
    expect(res.errors, isNull);
    expect(res.data, isNotNull);
    expect(res.data!.taskId, '628e0252554db618f045c398');
  });

  test(skip: false, 'task_run', () async {
    await clearCompleter.future;
    var res = await client.task.runOnce('628e0252554db618f045c398');

    print(res.data?.toJson());
    print(res.errors);

    expect(res.data, isNotNull);
    expect(res.errors, isNull);

    taskCompleted.complete();
  });

  test('db_added', () async {
    //await taskCompleted.future;

    var res = await client.db.model('test').filter('order == 1000').get();

    print(res.data);
    expect(res.data, isNotNull);
    expect(res.data, isA<List<dynamic>>());
    expect(res.data as List<dynamic>, isNotEmpty);
  });
}
