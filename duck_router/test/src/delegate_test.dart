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
  });
}
