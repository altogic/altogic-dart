import 'dart:async';
import 'package:altogic_dart/altogic_dart.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

import 'utils/test_utils.dart';

void main() {
  setUp(() async {
    await createClientAndSignIn();
    return;
  });

  group('db', () {
    late DatabaseManager db;
    var clearCompleter = Completer<void>();

    test('clear_db', () async {
      db = client.db;
      var res =
          await db.model('test').filter('STARTSWITH(name , "test")').delete();

      expect(res.errors, isNull);
      expect(res.data, isNotNull);

      clearCompleter.complete();
    });

    var createCompleter = Completer<void>();
    late String singleID;
    test(
      'create_single_object',
      () async {
        await clearCompleter.future;
        var created =
            (await db.model('test').create({'name': 'test1', 'order': 0}))
                .cast<Map<String, dynamic>>();

        expect(created.errors, isNull);
        expect(created.data, isNotNull);
        expect(created.data!['_id'], isNotNull);
        expect(created.data!['name'], 'test1');

        singleID = created.data!['_id'] as String;

        createCompleter.complete();
      },
    );

    var createMultipleCompleter = Completer<void>();

    late String id2, id3, id4;

    test(
      'create_multiple_object',
      () async {
        await createCompleter.future;
        var created = (await db.model('test').create([
          {'_id': 'test2_id', 'name': 'test2', 'order': 1},
          {'_id': 'test3_id', 'name': 'test3', 'order': 2},
          {'_id': 'test4_id', 'name': 'test4', 'order': 3},
        ]))
            .cast<List<dynamic>>();

        expect(created.errors, isNull);
        expect(created.data, isNotNull);
        expect(created.data!.length, 3);

        id2 = (created.data!.firstWhere((element) =>
                (element as Map<String, dynamic>)['name'] == 'test2')
            as Map<String, dynamic>)['_id'] as String;

        id3 = (created.data!.firstWhere((element) =>
                (element as Map<String, dynamic>)['name'] == 'test3')
            as Map<String, dynamic>)['_id'] as String;

        id4 = (created.data!.firstWhere((element) =>
                (element as Map<String, dynamic>)['name'] == 'test4')
            as Map<String, dynamic>)['_id'] as String;

        createMultipleCompleter.complete();
      },
    );

    var readsCompleters = List.generate(3, (index) => Completer<void>());

    test(
      'read with id',
      () async {
        await createMultipleCompleter.future;

        var obj = await db.model('test').object(singleID).get();

        expect(obj.errors, isNull);
        expect(obj.data, isNotNull);
        expect(obj.data, {'_id': singleID, 'name': 'test1', 'order': 0});

        readsCompleters[0].complete();
      },
    );

    test(
      'read single with filter',
      () async {
        await createMultipleCompleter.future;
        var obj = await db.model('test').filter('order == 1').get();

        expect(obj.errors, isNull);
        expect(obj.data, isNotNull);
        expect(obj.data, [
          {'_id': id2, 'name': 'test2', 'order': 1}
        ]);

        readsCompleters[1].complete();
      },
    );

    test(
      'read multiple with filter',
      () async {
        await createMultipleCompleter.future;
        var obj = await db.model('test').filter('order > 1').get();
        var equality = const DeepCollectionEquality.unordered().equals;
        expect(obj.errors, isNull);
        expect(obj.data, isNotNull);
        expect(
            equality(obj.data, [
              {'_id': id3, 'name': 'test3', 'order': 2},
              {'_id': id4, 'name': 'test4', 'order': 3},
            ]),
            true);

        readsCompleters[2].complete();
      },
    );

    var updateCompleter = Completer<void>();

    test(
      'update',
      () async {
        await Future.wait(readsCompleters.map((e) => e.future));
        var obj = await db.model('test').object(id2).update({'order': 10});

        expect(obj.data, isNotNull);
        expect(obj.errors, isNull);

        expect(obj.data, {'_id': id2, 'name': 'test2', 'order': 10});

        //ensure updated
        var nObj = await db.model('test').object(id2).get();

        expect(nObj.data, isNotNull);
        expect(nObj.errors, isNull);

        expect(nObj.data, {'_id': id2, 'name': 'test2', 'order': 10});

        updateCompleter.complete();
      },
    );
  });
}
