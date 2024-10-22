import 'package:duck_router/src/navigator.dart';
import 'package:duck_router/src/pages/page.dart' as duck_page;
import 'package:flutter/widgets.dart';

Page<T> pageBuilderForCustomPage<T>({
  required duck_page.DuckPage<T> page,
  required OnPopInvokedCallback onPopInvoked,
}) =>
    _DuckPage<T>(
      page,
      onPopInvoked: onPopInvoked,
    );

class _DuckPage<T> extends Page<T> {
  _DuckPage(
    duck_page.DuckPage<T> page, {
    super.onPopInvoked,
  })  : child = page.child,
        transitionDuration = page.transitionDuration,
        reverseTransitionDuration = page.reverseTransitionDuration,
        maintainState = page.maintainState,
        isModal = page.isModal,
        canTapToDismiss = page.canTapToDismiss,
        backgroundColor = page.backgroundColor,
        semanticLabel = page.semanticLabel,
        transitionsBuilder = page.transitionsBuilder,
        _page = page,
        super(
          name: page.name,
          canPop: page.canPop ?? true,
          restorationId: page.restorationId,
        );

  final duck_page.DuckPage<T> _page;

  /// Content of this page.
  final Widget? child;

  /// Duration of the transition.
  ///
  /// Defaults to 300ms.
  final Duration transitionDuration;

  /// Duration of the reverse transition.
  ///
  /// Defaults to 300ms.
  final Duration reverseTransitionDuration;

  /// If true, route will stay in memory.
  ///
  /// See also:
  /// - [ModalRoute.maintainState]
  final bool maintainState;

  /// Set to true to make this page route a modal page, which is a fullscreen
  /// page that covers the entire screen and shows an X instead of a back
  /// button.
  final bool isModal;

  /// Set to true to allow dismissing the route by tapping.
  ///
  /// Defaults to false.
  final bool canTapToDismiss;

  /// The color to use as background color for the route.
  ///
  /// If this is null, the barrier will be transparent.
  ///
  /// See also:
  /// - [ModalRoute.barrierColor]
  final Color? backgroundColor;

  /// The semantic label used if this route can be dismissed by tapping.
  ///
  /// See also:
  /// - [ModalRoute.barrierLabel]
  /// - [canTapToDismiss]
  final String? semanticLabel;

  /// Use the [transitionsBuilder] to define custom transitions for this page.
  ///
  /// This transition will wrap the [child] widget.
  ///
  /// See also:
  /// - [ModalRoute.buildTransitions] for more information on how to use this.
  final duck_page.TransitionBuilder? transitionsBuilder;

  @override
  Route<T> createRoute(BuildContext context) {
    return _page.createRoute(context, this) ?? _DuckPageRoute<T>(this);
  }
}

class _DuckPageRoute<T> extends PageRoute<T> {
  _DuckPageRoute(_DuckPage<T> page) : super(settings: page);

  _DuckPage<T> get _page => settings as _DuckPage<T>;

  @override
  bool get barrierDismissible => _page.canTapToDismiss;

  @override
  Color? get barrierColor => _page.backgroundColor;

  @override
  String? get barrierLabel => _page.semanticLabel;

  @override
  Duration get transitionDuration => _page.transitionDuration;

  @override
  Duration get reverseTransitionDuration => _page.reverseTransitionDuration;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.isModal;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: _page.child,
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      _page.transitionsBuilder!(
        context,
        animation,
        secondaryAnimation,
        child,
      );
}
