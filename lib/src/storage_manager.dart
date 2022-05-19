import '../altogic_dart.dart';

class StorageManager extends APIBase {
  StorageManager(super.fetcher);

  BucketManager bucket(String nameOrId) => BucketManager(nameOrId, fetcher);

  Future<APIResponse<Map<String, dynamic>>> createBucket(String name,
      [bool isPublic = true]) async {
    var res = await fetcher.post<Map<String, dynamic>>(
        '/_api/rest/v1/storage/create-bucket',
        body: {'name': name, 'isPublic': isPublic});
    return APIResponse(errors: res.errors, data: res.data);
  }

  Future<APIResponse<dynamic>> listBuckets(
          {String? expression, BucketListOptions? options}) =>
      fetcher.post('/_api/rest/v1/storage/list-buckets',
          body: {'expression': expression, 'options': options?.toJson()});

  BucketManager get root => BucketManager('root', fetcher);

  Future<APIResponse<Map<String, dynamic>>> getStats() =>
      fetcher.get<Map<String, dynamic>>('/_api/rest/v1/storage/stats');

  Future<APIResponse<List<Map<String, dynamic>>>> searchFiles(String expression,
      [FileListOptions? options]) async {
    var res = await fetcher.post<List<dynamic>>(
        '/_api/rest/v1/storage/search-files',
        body: {'expression': expression, 'options': options?.toJson()});

    return APIResponse(
        data: (res.data as List).cast<Map<String, dynamic>>(),
        errors: res.errors);
  }

  Future<APIError?> deleteFile(String fileUrl) async =>
      fetcher.post<dynamic>('/_api/rest/v1/storage/delete-file',
          body: {'fileUrl': fileUrl}).then((value) => value.errors);
}
