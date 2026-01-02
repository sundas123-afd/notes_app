import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';


class AuthProvider with ChangeNotifier {
  final AuthService authService = AuthService();
  User? currentUser;
  bool isLoading = false;

  
  AuthProvider() {
    currentUser = authService.getCurrentUser();
  }

  
  bool get isLoggedIn => currentUser != null;

  // Sign up with email
  Future<String?> signUp(String email, String password) async {
    isLoading = true;
    notifyListeners();

    String? error = await authService.signUpWithEmail(email, password);
    
    if (error == null) {
      currentUser = authService.getCurrentUser();
    }

    isLoading = false;
    notifyListeners();
    
    return error;
  }

  // Login with email
  Future<String?> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    String? error = await authService.loginWithEmail(email, password);
    
    if (error == null) {
      currentUser = authService.getCurrentUser();
    }

    isLoading = false;
    notifyListeners();
    
    return error;
  }

  // Sign in with Google
  Future<String?> signInWithGoogle() async {
    isLoading = true;
    notifyListeners();

    String? error = await authService.signInWithGoogle();
    
    if (error == null) {
      currentUser = authService.getCurrentUser();
    }

    isLoading = false;
    notifyListeners();
    
    return error;
  }

  // Logout
  Future<void> logout() async {
    await authService.logout();
    currentUser = null;
    notifyListeners();
  }

  // Reset password
  Future<String?> resetPassword(String email) async {
    return await authService.resetPassword(email);
  }
}