import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'utils/test_utils.dart';

void main() {
  group('altogic', () {
    test('init', () async {
      await expectLater(() async {
        await createClient();
      }, returnsNormally);
      // ensure late initilizer [client] is initialized.

      expect(() {
        client.auth;
      }, returnsNormally);
    });
  });
}

// test draft

// test('name', () async {
// await waitCompleter();
//
// setCompleter();
// });
