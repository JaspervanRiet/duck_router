// ignore_for_file: prefer_const_constructors

import 'package:duck_router/src/configuration.dart';
import 'package:duck_router/src/duck_router.dart';
import 'package:duck_router/src/interceptor.dart';
import 'package:duck_router/src/location.dart';
import 'package:duck_router/src/pages/pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<DuckRouter> createRouter(
  DuckRouterConfiguration routerConfiguration,
  WidgetTester tester, {
  String? restorationScopeId,
}) async {
  final router = DuckRouter.withConfig(
    configuration: routerConfiguration,
  );
  await tester.pumpWidget(
    MaterialApp.router(
      restorationScopeId:
          restorationScopeId != null ? '$restorationScopeId-root' : null,
      routerConfig: router,
    ),
  );
  return router;
}

Future<DuckRouter> createRouterOnIos(
  DuckRouterConfiguration routerConfiguration,
  WidgetTester tester, {
  String? restorationScopeId,
}) async {
  final router = DuckRouter.withConfig(
    configuration: routerConfiguration,
  );
  await tester.pumpWidget(
    CupertinoApp.router(
      restorationScopeId:
          restorationScopeId != null ? '$restorationScopeId-root' : null,
      routerConfig: router,
    ),
  );
  return router;
}

Future<DuckRouter> createRouterOnWidgetsApp(
  DuckRouterConfiguration routerConfiguration,
  WidgetTester tester, {
  String? restorationScopeId,
}) async {
  final router = DuckRouter.withConfig(
    configuration: routerConfiguration,
  );
  await tester.pumpWidget(
    WidgetsApp.router(
      color: Colors.blue,
      restorationScopeId:
          restorationScopeId != null ? '$restorationScopeId-root' : null,
      routerConfig: router,
    ),
  );
  return router;
}

class DummyScreen extends StatelessWidget {
  const DummyScreen({
    this.queryParametersAll = const <String, dynamic>{},
    super.key,
  });

  final Map<String, dynamic> queryParametersAll;

  @override
  Widget build(BuildContext context) => const Placeholder();
}

class HomeScreen extends DummyScreen {
  const HomeScreen({super.key});
}

class HomeLocation extends Location {
  const HomeLocation();

  @override
  String get path => 'home';

  @override
  LocationBuilder get builder => (context) => const HomeScreen();
}

class Page1Screen extends DummyScreen {
  const Page1Screen({super.key});
}

class Page1Location extends Location {
  const Page1Location();

  @override
  String get path => 'page1';

  @override
  LocationBuilder get builder => (context) => const Page1Screen();
}

class Page2Screen extends DummyScreen {
  const Page2Screen({super.key});
}

class Page2Location extends Location {
  const Page2Location();

  @override
  String get path => 'page2';

  @override
  LocationBuilder get builder => (context) => const Page2Screen();
}

class Page3Screen extends DummyScreen {
  const Page3Screen({super.key});
}

class Page3Location extends Location {
  const Page3Location();

  @override
  String get path => 'page3';

  @override
  LocationBuilder get builder => (context) => const Page3Screen();
}

class Page4Screen extends DummyScreen {
  const Page4Screen({super.key});
}

class Page4Location extends Location {
  const Page4Location();

  @override
  String get path => 'page4';

  @override
  LocationBuilder get builder => (context) => const Page4Screen();
}

class LoginScreen extends DummyScreen {
  const LoginScreen({super.key});
}

class LoginLocation extends Location {
  const LoginLocation();

  @override
  String get path => 'login';

  @override
  LocationBuilder get builder => (context) => const LoginScreen();
}

class SensitiveScreen extends DummyScreen {
  const SensitiveScreen({super.key});
}

class SensitiveLocation extends Location {
  const SensitiveLocation();

  @override
  String get path => 'sensitive';

  @override
  LocationBuilder get builder => (context) => const SensitiveScreen();
}

class AuthInterceptor extends LocationInterceptor {
  AuthInterceptor({
    required this.isLoggedIn,
  });

  final bool Function() isLoggedIn;

  @override
  Location? execute(Location to, Location? from) {
    if (to is SensitiveLocation && !isLoggedIn()) {
      return LoginLocation();
    }
    return null;
  }
}

class PushesOnTopInterceptor extends LocationInterceptor {
  PushesOnTopInterceptor() : super(pushesOnTop: true);

  @override
  Location? execute(Location to, Location? from) {
    return Page1Location();
  }
}

