import 'package:flutter/foundation.dart';

import '../../core/constants/app_enums.dart';

class AppNavigationProvider extends ChangeNotifier {
  AppTab _currentTab = AppTab.home;

  AppTab get currentTab => _currentTab;

  void setTab(AppTab tab) {
    _currentTab = tab;
    notifyListeners();
  }
}
