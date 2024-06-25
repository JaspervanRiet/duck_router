/// {@template duck_router_exception}
/// Exception thrown by the [DuckRouter].
/// {@endtemplate}
class DuckRouterException implements Exception {
  /// {@macro duck_router_exception}
  const DuckRouterException(this.message);

  /// The message of the exception.
  final String message;

  @override
  String toString() => 'RouterException: $message';
}
