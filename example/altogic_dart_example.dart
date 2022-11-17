/*

Flutter Altogic Client Package Examples:

- You can see the authentication basics with [Quickstart Guide](https://www.altogic.com/client/quick-start-authentication/with-flutter)
- You can try all methods and see the code blocks in the [Example/Test Application](https://altogic-flutter-example.netlify.app)
- Also you can see the basics with the [Example TO-DO Application](https://www.altogic.com/client/quick-start/quick-start-flutter)

For More Information About Altogic:

-  🚀 [Quick start](https://www.altogic.com/docs/quick-start)
-  📜 [Altogic Docs](https://www.altogic.com/docs)
-  💬 [Discord community](https://discord.gg/ERK2ssumh8)
-  📰 [Discussion forums](https://community.altogic.com)

 */

import 'package:altogic_dart/altogic_dart.dart';

Future<void> main() async {
  var client =
      createClient('https://c1-na.altogic.com/e:....207', '5ad85....a7c26');

  await client.auth.signInWithEmail('mehmet@altogic.com', 'mehmetyaz');

  var res = await client.db.getStats();

  print(res.data);
}
