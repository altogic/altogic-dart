class ClientException implements Exception {
  final String message;

  ClientException(this.message);

  @override
  String toString() => message;
}
