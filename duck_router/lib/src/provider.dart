import 'dart:async';

import 'package:collection/collection.dart';
import 'package:duck_router/src/configuration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:duck_router/src/location.dart';
import 'state.dart';

/// {@template duck_information_provider}
/// A [RouteInformationProvider] for the [DuckRouter].
/// {@endtemplate}
class DuckInformationProvider extends RouteInformationProvider
    with WidgetsBindingObserver, ChangeNotifier {
  /// {@macro duck_information_provider}
  DuckInformationProvider({
    required LocationStack stack,
    required DuckRouterConfiguration configuration,
  })  : _configuration = configuration,
        _codec = LocationStackCodec(configuration: configuration),
        _value = RouteInformation(
          uri: stack.uri,
          state: LocationState(
            location: stack.locations.last,
            baseLocationStack: stack.copyWith(
                locations: stack.locations.sublist(
              0,
              stack.locations.length - 1,
            )),
          ),
        );

  @override
  RouteInformation get value => _value;
  RouteInformation _value;

  final DuckRouterConfiguration _configuration;
  final LocationStackCodec _codec;

  static WidgetsBinding get _binding => WidgetsBinding.instance;

  /// Navigate to a new location.
  Future<T?> navigate<T>(
    Location location, {
    required LocationStack baseLocationStack,
    Location? replaced,
  }) async {
    // This [Completer] is used for later on, when the page is popped,
    // returning a result.
    //
    // The flow:
    // 1. We add the completer to the [LocationState].
    // 2. [DuckInformationParser] will add the completer to the
    // [RouterConfiguration], where it is saved in the form of a
    // [LocationMatch], so that we can have multiple completers in the tree
    // at the same time.
    // 3. When we pop, we look up the [LocationMatch] and complete the
    // completer.
    final completer = Completer<T?>();

    _value = RouteInformation(
      uri: location.uri,
      state: LocationState(
        location: location,
        baseLocationStack: baseLocationStack,
        completer: completer,
        replaced: replaced,
      ),
    );
    notifyListeners();
    return completer.future;
  }

  /// Syncs [_value] with what the [Router] reports after rebuilding from the
  /// delegate's [RouterDelegate.currentConfiguration]. Without this, [_value]
  /// would keep pointing at a popped location, and the [Router] would re-push
  /// it on rebuild or hot reload by re-reading [_value].
  ///
  /// Also forwards the new route information to the engine so the platform
  /// (browser URL bar, OS back stack) reflects the current stack — mirroring
  /// [PlatformRouteInformationProvider.routerReportsNewRouteInformation].
  @override
  void routerReportsNewRouteInformation(
    RouteInformation routeInformation, {
    RouteInformationReportingType type = RouteInformationReportingType.none,
  }) {
    if (_value.uri == routeInformation.uri &&
        const DeepCollectionEquality()
            .equals(_value.state, routeInformation.state)) {
      return;
    }
    _value = routeInformation;

    SystemNavigator.selectMultiEntryHistory();
    SystemNavigator.routeInformationUpdated(
      uri: routeInformation.uri,
      replace: type != RouteInformationReportingType.navigate,
    );
  }

  /// Returns the current [Location] the provider points to, regardless of
  /// whether [value]'s state is a freshly built [LocationState] (after a
  /// [navigate]) or the encoded [Map] form (after a [Router] rebuild reported
  /// via [routerReportsNewRouteInformation]).
  Location? get currentLocation {
    final state = _value.state;
    if (state is LocationState) {
      return state.location;
    }
    if (state is Map<Object?, Object?>) {
      try {
        return _codec.decode(state).locations.lastOrNull;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  void _platformReportsNewRouteInformation(RouteInformation routeInformation) {
    if (_value == routeInformation) {
      return;
    }

    if (_configuration.onDeepLink != null) {
      final currentLocation = this.currentLocation;
      if (currentLocation == null) return;
      final stackToGoTo = _configuration.onDeepLink!(
        routeInformation.uri,
        currentLocation,
      );

      if (stackToGoTo == null || stackToGoTo.isEmpty) {
        // If the stack is empty, the user does not want to navigate based on the deeplink.
        return;
      }

      final toLocation = stackToGoTo.last;

      /// Note: you might observe that directly calling `navigate` here means
      /// that we do NOT support opening a nested location. That is intentional.
      /// Allowing for such functionality would require a much more complicated
      /// deeplinking interface, while it is not a common use case.

      navigate(
        toLocation,
        baseLocationStack: LocationStack(
          locations: stackToGoTo.sublist(0, stackToGoTo.length - 1),
        ),
      );
      return;
    }

    _value = RouteInformation(
      uri: routeInformation.uri,
      state: LocationStack.empty,
    );
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    if (!hasListeners) {
      _binding.addObserver(this);
    }
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _binding.removeObserver(this);
    }
  }

  @override
  void dispose() {
    if (hasListeners) {
      _binding.removeObserver(this);
    }
    super.dispose();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    assert(hasListeners);
    _platformReportsNewRouteInformation(routeInformation);
    return SynchronousFuture<bool>(true);
  }

  @override
  Future<bool> didPushRoute(String route) {
    assert(hasListeners);
    _platformReportsNewRouteInformation(
        RouteInformation(uri: Uri.parse(route)));
    return SynchronousFuture<bool>(true);
  }
}
