import 'dart:async';

import 'package:flutter/material.dart';
import 'package:duck_router/src/configuration.dart';
import 'package:duck_router/src/exception.dart';
import 'package:duck_router/src/interceptor.dart';
import 'package:duck_router/src/location.dart';
import 'state.dart';

/// {@template duck_information_parser}
/// A [RouteInformationParser] for the [DuckRouter].
/// {@endtemplate}
class DuckInformationParser extends RouteInformationParser<LocationStack> {
  /// {@macro duck_information_parser}
  DuckInformationParser({
    required DuckRouterConfiguration configuration,
  })  : _codec = LocationStackCodec(configuration: configuration),
        _configuration = configuration;

  final LocationStackCodec _codec;
  final DuckRouterConfiguration _configuration;

  @override
  Future<LocationStack> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final state = routeInformation.state;

    if (state is! LocationState) {
      /// This would be the result of state restoration, see
      /// [restoreRouteInformation]. We can presume the routeInformation state
      /// is a [LocationStack] in this case.

      if (state is! Map<Object?, Object?>) {
        throw DuckRouterException('Invalid state type: ${state.runtimeType}');
      }

      final stack =
          _codec.decode(routeInformation.state! as Map<Object?, Object?>);

      return _maybeIntercept(
          stack.locations.last,
          // Before rebuild:
          // - /home/page1
          // Then we rebuild, so we need to remove page1, otherwise
          // we will have /home/page1/page1
          stack.locations.sublist(0, stack.locations.length - 1));
    }

    final currentStack = state.baseLocationStack.locations;
    return _maybeIntercept(
      state.location,
      currentStack,
      completer: state.completer,
    );
  }

  @override
  RouteInformation? restoreRouteInformation(LocationStack configuration) {
    return RouteInformation(
      uri: configuration.uri,
      // Note: notice how we are not saving LocationState here!
      // We can use the LocationStack in [parseRouteInformation] to restore the
      // state.
      state: _codec.encode(configuration),
    );
  }

  LocationStack _maybeIntercept(
    Location to,
    List<Location> currentStack, {
    Completer? completer,
  }) {
    for (final i in _configuration.interceptors ?? <LocationInterceptor>[]) {
      final result = i.execute(
        to,
        currentStack.lastOrNull,
      );
      if (result != null) {
        _configuration.addLocation(result, completer: completer);
        _configuration.onNavigate?.call(result);
        if (i.pushesOnTop) {
          return LocationStack(locations: [...currentStack, to, result]);
        }

        return LocationStack(
          locations: [...currentStack, result],
        );
      }
    }

    _configuration.addLocation(to, completer: completer);
    _configuration.onNavigate?.call(to);
    return LocationStack(locations: [...currentStack, to]);
  }
}
