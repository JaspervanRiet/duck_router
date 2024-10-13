If your app does not yet support deep linking, please see the documentation at [flutter.dev](https://docs.flutter.dev/ui/navigation/deep-linking).

To enable deeplinking support within duck_router, add an `onDeepLink` handler to the configuration:

```dart
final router = DuckRouter(
  onDeepLink: (uri, currentLocation) {
    // Do something with the deep link. You can choose how to handle the deeplink:
    // - Immediately return a stack of locations
    // - Fire-and-forget: save the deeplink in memory and return null here, so you can act upon it later in your own service.
  },
);
```

This gives you the current location and the URI for the deeplink, and asks you to return an optional stack of locations, with the last entry being the page shown. In cases where it's considered likely for the route to be intercepted (e.g. by a login screen), consider keeping the deeplink location in memory and acting upon it later, and returning `null` instead.
