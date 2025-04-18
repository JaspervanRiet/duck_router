import 'package:duck_router/src/configuration.dart';
import 'package:duck_router/src/delegate.dart';
import 'package:duck_router/src/exception.dart';
import 'package:duck_router/src/interceptor.dart';
import 'package:duck_router/src/location.dart';
import 'package:duck_router/src/parser.dart';
import 'package:duck_router/src/provider.dart';
import 'package:flutter/material.dart';

/// A builder for a shell around the [DuckRouter].
typedef DuckRouterShellBuilder = Widget Function(
  BuildContext context,
  Widget child,
);

/// Signature for the [DuckRouter.popUntil] predicate argument.
typedef LocationPredicate = bool Function(Location location);

/// {@template duck_router}
/// Creates a [DuckRouter].
///
/// The [initialLocation] will be the first location opened by the app.
///
/// Interceptors can be used to redirect the user to a different location based
/// on specific conditions.
///
/// Specify a [DuckRouterDeepLinkHandler] to handle deep links. Be aware that
/// deep links still go through interceptors.
///
/// {@endtemplate}
/// {@category Configuration}
/// {@category Deep linking}
/// {@category Stateful navigation}
/// {@category Custom pages and transitions}
class DuckRouter implements RouterConfig<LocationStack> {
  /// {@macro duck_router}
  factory DuckRouter({
    required Location initialLocation,
    List<LocationInterceptor>? interceptors,
    DuckRouterDeepLinkHandler? onDeepLink,
    DuckRouterNavigatorListener? onNavigate,
    DuckRouterNavigatorObserverBuilder? navigatorObserverBuilder,
  }) {
    return DuckRouter.withConfig(
      configuration: DuckRouterConfiguration(
        initialLocation: initialLocation,
        interceptors: interceptors,
        onDeepLink: onDeepLink,
        onNavigate: onNavigate,
        navigatorObserverBuilder: navigatorObserverBuilder,
      ),
    );
  }

  /// {@macro duck_router}
  DuckRouter.withConfig({
    required this.configuration,
  }) {
    WidgetsFlutterBinding.ensureInitialized();

    backButtonDispatcher = RootBackButtonDispatcher();
    routerDelegate = DuckRouterDelegate(
      configuration: configuration,
      shellBuilder: (context, child) => InheritedDuckRouter(
        router: this,
        child: child,
      ),
    );
    routeInformationParser =
        DuckInformationParser(configuration: configuration);
    routeInformationProvider = DuckInformationProvider(
      stack: _initialLocation(configuration.initialLocation),
      configuration: configuration,
    );
  }

  /// Find the current DuckRouter in the widget tree.
  ///
  /// This method throws when it is called during redirects.
  static DuckRouter of(BuildContext context) {
    final inherited = maybeOf(context);
    assert(inherited != null, 'No DuckRouter found in context');
    return inherited!;
  }

  /// The current DuckRouter in the widget tree, if any.
  ///
  /// This method returns null when it is called during redirects.
  static DuckRouter? maybeOf(BuildContext context) {
    final inherited = context
        .getElementForInheritedWidgetOfExactType<InheritedDuckRouter>()
        ?.widget as InheritedDuckRouter?;
    return inherited?.router;
  }

  /// The route configuration used by [DuckRouter].
  final DuckRouterConfiguration configuration;

  @override
  late final BackButtonDispatcher backButtonDispatcher;

  /// The router delegate. Provide this to the MaterialApp or CupertinoApp's
  /// `.router()` constructor
  @override
  late final DuckRouterDelegate routerDelegate;

  /// The route information provider used by [DuckRouter].
  @override
  late final DuckInformationProvider routeInformationProvider;

  /// The route information parser used by [DuckRouter].
  @override
  late final DuckInformationParser routeInformationParser;

