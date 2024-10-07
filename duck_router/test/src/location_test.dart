// ignore_for_file: prefer_const_constructors, cascade_invocations

import 'package:duck_router/src/configuration.dart';
import 'package:duck_router/src/exception.dart';
import 'package:duck_router/src/location.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  group('Location', () {
    test('should have a unique path', () {
      final location1 = HomeLocation();
      final location2 = HomeLocation();
      final location3 = Page1Location();

      expect(location1.path, equals(location2.path));
      expect(location1.path, isNot(equals(location3.path)));
    });

    test('should have a unique URI', () {
      final location1 = HomeLocation();
      final location2 = HomeLocation();
      final location3 = Page1Location();

      expect(location1.uri, equals(location2.uri));
      expect(location1.uri, isNot(equals(location3.uri)));
    });
  });

  group('LocationStack', () {
    test('should push a location', () {
      final list = LocationStack(locations: []);
      final location = HomeLocation();

      list.push(location);

      expect(list.locations.length, 1);
      expect(list.locations.first, equals(location));
    });

    test('should pop a location', () {
      final list = LocationStack(locations: []);
      final location = HomeLocation();

      list.push(location);
      list.pop();

      expect(list.locations.length, 0);
    });

    test('should generate a URI', () {
      final list = LocationStack(locations: []);
      final location1 = HomeLocation();
      final location2 = Page1Location();

      list.push(location1);
      list.push(location2);

      expect(list.uri, equals(Uri.parse('/home/page1')));
    });
  });

  group('LocationListCodec', () {
    final configuration = DuckRouterConfiguration(
      initialLocation: HomeLocation(),
    );

    setUp(() {
      configuration.addLocation(HomeLocation());
      configuration.addLocation(Page1Location());
    });

    test('should encode and decode a location list', () {
      final codec = LocationStackCodec(configuration: configuration);
      final list = LocationStack(
        locations: [
          HomeLocation(),
          Page1Location(),
        ],
      );

      final encoded = codec.encode(list);
      final decoded = codec.decode(encoded);

      expect(decoded.locations.length, 2);
      expect(decoded.locations.first, equals(HomeLocation()));
      expect(decoded.locations.last, equals(Page1Location()));
    });

    test('Throws error when decoding Location that is not declared', () {
      final codec = LocationStackCodec(configuration: configuration);
      final list = LocationStack(
        locations: [
          HomeLocation(),
          Page2Location(),
        ],
      );

      final encoded = codec.encode(list);
      expect(() => codec.decode(encoded), throwsA(isA<DuckRouterException>()));
    });
  });
}
