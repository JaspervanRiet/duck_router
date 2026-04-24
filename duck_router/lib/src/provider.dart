import 'dart:async';

import 'package:duck_router/src/configuration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  /// Synchronises [_value] with the current [LocationStack] after a pop.
  ///
  /// [_value] is only updated on forward navigation (via [navigate]). When a
  /// route is popped, [DuckRouterDelegate] updates its
  /// [DuckRouterDelegate.currentConfiguration] but [_value] still points to
  /// the popped location.
  ///
  /// This becomes a problem whenever Flutter's [Router] re-reads [value]:
  ///
  /// - **Hot reload / reassemble**: [Router] re-reads [value] in
  ///   `didChangeDependencies` and feeds it through
  ///   [DuckInformationParser.parseRouteInformation].
  /// - **Widget rebuild**: any ancestor rebuild that causes the [Router] to
  ///   call `didChangeDependencies` (e.g. an [InheritedWidget] change or a
  ///   widget tree restructure) triggers the same re-read.
  ///
  /// In both cases, a stale [_value] causes the parser to re-process the
  /// popped location and re-add it to the stack — reopening the route the
  /// user just closed.
  ///
  /// This method is called by the delegate after every pop to keep [_value]
  /// in sync with the delegate's stack. It mirrors the same
  /// [RouteInformation] / [LocationState] structure used by the constructor
  /// and [navigate], but without a [Completer] — no future result is expected
  /// for a location that is already on the stack.
  ///
  /// Note: this method intentionally does NOT call [notifyListeners]. Notifying
  /// the provider's listeners would trigger [Router] to re-parse the value
  /// through [DuckInformationParser], which would re-run interceptors and
  /// potentially re-push routes that were just popped. Instead, the delegate
  /// calls [ChangeNotifier.notifyListeners] on itself after syncing. [Router]
  /// handles delegate notifications through a separate path
  /// (`_handleRouterDelegateNotification`) that updates its internal route
  /// information cache directly from [RouterDelegate.currentConfiguration]
  /// — without re-parsing.
  void syncValue(LocationStack stack) {
    _value = RouteInformation(
      uri: stack.uri,
      state: LocationState(
        location: stack.locations.last,
        baseLocationStack: stack.copyWith(
          locations: stack.locations.sublist(0, stack.locations.length - 1),
        ),
      ),
    );
  }

  void _platformReportsNewRouteInformation(RouteInformation routeInformation) {
    if (_value == routeInformation) {
      return;
    }

    if (_configuration.onDeepLink != null) {
      final currentState = _value.state as LocationState;
      final stackToGoTo = _configuration.onDeepLink!(
        routeInformation.uri,
        currentState.location,
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
