import 'dart:typed_data';

import '../altogic_dart.dart';

/// BucketManager is primarily used to manage a bucket and its contents
/// (e.g., files, documents, images). Using the {@link StorageManager.bucket}
/// method, you can create a BucketManager instance for a specific bucket
/// identified by its unique name or id.
///
/// > Each object uploaded to a bucket needs to have a unique name. You cannot
/// upload a file with the same name multiple times to a bucket.
///
/// @export
/// @class BucketManager
class BucketManager extends APIBase {
  /// Creates an instance of BucketManager to manage a specific
  /// bucket of your cloud storage
  /// @param {string} nameOrId The name or id of the bucket that this
  /// bucket manager will be operating on
  /// @param {Fetcher} fetcher The http client to make RESTful API calls
  /// to the application's execution engine
  BucketManager(this._bucketNameOrId, super.fetcher);

  /// The name of the bucket that the bucket manager will be operating on
  /// @private
  /// @type {string}
  final String _bucketNameOrId;

  /// Check if the bucket exists.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  /// @returns Returns true if bucket exists, false otherwise
  Future<APIResponse<bool>> exists() {
    if (_bucketNameOrId == 'root') return Future.value(APIResponse(data: true));

    return fetcher.post<bool>('/_api/rest/v1/storage/bucket/exists',
        body: {'bucket': _bucketNameOrId});
  }

  /// Gets information about the bucket. If `detailed=true`, it provides
  /// additional information about the total number of files contained, their
  /// overall total size in bytes, average, min and max file size in bytes etc.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  /// @param {boolean} detailed Specifies whether to get detailed bucket
  /// statistics or not
  /// @returns Returns basic bucket metadata informaton. If `detailed=true`
  /// provides additional information about contained files.
  Future<APIResponse<Map<String, dynamic>>> getInfo([bool detailed = false]) =>
      fetcher.post<Map<String, dynamic>>('/_api/rest/v1/storage/bucket/get',
          body: {'detailed': detailed, 'bucket': _bucketNameOrId});

  /// Renames the bucket.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  /// @param {string} newName The new name of the bucket. `root` is a
  /// reserved name and cannot be used.
  /// @returns Returns the updated bucket information
  Future<APIError?> empty() async =>
      (await fetcher.post<dynamic>('/_api/rest/v1/storage/bucket/empty', body: {
        'bucket': _bucketNameOrId,
      }))
          .errors;

  /// Renames the bucket.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  /// @param {string} newName The new name of the bucket. `root` is a reserved
  /// name and cannot be used.
  /// @returns Returns the updated bucket information
  Future<APIResponse<Map<String, dynamic>>> rename(String newName) =>
      fetcher.post<Map<String, dynamic>>('/_api/rest/v1/storage/bucket/rename',
          body: {'newName': newName, 'bucket': _bucketNameOrId});

  /// Deletes the bucket and all objects (e.g., files) inside the bucket.
  /// Returns an error if `root` bucket is tried to be deleted.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  Future<APIError?> delete() async => (await fetcher
              .post<dynamic>('/_api/rest/v1/storage/bucket/delete', body: {
        'bucket': _bucketNameOrId,
      }))
          .errors;

  /// Sets the default privacy of the bucket to **true**. You may also choose
  /// to make the contents of the bucket publicly readable by specifying
  /// `includeFiles=true`. This will automatically set `isPublic=true` for
  /// every file in the bucket.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  /// @param {boolean} includeFiles Specifies whether to make each file in
  /// the bucket public.
  /// @returns Returns the updated bucket information
  Future<APIResponse<Map<String, dynamic>>> makePublic(
          [bool includeFiles = false]) =>
      fetcher.post<Map<String, dynamic>>(
          '/_api/rest/v1/storage/bucket/make-public',
          body: {'includeFiles': includeFiles, 'bucket': _bucketNameOrId});

  /// Sets the default privacy of the bucket to **true**. You may also choose
  /// to make the contents of the bucket publicly readable by specifying
  /// `includeFiles=true`. This will automatically set `isPublic=true` for
  /// every file in the bucket.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  /// @param {boolean} includeFiles Specifies whether to make each file
  /// in the bucket public.
  /// @returns Returns the updated bucket information
  Future<APIResponse<Map<String, dynamic>>> makePrivate(
          [bool includeFiles = false]) =>
      fetcher.post<Map<String, dynamic>>(
          '/_api/rest/v1/storage/bucket/make-private',
          body: {'includeFiles': includeFiles, 'bucket': _bucketNameOrId});

  //ignore_for_file: lines_longer_than_80_chars

  /// Gets the list of files stored in the bucket. If query `expression`
  /// is specified, it runs the specified filter query to narrow down returned
  /// results, otherwise, returns all files contained in the bucket. You can
  /// use the following file fields in your query expressions.
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
  /// {@link FileListOptions} parameter.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  /// @param {string} expression The query expression string that will be used
  /// to filter file objects
  /// @param {FileListOptions} options Pagination and sorting options
  /// @returns Returns the array of files. If `returnCountInfo=true` in
  /// {@link FileListOptions}, returns an object which includes count
  /// information and array of files.
  Future<APIResponse<dynamic>> listFiles(
          {String? expression, FileListOptions? options}) =>
      fetcher.post('/_api/rest/v1/storage/bucket/list-files', body: {
        'expression': expression,
        'options': options?.toJson(),
        'bucket': _bucketNameOrId,
      });

  Future<APIResponse<Map<String, dynamic>>> upload(
          String fileName, Uint8List fileBody, [FileUploadOptions? options]) =>
      fetcher.upload<Map<String, dynamic>>(
          '/_api/rest/v1/storage/bucket/upload-formdata',
          fileBody,
          fileName,
          options?.contentType ?? DEFAULT_FILE_OPTIONS.contentType!,
          query: {
            'bucket': _bucketNameOrId,
            'fileName': fileName,
            'options': DEFAULT_FILE_OPTIONS.merge(options).toJson(),
          },
          onProgress: options?.onProgress);

  FileManager file(String fileNameOrId) =>
      FileManager(_bucketNameOrId, fileNameOrId, fetcher);

  Future<APIError?> deleteFiles(List<String> fileNamesOrIds) async =>
      (await fetcher.post<dynamic>('/_api/rest/v1/storage/bucket/delete-files',
              body: {
            'fileNamesOrIds': fileNamesOrIds,
            'bucket': _bucketNameOrId
          }))
          .errors;
}

//ignore:constant_identifier_names
const FileUploadOptions DEFAULT_FILE_OPTIONS = FileUploadOptions(
    contentType: 'text/plain;charset=UTF-8',
    createBucket: false,
    isPublic: false);
