part of altogic_dart;

/// [FileManager] is primarily used to manage a file. Using the
/// [BucketManager.file] method, you can create a FileManager instance for a
/// specific file identified by its unique name or id.
class FileManager extends APIBase {
  /// Creates an instance of [FileManager] to manage a specific bucket of your
  /// cloud storage.
  ///
  /// [bucketNameOrId] The name or id of the bucket that this file is contained
  /// in.
  ///
  /// [fileNameOrId] The name of id of the file that this file manager will
  /// be operating on.
  ///
  /// [_fetcher] The http client to make RESTful API calls to the application's
  /// execution engine.
  FileManager(String bucketNameOrId, String fileNameOrId, super.fetcher)
      : _bucketNameOrId = bucketNameOrId,
        _fileNameOrId = fileNameOrId;

  /// The name or id of the bucket
  final String _bucketNameOrId;

  /// The name or id of the file
  final String _fileNameOrId;

  Future<APIResponse<T>> _call<T>(String path,
          {ResolveType? resolveType,
          String? newName,
          String? duplicateName,
          String? bucketNameOrId}) =>
      _fetcher.post<T>(path,
          body: {
            if (newName != null) 'newName': newName,
            if (duplicateName != null) 'duplicateName': duplicateName,
            if (bucketNameOrId != null) 'bucketNameOrId': bucketNameOrId,
            'file': _fileNameOrId,
            'bucket': _bucketNameOrId
          },
          resolveType: resolveType ?? ResolveType.json);

  /// Check if the file exists. It returns false if file does not exist.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// Returns true if file exists, false otherwise
  Future<APIResponse<bool>> exists() =>
      _call<bool>('/_api/rest/v1/storage/bucket/file/exists');

  /// Gets information about the file.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// Returns basic file metadata informaton.
  Future<APIResponse<Map<String, dynamic>>> getInfo() =>
      _call<Map<String, dynamic>>('/_api/rest/v1/storage/bucket/file/get');

  /// Sets the default privacy of the file to **true**.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// Returns the updated file information
  Future<APIResponse<Map<String, dynamic>>> makePublic() =>
      _call<Map<String, dynamic>>(
          '/_api/rest/v1/storage/bucket/file/make-public');

  /// Sets the default privacy of the file to **false**.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// Returns the updated file information
  Future<APIResponse<Map<String, dynamic>>> makePrivate() =>
      _call<Map<String, dynamic>>(
          '/_api/rest/v1/storage/bucket/file/make-private');

  /// Downloads the file.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// Returns the contents of the file in a `Blob`
  Future<APIResponse<Uint8List>> download() =>
      _call<Uint8List>('/_api/rest/v1/storage/bucket/file/download',
          resolveType: ResolveType.blob);

  /// Renames the file.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [newName] The new name of the file.
  ///
  /// Returns the updated file information
  Future<APIResponse<Map<String, dynamic>>> rename(String newName) =>
      _call<Map<String, dynamic>>('/_api/rest/v1/storage/bucket/file/rename',
          newName: newName);

  /// Duplicates an existing file within the same bucket.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [duplicateName] The new duplicate file name. If not specified, uses the
  /// `fileName` as template and ensures the duplicated file name to be unique
  /// in its bucket.
  /// Returns the new duplicate file information
  Future<APIResponse<Map<String, dynamic>>> duplicate(String duplicateName) =>
      _call<Map<String, dynamic>>('/_api/rest/v1/storage/bucket/file/duplicate',
          duplicateName: duplicateName);

  /// Deletes the file from the bucket.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  Future<APIError?> delete() async =>
      (await _call<dynamic>('/_api/rest/v1/storage/bucket/file/delete')).errors;

