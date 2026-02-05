// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:duck_router/src/duck_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

Future<DuckRouter> createRouter(
  WidgetTester tester, {
  bool dispose = true,
}) async {
  final router = DuckRouter(initialLocation: HomeLocation());
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
    ),
  );
  return router;
}

void main() {
  group('DuckRouterDelegate', () {
    group('navigate', () {
      testWidgets(
        'should allow navigating to a new location',
        (WidgetTester tester) async {
          final router = await createRouter(tester);
          expect(
            router.routerDelegate.currentConfiguration.locations.length,
            1,
          );

          unawaited(router.navigate(to: Page1Location()));
          await tester.pumpAndSettle();

          unawaited(router.navigate(to: Page2Location()));
          await tester.pumpAndSettle();

          expect(
            router.routerDelegate.currentConfiguration.locations.length,
            3,
          );
        },
      );
    });

    group('pop', () {
      testWidgets('removes the last element', (WidgetTester tester) async {
        final router = await createRouter(tester);
        unawaited(router.navigate(to: Page1Location()));
        await tester.pumpAndSettle();
        expect(find.byType(Page1Screen), findsOneWidget);
        final last = router.routerDelegate.currentConfiguration.locations.last;
        await router.routerDelegate.popRoute();
        expect(router.routerDelegate.currentConfiguration.locations.length, 1);
        expect(
          router.routerDelegate.currentConfiguration.locations.contains(last),
          false,
        );
      });

      testWidgets('trying to pop the root should return false',
          (WidgetTester tester) async {
        final router = await createRouter(tester);
        unawaited(router.navigate(to: Page1Location()));
        await tester.pumpAndSettle();
        await router.routerDelegate.popRoute();
        expect(await router.routerDelegate.popRoute(), isFalse);
      });
    });

    group('_onPopPage', () {
      testWidgets(
        'system back button removes location from currentConfiguration',
        (WidgetTester tester) async {
          final router = await createRouter(tester);
          unawaited(router.navigate(to: Page1Location()));
          await tester.pumpAndSettle();
          expect(find.byType(Page1Screen), findsOneWidget);
          expect(
            router.routerDelegate.currentConfiguration.locations.length,
            2,
          );

          // Simulate system back button, which triggers _onPopPage
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          expect(
            router.routerDelegate.currentConfiguration.locations.length,
            1,
          );
          expect(
            router.routerDelegate.currentConfiguration.locations.last,
            isA<HomeLocation>(),
          );
          expect(find.byType(HomeScreen), findsOneWidget);
        },
      );

      testWidgets(
        'sequential system back button pops maintain correct stack state',
        (WidgetTester tester) async {
          final router = await createRouter(tester);
          unawaited(router.navigate(to: Page1Location()));
          await tester.pumpAndSettle();
          unawaited(router.navigate(to: Page2Location()));
          await tester.pumpAndSettle();

          expect(
            router.routerDelegate.currentConfiguration.locations.length,
            3,
          );

          // First back press: should remove Page2
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          expect(
            router.routerDelegate.currentConfiguration.locations.length,
            2,
          );
          expect(
            router.routerDelegate.currentConfiguration.locations.last,
            isA<Page1Location>(),
          );
          expect(find.byType(Page1Screen), findsOneWidget);

          // Second back press: should remove Page1
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          expect(
            router.routerDelegate.currentConfiguration.locations.length,
            1,
          );
          expect(
            router.routerDelegate.currentConfiguration.locations.last,
            isA<HomeLocation>(),
          );
          expect(find.byType(HomeScreen), findsOneWidget);
        },
      );

      testWidgets(
        'does not modify stack when pop is not allowed (didPop is false)',
        (WidgetTester tester) async {
          final router = await createRouter(tester);
          unawaited(router.navigate(to: NonPoppableLocation()));
          await tester.pumpAndSettle();

          expect(
            router.routerDelegate.currentConfiguration.locations.length,
            2,
          );

          // Simulate system back button on a non-poppable page.
          // PopScope(canPop: false) should cause didPop to be false,
          // and _onPopPage should early return without modifying the stack.
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          // Stack should be unchanged
          expect(
            router.routerDelegate.currentConfiguration.locations.length,
            2,
          );
          expect(
            router.routerDelegate.currentConfiguration.locations.last,
            isA<NonPoppableLocation>(),
          );
        },
      );

      testWidgets(
        'pop correctly passes result and removes location from stack',
        (WidgetTester tester) async {
          final router = await createRouter(tester);

          int? result;
          router.navigate<int>(to: Page1Location()).then((value) {
            result = value;
          });
          await tester.pumpAndSettle();
          expect(find.byType(Page1Screen), findsOneWidget);

          // Pop with a result triggers _onPopPage which should call
          // removeLocation with the result, completing the future.
          router.pop(42);
          await tester.pumpAndSettle();

          expect(result, equals(42));
          expect(
            router.routerDelegate.currentConfiguration.locations.length,
            1,
          );
          expect(
            router.routerDelegate.currentConfiguration.locations.last,
            isA<HomeLocation>(),
          );
        },
      );

      testWidgets(
        'pop without result still removes location from stack',
        (WidgetTester tester) async {
          final router = await createRouter(tester);
          unawaited(router.navigate(to: Page1Location()));
          await tester.pumpAndSettle();
          unawaited(router.navigate(to: Page2Location()));
          await tester.pumpAndSettle();

          expect(
            router.routerDelegate.currentConfiguration.locations.length,
            3,
          );

          router.pop();
          await tester.pumpAndSettle();

          expect(
            router.routerDelegate.currentConfiguration.locations.length,
            2,
          );
          expect(
            router.routerDelegate.currentConfiguration.locations.last,
            isA<Page1Location>(),
          );
          expect(find.byType(Page1Screen), findsOneWidget);
        },
      );
    });
  });
}
