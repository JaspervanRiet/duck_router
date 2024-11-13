# duck_router

[![Badge](https://img.shields.io/pub/v/duck_router.svg)](https://pub.dev/packages/duck_router)

A powerful intent-based router for Flutter, inspired by production-grade architectures in the mobile domain.

See also: https://onsi.com/blog/app-navigation-at-scale-introducing-duckrouter

## Features

DuckRouter aims to be a router that _just works_.

- **Intent-based Navigation**: Make routing less error prone by defining routes as intents
- **Interceptors**: Add pre-navigation logic, perfect for authentication flows or feature flags.
- **Type-safe**: Leverage Dart's type system for safer routing.
- **Dynamic routing registry**: Routes do not need to be initialised before navigating to them, avoiding tricky bugs.
- **Deeplinking**: Adding deeplinking support is trivial, and works reliably.
- **Nested Navigation Support**: Easily support complex navigation scenarios.

## Usage

### 1. Define Your Locations

Create locations (route classes) for each destination in your app. Add as many properties to the class as needed, with any type needed:

```dart
class HomeLocation extends Location {
  const HomeLocation();

  @override
  String get path => '/home';

  @override
  LocationBuilder get builder => (context) => const HomeScreen();
}

class Page1Location extends Location {
  const Page1Location(this.money);

  final Money money; // Or any other type

  @override
  String get path => '/page1';

  @override
  LocationBuilder get builder => (context) => const Page1Screen(money);
}
```

### 2. Create Interceptors

If wanted, create interceptors to redirect users.

```dart
class AuthInterceptor extends LocationInterceptor {
  @override
  Location? execute(Location to, Location? from) {
    if (!loggedIn) {
      return const LoginLocation();
    }
    return null;
  }
}
```

### 3. Set Up the Router

Add the router to your app:

```dart
    final router = DuckRouter(initialLocation: ...);
    return MaterialApp.router(
      ...
      routerConfig: router,
    );
```

### 4. Navigate

Now you can navigate:

```dart
DuckRouter.of(context).navigate(to: const Page1Location(money));
```

## Further documentation

- [Configuration](https://pub.dev/documentation/duck_router/latest/topics/Configuration-topic.html)
- [Stateful navigation](https://pub.dev/documentation/duck_router/latest/topics/Stateful%20navigation-topic.html)
- [Deep linking](https://pub.dev/documentation/duck_router/latest/topics/Deep%20linking-topic.html)
- [Custom pages and transitions](https://pub.dev/documentation/duck_router/latest/topics/Custom%20pages%20and%20transitions-topic.html)
