import 'package:flutter/foundation.dart';

import '../widgets/bottom_tab_bar.dart';

/// The currently selected home tab, shared between the mobile bottom bar and the
/// desktop sidebar so both drive the same view. HomeScreen is the source of
/// truth for rendering; this notifier lets the desktop sidebar (which lives
/// above the Navigator) change tabs without threading callbacks through.
final ValueNotifier<AppTab> homeTab = ValueNotifier<AppTab>(AppTab.home);
