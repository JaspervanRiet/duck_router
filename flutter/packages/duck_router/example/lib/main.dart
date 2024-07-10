import 'package:flutter/material.dart';
import 'package:duck_router/duck_router.dart';

void main() {
  runApp(const MyApp());
}

final router = DuckRouter(
  initialLocation: RootLocation(),
  onDeepLink: (uri, currentLocation) {
    return [const DetailLocation()];
  },
  interceptors: [AuthInterceptor()],
);

bool loggedIn = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DuckRouter demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
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
  StatefulLocationBuilder get childBuilder =>
      (c, shell) => RootPage(shell: shell);
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
  const DetailLocation();

  @override
  String get path => 'detail';

  @override
  LocationBuilder get builder => (context) => const DetailScreen();
}

class MoreDetailLocation extends Location {
  const MoreDetailLocation();
  @override
  String get path => 'more-detail';

  @override
  LocationBuilder get builder => (context) => const MoreDetailScreen();
}

class RootPage extends StatefulWidget {
  const RootPage({
    required this.shell,
    super.key,
  });

  final DuckShell shell;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.shell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (i) {
          widget.shell.switchChild(i);
          setState(() {
            _currentIndex = i;
          });
        },
      ),
    );
  }
}

class Page1Screen extends StatelessWidget {
  const Page1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              DuckRouter.of(context).navigate(to: const DetailLocation());
            },
            child:
                const Text('Push me to navigate inside the stateful location!'),
          ),
          ElevatedButton(
            onPressed: () {
              DuckRouter.of(context)
                  .navigate(to: const DetailLocation(), root: true);
            },
            child: const Text(
                'Push me to navigate OUTSIDE the stateful location!'),
          ),
        ],
      ),
    );
  }
}

class Page2Screen extends StatelessWidget {
  const Page2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('This is a page 2 screen!'),
    );
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            const Text('This is a detail screen!'),
            ElevatedButton(
              onPressed: () {
                DuckRouter.of(context).navigate(to: const MoreDetailLocation());
              },
              child: const Text('Push me to navigate even further'),
            ),
          ],
        ),
      ),
    );
  }
}

class MoreDetailScreen extends StatelessWidget {
  const MoreDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('This is a more detail screen!'),
      ),
    );
  }
}

class LoginLocation extends Location {
  const LoginLocation();

  @override
  String get path => 'login';

  @override
  LocationBuilder get builder => (context) => const LoginScreen();
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              loggedIn = true;
              DuckRouter.of(context).navigate(
                to: const DetailLocation(),
                replace: true,
              );
            },
            child: const Text('Log in')),
      ),
    );
  }
}

class AuthInterceptor extends LocationInterceptor {
  @override
  Location? execute(Location to, Location? from) {
    if (to is DetailLocation) {
      if (!loggedIn) {
        return const LoginLocation();
      }
    }
    return null;
  }
}
