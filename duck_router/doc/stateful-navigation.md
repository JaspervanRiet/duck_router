To enable nested navigation, such as for a bottom bar implementation, you can use `StatefulLocation`:

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

Note that you might want to consider saving location instances in memory to avoid the instantiation.
