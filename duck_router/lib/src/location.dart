import 'dart:convert';

import 'package:duck_router/duck_router.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:duck_router/src/exception.dart';

/// {@template location_stack}
/// A stack of locations.
/// {@endtemplate}
class LocationStack extends Equatable {
  /// {@macro location_stack}
  const LocationStack({
    required this.locations,
  });

  /// Creates a const empty list
  static LocationStack empty = const LocationStack(
    locations: [],
  );

  /// The locations in this list.
  final List<Location> locations;

  /// The URI representation of this location list.
  Uri get uri {
    return Uri.parse(
      '/${[
        for (final location in locations) location.uri,
      ].join('/')}',
    );
  }

  /// Pushes a new location to the stack
  void push(Location location) {
    locations.add(location);
  }

  /// Pops the top-most location from the stack
  void pop() {
    locations.removeLast();
  }

  LocationStack copyWith({
    List<Location>? locations,
  }) {
    return LocationStack(
      locations: locations ?? this.locations,
    );
  }

  @override
  List<Object?> get props => [locations];
}

/// A builder that creates a widget for a location.
///
/// See also:
/// - [LocationPageBuilder] for a more advanced builder that allows you to build
/// a [Page].
typedef LocationBuilder = Widget Function(BuildContext context);

/// A builder that allows a fully custom [Page] to be built. We call these
/// custom pages [DuckPage].
///
/// For example, you might use this to build a custom transition for a page,
/// or to use it from within a modal. Here's how you would use it to build a
/// dialog page:
///
/// ```dart
/// class DialogPage<T> extends DuckPage<T> {
///   final Offset? anchorPoint;
///   final Color? barrierColor;
///   final bool barrierDismissible;
///   final String? barrierLabel;
///   final bool useSafeArea;
///   final CapturedThemes? themes;
///   final WidgetBuilder builder;
///
///   const DialogPage.custom({
///     required super.name,
///     required this.builder,
///     this.anchorPoint,
///     this.barrierColor = Colors.black87,
///     this.barrierDismissible = true,
///     this.barrierLabel,
///     this.useSafeArea = true,
///     this.themes,
///     super.restorationId,
///   }) : super.custom(name: name);
///
///   @override
///   Route<T> createRoute(BuildContext context, RouteSettings? settings) => DialogRoute<T>(
///         context: context,
///         settings: settings,
///         builder: (context) => Dialog(
///           child: builder(context),
///         ),
///         anchorPoint: anchorPoint,
///         barrierColor: barrierColor,
///         barrierDismissible: barrierDismissible,
///         barrierLabel: barrierLabel,
///         useSafeArea: useSafeArea,
///         themes: themes,
///       );
/// }
/// ```
///
/// See also:
/// * [LocationBuilder] for a simpler builder that returns a [Widget].
/// * [DuckPage] for the page you must override.
typedef LocationPageBuilder = DuckPage<dynamic> Function(
  BuildContext context,
);

/// {@template location}
/// A location in the app.
///
/// See also:
/// - [StatefulLocation] for a location that maintains its own state, such as
/// for a bottom navigation bar.
/// - [LocationPageBuilder] for a builder that allows you to build a custom
/// [Page], e.g. for custom transitions.
/// {@endtemplate}
abstract class Location extends Equatable {
  /// {@macro location}
  const Location();

  /// The path of this location.
  ///
  /// Must be unique
  String get path;

  /// The URI representation of this location.
  Uri get uri {
    return Uri.parse(path);
  }

  /// What [Widget] to build for this location.
  LocationBuilder? get builder => null;

  /// Advanced builder for cases wherein you want to provide a custom [Page].
  LocationPageBuilder? get pageBuilder => null;

  @override
  List<Object?> get props => [path];
}

/// A builder that creates a widget for a stateful location.
typedef StatefulLocationBuilder = Widget Function(
  BuildContext context,
  DuckShell shell,
);

/// {@template stateful_location}
/// A location that maintains its own state with the use of a [Navigator].
/// {@endtemplate}
abstract class StatefulLocation extends Location {
  /// {@macro stateful_location}
  StatefulLocation();

  /// The children of this location, these will be the root of each
  /// [Navigator] in the [DuckShell].
  List<Location> get children;

  final GlobalKey<DuckShellState> _key = GlobalKey<DuckShellState>(
    debugLabel: 'StatefulLocationShell',
  );

  /// The builder for the wrapping page of this location.
  StatefulLocationBuilder get childBuilder;

  /// The state of the [DuckShell] for this location.
  DuckShellState get state => _key.currentState!;

  @override
  LocationBuilder get builder => (context) {
        return childBuilder(
          context,
          DuckShell(
            key: _key,
            children: children,
            configuration: DuckRouter.of(context).configuration,
          ),
        );
      };

  @override
  List<Object?> get props => [children, path];
}

/// {@template location_list_codec}
/// A [Codec] for encoding and decoding a [LocationStack].
/// {@endtemplate}
class LocationStackCodec extends Codec<LocationStack, Map<Object?, Object?>> {
  /// {@macro location_list_codec}
  LocationStackCodec({
    required DuckRouterConfiguration configuration,
  })  : encoder = _LocationStackEncoder(configuration: configuration),
        decoder = _LocationStackDecoder(configuration: configuration);

  static const String _keyLocationPath = 'path';
  static const String _keyLocations = 'locations';

  @override
  final Converter<Map<Object?, Object?>, LocationStack> decoder;

  @override
  final Converter<LocationStack, Map<Object?, Object?>> encoder;
}

class _LocationStackEncoder
    extends Converter<LocationStack, Map<Object?, Object?>> {
  const _LocationStackEncoder({
    required DuckRouterConfiguration configuration,
  }) : _configuration = configuration;

  // ignore: unused_field
  final DuckRouterConfiguration _configuration;

  @override
  Map<Object?, Object?> convert(LocationStack input) {
    final encodedInput = <Map<Object?, Object?>>[];

    for (final l in input.locations) {
      encodedInput.add({
        LocationStackCodec._keyLocationPath: l.path,
      });
    }

    return <Object?, Object?>{
      LocationStackCodec._keyLocations: encodedInput,
    };
  }
}

class _LocationStackDecoder
    extends Converter<Map<Object?, Object?>, LocationStack> {
  const _LocationStackDecoder({
    required DuckRouterConfiguration configuration,
  }) : _configuration = configuration;

  final DuckRouterConfiguration _configuration;

  @override
  LocationStack convert(Map<Object?, Object?> input) {
    final locations = input[LocationStackCodec._keyLocations] as List?;
    if (locations == null) {
      throw const FormatException('Invalid locations');
    }

    final decodedLocations = <Location>[];

    for (final l in locations) {
      if (l is Map<Object?, Object?>) {
        decodedLocations.add(_convertLocation(l));
      }
    }

    return LocationStack(
      locations: decodedLocations,
    );
  }

  Location _convertLocation(Map<Object?, Object?> input) {
    final path = input[LocationStackCodec._keyLocationPath] as String?;
    if (path == null) {
      throw const DuckRouterException('Invalid path');
    }

    final route = _configuration.findLocation(path);
    if (route == null) {
      throw const DuckRouterException('Route not found');
    }

    return route.location;
  }
}
