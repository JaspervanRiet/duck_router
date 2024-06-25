The DuckRouter is a Flutter router using intents. It has been tested at scale at [Onsi](https://onsi.com/). DuckRouter has been designed using a philosophy of no "magic", while focusing on reliability.

# Features

- Intent-based navigation using types
- Dynamic route registry
- Interceptors for routes
- Stack-based routing

# Getting started

Add the router:

```dart
    final router = DuckRouter(initialLocation: ...);
    return MaterialApp.router(
      ...
      routerConfig: router,
    );
```

Define some routes:

```dart
class HomeLocation extends Location {
  const HomeLocation() : super(path: 'home');

  @override
  LocationBuilder get builder => (context) => const HomeScreen();
}

class Page1Location extends Location {
  const Page1Location() : super(path: 'page1');

  @override
  LocationBuilder get builder => (context) => const Page1Screen();
}
```

Now you can navigate:

```dart
DuckRouter.of(context).navigate(to: const Page1Location());
```

See also the example.

# Key features

DuckRouter is an intent-based router. This makes navigation intentional. We try to avoid magic, since it's easy to get into edge cases where the magic starts posing a problem. DuckRouter uses a dynamic registry. That means that you do not have to map your routes beforehand. You do have to define them, but from then on you can add them anywhere inside the backstack. This approach means you can no longer forget to add routes, nor do you have to declare all the entrypoints for a page. Your page is declared in one page, and you can navigate to it whenever you wish. Easy!

## Nested navigation

To enable nested navigation, such as for a bottom bar implementation, you can use `StatefulLocation`:

```dart
class RootLocation extends StatefulLocation {
  @override
  String get path => 'root';

  @override
  List<StatefulChildLocation> get children => [
        const Child1Location(),
        const Child2Location(),
      ];

  /// Note: here, we have implemented the pagebuilder in place. We of
  /// course recommend making this its own class.
  @override
  StatefulLocationBuilder get pageBuilder => (c, shell) => Scaffold(
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

class Child1Location extends StatefulChildLocation {
  const Child1Location();

  @override
  String get path => 'child1';

  @override
  LocationBuilder get builder => (context) => const Page1Screen();
}

class Child2Location extends StatefulChildLocation {
  const Child2Location();

  @override
  String get path => 'child2';

  @override
  LocationBuilder get builder => (context) => const Page2Screen();
}
```

That's it. Then, when navigating you have two options:

```dart
// Navigate while still showing the bottom bar, i.e. inside the child navigator
DuckRouter.of(context).navigate(to: const DetailLocation());

// Navigate while not showing the bottom bar, i.e. on root navigator
DuckRouter.of(context).navigate(to: const DetailLocation(), root: true);
```

Note that you might want to consider saving location instances in memory to avoid the instantiation.

## Deep linking

To enable deeplinking support, add an `onDeepLink` handler to the configuration:

```dart
final router = DuckRouter(
  onDeepLink: (uri, currentLocation) {
    // do something with the deep link and return a stack of locations
  },
);
```

This gives you the current location and the URI for the deeplink, and asks you to return a stack of locations, with the last entry being the page shown. In cases where it's considered likely for the route to be intercepted (e.g. by a login screen), consider keeping the deeplink location in memory and acting upon it later.
