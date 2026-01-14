import 'package:flutter/material.dart';
import 'dart:async';

/// Abstract base class for controllers with lifecycle support.
abstract class ValentyController {
  /// Called when the controller is initialized.
  void onInit() {}

  /// Called when the controller is disposed.
  void onDispose() {}
}

/// A simple dependency injection and state management container.
class Valenty {
  // Singleton instance
  static final Valenty _instance = Valenty._internal();
  factory Valenty() => _instance;
  Valenty._internal();

  final Map<String, dynamic> _dependencies = {};

  // --- Context-less Navigation & UI ---

  /// Global Key for Navigator.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Global Key for ScaffoldMessenger.
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Helper to get current context.
  static BuildContext? get context => _instance.navigatorKey.currentContext;

  /// Registers a dependency.
  ///
  /// [dependency] is the instance to be registered.
  /// [tag] uses a unique tag to register multiple instances of the same type.
  ///
  /// Returns the registered dependency.
  static S put<S>(S dependency, {String? tag}) {
    final String key = _getKey(S, tag);
    if (_instance._dependencies.containsKey(key)) {
      debugPrint(
        'Valenty: $key already registered. Returning existing instance.',
      );
      return _instance._dependencies[key] as S;
    }

    _instance._dependencies[key] = dependency;
    if (dependency is ValentyController) {
      dependency.onInit();
    }
    debugPrint('Valenty: Registered $key');
    return dependency;
  }

  /// Finds a registered dependency.
  ///
  /// [tag] optional tag to lookup.
  ///
  /// Throws an error if the dependency is not found.
  static S find<S>({String? tag}) {
    final String key = _getKey(S, tag);
    final dep = _instance._dependencies[key];
    if (dep == null) {
      throw 'Valenty: $key not found. Make sure to call Valenty.put() first.';
    }
    return dep as S;
  }

  /// Deletes a registered dependency.
  ///
  /// [tag] optional tag to lookup.
  ///
  /// Returns true if the dependency was found and deleted.
  static bool delete<S>({String? tag}) {
    final String key = _getKey(S, tag);
    return _deleteByKey(key);
  }

  /// Internal method to delete by key.
  static bool _deleteByKey(String key) {
    if (_instance._dependencies.containsKey(key)) {
      final dependency = _instance._dependencies.remove(key);
      if (dependency is ValentyController) {
        dependency.onDispose();
      }
      debugPrint('Valenty: Deleted $key');
      return true;
    }
    return false;
  }

  static String _getKey(Type type, String? tag) {
    return tag == null ? type.toString() : '${type.toString()}_$tag';
  }

  // --- Global UI Methods ---

