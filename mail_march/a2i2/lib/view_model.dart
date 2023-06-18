import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewModel with ChangeNotifier {
  bool _shouldShowCcBcc = false;

  bool get shouldShowCcBcc => _shouldShowCcBcc;

  set shouldShowCcBcc(bool value) {
    _shouldShowCcBcc = value;
    notifyListeners();
  }
}
