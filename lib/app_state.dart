import 'package:flutter/widgets.dart';

/// The six languages the product supports. Each person picks their own; a
/// stable is routinely multilingual. Arabic and Urdu are right-to-left.
const List<Locale> kSupportedLocales = [
  Locale('en'),
  Locale('ar'),
  Locale('hi'),
  Locale('ur'),
  Locale('bn'),
  Locale('ne'),
];

/// Holds the app-wide selected locale. In production this is per-person server
/// state; here it is a simple notifier that drives [MaterialApp.locale], which
/// in turn flips text direction for Arabic and Urdu automatically.
class LocaleController extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  void setLocale(Locale value) {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
  }
}

/// Exposes the [LocaleController] to the widget tree.
class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'No LocaleScope found in context');
    return scope!.notifier!;
  }
}