  /// Replaces an existing file with another. It keeps the name of the file but
  /// replaces file contents, size, encoding and mime-type with the newly
  /// uploaded file info.
  ///
  /// If `onProgress` callback function is defined in [FileUploadOptions], it
  /// periodically calls this function to inform about upload progress.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [fileBody] The body of the new file that will be used to replace the
  /// existing file.
  ///
  /// [options] Content type and privacy setting of the new file. `contentType`
  /// is ignored, if `fileBody` is `Blob`, `File` or `FormData`, otherwise
  /// `contentType` option needs to be specified. If not specified,
  /// `contentType` will default to `text/plain;charset=UTF-8`. If `isPublic`
  /// is not specified, defaults to the bucket's privacy setting.
  ///
  /// Returns the metadata of the file after replacement
  Future<APIResponse<JsonMap>> replace(Uint8List fileBody,
          [FileUploadOptions? options]) =>
      _fetcher.upload<JsonMap>(
          '/_api/rest/v1/storage/bucket/file/replace-formdata',
          fileBody,
          _fileNameOrId,
          options?.contentType ?? DEFAULT_FILE_OPTIONS.contentType!,
          query: {
            'bucket': _bucketNameOrId,
            'file': _fileNameOrId,
            'options': DEFAULT_FILE_OPTIONS.merge(options).toJson(),
          },
          onProgress: options?.onProgress);

  /// Moves the file to another bucket. The file will be removed from its
  /// current bucket and will be moved to its new bucket. If there already
  /// exists a file with the same name in destination bucket, it ensures
  /// the moved file name to be unique in its new destination.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [bucketNameOrId] The name or id of the bucket to move the file into.
  ///
  /// Returns the moved file information
  Future<APIResponse<Map<String, dynamic>>> moveTo(String bucketNameOrId) =>
      _call<Map<String, dynamic>>('/_api/rest/v1/storage/bucket/file/move',
          bucketNameOrId: bucketNameOrId);

  /// Copies the file to another bucket. If there already exists a file with
  /// the same name in destination bucket, it ensures the copied file name
  /// to be unique in its new destination.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [bucketNameOrId] The name or id of the bucket to copy the file into.
  ///
  /// Returns the copied file information
  Future<APIResponse<Map<String, dynamic>>> copyTo(String bucketNameOrId) =>
      _call<Map<String, dynamic>>('/_api/rest/v1/storage/bucket/file/copy',
          bucketNameOrId: bucketNameOrId);

  /// Adds the specified tags to file's metadata.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [tags] A single tag or an array of tags to add to file's metadata.
  /// [tags] can be ``String`` or ``List<String>``
  ///
  /// Returns the updated file information
  Future<APIResponse<JsonMap>> addTags(dynamic tags) {
    assert(
        tags is String || tags is List<String>,
        '[tags] must be String '
        'or List<String>');
    return _fetcher.post<JsonMap>('/_api/rest/v1/storage/bucket/file/add-tags',
        body: {'tags': tags, 'bucket': _bucketNameOrId, 'file': _fileNameOrId});
  }

  /// Removes the specified tags from file's metadata.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [tags] A single tag or an array of tags to remove from file's metadata.
  /// [tags] can be ``String`` or ``List<String>``
  ///
  /// Returns the updated file information
  Future<APIResponse<JsonMap>> removeTags(dynamic tags) {
    assert(
        tags is String || tags is List<String>,
        '[tags] must be String '
        'or List<String>');
    return _fetcher.post<JsonMap>(
        '/_api/rest/v1/storage/bucket/file/remove-tags',
        body: {'tags': tags, 'bucket': _bucketNameOrId, 'file': _fileNameOrId});
  }

  /// Updates the overall file metadata (name, isPublic and tags) in a single
  /// method call.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [newName] The new name of the file.
  ///
  /// [isPublic] The privacy setting of the file.
  ///
  /// [tags] Array of string values that will be added to the file metadata.
  ///
  /// Returns the updated file information
  Future<APIResponse<JsonMap>> updateInfo(
          {required String newName,
          required bool isPublic,
          required List<String> tags}) =>
      _fetcher.post<JsonMap>('/_api/rest/v1/storage/bucket/file/update', body: {
        'tags': tags,
        'newName': newName,
        'isPublic': isPublic,
        'bucket': _bucketNameOrId,
        'file': _fileNameOrId
      });
}
