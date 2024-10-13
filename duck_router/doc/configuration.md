When creating a DuckRouter instance, you have a number of options. This document provides documentation for those options.

```dart
final router = DuckRouter(
  initialLocation: ...,
  onDeepLink: (uri, currentLocation) {
    ...
  },
  interceptors: ...,
  navigatorObserverBuilder: (navigatorKey) {
    ...
  },
  onNavigate: ...
);
```

## Initial location

The first location the router will visit.

## Deep linking

See [Deep linking](https://pub.dev/documentation/duck_router/latest/topics/Deep-linking-topic.html)

## Interceptors

Interceptors are a powerful concept. They act as "hooks" that react to your navigation events. For example:

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

This interceptor would send the user to your login page if they are not logged in. Otherwise, it does not interfere with routing. There are many other concepts for which this concept can be used, such as maintenance pages, deep linking, push notification handling, and more.

## Navigator observers

Adding support for [NavigatorObservers](https://api.flutter.dev/flutter/widgets/NavigatorObserver-class.html) to the standard we would like is not trivial, due to the many limitations it has, and the fact we want to hide the implementation details of this package as much as possible.

Because of this, the support for this feature is kept basic, and users of this feature should be aware of the limitations!

- Observers should always be **stateless**
- Observers **can not be shared** between Navigators

When creating the DuckRouter instance, it is possible to pass a builder function for adding NavigatorObservers to each (nested) navigator, like the example below:

```dart
final router = DuckRouter(
  initialLocation: RootLocation(),
  onDeepLink: (uri, currentLocation) {
    return [const DetailLocation()];
  },
  interceptors: [AuthInterceptor()],
  navigatorObserverBuilder: (navigatorKey) {
    return [
      LoggerNavigatorObserver(),
    ];
  },
);
```

This builder will be called for every Navigator that is created. Because of the limitations above, it is important that each time this callback is triggered, new instances of the observers are returned!

## onNavigate

onNavigate allows observing all navigation that happens through duck_router. For example, you could use it to track which locations are visited by the user:

```dart
      onNavigate: (l) {
        if (l is Analytics) {
          analyticsService.track(l);
        }
      },
```

Remember, Locations are just classes. You can add mixins to them, inherit from them, and define any type of property or function you want. That makes for a really powerful concept.
