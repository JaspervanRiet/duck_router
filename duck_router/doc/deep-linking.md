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

This gives you the current location and the URI for the deeplink, and asks you to return an optional stack of locations, with the last entry being the page shown.

## Advanced scenarios

In cases where it's considered likely for the route to be intercepted (e.g. by a login screen), consider keeping the deeplink location in memory and acting upon it later, and returning `null` instead.

For example. Imagine a flow where you have a splash screen (`SplashLocation`) that opens a page with a bottom bar (`RootLocation`). Upon receiving a deeplink, this app should display its splash screen, then open the deep linked page, but backed by the `RootLocation` behind it. An interceptor using Riverpod for that scenario could look like below:

````dart
class DeepLinkInterceptor extends LocationInterceptor {
  DeepLinkInterceptor(
    this.ref, {
    // This is an important parameter. This parameter means that instead of intercepting
    // the route, we add this route on top.
    super.pushesOnTop = true,
  });

  final Ref ref;

  @override
  Location? execute(Location to, Location? from) {
    if (to is SplashLocation) {
      /// Let the splash page do its thing, e.g. load users.
      return null;
    }

    /// Get a deeplink if we have one. This requires setting
    /// the deeplink in `onDeepLink`.
    ///
    /// ```dart
    /// onDeepLink: (deepLink, current) {
    ///   if (current is SplashLocation) {
    ///     ref
    ///       .read(deepLinkServiceProvider.notifier)
    ///       .setDeepLink(deepLink.path);
    ///
    ///     return null;
    ///   }
    ///
    ///   // handle deeplink normally
    /// }
    /// ```
    final deepLink = ref.read(deepLinkServiceProvider);

    if (deepLink == null) {
      return null;
    }

    ref.read(deepLinkServiceProvider.notifier).clear();

    if (deepLink.contains('duck') {
      // This will be put on top of `RootLocation`
      return DuckLocation(slug: deepLink);
    }

    return null;
  }
}
````
