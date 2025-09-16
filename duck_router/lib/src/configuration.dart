import 'dart:async';

import 'package:duck_router/src/exception.dart';
import 'package:flutter/material.dart';
import 'package:duck_router/src/interceptor.dart';
import 'package:duck_router/src/location.dart';

/// Handler for when the app gets a deeplink.
///
/// When a list of locations is returned, the router will update the current location stack with the new stack.
/// If `null` is returned, the router will either not update the stack (in case of a deeplink while the app is running)
/// or navigate to the initial location (in case of a deeplink while the app is not running).
typedef DuckRouterDeepLinkHandler = List<Location>? Function(
  Uri uri,
  Location currentLocation,
);

/// A listener for when the router navigates.
typedef DuckRouterNavigatorListener = void Function(Location destination);

/// A builder that creates a list of [NavigatorObserver]s.
/// A builder has to be provided, as a [NavigatorObserver] can not be shared between navigators.
/// The builder is called with the navigator key of the navigator that the observers are for.
/// Note that the observers returned by the builder should not be shared between navigators!
typedef DuckRouterNavigatorObserverBuilder = List<NavigatorObserver> Function(
    GlobalKey<NavigatorState> navigatorKey);

/// {@template duck_router_configuration}
/// A configuration object for the [DuckRouter].
/// {@endtemplate}
class DuckRouterConfiguration {
  /// {@macro duck_router_configuration}
  DuckRouterConfiguration({
    required this.initialLocation,
    GlobalKey<NavigatorState>? rootNavigatorKey,
    this.interceptors,
    this.onDeepLink,
    this.onNavigate,
    this.navigatorObserverBuilder,
    this.duckRestorer,
  }) : rootNavigatorKey = rootNavigatorKey ?? GlobalKey<NavigatorState>();

  /// The list of locations that the user can route to
  final Location initialLocation;

  /// The list of interceptors to run before routing.
  ///
  /// See also:
  /// - [LocationInterceptor]
  final List<LocationInterceptor>? interceptors;

  /// The root navigator key.
  final GlobalKey<NavigatorState> rootNavigatorKey;

  /// If set, router will ask consumer to provide a stack of locations
  /// to navigate to.
  final DuckRouterDeepLinkHandler? onDeepLink;

  /// A listener for when the router navigates.
  final DuckRouterNavigatorListener? onNavigate;

  /// A builder that creates a list of [NavigatorObserver]s.
  /// A builder has to be provided, as a [NavigatorObserver] can not be shared between navigators.
  /// The builder is called with the navigator key of the navigator that the observers are for.
  /// Note that the observers returned by the builder should not be shared between navigators!
  final DuckRouterNavigatorObserverBuilder? navigatorObserverBuilder;

  final Map<String, LocationMatch> _routeMapping = {};

  /// {@macro duck_restorer}
  final DuckRestorer? duckRestorer;

  /// Adds a [Location] to the current dynamic directory of locations, so
  /// that we can find it back later, e.g. upon state restoration.
  void addLocation<T>(
    Location location, {
    Completer<T>? completer,

    /// If this location replaced another, the location needs to be
    /// provided here so that we can redirect the completer.
    Location? replaced,
  }) {
    if (_routeMapping.containsKey(location.path)) {
      return;
    }

    if (replaced != null) {
      final replacedCompleter = _routeMapping[replaced.path]?.completer;

      // If we have both a new completer (from the navigate call) and a replaced completer,
      // we need to chain them so both get completed when the location is popped.
      Completer? finalCompleter;
      if (completer != null && replacedCompleter != null) {
        // Create a combined completer that will complete both when resolved
        finalCompleter = _createCombinedCompleter(completer, replacedCompleter);
      } else {
        // Use whichever completer is available
        finalCompleter = completer ?? replacedCompleter;
      }

      _routeMapping[location.path] = LocationMatch(
        location: location,
        completer: finalCompleter,
      );
      _routeMapping.remove(replaced.path);
      return;
    }

    _routeMapping[location.path] = LocationMatch(
      location: location,
      completer: completer,
    );
  }

  /// Clears a location from the current dynamic directory of locations, so
  /// that we close any potential awaiters.
  void clearLocation(Location location) {
    final completer = _routeMapping[location.path]?.completer;

    // If future does not have a listener, it will be considered an uncaught
    // error. Thus, we need to handle the error and ignore it. User
    // will still receive the error via the completer if they are listening.
    completer?.future.catchError((e, s) {
      // Do nothing, user has received error.
    });
    completer?.completeError(ClearStackException(location));
    _routeMapping.remove(location.path);
  }

  /// Returns the [LocationMatch] for the given path.
  LocationMatch? findLocation(String path) {
    return _routeMapping[path];
  }

  /// Removes a location from the current dynamic directory of locations.
  void removeLocation<T>(Location location, [FutureOr<T>? value]) {
    final completer = _routeMapping[location.path]?.completer;
    try {
      completer?.complete(value);
    } on TypeError catch (_) {
      completer?.completeError(InvalidPopTypeException(location, value));
    }
    _routeMapping.remove(location.path);
  }

  /// Creates a combined completer that will complete both completers with the same result.
  /// This is used when replacing a location to ensure both the original awaiter and
  /// the new awaiter get the result when the location is popped.
  Completer<T> _createCombinedCompleter<T>(
      Completer<T> newCompleter, Completer replacedCompleter) {
    final combinedCompleter = Completer<T>();

    combinedCompleter.future.then((value) {
      // Complete both completers with the same value
      if (!newCompleter.isCompleted) {
        try {
          newCompleter.complete(value);
        } on TypeError catch (_) {
          replacedCompleter
              .completeError(InvalidCompletionTypeException(value));
        } catch (e) {
          // If there's any other error, complete with the error instead
          newCompleter.completeError(e);
        }
      }
      if (!replacedCompleter.isCompleted) {
        try {
          replacedCompleter.complete(value);
        } on TypeError catch (_) {
          replacedCompleter
              .completeError(InvalidCompletionTypeException(value));
        } catch (e) {
          // If there's any other error, complete with the error instead
          replacedCompleter.completeError(e);
        }
      }
    }).catchError((error, stackTrace) {
      // Complete both completers with the same error
      if (!newCompleter.isCompleted) {
        newCompleter.completeError(error, stackTrace);
      }
      if (!replacedCompleter.isCompleted) {
        replacedCompleter.completeError(error, stackTrace);
      }
    });

    return combinedCompleter;
  }
}

/// {@template location_match}
/// A match for a location, containing some extra context around the location.
///
/// Some locations need extra context when performing certain actions, for
/// example, we might need the [Completer] when trying to pop the page.
/// {@endtemplate}
class LocationMatch<T> {
  /// {@macro location_match}
  LocationMatch({
    required this.location,
    this.completer,
  });

  final Location location;
  final Completer<T>? completer;
}

/// {@template duck_restorer}
/// A [DuckRestorer] allows restoration of [Location] objects upon e.g. an app
/// restart.
/// {@endtemplate}
abstract class DuckRestorer {
  /// [fromJson] is called when the router is being restored from e.g. an app
  /// restart. In that case, the router will repeatedly call this method
  /// to re-create the state.
  ///
  /// Note: `path` and `arguments` correspond to [Location.path] and
  /// [Location.toJson] respectively.
  ///
  /// See also:
  /// - [toJson]: the inverse
  Location? fromJson(String path, Map<String, dynamic> arguments);

  /// [toJson] will be called when the router is saving itself for a later
  /// restoration, e.g. on app restart.
  ///
  /// See also:
  /// - [fromJson]: the inverse
  Map<String, dynamic> toJson(Location location);
}
