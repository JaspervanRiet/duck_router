import 'package:duck_router/src/navigator.dart';
import 'package:flutter/widgets.dart';

bool isWidgetsApp(BuildContext context) =>
    context.findAncestorWidgetOfExactType<WidgetsApp>() != null;

Page<void> pageBuilderForWidgetsApp({
  required LocalKey key,
  required String? name,
  required Widget child,
  required OnPopInvokedCallback onPopInvoked,
}) =>
    WidgetsPage<void>(
      name: name,
      key: key,
      child: child,
      onPopInvoked: onPopInvoked,
    );

class WidgetsPage<T> extends Page<T> {
  const WidgetsPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    super.onPopInvoked,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return child;
      },
    );
  }
}