class RootLocation extends StatefulLocation {
  @override
  String get path => 'root';

  @override
  List<Location> get children => [
        const Child1Location(),
        const Child2Location(),
      ];

  @override
  StatefulLocationBuilder get childBuilder => (c, shell) => Scaffold(
        body: shell,
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Page 1',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Page 2',
            ),
          ],
          onTap: (value) => shell.switchChild(value),
        ),
      );
}

class NestedChildRootLocation extends StatefulLocation {
  @override
  String get path => 'nested';

  @override
  List<Location> get children => [Child1Location()];

  @override
  StatefulLocationBuilder get childBuilder => (c, shell) => shell;
}

class RootLocationWithCustomPage extends StatefulLocation {
  @override
  String get path => 'root';

  @override
  List<Location> get children => [
        const CustomPageLocation(),
        const Child1Location(),
      ];

  @override
  StatefulLocationBuilder get childBuilder => (c, shell) => Scaffold(
        body: shell,
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Page 1',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Page 2',
            ),
          ],
          onTap: (value) => shell.switchChild(value),
        ),
      );
}

class Child1Location extends Location {
  const Child1Location();

  @override
  String get path => 'child1';

  @override
  LocationBuilder get builder => (context) => const Page1Screen();
}

class Child2Location extends Location {
  const Child2Location();

  @override
  String get path => 'child2';

  @override
  LocationBuilder get builder => (context) => const Page2Screen();
}

class DetailLocation extends Location {
  const DetailLocation({
    required this.message,
  });

  final String message;

  @override
  String get path => 'detail';

  @override
  LocationBuilder get builder => (context) => DetailScreen(message: message);

  @override
  List<Object?> get props => [path, message];
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(message);
  }
}

class CustomPageLocation extends Location {
  const CustomPageLocation();

  @override
  String get path => 'custom-page';

  @override
  LocationPageBuilder get pageBuilder => (context) => CustomPage();
}

class CustomPageTransitionLocation extends Location {
  const CustomPageTransitionLocation();

  @override
  String get path => 'custom-page-transition';

  @override
  LocationPageBuilder get pageBuilder => (context) => DuckPage(
        child: HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      );
}

class CustomPage<T> extends DuckPage<T> {
  const CustomPage() : super.custom();

  @override
  Route<T> createRoute(BuildContext context, RouteSettings? settings) {
    return MaterialPageRoute<T>(
      settings: settings,
      builder: (context) => const CustomScreen(),
    );
  }
}

class CustomScreen extends StatelessWidget {
  const CustomScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) => const Placeholder();
}

class TestFlowLocation extends FlowLocation {
  @override
  String get path => 'flow';

  @override
  Location get start => Page1Location();

  @override
  StatefulLocationPageBuilder? get containerBuilder => null;
}

class TestFlowLocationWithContainer extends FlowLocation {
  @override
  String get path => 'flow';

  @override
  Location get start => Page1Location();

  @override
  StatefulLocationPageBuilder? get containerBuilder => (c, b) {
        return DuckPage(
            child: b(c),
            transitionsBuilder: (c, a1, a2, child) =>
                FadeTransition(opacity: a1, child: child));
      };
}

/// This is a faulty custom implementation because it uses the custom constructor
/// without overriding `createRoute`.
class FaultyCustomPage<T> extends DuckPage<T> {
  const FaultyCustomPage() : super.custom();
}

class RefreshableApp extends StatelessWidget {
  RefreshableApp({
    required this.stream,
    super.key,
  });

  final Stream<int> stream;

  final DuckRouter router = DuckRouter(
    initialLocation: HomeLocation(),
    interceptors: [],
  );

  final appKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Widget child = KeyedSubtree(
      key: appKey,
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );

    return StreamBuilder(
        stream: stream,
        builder: (context, s) {
          if (s.data == 1) {
            router.navigate(to: Page1Location());
          }
          if (s.data == 2) {
            child = Container(
              child: child,
            );
          }
          return child;
        });
  }
}

class TestDuckRestorer implements DuckRestorer {
  @override
  Location? fromJson(String path, Map<String, dynamic> json) {
    switch (path) {
      case 'home':
        return HomeLocation();
      case 'detail':
        return DetailLocation(message: json['message']);
      default:
        return null;
    }
  }

  @override
  Map<String, dynamic> toJson(Location l) {
    if (l is DetailLocation) {
      return {'message': l.message};
    }
    return {};
  }
}
