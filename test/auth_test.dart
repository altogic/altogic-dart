import 'dart:async';

import 'package:altogic_dart/src/auth_manager.dart';
import 'package:test/test.dart';

import 'utils/test_utils.dart';

void main() {
  setUp(() async {
    await createClient();
    return;
  });

  group('auth', () {
    // skipped, already signed up
    // change mail address for re-test

    var signUpCompleter = Completer<void>();

    test(skip: true, 'sign_up', () async {
      var auth = client.auth;
      var signUp =
          await auth.signUpWithEmail('testmail3@example.com', 'test_pass');
      expect(signUp.errors, isNull);
      // email verification open
      expect(signUp.session, isNull);

      expect(signUp.user, isNotNull);

      expect(signUp.user?.email, 'testmail3@example.com');
      expect(signUp.user?.provider, 'altogic');
      signUpCompleter.complete();
    });
    //testCount++;
    late AuthManager auth;

    var alreadyCompleter = Completer<void>();

    test('sign_up_already', () async {
      //await signUpCompleter.future;
      auth = client.auth;
      var signUp =
          await auth.signUpWithEmail('testmail2@example.com', 'test_pass');
      expect(signUp.errors, isNotNull);
      // email verification open
      expect(signUp.session, isNull);

      expect(signUp.user, isNull);
      alreadyCompleter.complete();
    });

    var failCompleter = Completer<void>();

    test('sign_in_fail', () async {
      await alreadyCompleter.future;

      var signInRes = await auth.signInWithEmail(
          'mehmedyaz@gmail.com', 'wrong_pwd'); //correct mehmetyaz

      expect(signInRes.errors, isNotNull);
      expect(signInRes.user, isNull);
      expect(signInRes.session, isNull);

      failCompleter.complete();
    });

    test('sign_in_success', () async {
      await failCompleter.future;

      var signInRes =
          await auth.signInWithEmail('mehmedyaz@gmail.com', 'mehmetyaz');

      expect(signInRes.errors, isNull);
      expect(signInRes.user, isNotNull);
      expect(signInRes.session, isNotNull);
    });
  });
}
