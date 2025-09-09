// ignore_for_file: prefer_const_constructors

import 'package:duck_router/duck_router.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  group('State Restoration', () {
    testWidgets('should restore locations with their arguments',
        (tester) async {
      final restorer = TestDuckRestorer();
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
        duckRestorer: restorer,
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

      final newConfig = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
        duckRestorer: restorer,
      );

      final newRouter = await createRouter(newConfig, tester);
      expect(newRouter.configuration.findLocation(detailLocation.path), isNull,
          reason: 'Fresh router should not have location without restoration');

      final restoredStack = await newRouter.routeInformationParser
          .parseRouteInformation(restorationRouteInfo!);
      final restoredDetailLocation =
          restoredStack.locations.whereType<DetailLocation>().first;

      expect(restoredDetailLocation.message, equals(originalMessage),
          reason: 'Location parameters should be preserved during restoration');

      newRouter.routerDelegate.setNewRoutePath(restoredStack);
      await tester.pumpAndSettle();
      expect(find.text(originalMessage), findsOneWidget,
          reason: 'Restored location should display with original parameters');
    });

    testWidgets('should serialize different location parameters differently',
        (tester) async {
      final restorer = TestDuckRestorer();

      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
        duckRestorer: restorer,
      );
      final router = await createRouter(config, tester);

      final location1 = DetailLocation(message: 'First Message');
      final location2 = DetailLocation(message: 'Second Message');

      final codec = LocationStackCodec(configuration: router.configuration);
      final stack1 = LocationStack(locations: [HomeLocation(), location1]);
      final stack2 = LocationStack(locations: [HomeLocation(), location2]);

      final encoded1 = codec.encode(stack1);
      final encoded2 = codec.encode(stack2);

      expect(
        encoded1,
        isNot(equals(encoded2)),
        reason:
            'Different location parameters should be serialized differently',
      );

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

    testWidgets('Intercepts routes when restoring', (tester) async {
      final restorer = TestDuckRestorer();

      final config = DuckRouterConfiguration(
          initialLocation: HomeLocation(), duckRestorer: restorer);

      final router = await createRouter(config, tester);
      final message = 'Quack quack';
      final detailLocation = DetailLocation(message: message);

      router.navigate(to: detailLocation);
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);

      final currentStack = router.routerDelegate.currentConfiguration;
      final restorationRouteInfo =
          router.routeInformationParser.restoreRouteInformation(currentStack);
      expect(restorationRouteInfo, isNotNull);

      final newConfig = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
        duckRestorer: restorer,
        interceptors: [_TestInterceptor()],
      );

      final newRouter = await createRouter(newConfig, tester);
      expect(newRouter.configuration.findLocation(detailLocation.path), isNull);

      final restoredStack = await newRouter.routeInformationParser
          .parseRouteInformation(restorationRouteInfo!);

      newRouter.routerDelegate.setNewRoutePath(restoredStack);
      await tester.pumpAndSettle();
      expect(find.byType(Page1Screen), findsOneWidget);
    });
  });
}

class _TestInterceptor extends LocationInterceptor {
  @override
  Location? execute(Location to, Location? from) {
    if (to is DetailLocation) {
      return Page1Location();
    }

    return null;
  }
}
