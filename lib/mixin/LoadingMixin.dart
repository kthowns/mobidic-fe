import 'package:flutter/cupertino.dart';

mixin LoadingMixin on ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @protected
  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  @protected
  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }
}