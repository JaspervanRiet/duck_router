import 'dart:async';

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

  /// Adds a [Location] to the current dynamic directory of locations, so
  /// that we can find it back later, e.g. upon state restoration.
  void addLocation<T>(Location location, {Completer<T>? completer}) {
    if (_routeMapping.containsKey(location.path)) {
      return;
    }
    _routeMapping[location.path] = LocationMatch(
      location: location,
      completer: completer,
    );
  }

  /// Returns the [LocationMatch] for the given path.
  LocationMatch? findLocation(String path) {
    return _routeMapping[path];
  }

  /// Removes a location from the current dynamic directory of locations.
  void removeLocation<T>(Location location, [FutureOr<T>? value]) {
    _routeMapping[location.path]?.completer?.complete(value);
    _routeMapping.remove(location.path);
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
