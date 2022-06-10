import 'package:altogic_dart/altogic_dart.dart';

AltogicClient createClient() => client = AltogicClient(
     'https://c1-na.altogic.com/e:62863f06bb75ed002ed0f207',
    '5ad8526dbd014613a8dbeff60daa7c26');

Future<AltogicClient> createClientAndSignIn() async {
  client = AltogicClient(
      'https://c1-na.altogic.com/e:62863f06bb75ed002ed0f207',
       '5ad8526dbd014613a8dbeff60daa7c26');

  await client.auth.signInWithEmail('mehmedyaz@gmail.com', 'mehmetyaz');

  return client;
}

late AltogicClient client;
