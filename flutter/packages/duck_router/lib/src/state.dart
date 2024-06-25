import 'dart:async';

import 'package:duck_router/src/location.dart';

/// {@template location_state}
/// A state object that maintains state for the current location in the router.
/// {@endtemplate}
class LocationState<T> {
  /// {@macro location_state}
  LocationState({
    required this.location,
    required this.baseLocationStack,
    this.completer,
  });

  /// The current location.
  final Location location;

  /// The stack of locations that the current location is pushed on top of.
  final LocationStack baseLocationStack;

  /// The completer for the current location. When the location is popped,
  /// this completer should be completed.
  final Completer<T?>? completer;
}
