// ignore_for_file: prefer_const_constructors, unawaited_futures

import 'dart:async';

import 'package:duck_router/src/configuration.dart';
import 'package:duck_router/src/exception.dart';
import 'package:duck_router/src/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  group('Basic routing', () {
    testWidgets('match home route', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.locations.length, 1);
      expect(locations.uri.path, '/home');
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('can replace location', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      router.navigate(to: Page1Location(), replace: true);
      await tester.pumpAndSettle();
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/page1');
    });

    testWidgets('Pops', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      router.navigate(
        to: Page1Location(),
      );
      await tester.pumpAndSettle();
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.locations.length, 2);

      router.pop();
      final locations2 = router.routerDelegate.currentConfiguration;
      expect(locations2.locations.length, 1);
      expect(locations2.uri.path, '/home');
    });

    testWidgets('Pops until X', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      router.navigate(
        to: Page1Location(),
      );
      await tester.pumpAndSettle();
      router.navigate(
        to: Page2Location(),
      );
      await tester.pumpAndSettle();
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.locations.length, 3);

      router.popUntil((location) => location is HomeLocation);
      final locations2 = router.routerDelegate.currentConfiguration;
      expect(locations2.locations.length, 1);
      expect(locations2.uri.path, '/home');
    });

    testWidgets('Pops until X from nested flow', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      router.navigate(
        to: NestedChildRootLocation(),
      );
      await tester.pumpAndSettle();
      router.navigate(
        to: Child2Location(),
      );
      await tester.pumpAndSettle();
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.locations.length, 2);
      final nestedLocations = (locations.locations.last as StatefulLocation)
          .state
          .currentRouterDelegate
          .currentConfiguration;
      expect(nestedLocations.locations.length, 2);

      router.popUntil((location) => location is HomeLocation);
      final locations2 = router.routerDelegate.currentConfiguration;
      expect(locations2.locations.length, 1);
      expect(locations2.uri.path, '/home');
    });

    testWidgets('can popUntil just one pop', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      router.navigate(
        to: Page1Location(),
      );
      await tester.pumpAndSettle();
      router.navigate(
        to: Page2Location(),
      );
      await tester.pumpAndSettle();
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.locations.length, 3);

      router.popUntil((location) => location is Page1Location);
      final locations2 = router.routerDelegate.currentConfiguration;
      expect(locations2.locations.length, 2);
      expect(locations2.uri.path, '/home/page1');
    });

    testWidgets('Does nothing for popUntil if already in the location',
        (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      await tester.pumpAndSettle();

      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.locations.length, 1);
      expect(locations.uri.path, '/home');

      router.popUntil((location) => location is HomeLocation);
      await tester.pumpAndSettle();

      final locations2 = router.routerDelegate.currentConfiguration;
      expect(locations2.locations.length, 1);
      expect(locations2.uri.path, '/home');
    });

    testWidgets('Resets to root', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      router.navigate(
        to: Page1Location(),
      );
      await tester.pumpAndSettle();

      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.locations.length, 2);

      router.root();

      final locations2 = router.routerDelegate.currentConfiguration;

      expect(locations2.uri.path, '/home');
    });

    testWidgets('Clears stack', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      router.navigate(
        to: Page1Location(),
      );
      await tester.pumpAndSettle();
      router.navigate(
        to: Page2Location(),
      );
      await tester.pumpAndSettle();

      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.locations.length, 3);

      router.navigate(to: LoginLocation(), clearStack: true);
      await tester.pumpAndSettle();

      final locations2 = router.routerDelegate.currentConfiguration;

      expect(locations2.uri.path, '/login');
    });

    testWidgets('Does not reset when already in root', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      router.navigate(
        to: RootLocation(),
        replace: true,
      );
      await tester.pumpAndSettle();
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/root');
      router.navigate(
        to: HomeLocation(),
        replace: true,
      );
      await tester.pumpAndSettle();

      router.root();
      await tester.pumpAndSettle();
      final locations3 = router.routerDelegate.currentConfiguration;
      expect(locations3.uri.path, '/root');

      router.root();

      await tester.pumpAndSettle();
      final locations4 = router.routerDelegate.currentConfiguration;
      expect(locations4.uri.path, '/root');
    });

    testWidgets('can await navigate', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/home');

      int result = 0;
      router
          .navigate<int>(
        to: Page1Location(),
      )
          .then((value) {
        return result = value!;
      });
      await tester.pumpAndSettle();
      expect(find.byType(Page1Screen), findsOneWidget);

      router.pop(1);
      await tester.pumpAndSettle();

      expect(result, equals(1));
    });

    testWidgets('can navigate to and from locations with arguments',
        (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      expect(find.byType(HomeScreen), findsOneWidget);

      final detailLocation = DetailLocation(message: 'Hello!');
      router.navigate(
        to: detailLocation,
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello!'), findsOneWidget);

      router.navigate(to: Page1Location());
      await tester.pumpAndSettle();
      expect(find.text('Hello!'), findsNothing);
    });

    testWidgets('works with iOS', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouterOnIos(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.locations.length, 1);
      expect(locations.uri.path, '/home');
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    group('Custom page', () {
      testWidgets('can specify custom page', (tester) async {
        final config = DuckRouterConfiguration(
          initialLocation: CustomPageLocation(),
        );

        final router = await createRouterOnIos(config, tester);
        final locations = router.routerDelegate.currentConfiguration;
        expect(locations.locations.length, 1);
        expect(locations.uri.path, '/custom-page');
        expect(find.byType(CustomScreen), findsOneWidget);
      });

      testWidgets('can specify custom page transition', (tester) async {
        final config = DuckRouterConfiguration(
          initialLocation: CustomPageTransitionLocation(),
        );

        final router = await createRouterOnIos(config, tester);
        final locations = router.routerDelegate.currentConfiguration;
        expect(locations.locations.length, 1);
        expect(locations.uri.path, '/custom-page-transition');
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('Can pop from custom page', (tester) async {
        final config = DuckRouterConfiguration(
          initialLocation: HomeLocation(),
        );

        final router = await createRouter(config, tester);
        router.navigate(to: CustomPageLocation());
        await tester.pumpAndSettle();
        final locations = router.routerDelegate.currentConfiguration;
        expect(locations.locations.length, 2);
        expect(locations.uri.path, '/home/custom-page');
        expect(find.byType(CustomScreen), findsOneWidget);

        router.pop();
        await tester.pumpAndSettle();
        final locations2 = router.routerDelegate.currentConfiguration;
        expect(locations2.locations.length, 1);
        expect(locations2.uri.path, '/home');
      });

      testWidgets('Throws error when custom page does not override createRoute',
          (tester) async {
        late BuildContext context;

        await tester.pumpWidget(
          Builder(builder: (c) {
            context = c;
            return Container();
          }),
        );

        final page = FaultyCustomPage();
        try {
          page.createRoute(context);
          fail('Should have thrown an error');
        } catch (e) {
          expect(e, isInstanceOf<DuckRouterException>());
          expect(
              e.toString(),
              contains(
                  'When using a custom DuckPage, you must override createRoute'));
        }
      });
    });

    testWidgets('Does not error when refreshing app', (tester) async {
      StreamController<int> streamController =
          StreamController<int>.broadcast();

      await tester.pumpWidget(
        RefreshableApp(stream: streamController.stream),
      );

      streamController.add(1);
      await tester.pumpAndSettle();

      streamController.close();
    });
  });

  group('Interceptors', () {
    testWidgets('can intercept a location', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
        interceptors: [
          AuthInterceptor(isLoggedIn: () => false),
        ],
      );

      final router = await createRouter(config, tester);
      router.navigate(
        to: SensitiveLocation(),
      );
      await tester.pumpAndSettle();

      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/home/login');
    });

    testWidgets('Goes through as expected when not intercepting',
        (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
        interceptors: [
          AuthInterceptor(isLoggedIn: () => true),
        ],
      );

      final router = await createRouter(config, tester);
      router.navigate(
        to: SensitiveLocation(),
      );
      await tester.pumpAndSettle();

      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/home/sensitive');
    });

    testWidgets('Pushes on top if specified', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
        interceptors: [
          PushesOnTopInterceptor(),
        ],
      );

      final router = await createRouter(config, tester);
      await tester.pumpAndSettle();

      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/home/page1');
    });

    testWidgets('Errors when pushing a route with a duplicate path',
        (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      await tester.pumpAndSettle();

      // Second navigation to the same path
      expect(
        () => router.navigate(to: HomeLocation()),
        throwsA(isA<DuckRouterException>().having(
          (e) => e.toString(),
          'message',
          contains('Cannot push duplicate route: home'),
        )),
      );

      await tester.pumpAndSettle();
    });
  });

  group('Nested navigation', () {
    testWidgets('can host a stateful location', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.locations.length, 1);
      expect(locations.uri.path, '/root');
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Page1Screen), findsOneWidget);
      expect(find.byType(Page2Screen), findsNothing);
    });

    testWidgets('can switch between tabs', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.locations.length, 1);
      expect(locations.uri.path, '/root');
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Page1Screen), findsOneWidget);
      expect(find.byType(Page2Screen), findsNothing);

      await tester.tap(find.text('Page 2'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(find.byType(Page1Screen), findsNothing);
      expect(find.byType(Page2Screen), findsOneWidget);
    });

    testWidgets('can push and pop inside stateful locations', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/root');

      router.navigate(to: HomeLocation());
      await tester.pumpAndSettle();

      final locations2 = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/root');
      final statefulLocation = locations2.locations.last as StatefulLocation;
      final child =
          statefulLocation.state.currentRouterDelegate.currentConfiguration;
      expect(child.uri.path, '/child1/home');
      expect(find.byType(HomeScreen), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(
          statefulLocation
              .state.currentRouterDelegate.currentConfiguration.uri.path,
          '/child1');

      // Now we should start seeing an error because we're trying to pop
      // the root.
      expect(router.pop, throwsException);
    });

    testWidgets('can clear stack in nested locations', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/root');

      router.navigate(to: Page1Location());
      await tester.pumpAndSettle();

      router.navigate(to: Page2Location());
      await tester.pumpAndSettle();

      final locations2 = router.routerDelegate.currentConfiguration;
      expect(locations2.uri.path, '/root');
      final statefulLocation = locations2.locations.last as StatefulLocation;
      final child =
          statefulLocation.state.currentRouterDelegate.currentConfiguration;
      expect(child.uri.path, '/child1/page1/page2');
      expect(find.byType(Page2Screen), findsOneWidget);

      router.navigate(to: HomeLocation(), clearStack: true);
      await tester.pumpAndSettle();
      expect(
          statefulLocation
              .state.currentRouterDelegate.currentConfiguration.uri.path,
          '/home');
    });

    testWidgets('can clear root stack from nested location', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/root');

      router.navigate(to: Page1Location());
      await tester.pumpAndSettle();

      router.navigate(to: Page2Location());
      await tester.pumpAndSettle();

      final locations2 = router.routerDelegate.currentConfiguration;
      expect(locations2.uri.path, '/root');
      final statefulLocation = locations2.locations.last as StatefulLocation;
      final child =
          statefulLocation.state.currentRouterDelegate.currentConfiguration;
      expect(child.uri.path, '/child1/page1/page2');
      expect(find.byType(Page2Screen), findsOneWidget);

      router.navigate(to: HomeLocation(), clearStack: true, root: true);
      await tester.pumpAndSettle();
      final locations3 = router.routerDelegate.currentConfiguration;
      expect(locations3.uri.path, '/home');
    });

    testWidgets('Can popUntil in nested locations', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/root');

      router.navigate(to: HomeLocation());
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      router.navigate(to: Page1Location());
      await tester.pumpAndSettle();
      expect(find.byType(Page1Screen), findsOneWidget);

      router.navigate(to: Page2Location());
      await tester.pumpAndSettle();
      expect(find.byType(Page2Screen), findsOneWidget);

      router.popUntil((location) => location is HomeLocation);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('can replace location', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/root');

      router.navigate(to: HomeLocation(), replace: true);
      await tester.pumpAndSettle();

      final locations2 = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/root');
      final statefulLocation = locations2.locations.last as StatefulLocation;
      final child =
          statefulLocation.state.currentRouterDelegate.currentConfiguration;
      expect(child.uri.path, '/home');
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('can still push to root navigator', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
      );

      final router = await createRouter(config, tester);

      router.navigate(to: HomeLocation(), root: true);
      await tester.pumpAndSettle();

      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/root/home');
    });

    testWidgets('can mix pushing to root and pushing to nested',
        (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/root');

      router.navigate(to: HomeLocation());
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(Page1Screen), findsOneWidget);

      router.navigate(to: HomeLocation(), root: true);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(Page1Screen), findsOneWidget);
    });

    testWidgets('can await navigate', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/root');

      int result = 0;
      router.navigate<int>(to: HomeLocation()).then((value) {
        return result = value!;
      });
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      router.pop(1);
      await tester.pumpAndSettle();

      expect(result, equals(1));
    });

    testWidgets('Child back button dispatcher handles back button press',
        (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
      );

      final router = await createRouter(config, tester);

      // Navigate to a child route
      router.navigate(to: HomeLocation());
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);

      // Simulate a back button press
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(Page1Screen), findsOneWidget);
    });

    testWidgets('Nested back button handling works correctly', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
      );

      final router = await createRouter(config, tester);

      // Navigate to a child route
      router.navigate(to: HomeLocation());
      await tester.pumpAndSettle();

      // Navigate to another child route
      router.navigate(to: Page1Location());
      await tester.pumpAndSettle();

      expect(find.byType(Page1Screen), findsOneWidget);

      // Simulate a back button press
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // Check if we've returned to the HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Page1Screen), findsNothing);

      // Simulate another back button press
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // Should now be at first page of RootLocation
      // Which is the Page1Screen
      expect(find.byType(Page1Screen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      // Try to go back again (should stay at RootLocation)
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // Should still be at RootLocation
      expect(find.byType(Page1Screen), findsOneWidget);
    });

    testWidgets('can reset', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/root');

      router.navigate(to: HomeLocation());
      await tester.pumpAndSettle();

      final locations2 = router.routerDelegate.currentConfiguration;
      final statefulLocation = locations2.locations.last as StatefulLocation;
      final child =
          statefulLocation.state.currentRouterDelegate.currentConfiguration;
      expect(child.uri.path, '/child1/home');
      expect(find.byType(HomeScreen), findsOneWidget);

      router.root();
      await tester.pumpAndSettle();
      expect(
          statefulLocation
              .state.currentRouterDelegate.currentConfiguration.uri.path,
          '/child1');

      // Now we should start seeing an error because we're trying to pop
      // the root.
      expect(router.pop, throwsException);
    });

    group('Custom', () {
      testWidgets('can host', (tester) async {
        final config = DuckRouterConfiguration(
          initialLocation: RootLocationWithCustomPage(),
        );

        final router = await createRouter(config, tester);
        final locations = router.routerDelegate.currentConfiguration;
        expect(locations.locations.length, 1);
        expect(locations.uri.path, '/root');
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(CustomScreen), findsOneWidget);
        expect(find.byType(Page2Screen), findsNothing);
      });

      testWidgets('Can pop from custom page', (tester) async {
        final config = DuckRouterConfiguration(
          initialLocation: RootLocation(),
        );

        final router = await createRouter(config, tester);
        await tester.pumpAndSettle();
        router.navigate(to: CustomPageLocation());
        await tester.pumpAndSettle();
        expect(find.byType(CustomScreen), findsOneWidget);

        router.pop();
        await tester.pumpAndSettle();
        expect(find.byType(Page1Screen), findsOneWidget);
      });
    });
  });

  group('Deeplinking', () {
    testWidgets('receives deep links', (tester) async {
      final binding = _retrieveTestBinding(tester);
      binding.platformDispatcher.defaultRouteNameTestValue = '/page1';

      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
        onDeepLink: (deeplink, initialLocation) {
          return [Page1Location()];
        },
      );

      final router = await createRouter(
        config,
        tester,
      );
      final locations = router.routerDelegate.currentConfiguration;
      await tester.pumpAndSettle();

      expect(locations.uri.path, '/page1');
      expect(find.byType(Page1Screen), findsOneWidget);
    });

    testWidgets('handles full URLs', (tester) async {
      final binding = _retrieveTestBinding(tester);
      binding.platformDispatcher.defaultRouteNameTestValue =
          'https://app.onsi.com/page1';

      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
        onDeepLink: (deeplink, initialLocation) {
          if (deeplink.path == '/page1') {
            return [Page1Location()];
          }
          return [HomeLocation()];
        },
      );

      final router = await createRouter(
        config,
        tester,
      );
      final locations = router.routerDelegate.currentConfiguration;
      await tester.pumpAndSettle();

      expect(locations.uri.path, '/page1');
      expect(find.byType(Page1Screen), findsOneWidget);
    });

    testWidgets('ignores deep links if no handler set', (tester) async {
      final binding = _retrieveTestBinding(tester);
      binding.platformDispatcher.defaultRouteNameTestValue = '/page1';

      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(
        config,
        tester,
      );
      final locations = router.routerDelegate.currentConfiguration;
      await tester.pumpAndSettle();

      expect(locations.uri.path, '/home');
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Page1Screen), findsNothing);
    });

    testWidgets(
        'ignores deep links if location stack returned (supports the fire-and-forget scenario)',
        (tester) async {
      final binding = _retrieveTestBinding(tester);
      binding.platformDispatcher.defaultRouteNameTestValue = '/page1';

      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
        onDeepLink: (_, __) => null,
      );

      final router = await createRouter(
        config,
        tester,
      );
      final locations = router.routerDelegate.currentConfiguration;
      await tester.pumpAndSettle();

      expect(locations.uri.path, '/home');
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Page1Screen), findsNothing);
    });

    testWidgets('sends empty deep link to initial location', (tester) async {
      final binding = _retrieveTestBinding(tester);
      binding.platformDispatcher.defaultRouteNameTestValue = '';

      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
        onDeepLink: (deeplink, initialLocation) {
          return [Page1Location()];
        },
      );

      final router = await createRouter(
        config,
        tester,
      );
      final locations = router.routerDelegate.currentConfiguration;
      await tester.pumpAndSettle();

      expect(locations.uri.path, '/home');
    });

    testWidgets('classes base URL as empty deep link', (tester) async {
      final binding = _retrieveTestBinding(tester);
      binding.platformDispatcher.defaultRouteNameTestValue =
          'https://google.com';

      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
        onDeepLink: (deeplink, initialLocation) {
          return [Page1Location()];
        },
      );

      final router = await createRouter(
        config,
        tester,
      );
      final locations = router.routerDelegate.currentConfiguration;
      await tester.pumpAndSettle();

      expect(locations.uri.path, '/home');
    });

    testWidgets('handles deep link while router is active', (tester) async {
      final binding = _retrieveTestBinding(tester);
      binding.platformDispatcher.defaultRouteNameTestValue = '';

      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
        onDeepLink: (deeplink, initialLocation) {
          return [Page1Location()];
        },
      );

      final router = await createRouter(
        config,
        tester,
      );
      final locations = router.routerDelegate.currentConfiguration;
      await tester.pumpAndSettle();

      expect(locations.uri.path, '/home');

      const Map<String, dynamic> testRouteInformation = <String, dynamic>{
        'location': '/page1',
        'state': 'state',
        'restorationData': <dynamic, dynamic>{'test': 'config'},
      };
      final ByteData message = const JSONMethodCodec().encodeMethodCall(
        const MethodCall('pushRouteInformation', testRouteInformation),
      );

      await tester.binding.defaultBinaryMessenger
          .handlePlatformMessage('flutter/navigation', message, (_) {});

      await tester.pumpAndSettle();
      final locations2 = router.routerDelegate.currentConfiguration;

      expect(locations2.uri.path, '/page1');
    });

    testWidgets(
        'handles deep link while router is active but returns null as location stack',
        (tester) async {
      final binding = _retrieveTestBinding(tester);
      binding.platformDispatcher.defaultRouteNameTestValue = '';

      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
        onDeepLink: (deeplink, initialLocation) {
          return null;
        },
      );

      final router = await createRouter(
        config,
        tester,
      );
      final locations = router.routerDelegate.currentConfiguration;
      await tester.pumpAndSettle();

      expect(locations.uri.path, '/home');

      const Map<String, dynamic> testRouteInformation = <String, dynamic>{
        'location': '/page1',
        'state': 'state',
        'restorationData': <dynamic, dynamic>{'test': 'config'},
      };
      final ByteData message = const JSONMethodCodec().encodeMethodCall(
        const MethodCall('pushRouteInformation', testRouteInformation),
      );

      await tester.binding.defaultBinaryMessenger
          .handlePlatformMessage('flutter/navigation', message, (_) {});

      await tester.pumpAndSettle();
      final locations2 = router.routerDelegate.currentConfiguration;

      expect(locations2.uri.path, '/home');
    });

    // We intentionally do not support this feature, see
    // [_platformReportsNewRouteInformation] in [DuckInformationProvider].
    testWidgets('does not start nesting for the user', (tester) async {
      final binding = _retrieveTestBinding(tester);
      binding.platformDispatcher.defaultRouteNameTestValue = '';

      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
        onDeepLink: (deeplink, initialLocation) {
          return [
            RootLocation(),
            Child1Location(),
            HomeLocation(),
          ];
        },
      );

      final router = await createRouter(
        config,
        tester,
      );
      final locations = router.routerDelegate.currentConfiguration;
      await tester.pumpAndSettle();

      expect(locations.uri.path, '/root');

      const Map<String, dynamic> testRouteInformation = <String, dynamic>{
        'location': '/root/child1/home',
        'state': 'state',
        'restorationData': <dynamic, dynamic>{'test': 'config'},
      };
      final ByteData message = const JSONMethodCodec().encodeMethodCall(
        const MethodCall('pushRouteInformation', testRouteInformation),
      );

      await tester.binding.defaultBinaryMessenger
          .handlePlatformMessage('flutter/navigation', message, (_) {});

      await tester.pumpAndSettle();
      final locations2 = router.routerDelegate.currentConfiguration;

      expect(locations2.uri.path, '/root/child1/home');
    });
  });
}

TestWidgetsFlutterBinding _retrieveTestBinding(WidgetTester tester) {
  final WidgetsBinding binding = tester.binding;
  assert(binding is TestWidgetsFlutterBinding);
  final TestWidgetsFlutterBinding testBinding =
      binding as TestWidgetsFlutterBinding;
  return testBinding;
}

class PushRouteObserver with WidgetsBindingObserver {
  late String pushedRoute;

  @override
  Future<bool> didPushRoute(String route) async {
    pushedRoute = route;
    return true;
  }
}
