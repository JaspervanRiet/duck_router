import 'package:collection/collection.dart';
import 'package:duck_router/duck_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'navigator.dart';

/// {@template duck_router_delegate}
/// The [RouterDelegate] for [DuckRouter].
/// {@endtemplate}
class DuckRouterDelegate extends RouterDelegate<LocationStack>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<LocationStack> {
  /// {@macro duck_router_delegate}
  DuckRouterDelegate({
    required DuckRouterConfiguration configuration,
    required DuckRouterShellBuilder shellBuilder,
  })  : _configuration = configuration,
        _shellBuilder = shellBuilder,
        currentConfiguration =
            LocationStack(locations: [configuration.initialLocation]);

  final DuckRouterConfiguration _configuration;
  final DuckRouterShellBuilder _shellBuilder;

  @override
  Widget build(BuildContext context) {
    return _shellBuilder(
      context,
      DuckNavigator(
        navigatorKey: navigatorKey,
        stack: currentConfiguration,
        onPopPage: _onPopPage,
        onDidRemovePage: _onDidRemovePage,
        observers: _configuration.navigatorObserverBuilder != null
            ? _configuration.navigatorObserverBuilder!(navigatorKey)
            : null,
      ),
    );
  }

  /// See RouterDelegate.onDidRemovePage.
  void _onDidRemovePage(Page<Object?> page) {
    /// There's two cases where this function is used:
    /// 1. When a page is popped from the stack
    /// 2. When a page is replaced
    ///
    /// In scenario 2, `setNewRoutePath` is called with the new configuration
    /// before this function, so the page will already have been removed.
    final doesStackContainPage =
        currentConfiguration.locations.any((l) => l.path == page.name);
    if (doesStackContainPage) {
      currentConfiguration.locations.removeWhere((l) => l.path == page.name);
    }

    final newLocation = currentConfiguration.locations.last;
    if (newLocation is StatefulLocation) {
      newLocation.state.takePriority();
    }
  }

  /// See RouterDelegate.onPopPage.
  void _onPopPage(bool didPop, Object? result) {
    if (!didPop) return;

    final currentLocation = currentConfiguration.locations.last;
    _configuration.removeLocation(currentLocation, result);

    currentConfiguration.locations
        .removeWhere((l) => l.path == currentLocation.path);
  }

  @override
  LocationStack currentConfiguration = LocationStack.empty;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _configuration.rootNavigatorKey;

  @override
  Future<void> setNewRoutePath(LocationStack configuration) {
    if (currentConfiguration == configuration) {
      return SynchronousFuture<void>(null);
    }

    currentConfiguration = configuration;
    return SynchronousFuture(null);
  }

  @override
  Future<bool> popRoute() async {
    var state = navigatorKey.currentState;
    if (state == null) {
      return false;
    }
    if (!state.canPop()) {
      state = null;
    }

    if (state != null) {
      return state.maybePop();
    }

    return false;
  }

  /// Pops the top location on the routing stack
  void pop<T extends Object?>([T? result, bool root = false]) {
    final currentLocation = currentConfiguration.locations.last;

    if (currentLocation is StatefulLocation && !root) {
      /// Pop inside the stateful child location as long as that's possible.
      /// Else we will pop the whole route.
      if (currentLocation.state.currentRouterDelegate.currentConfiguration
              .locations.length >
          1) {
        return currentLocation.state.pop(result);
      }
    }

    if (currentLocation is StatefulLocation && root) {
      // When popping a stateful location, we can consider the nested stack to be cleared from the stack.
      // So we will follow the same cleanup logic as if navigating to a new page, with the clearStack flag set to true.
      for (final l in currentLocation
          .state.currentRouterDelegate.currentConfiguration.locations) {
        _configuration.clearLocation(l);
      }
      currentLocation.state.currentRouterDelegate.currentConfiguration.locations
          .clear();
    }

    NavigatorState? state;
    if (navigatorKey.currentState?.canPop() ?? false) {
      state = navigatorKey.currentState;
    }
    if (currentConfiguration.locations.length == 1) {
      throw const EmptyStackException();
    }
    state?.pop(result);
  }

  void popUntil(LocationPredicate predicate) {
    final currentLocation = currentConfiguration.locations.last;

    if (currentLocation is StatefulLocation) {
      /// Pop inside the stateful child location as long as that's possible.
      /// Else we will pop the whole route.
      if (currentLocation.state.currentRouterDelegate.currentConfiguration
              .locations.length >
          1) {
        final result = currentLocation.state.popUntil(predicate);
        if (result) {
          return;
        }
      }
    }

    final destination = currentConfiguration.locations
        .firstWhereOrNull((location) => predicate(location));
    if (destination == null) {
      throw const NoLocationMatchFoundException();
    }

    NavigatorState? state;
    if (navigatorKey.currentState?.canPop() ?? false) {
      state = navigatorKey.currentState;
    }
    state?.popUntil((route) {
      return route.settings.name == destination.path;
    });
  }

  /// Reset the router to the root
  void root() {
    final currentLocation = currentConfiguration.locations.last;

    if (currentLocation is StatefulLocation) {
      /// Pop inside the stateful child location as long as that's possible.
      /// Else we will pop the whole route.
      if (currentLocation.state.currentRouterDelegate.currentConfiguration
              .locations.length >
          1) {
        return currentLocation.state.reset();
      } else {
        return;
      }
    }

    currentConfiguration = LocationStack(locations: [
      currentConfiguration.locations.firstOrNull ??
          _configuration.initialLocation
    ]);
    notifyListeners();
  }
}
