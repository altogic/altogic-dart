/// Class to create and throw instances of client errors during runtime.
class ClientError implements Exception {
  /// Creates an instance of ClientError.
  ClientError(this.code, this.message, {this.details})
      : origin = 'client_error';

  /// Originator of the error either a client error or an internal server error
  String origin;

  /// Specific short code of the error message (e.g., validation_error,
  /// content_type_error)
  String code;

  /// Short description of the error
  String message;

  /// Any additional details about the error. Details is a JSON object and can
  /// have a different structure for different error types.
  Map<String, dynamic>? details;
}
