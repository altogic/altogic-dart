import 'package:altogic_dart/altogic_dart.dart';

Future<void> main() async {
  var client =
      createClient('https://c1-na.altogic.com/e:....207', '5ad85....a7c26');

  await client.auth.signInWithEmail('mehmedyaz@gmail.com', 'mehmetyaz');

  var res = await client.db.getStats();

  print(res.data);
}