  /// Shows a dialog.
  static Future<T?> dialog<T>(Widget widget, {bool barrierDismissible = true}) {
    if (context == null) {
      throw 'Valenty: Context is null. Did you use ValentyApp?';
    }
    return showDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      builder: (_) => widget,
    );
  }

  /// Shows a bottom sheet.
  static Future<T?> bottomSheet<T>(
    Widget widget, {
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    bool isScrollControlled = false,
  }) {
    if (context == null) {
      throw 'Valenty: Context is null. Did you use ValentyApp?';
    }
    return showModalBottomSheet<T>(
      context: context!,
      builder: (_) => widget,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      isScrollControlled: isScrollControlled,
    );
  }

  /// Shows a snackbar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackbar(
    String title,
    String message, {
    Color? backgroundColor,
    Color? colorText,
    Duration duration = const Duration(seconds: 3),
    SnackPosition snackPosition = SnackPosition.bottom,
  }) {
    final messenger = _instance.scaffoldMessengerKey.currentState;
    if (messenger == null) {
      throw 'Valenty: ScaffoldMessengerState is null. Did you use ValentyApp?';
    }

    return messenger.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: colorText),
            ),
            SizedBox(height: 4),
            Text(message, style: TextStyle(color: colorText)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: snackPosition == SnackPosition.top
            ? SnackBarBehavior.floating
            : SnackBarBehavior.fixed,
        margin: snackPosition == SnackPosition.top
            ? EdgeInsets.only(
                bottom: MediaQuery.of(context!).size.height - 150,
                left: 10,
                right: 10,
              )
            : null,
      ),
    );
  }

  // --- Navigation Methods ---

  static dynamic _arguments;

  /// Global arguments passed to routes.
  static dynamic get arguments => _arguments;

  /// Navigate to a new page.
  static Future<T?>? to<T>(
    Widget page, {
    bool? opaque,
    Transition? transition,
    Curve? curve,
    Duration? duration,
    int? id,
    String? routeName,
    bool fullscreenDialog = false,
    dynamic arguments,
    bool preventDuplicates = true,
    double? popGesture,
  }) {
    if (context == null) {
      throw 'Valenty: Context is null. Did you use ValentyApp?';
    }

    _arguments = arguments;

    // Simplistic implementation using MaterialPageRoute for now.
    // Enhanced functionality (transitions) would require custom Route implementation.
    return Navigator.of(context!).push<T>(
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: routeName, arguments: arguments),
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Navigate to a named route.
  static Future<T?>? toNamed<T>(String page, {dynamic arguments}) {
    if (context == null) {
      throw 'Valenty: Context is null. Did you use ValentyApp?';
    }
    _arguments = arguments;
    return Navigator.of(context!).pushNamed<T>(page, arguments: arguments);
  }

  /// Replace the current page.
  static Future<T?>? off<T>(
    Widget page, {
    String? routeName,
    dynamic arguments,
    bool fullscreenDialog = false,
  }) {
    if (context == null) {
      throw 'Valenty: Context is null. Did you use ValentyApp?';
    }
    _arguments = arguments;
    return Navigator.of(context!).pushReplacement<T, T>(
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: routeName, arguments: arguments),
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Replace the current page with named route.
  static Future<T?>? offNamed<T>(String page, {dynamic arguments}) {
    if (context == null) {
      throw 'Valenty: Context is null. Did you use ValentyApp?';
    }
    _arguments = arguments;
    return Navigator.of(
      context!,
    ).pushReplacementNamed<T, T>(page, arguments: arguments);
  }

  /// Remove all previous pages and go to new page.
  static Future<T?>? offAll<T>(
    Widget page, {
    String? routeName,
    dynamic arguments,
    bool fullscreenDialog = false,
    RoutePredicate? predicate,
  }) {
    if (context == null) {
      throw 'Valenty: Context is null. Did you use ValentyApp?';
    }
    _arguments = arguments;
    return Navigator.of(context!).pushAndRemoveUntil<T>(
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: routeName, arguments: arguments),
        fullscreenDialog: fullscreenDialog,
      ),
      predicate ?? (_) => false,
    );
  }

  /// Remove all previous pages and go to named route.
  static Future<T?>? offAllNamed<T>(
    String page, {
    dynamic arguments,
    RoutePredicate? predicate,
  }) {
    if (context == null) {
      throw 'Valenty: Context is null. Did you use ValentyApp?';
    }
    _arguments = arguments;
    return Navigator.of(context!).pushNamedAndRemoveUntil<T>(
      page,
      predicate ?? (_) => false,
      arguments: arguments,
    );
  }

  /// Pop the current page.
  static void back<T>([T? result]) {
    if (context == null) {
      throw 'Valenty: Context is null. Did you use ValentyApp?';
    }
    return Navigator.of(context!).pop<T>(result);
  }
}

enum Transition {
  fade,
  rightToLeft,
  leftToRight,
  upToDown,
  downToUp,
  scale,
  rotate,
  size,
  rightToLeftWithFade,
  leftToRightWithFade,
}

enum SnackPosition { top, bottom }

/// Mixin to handle automatic disposal of ValentyControllers in StatefulWidget.
mixin ValentyStateMixin<T extends StatefulWidget> on State<T> {
  final List<String> _tags = [];

  /// Registers a controller that should be auto-disposed when this State is disposed.
  S put<S>(S dependency, {String? tag}) {
    final controller = Valenty.put(dependency, tag: tag);
    _tags.add(Valenty._getKey(S, tag));
    return controller;
  }

  @override
  void dispose() {
    for (final key in _tags) {
      Valenty._deleteByKey(key);
    }
    super.dispose();
  }
}

