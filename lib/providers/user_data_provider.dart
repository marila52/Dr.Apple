import 'package:flutter/material.dart';

class UserDataProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<bool> savePersonalData({
    required dynamic gender,
    required double weight,
    required double height,
    required int age,
    required dynamic activityLevel,
    required dynamic goal,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    // Имитация сохранения
    await Future.delayed(const Duration(seconds: 1));
    
    _isLoading = false;
    notifyListeners();
    return true;
  }
}