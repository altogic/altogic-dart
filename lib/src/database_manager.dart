part of altogic_dart;

/// The database manager allows you manage your applications database.
/// With DatabaseManager you can create new objects in your data model,
/// update or delete existing ones, run queries and paginate over large
/// data sets.
class DatabaseManager extends APIBase {
  /// Creates an instance of DatabaseManager to manage data of your application.
  /// [_fetcher] The http client to make RESTful API calls to the application's
  /// execution engine.
  DatabaseManager(super.fetcher);

  /// Creates a new [QueryBuilder] for the specified model.
  ///
  /// In Altogic, models define the data structure and data validation rules
  /// of your applications. A model is composed of basic, advanced, and
  /// sub-model fields. As an analogy, you can think of models as tables
  /// and fields as columns in relational databases.
  ///
  /// You can specify a top-level model or a sub-model name for this method.
  /// As an example if you have a model named `users` where you keep your
  /// app users information you can create a [QueryBuilder] for `users`
  /// model by calling `altogic.db.model('users')`
  ///
  /// In case you need to work on a sub-model object, such as your users might
  /// have a list of addresses and these addresses are stored under a users
  /// object, you can create a [QueryBuilder] for `addresses` sub-model
  /// using the *dot-notation* by calling `altogic.db.model('users.addresses')`
  ///
  /// [name] The name of the model
  ///
  /// Returns a new query builder object that will be issuing
  /// database commands (e.g., CRUD operations, queries) on the specified model
  QueryBuilder model(String name) => QueryBuilder(name, _fetcher);

  /// Returns the overall information about your apps database and its models.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// Returns information about your app's database
  Future<APIResponse<List<dynamic>>> getStats() =>
      _fetcher.get<List<dynamic>>('/_api/rest/v1/db/stats');
}
