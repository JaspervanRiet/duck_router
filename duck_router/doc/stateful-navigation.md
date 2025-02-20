Sometimes you want to have a separate navigation stack. For example:

- A bottom bar with multiple pages, each with their own navigation stack.
- A bottom sheet, or any other flow-like navigation, that allows users to go forward and backward.
- Cases where you want to have a wrapper element around a set of routes

See below for examples of such flows.

## Bottom bar

```dart
class RootLocation extends StatefulLocation {
  @override
  String get path => 'root';

  @override
  List<Location> get children => [
        const Child1Location(),
        const Child2Location(),
      ];

  /// Note: here, we have implemented the childBuilder in place. We of
  /// course recommend making this its own class.
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
```

That's it. Then, when navigating you have two options:

```dart
// Navigate while still showing the bottom bar, i.e. inside the child navigator
DuckRouter.of(context).navigate(to: const DetailLocation());

// Navigate while not showing the bottom bar, i.e. on root navigator
DuckRouter.of(context).navigate(to: const DetailLocation(), root: true);
```

## Bottom sheet

This example shows how one might implement a bottom sheet containing a login/registration flow. It uses the [modal_bottom_sheet](https://pub.dev/packages/modal_bottom_sheet) package to accomplish that. To achieve cases like these, [DuckRouter] provides the convenience class [FlowLocation], a wrapper around [StatefulLocation]. This example combines usage of a [FlowLocation] with custom pages, see also [Custom Pages](https://pub.dev/documentation/duck_router/latest/topics/Custom-pages-topic.html).

```dart
class SheetPage<T> extends DuckPage<T> {
  const SheetPage({
    required this.builder,
  }) : super.custom();

  final WidgetBuilder builder;

  @override
  Route<T> createRoute(BuildContext context, RouteSettings? settings) {
    return modalSheetBuilder(context, builder, settings);
  }
}

class BottomSheetContainer extends StatelessWidget {
  final Widget child;
  final Radius topRadius;

  const BottomSheetContainer({
    super.key,
    required this.child,
    required this.topRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DesignSystem.of(context);

    final topSafeAreaPadding = MediaQuery.of(context).padding.top;
    final topPadding = topSafeAreaPadding + theme.spacing.s800;

    const shadow = BoxShadow(
      blurRadius: 30,
      color: Colors.black26,
      spreadRadius: 15,
    );

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colors.surfaceDefaultDefault,
          boxShadow: const [shadow],
          borderRadius: BorderRadius.only(
            topLeft: topRadius,
            topRight: topRadius,
          ),
        ),
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: topRadius),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          ),
        ),
      ),
    );
  }
}

Route<T> modalSheetBuilder<T>(
    BuildContext context, WidgetBuilder builder, RouteSettings? settings) {
  final theme = DesignSystem.of(context);

  return CupertinoModalBottomSheetRoute(
    settings: settings,
    builder: builder,
    expanded: false,
    enableDrag: true,
    containerBuilder: (context, animation, child) => BottomSheetContainer(
      topRadius: Radius.circular(theme.spacing.s400),
      child: child,
    ),
  );
}
```

Your actual flow would then look like this:

```dart

class LoginFlowLocation extends FlowLocation {
  @override
  String get path => 'login-flow';

  @override
  Location get start => EmailLocation();

  @override
  LocationPageBuilder? get containerBuilder => (context) => SheetPage(
        builder: builder,
      );
}
```

You would start the flow by navigating to it:

```dart
DuckRouter.of(context).navigate(to: const LoginFlowLocation());
// Within the flow, you can navigate back and forth like so:
DuckRouter.of(context).navigate(to: const PasswordLocation());
// Or go all the way back to the root:
DuckRouter.of(context).root();
// Or close the sheet entirely:
DuckRouter.of(context).popRoot();
```