  /// Navigate to a new location.
  ///
  /// Use [root] to navigate from the root navigator.
  ///
  /// If [replace] is set, the current location will be replaced with [to].
  ///
  /// If [clearStack] is set, the current stack will be cleared before navigating.
  /// [clearStack] will take precedence over [replace].
  ///
  /// You can await [navigate] to pass back results from the new location.
  /// This can create complicated scenarios when used in combination with
  /// [replace]. The behavior defined as follows:
  ///
  /// - Location A navigates to and awaits Location B
  /// - Location B is replaced by Location C
  /// - Location C pops, with a result.
  ///
  /// This result will still be passed to Location A. Be mindful that this
  /// result should be of the same type as the result of Location B.
  ///
  /// If the awaited location is cleared using [clearStack], an error will be
  /// thrown.
  Future<T?> navigate<T extends Object?>({
    required Location to,
    bool root = false,
    bool? replace,
    bool? clearStack,
  }) {
    final currentStack = routerDelegate.currentConfiguration;
    final currentRootLocation = currentStack.locations.last;
    Location? replaced;

    if (clearStack ?? false) {
      if (currentRootLocation is StatefulLocation && !root) {
        return currentRootLocation.state.navigate(
          to,
          replace: replace,
          clearStack: clearStack,
        );
      }

      for (final l in currentStack.locations) {
        configuration.clearLocation(l);
      }
      currentStack.locations.clear();

      return routeInformationProvider.navigate<T>(
        to,
        baseLocationStack: currentStack,
      );
    }

    if (!(replace ?? false) &&
        currentStack.locations.any((loc) => loc.path == to.path)) {
      throw DuplicateRouteException(to);
    }

    if (currentRootLocation is StatefulLocation && !root) {
      return currentRootLocation.state.navigate(to, replace: replace);
    }

    if (replace ?? false) {
      replaced = currentStack.locations.removeLast();
    }

    return routeInformationProvider.navigate<T>(
      to,
      baseLocationStack: currentStack,
      replaced: replaced,
    );
  }

  /// Pop the top-most route off the current screen.
  ///
  /// If the top-most route is a pop up or dialog, this method pops it instead
  /// of any route under it.
  void pop<T extends Object?>([T? result]) {
    routerDelegate.pop<T>(result);
  }

  /// Pop the root route off the current screen.
  @Deprecated('Use exit instead')
  void popRoot<T extends Object?>([T? result]) {
    routerDelegate.pop<T>(result, true);
  }

  /// Close the current stack of routes if in a [StatefulLocation] or
  /// [FlowLocation], otherwise, pop.
  ///
  /// This is equivalent to calling [pop] until the root location is reached,
  /// in other words, it will immediately pop the root location.
  ///
  /// See also:
  /// - [StatefulLocation] for creating an inner navigation stack.
  void exit<T extends Object?>([T? result]) {
    routerDelegate.pop<T>(result, true);
  }

  /// Pop until the given predicate is satisfied.
  void popUntil(LocationPredicate predicate) {
    routerDelegate.popUntil(predicate);
  }

  /// Reset the router to the root location.
  void root() {
    routerDelegate.root();
  }

  LocationStack _initialLocation(Location userSpecifiedInitialLocation) {
    Uri platformInitialLocation = Uri.parse(
      WidgetsBinding.instance.platformDispatcher.defaultRouteName,
    );
    if (platformInitialLocation.hasEmptyPath) {
      platformInitialLocation = Uri(
        path: '/',
        queryParameters: platformInitialLocation.queryParameters,
      );
    }

    if (platformInitialLocation.path == '/') {
      return LocationStack(
        locations: [userSpecifiedInitialLocation],
      );
    }

    if (configuration.onDeepLink != null) {
      final locationStack = configuration.onDeepLink!(
        platformInitialLocation,
        userSpecifiedInitialLocation,
      );
      if (locationStack != null) {
        return LocationStack(locations: locationStack);
      }
    }

    return LocationStack(
      locations: [userSpecifiedInitialLocation],
    );
  }
}

/// DuckRouter implementation of InheritedWidget.
///
/// Used to find the current DuckRouter in the widget tree. This is useful
/// when routing from anywhere in your app.
class InheritedDuckRouter extends InheritedWidget {
  /// Default constructor for the inherited duck router.
  const InheritedDuckRouter({
    required super.child,
    required this.router,
    super.key,
  });

  /// The [DuckRouter] that is made available to the widget tree.
  final DuckRouter router;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
