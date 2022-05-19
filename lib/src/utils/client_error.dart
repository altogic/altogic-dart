/// Class to create and throw instances of client errors during runtime.
/// @export
/// @class ClientError
/// @extends {Error}
class ClientError implements Exception {
  /// Creates an instance of ClientError.
  /// @param {string} code Specific short code of the error message
  /// @param {string} message Short description of the error
  /// @param {object} [details] Any additional details about the error
  ClientError(this.code, this.message, {this.details})
      : origin = 'client_error';

  /// Originator of the error either a client error or an internal server error
  /// @type {string}
  String origin;

  /// Specific short code of the error message (e.g., validation_error,
  /// content_type_error)
  /// @type {string}
  String code;

  /// Short description of the error
  /// @type {string}
  String message;

  /// Any additional details about the error. Details is a JSON object and can
  /// have a different structure for different error types.
  /// @type {object}
  Map<String, dynamic>? details;
}
