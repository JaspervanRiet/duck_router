import 'package:duck_router/duck_router.dart';
import 'package:flutter/widgets.dart' as widgets;

/// {@template duck_router_exception}
/// Exception thrown by the [DuckRouter].
/// {@endtemplate}
class DuckRouterException implements Exception {
  /// {@macro duck_router_exception}
  const DuckRouterException(this.message);

  /// The message of the exception.
  final String message;

  @override
  String toString() => 'RouterException: $message';
}

class DuckRouterError extends widgets.FlutterError {
  DuckRouterError({
    required String summary,
    required List<String> details,
  }) : super.fromParts(<widgets.DiagnosticsNode>[
          widgets.ErrorSummary(summary),
          ...details.map((detail) => widgets.ErrorDescription(detail)),
        ]);

  factory DuckRouterError.missingOverride({
    required widgets.Widget? child,
    required TransitionBuilder? transitionsBuilder,
  }) {
    return DuckRouterError(
      summary: 'Invalid DuckPage configuration',
      details: [
        'When using a custom DuckPage, you must override createRoute or provide both child and transitionsBuilder.',
        'Current configuration:',
        '  child: ${child ?? 'null'}',
        '  transitionsBuilder: ${transitionsBuilder ?? 'null'}',
        'To fix this, either:',
        '  1. Override the createRoute method in your custom DuckPage, or',
        '  2. Provide both child and transitionsBuilder when creating DuckPage.',
      ],
    );
  }
}
