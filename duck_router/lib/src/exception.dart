import 'package:duck_router/duck_router.dart';

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

class ClearStackException extends DuckRouterException {
  final Location location;

  const ClearStackException(this.location)
      : super(
          'Could not return a result from this location, it was cleared from the stack.',
        );
}

class InvalidPopTypeException extends DuckRouterException {
  final Location location;
  final Object? value;

  const InvalidPopTypeException(this.location, this.value)
      : super('Trying to return result with pop that does not match the '
            'awaited type. \n'
            'Check the type of the result you are returning. This can also happen '
            'if you have replaced a location with another location, and the new '
            'location returns a different type.');
}

class EmptyStackException extends DuckRouterException {
  const EmptyStackException() : super('There is nothing to pop!');
}

class NoLocationMatchFoundException extends DuckRouterException {
  const NoLocationMatchFoundException()
      : super(
            'Provided Location predicate does not match any Locations in current stack!');
}

class DuplicateRouteException extends DuckRouterException {
  final Location location;

  DuplicateRouteException(this.location)
      : super('Cannot push duplicate route: ${location.path}');
}

class LocationStackDecoderException extends DuckRouterException {
  const LocationStackDecoderException(super.message);
}

class MissingCreateRouteException extends DuckRouterException {
  const MissingCreateRouteException()
      : super('When using a custom DuckPage, you must override createRoute');
}