/// A widget that manages the lifecycle of a ValentyController.
/// It creates the controller on initialization and deletes it when disposed.
class ValentyProvider<T extends ValentyController> extends StatefulWidget {
  final T Function() create;
  final Widget Function(T controller) builder;
  final String? tag;

  const ValentyProvider({
    super.key,
    required this.create,
    required this.builder,
    this.tag,
  });

  @override
  ValentyProviderState<T> createState() => ValentyProviderState<T>();
}

class ValentyProviderState<T extends ValentyController>
    extends State<ValentyProvider<T>> {
  late T controller;

  @override
  void initState() {
    super.initState();
    controller = Valenty.put(widget.create(), tag: widget.tag);
  }

  @override
  void dispose() {
    Valenty.delete<T>(tag: widget.tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(controller);
  }
}

// --- REACTIVE SYSTEM ---

/// Internal observer to track currently building Obx widgets.
class _ValentyObserver {
  static final _ValentyObserver _instance = _ValentyObserver._internal();
  factory _ValentyObserver() => _instance;
  _ValentyObserver._internal();

  /// The current observer (Obx's logic).
  RxInterface? observer;
}

/// Interface for Rx classes and internal observers.
abstract class RxInterface {
  void notify();
}

/// A reactive variable base class.
class Rx<T> implements RxInterface {
  T _value;
  final Set<RxInterface> _listeners = {};

  Rx(this._value);

  T get value {
    // If there is a current observer (Obx), register it as a listener.
    final observer = _ValentyObserver().observer;
    if (observer != null) {
      _listeners.add(observer);
    }
    return _value;
  }

  set value(T val) {
    if (_value != val) {
      _value = val;
      notify();
    }
  }

  @override
  void notify() {
    // Notify all listeners (Obx widgets).
    for (var listener in _listeners) {
      listener.notify();
    }
  }

  /// Bind the stream to this Rx.
  void bindStream(Stream<T> stream) {
    stream.listen((val) => value = val);
  }

  @override
  String toString() => value.toString();
}

/// Extension for easy Rx creation.
extension RxIntExtension on int {
  Rx<int> get obs => Rx<int>(this);
}

extension RxStringExtension on String {
  Rx<String> get obs => Rx<String>(this);
}

extension RxDoubleExtension on double {
  Rx<double> get obs => Rx<double>(this);
}

extension RxBoolExtension on bool {
  Rx<bool> get obs => Rx<bool>(this);
}

/// The Obx widget which listens to Rx changes.
class Obx extends StatefulWidget {
  final Widget Function() builder;

  const Obx(this.builder, {super.key});

  @override
  ObxState createState() => ObxState();
}

class ObxState extends State<Obx> implements RxInterface {
  final _observer = _ValentyObserver();
  RxInterface? _previousObserver;

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void notify() {
    _update();
  }

  @override
  Widget build(BuildContext context) {
    _previousObserver = _observer.observer;
    _observer.observer = this;

    final builtWidget = widget.builder();

    _observer.observer = _previousObserver;
    return builtWidget;
  }
}

// --- ValentyApp ---

/// A wrapper around MaterialApp that sets up Valenty's global keys.
class ValentyApp extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final Widget? home;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final RouteFactory? onUnknownRoute;
  final String title;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;
  final bool debugShowCheckedModeBanner;

  // Add more properties as needed to match MaterialApp

  const ValentyApp({
    super.key,
    this.navigatorKey,
    this.scaffoldMessengerKey,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.title = '',
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.debugShowCheckedModeBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: key,
      navigatorKey: navigatorKey ?? Valenty().navigatorKey,
      scaffoldMessengerKey:
          scaffoldMessengerKey ?? Valenty().scaffoldMessengerKey,
      home: home,
      routes: routes,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
      title: title,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
    );
  }
}
