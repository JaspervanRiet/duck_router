// ignore_for_file: prefer_const_constructors

import 'package:duck_router/src/configuration.dart';
import 'package:duck_router/src/location.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  group('State Restoration', () {
    testWidgets('should restore locations with their arguments',
        (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      final originalMessage = 'Quack quack';
      final detailLocation = DetailLocation(message: originalMessage);

      router.navigate(to: detailLocation);
      await tester.pumpAndSettle();
      expect(find.text(originalMessage), findsOneWidget);

      // Get the actual restoration data by calling restoreRouteInformation
      final currentStack = router.routerDelegate.currentConfiguration;
      final restorationRouteInfo =
          router.routeInformationParser.restoreRouteInformation(currentStack);
      expect(restorationRouteInfo, isNotNull);

      // Simulate app restart by creating a completely fresh router
      final newConfig = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final newRouter = await createRouter(newConfig, tester);
      expect(newRouter.configuration.findLocation(detailLocation.path), isNull,
          reason: 'Fresh router should not have pre-registered locations');

      // Try to restore using the serialized restoration data
      // This should fail because the detail location is not pre-registered
      final restoredStack = await newRouter.routeInformationParser
          .parseRouteInformation(restorationRouteInfo!);

      // The restored location should have the same message parameter
      final restoredDetailLocation =
          restoredStack.locations.whereType<DetailLocation>().first;

      expect(restoredDetailLocation.message, equals(originalMessage),
          reason: 'Location parameters should be preserved during restoration');

      // Navigate to the restored stack
      newRouter.routerDelegate.setNewRoutePath(restoredStack);
      await tester.pumpAndSettle();
      expect(find.text(originalMessage), findsOneWidget,
          reason: 'Restored location should display with original parameters');
    });

    testWidgets('should serialize different location parameters differently',
        (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );
      final router = await createRouter(config, tester);

      // Create locations with different parameters
      final location1 = DetailLocation(message: 'First Message');
      final location2 = DetailLocation(message: 'Second Message');

      final codec = LocationStackCodec(configuration: router.configuration);
      final stack1 = LocationStack(locations: [HomeLocation(), location1]);
      final stack2 = LocationStack(locations: [HomeLocation(), location2]);

      final encoded1 = codec.encode(stack1);
      final encoded2 = codec.encode(stack2);

      // Different location parameters should produce different encoded data
      expect(encoded1, isNot(equals(encoded2)),
          reason:
              'Different location parameters should be serialized differently');

      // Verify parameters are included in serialized form
      final locations1 = encoded1['locations'] as List;
      final locations2 = encoded2['locations'] as List;

      final detail1 = locations1[1] as Map<Object?, Object?>;
      final detail2 = locations2[1] as Map<Object?, Object?>;

      expect(detail1['path'], equals('detail'));
      expect(detail2['path'], equals('detail'));

      // Parameters should be serialized
      expect(detail1['message'], equals('First Message'),
          reason: 'Location parameters should be serialized');
      expect(detail2['message'], equals('Second Message'),
          reason: 'Location parameters should be serialized');

      expect(detail1, isNot(equals(detail2)),
          reason:
              'Different parameters should result in different serialized data');
    });
  });
}
