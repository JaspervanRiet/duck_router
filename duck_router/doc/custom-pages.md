DuckRouter uses the [Pages](https://api.flutter.dev/flutter/widgets/Page-class.html) API from Flutter to handle the conversions to [Routes](https://api.flutter.dev/flutter/widgets/Route-class.html).

To have a page animate with a custom transition, we can use `DuckPage`:

```dart
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
```

In this case `DuckPage` will create a custom route for you. This means that to specify a non-default route, such as a dialog, we need to override `DuckPage`.

Let's take the case of a dialog (but you can implement any type of Route in this way):

```dart
class DialogPage<T> extends DuckPage<T> {
  const DialogPage({
    required this.builder,
  }) : super.custom();

  final WidgetBuilder builder;

   @override
   Route<T> createRoute(context, settings) => DialogRoute<T>(
         context: context,
         settings: settings,
         builder: (context) => Dialog(
           child: builder(context),
         ),
       );
 }
```

We can then use this page like so:

```dart
class DialogPageLocation extends Location {
  const DialogPageLocation();

  @override
  String get path => 'dialog-page';

  @override
  LocationPageBuilder get pageBuilder=> (context) => DialogPage(
    name: path,
    builder: ...
  );
}
```

And to open it, all we do is:

```dart
DuckRouter.of(context).navigate(to: DialogPageLocation);
```
