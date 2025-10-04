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

    /// Screen A --- navigates to and waits for result of ---> Screen B
    /// Screen B --- navigates to with replace:true ---> Screen C
    /// Screen C --- pops to ---> Screen A
    testWidgets('shows correct screen after replace and pop', (tester) async {
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

      router.navigate(to: Page2Location(), replace: true);
      await tester.pumpAndSettle();
      expect(find.byType(Page2Screen), findsOneWidget);

      router.pop(1);
      await tester.pumpAndSettle();

      expect(result, equals(1));
    });

    /// Screen A --- navigates to and waits for result of ---> Screen B
    /// Screen B --- navigates to with replace:true ---> Screen C
    /// Screen C --- pops to ---> Screen A
    testWidgets('can await navigate that gets replaced', (tester) async {
      const timeout = Duration(seconds: 10);

      // Initial screen A
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/home');

      /// A -> B: expect result 1 from B
      final navigateFuture1 = expectLater(
        router.navigate<int>(to: Page1Location()).timeout(timeout),
        completion(equals(1)),
      );
      await tester.pumpAndSettle();

      /// A -> B replaces to C: expect result 1 from C
      /// This is expected to produce result on its own and propagate result
      /// back to creator of B (to the screen A)
      final navigateFuture2 = expectLater(
        router.navigate(to: Page2Location(), replace: true).timeout(timeout),
        completion(equals(1)),
      );
      await tester.pumpAndSettle();

      /// C pops with result 1. This result should be delivered to function from
      /// screen B (the original caller) and to screen A (since C took place of B).
      router.pop(1);
      await tester.pumpAndSettle();

      await (
        navigateFuture1,
        navigateFuture2,
        tester.pump(Duration(seconds: 25)),
      ).wait;
    });

    testWidgets(
        'throws error if trying to return different type result in location that replaces another',
        (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/home');

      // ignore: unused_local_variable
      int a = 0;
      Exception? exception;
      router
          .navigate<int>(
        to: Page1Location(),
      )
          .then((value) {
        return a = value!;
      }).catchError((e) {
        exception = e;
        return 0;
      });
      await tester.pumpAndSettle();
      expect(find.byType(Page1Screen), findsOneWidget);

      router.navigate(to: Page2Location(), replace: true);
      await tester.pumpAndSettle();
      expect(find.byType(Page2Screen), findsOneWidget);

      router.pop('different type than int');
      await tester.pumpAndSettle();
      expect(exception, isA<InvalidPopTypeException>());
    });

    testWidgets('Can return null when a page replacing a page is being awaited',
        (tester) async {
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
        return result = value ?? 1;
      });
      await tester.pumpAndSettle();
      expect(find.byType(Page1Screen), findsOneWidget);

      router.navigate(to: Page2Location(), replace: true);
      await tester.pumpAndSettle();
      expect(find.byType(Page2Screen), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(result, equals(1));
    });

    testWidgets('can await navigate that gets cleared via clearStack',
        (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/home');

      int result = 0;
      Exception? error;
      router
          .navigate<int>(
        to: Page1Location(),
      )
          .then((value) {
        return result = 1;
      }).catchError((e) {
        error = e;
        return 2;
      });
      await tester.pumpAndSettle();
      expect(find.byType(Page1Screen), findsOneWidget);

      router.navigate(to: Page2Location(), clearStack: true);
      await tester.pumpAndSettle();
      expect(find.byType(Page2Screen), findsOneWidget);

      expect(result, equals(0));
      expect(error, TypeMatcher<ClearStackException>());
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

    testWidgets('works with WidgetsApp', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouterOnWidgetsApp(config, tester);
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

      testWidgets('can await navigate to custom page', (tester) async {
        final config = DuckRouterConfiguration(
          initialLocation: HomeLocation(),
        );

        final router = await createRouter(config, tester);
        final locations = router.routerDelegate.currentConfiguration;
        expect(locations.uri.path, '/home');

        int result = 0;
        router.navigate<int>(to: CustomPageLocation()).then((value) {
          return result = value!;
        });
        await tester.pumpAndSettle();
        expect(find.byType(CustomScreen), findsOneWidget);

        router.pop(1);
        await tester.pumpAndSettle();

        expect(result, equals(1));
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
          page.createRoute(context, null);
          fail('Should have thrown an error');
        } catch (e) {
          expect(e, isInstanceOf<MissingCreateRouteException>());
        }
      });
    });

    /// See https://github.com/JaspervanRiet/duck_router/issues/40
    ///
    /// This test is to ensure that the router does not error when
    /// it has to restore itself.
    testWidgets('Does not error when refreshing app', (tester) async {
      StreamController<int> streamController =
          StreamController<int>.broadcast();

      addTearDown(() {
        streamController.close();
      });

      await tester.pumpWidget(
        RefreshableApp(stream: streamController.stream),
      );

      // This will navigate to a new page. We do this
      // to ensure that we're not just fixing a duplication issue
      // for the initial location, but in general instead.
      streamController.add(1);
      await tester.pumpAndSettle();

      // This will trigger a rebuild of the app,
      // including the router. That will trigger
      // a restoration of the router.
      streamController.add(2);
      await tester.pumpAndSettle();
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
        throwsA(isA<DuplicateRouteException>()),
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

    testWidgets('can pop the root', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      var locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/home');

      router.navigate(to: RootLocation());
      await tester.pumpAndSettle();

      locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/home/root');

      router.navigate(to: Page1Location());
      await tester.pumpAndSettle();

      final locations2 = router.routerDelegate.currentConfiguration;
      final statefulLocation = locations2.locations.last as StatefulLocation;
      final child =
          statefulLocation.state.currentRouterDelegate.currentConfiguration;
      expect(child.uri.path, '/child1/page1');
      expect(find.byType(Page1Screen), findsOneWidget);

      router.exit();
      locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/home');
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

    testWidgets('can await navigate that gets cleared via clearStack',
        (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: RootLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/root');

      int result = 0;
      Exception? error;
      router
          .navigate<int>(
        to: Page1Location(),
      )
          .then((value) {
        return result = 1;
      }).catchError((e) {
        error = e;
        return 2;
      });
      await tester.pumpAndSettle();
      expect(find.byType(Page1Screen), findsOneWidget);

      router.navigate(to: Page2Location(), clearStack: true);
      await tester.pumpAndSettle();
      expect(find.byType(Page2Screen), findsOneWidget);

      expect(result, equals(0));
      expect(error, TypeMatcher<ClearStackException>());
    });

    /// Screen A --- opens nested screen B
    /// Screen B --- navigates to and waits for result of ---> Screen C
    /// Screen C --- exits ---> Screen A
    /// Screen B's navigate should throw a ClearStackException
    testWidgets('can await navigate that gets cleared via exit',
        (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/home');

      router.navigate(to: NestedChildRootLocation());
      await tester.pumpAndSettle();

      int result = 0;
      Exception? error;
      router
          .navigate<int>(
        to: Page2Location(),
      )
          .then((value) {
        return result = 1;
      }).catchError((e) {
        error = e;
        return 2;
      });
      await tester.pumpAndSettle();
      expect(find.byType(Page2Screen), findsOneWidget);

      router.exit();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      expect(result, equals(0));
      expect(error, TypeMatcher<ClearStackException>());
    });

    /// Screen A --- opens nested screen B
    /// Screen B --- navigates to and waits for result of ---> Screen C
    /// Screen C --- navigates to with replace:true ---> Screen D
    /// Screen D --- pops to ---> Screen B
    testWidgets('shows correct screen after replace and pop', (tester) async {
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/home');

      router.navigate(to: RootLocation());
      await tester.pumpAndSettle();

      expect(find.byType(Page1Screen), findsOneWidget);

      int result = 0;
      router
          .navigate<int>(
        to: Page2Location(),
      )
          .then((value) {
        return result = value!;
      });
      await tester.pumpAndSettle();

      router.navigate(to: Page3Location(), replace: true);
      await tester.pumpAndSettle();

      expect(find.byType(Page3Screen), findsOneWidget);

      router.pop(1);
      await tester.pumpAndSettle();

      expect(find.byType(Page1Screen), findsOneWidget);

      expect(result, equals(1));
    });

    /// Screen A --- opens nested screen B
    /// Screen B --- navigates to and waits for result of ---> Screen C
    /// Screen C --- navigates to with replace:true ---> Screen D
    /// Screen D --- pops to ---> Screen B
    testWidgets('can await navigate that gets replaced', (tester) async {
      const timeout = Duration(seconds: 10);

      // Initial screen A
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/home');

      /// A -> B: expect timeout, since we never pop it
      final navigateFuture1 = expectLater(
        router.navigate(to: RootLocation()).timeout(timeout),
        throwsA(isA<TimeoutException>()),
      );
      await tester.pumpAndSettle();

      /// A -> B -> C: expect result 1 from C
      final navigateFuture2 = expectLater(
        router.navigate<int>(to: Page2Location()).timeout(timeout),
        completion(equals(1)),
      );
      await tester.pumpAndSettle();

      /// A -> B -> C replaces to D: expect result 1 from D
      /// This is expected to produce result on its own and propagate result
      /// back to creator of C (to the screen B)
      final navigateFuture3 = expectLater(
        router.navigate(to: Page3Location(), replace: true).timeout(timeout),
        completion(equals(1)),
      );
      await tester.pumpAndSettle();

      /// D pops with result 1. This result should be delivered to function from
      /// screen C (the original caller) and to screen B (since D took place of C).
      router.pop(1);
      await tester.pumpAndSettle();

      await (
        navigateFuture1,
        navigateFuture2,
        navigateFuture3,
        tester.pump(Duration(seconds: 25)),
      ).wait;
    });

    /// Screen A -> Screen B (awaited, timeout)
    /// Screen B -> Screen C (awaited, result 42)
    /// Screen C -> Screen D (replaced, result 42)
    /// Screen D -> Screen E (replaced, result 42)
    /// Screen E -> Screen F (replaced, result 42)
    /// Screen F -> Screen G (replaced, result 42)
    /// Screen G pops with result 42, which should propagate back through the chain
    testWidgets(
        'can handle more awaited navigations with multiple replacements',
        (tester) async {
      const timeout = Duration(seconds: 15);

      // Initial screen A
      final config = DuckRouterConfiguration(
        initialLocation: HomeLocation(),
      );

      final router = await createRouter(config, tester);
      final locations = router.routerDelegate.currentConfiguration;
      expect(locations.uri.path, '/home');

      /// A -> B: expect timeout, since we never pop it
      final navigateFuture1 = expectLater(
        router.navigate(to: RootLocation()).timeout(timeout),
        throwsA(isA<TimeoutException>()),
      );
      await tester.pumpAndSettle();

      /// A -> B -> C: expect result 42 from C
      final navigateFuture2 = expectLater(
        router.navigate<int>(to: Page2Location()).timeout(timeout),
        completion(equals(42)),
      );
      await tester.pumpAndSettle();

      /// A -> B -> C replaces to D: expect result 42 from D
      final navigateFuture3 = expectLater(
        router.navigate(to: Page3Location(), replace: true).timeout(timeout),
        completion(equals(42)),
      );
      await tester.pumpAndSettle();

      /// A -> B -> D replaces to E: expect result 42 from E
      final navigateFuture4 = expectLater(
        router.navigate(to: Page1Location(), replace: true).timeout(timeout),
        completion(equals(42)),
      );
      await tester.pumpAndSettle();

      /// A -> B -> E replaces to F: expect result 42 from F
      final navigateFuture5 = expectLater(
        router.navigate(to: LoginLocation(), replace: true).timeout(timeout),
        completion(equals(42)),
      );
      await tester.pumpAndSettle();

      /// A -> B -> F replaces to G: expect result 42 from G
      final navigateFuture6 = expectLater(
        router.navigate(to: Page4Location(), replace: true).timeout(timeout),
        completion(equals(42)),
      );
      await tester.pumpAndSettle();

      /// F pops with result 42. This result should be delivered to function from
      /// screen F (the original caller) and propagate back through the entire chain
      router.pop(42);
      await tester.pumpAndSettle();

      await (
        navigateFuture1,
        navigateFuture2,
        navigateFuture3,
        navigateFuture4,
        navigateFuture5,
        navigateFuture6,
        tester.pump(Duration(seconds: 30)),
      ).wait;
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

    group('FlowLocation', () {
      testWidgets('can navigate to page', (tester) async {
        final config = DuckRouterConfiguration(
          initialLocation: HomeLocation(),
        );

        final router = await createRouter(config, tester);
        await tester.pumpAndSettle();
        router.navigate(to: TestFlowLocation());
        await tester.pumpAndSettle();
        expect(find.byType(Page1Screen), findsOneWidget);
        final locations = router.routerDelegate.currentConfiguration;
        expect(locations.uri.path, '/home/flow');
      });

      testWidgets('can navigate to another page from start', (tester) async {
        final config = DuckRouterConfiguration(
          initialLocation: HomeLocation(),
        );

        final router = await createRouter(config, tester);
        await tester.pumpAndSettle();
        router.navigate(to: TestFlowLocation());
        await tester.pumpAndSettle();
        expect(find.byType(Page1Screen), findsOneWidget);
        router.navigate(to: Page2Location());
        await tester.pumpAndSettle();
        expect(find.byType(Page2Screen), findsOneWidget);
        final locations = router.routerDelegate.currentConfiguration;
        expect(locations.uri.path, '/home/flow');
        final flowLocation = locations.locations.last as FlowLocation;
        final innerLocations =
            flowLocation.state.currentRouterDelegate.currentConfiguration;
        expect(innerLocations.uri.path, '/page1/page2');
      });

      testWidgets('can render with container', (tester) async {
        final config = DuckRouterConfiguration(
          initialLocation: HomeLocation(),
        );

        final router = await createRouter(config, tester);
        await tester.pumpAndSettle();
        router.navigate(to: TestFlowLocationWithContainer());
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
