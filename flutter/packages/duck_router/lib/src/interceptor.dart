// ignore_for_file: one_member_abstracts

import 'package:duck_router/src/location.dart';

/// {@template location_interceptor}
/// A location interceptor acts as a guard for a [Location], preventing a
/// user from navigating to that location depending on certain conditions, for
/// example if the user is not logged in.
/// {@endtemplate}
abstract class LocationInterceptor {
  /// {@macro location_interceptor}
  const LocationInterceptor({
    this.pushesOnTop = false,
  });

  /// Executes the interceptor and returns null if the navigation should
  /// continue as normal, or a [Location] if the navigation should be
  /// redirected.
  Location? execute(Location to, Location? from);

  /// If true, the redirect location will be pushed ON TOP of the stack,
  /// instead of replacing the location.
  final bool pushesOnTop;
}
