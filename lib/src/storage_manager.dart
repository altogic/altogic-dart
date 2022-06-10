import '../altogic_dart.dart';

/// Allows you manage your app's cloud storage buckets and files. With
/// [StorageManager] you can create and list buckets and use the [BucketManager]
/// to manage a specific bucket and and its contained files.
///
/// You store your files, documents, images etc. under buckets, which are the
/// basic containers that hold your application data. You typically create a
/// bucket and upload files/objects to this bucket.
///
/// When you deploy your app to an environment Altogic creates a default bucket
/// called `root`. The `root` bucket helps you to group your app files that are
/// not under any other bucket. Any file upload, which does not specify a
/// bucket, is uploaded to the `root` bucket.
///
/// You cannot rename or delete `root` bucket, but you can empty its contents
/// and change its default privacy setting. By default the files contained in
/// `root` bucket is publicly accessible through their URLs. You can change
/// the default privacy setting of the `root` bucket using the
/// [BucketManager.makePublic] or [BucketManager.makePrivate] methods.
class StorageManager extends APIBase {
  /// Creates an instance of [StorageManager] to manage storage (i.e., files)
  /// of your application.
  ///
  /// [fetcher] The http client to make RESTful API calls to the application's
  /// execution engine
  StorageManager(super.fetcher);

  /// Creates a new [BucketManager] object for the specified bucket.
  ///
  /// Buckets are the basic containers that hold your application data
  /// (i.e., files). Everything that you store in your app storage must
  /// be contained in a bucket. You can use buckets to organize your data and
  /// control access to your data, but unlike directories and folders, you
  /// cannot nest buckets.
  ///
  /// Altogic automatically provides a default **`root`** bucket where you can
  /// store your files. You can pretty much do everthing with the **`root`**
  /// bucket that you can do with a normal bucket except you cannot delete or
  /// rename it.
  ///
  /// [nameOrId] The name or id of the bucket.
  ///
  /// Returns a new [BucketManager] object that will be used for managing the
  /// bucket
  BucketManager bucket(String nameOrId) => BucketManager(nameOrId, fetcher);

  /// Creates a new bucket. If there already exists a bucket with the specified
  /// name, it returns an error.
  ///
  /// Files can be specified as **public** or **private**, which defines how the
  /// public URL of the file will behave. If a file is marked as private then
  /// external apps/parties will not be able to access it through its public
  /// URL. With [isPublic] parameter of a bucket, you can specify default
  /// privacy setting of the files contained in this bucket, meaning that when
  /// you add a file to a bucket and if the file did not specify public/private
  /// setting, then the the bucket's privacy setting will be applied. You can
  /// always override the default privacy setting of a bucket at the individual
  /// file level.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [name] The name of the bucket to create (case sensitive). [root] is a
  /// reserved name and cannot be used.
  ///
  /// [isPublic] The default privacy setting that will be applied to the files
  /// uploaded to this bucket.
  ///
  /// [tags] List of string values that will be added to the bucket metadata.
  ///
  /// Returns info about newly created bucket
  Future<APIResponse<Map<String, dynamic>>> createBucket(String name,
      [bool isPublic = true, List<String> tags = const []]) async {
    var res = await fetcher.post<Map<String, dynamic>>(
        '/_api/rest/v1/storage/create-bucket',
        body: {'name': name, 'isPublic': isPublic, 'tags': tags});
    return APIResponse(errors: res.errors, data: res.data);
  }

  /// Gets the list of buckets in your app cloud storage. If query [expression]
  /// is specified, it runs the specified filter query to narrow down returned
  /// results, otherwise, returns all buckets contained in your app's
  /// cloud storage. You can use the following bucket fields in your
  /// query expressions.
  ///
  /// | Field name | Type | Desciption |
  /// | :--- | :--- | :--- |
  /// | _id | `text` *(`identifier`)* | Unique identifier of the file |
  /// | name | `text` | Name of the bucket |
  /// | isPublic | `boolean` | Default privacy setting that will be applied to files of the bucket |
  /// | createdAt | `datetime` *(`text`)* | The creation date and time of the bucket |
  /// | updatedAt | `datetime` *(`text`)* | The last modification date and time of bucket metadata |
  ///
  /// You can paginate through your buckets and sort them using the input
  /// [BucketListOptions] parameter.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [expression] The query expression string that will be used to filter buckets
  ///
  /// [options] Options to configure how buckets will be listed, primarily
  /// used to set pagination and sorting settings
  ///
  /// Returns the array of matching buckets. If `returnCountInfo=true` in
  /// [BucketListOptions], it returns an object which includes the count
  /// information and the matching buckets array.
  Future<APIResponse<dynamic>> listBuckets(
          {String? expression, BucketListOptions? options}) =>
      fetcher.post('/_api/rest/v1/storage/list-buckets',
          body: {'expression': expression, 'options': options?.toJson()});

  //ignore_for_file: lines_longer_than_80_chars

  /// Returns a [BucketManager] for the [root] bucket. It is equivalent to
  /// calling `bucket('root')`
  BucketManager get root => BucketManager('root', fetcher);

  /// Returns the overall information about your apps cloud storage including
  /// total number of buckets and files stored, total storage size in bytes
  /// and average, min and max file size in bytes.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// Returns information about your app's cloud storage
  Future<APIResponse<Map<String, dynamic>>> getStats() =>
      fetcher.get<Map<String, dynamic>>('/_api/rest/v1/storage/stats');

  /// Gets the list of files matching the search expression. This method
  /// performs a global search across all the files contained in all the
  /// buckets. You can use the following file fields in your search expression.
  ///
  /// | Field name | Type | Description
  /// | :--- | :--- | :--- |
  /// | _id | `text` *(`identifier`)* | Unique identifier of the file |
  /// | bucketId | `text` *(`identifier`)* | Identifier of the bucket |
  /// | fileName | `text` | Name of the file |
  /// | isPublic | `boolean` | Whether file is publicy accessible or not |
  /// | size | `integer` | Size of the file in bytes |
  /// | encoding | `text` | The encoding type of the file such as `7bit`, `utf8` |
  /// | mimeType | `text` | The mime-type of the file such as `image/gif`, `text/html` |
  /// | publicPath | `text` | The public path (URL) of the file |
  /// | uploadedAt | `datetime` *(`text`)* | The upload date and time of the file |
  /// | updatedAt | `datetime` *(`text`)* | The last modification date and time of file metadata |
  ///
  /// You can paginate through your files and sort them using the input
  /// [FileListOptions] parameter.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [expression] The search expression string that will be used to filter
  /// file objects
  ///
  /// [options] Pagination and sorting options
  ///
  /// Returns the files matching the search query. If `returnCountInfo=true`
  /// in [FileListOptions], returns an object which includes count information
  /// and array of matching files.
  Future<APIResponse<List<Map<String, dynamic>>>> searchFiles(String expression,
      [FileListOptions? options]) async {
    var res = await fetcher.post<List<dynamic>>(
        '/_api/rest/v1/storage/search-files',
        body: {'expression': expression, 'options': options?.toJson()});

    return APIResponse(
        data: (res.data as List).cast<Map<String, dynamic>>(),
        errors: res.errors);
  }

  /// Deletes a file identified by the url string. You can directly use this
  /// method to delete any file that you know its url (e.g., no need to
  /// specify bucket name/id and file name/id)
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [fileUrl] The url of the file that will be deleted
  Future<APIError?> deleteFile(String fileUrl) =>
      fetcher.post<dynamic>('/_api/rest/v1/storage/delete-file',
          body: {'fileUrl': fileUrl}).then((value) => value.errors);
}
