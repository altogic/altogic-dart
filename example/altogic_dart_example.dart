import 'package:altogic_dart/altogic_dart.dart';

Future<void> main() async {
  var client = await AltogicClient.init(
      envUrl: '{YOUR-REMOTE-URL}', clientKey: '{YOUR-CLIENT-KEY}');

  var signIn =
      await client.auth.signInWithEmail('mehmedyaz@gmail.com', 'mehmetyaz');

  if (signIn.errors != null) {
    // signed in
  } else {
    // error
  }

  var dbRes = await client.db.model('car').create({'car_name': 'My car'});

  if (dbRes.errors != null) {
    print(dbRes.data);
  }
}
