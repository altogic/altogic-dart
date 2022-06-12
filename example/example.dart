import 'package:altogic_dart/altogic_dart.dart';

void main() async {
  var client = AltogicClient(
      'https://c1-na.altogic.com/e:62863f06bb75ed002ed0f207',
      '5ad8526dbd014613a8dbeff60daa7c26');

  var auth =
      await client.auth.signInWithEmail('mehmedyaz@gmail.com', 'mehmetyaz');

  if (auth.errors == null) {
    var res =
        await client.db.model('test').filter('STARTSWITH(name , test)').get();

    print(res.errors);
    print(res.data);
  } else {
    print(auth.errors);
  }
}
