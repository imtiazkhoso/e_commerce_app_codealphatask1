import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Role-based permissions
  bool get isAdmin => _userModel?.role == UserRole.admin;
  bool get isSeller => _userModel?.role == UserRole.seller;
  bool get canAddProducts => _userModel?.canAddProducts ?? false;
  bool get canManageUsers => _userModel?.canManageUsers ?? false;
  
  AuthProvider() {
    _initializeAuth();
  }
  
  // Initialize authentication state
  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Get current Firebase user
      _user = _auth.currentUser;
      debugPrint('Current user: ${_user?.email}');
      
      // Load user model if authenticated
      if (_user != null) {
        await _loadUserModel();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Auth initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load user model from Firestore
  Future<void> _loadUserModel() async {
    if (_user == null) return;
    
    try {
      _userModel = await _userRepository.getUserById(_user!.uid);
      
      // If the user model doesn't exist, create it
      if (_userModel == null) {
        _userModel = UserModel(
          uid: _user!.uid,
          email: _user!.email ?? '',
          displayName: _user!.displayName,
          photoUrl: _user!.photoURL,
        );
        
        await _userRepository.saveUser(_userModel!);
      }
      
      debugPrint('User model loaded: ${_userModel?.displayName} (${_userModel?.role.name})');
    } catch (e) {
      debugPrint('Error loading user model: $e');
    }
  }
  
  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      debugPrint('Attempting to sign in with email: $email');
      
      // Authenticate with Firebase
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      _user = userCredential.user;
      
      if (_user != null) {
        // Load user from Firestore
        await _loadUserModel();
        
        // Update last login timestamp
        if (_userModel != null) {
          final updatedUser = _userModel!.copyWith(
            lastLogin: DateTime.now(),
          );
          
          await _userRepository.saveUser(updatedUser);
          _userModel = updatedUser;
        }
        
        debugPrint('Sign in successful for user: ${_user?.email}');
      }
      
      notifyListeners();
      return _user != null;
    } on FirebaseAuthException catch (e) {
      _error = _handleAuthException(e);
      debugPrint('Login error: $_error (code: ${e.code})');
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Login failed: $e';
      debugPrint('Generic login error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword(String email, String password, {String? displayName}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      debugPrint('Attempting to create user with email: $email');
      
      // Create the user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      _user = userCredential.user;
      
      if (_user != null) {
        // Set display name if provided
        if (displayName != null && displayName.isNotEmpty) {
          await _user!.updateDisplayName(displayName);
          await _user!.reload();
          _user = _auth.currentUser;
        }
        
        // Create user in Firestore
        _userModel = UserModel(
          uid: _user!.uid,
          email: _user!.email ?? '',
          displayName: displayName ?? _user!.displayName,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        
        await _userRepository.saveUser(_userModel!);
        
        // Send verification email
        try {
          await _user!.sendEmailVerification();
          debugPrint('Verification email sent');
        } catch (e) {
          debugPrint('Error sending verification email: $e');
        }
        
        debugPrint('User created: ${_user?.email}');
      }
      
      notifyListeners();
      return _user != null;
    } on FirebaseAuthException catch (e) {
      _error = _handleAuthException(e);
      debugPrint('Signup error: $_error (code: ${e.code})');
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Signup failed: $e';
      debugPrint('Generic signup error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    File? profileImage,
    UserRole? role,
  }) async {
    if (_user == null || _userModel == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Update display name in Firebase Auth if provided
      if (displayName != null && displayName.isNotEmpty) {
        debugPrint('Updating display name to: $displayName');
        await _user!.updateDisplayName(displayName);
        debugPrint('Display name updated in Firebase Auth');
      }
      
      // Reload Firebase user to get updated information
      await _user!.reload();
      _user = _auth.currentUser;
      
      // Update user model
      final updatedModel = _userModel!.copyWith(
        displayName: displayName ?? _userModel!.displayName,
        role: role ?? _userModel!.role,
      );
      
      // Save to Firestore
      final success = await _userRepository.saveUser(updatedModel);
      
      if (success) {
        _userModel = updatedModel;
        debugPrint('User model updated in Firestore');
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      debugPrint('Update profile error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update user role (admin only)
  Future<bool> updateUserRole(String uid, UserRole role) async {
    if (!canManageUsers) {
      _error = 'Permission denied: Only admins can change user roles';
      return false;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final success = await _userRepository.updateUserRole(uid, role);
      return success;
    } catch (e) {
      _error = 'Failed to update user role: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get all users (admin only)
  Future<List<UserModel>> getAllUsers() async {
    if (!canManageUsers) {
      _error = 'Permission denied: Only admins can view all users';
      return [];
    }
    
    return _userRepository.getAllUsers();
  }
  
  // Sign out
  Future<void> signOut() async {
    if (_user == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      debugPrint('Signing out user: ${_user?.email}');
      await _auth.signOut();
      _user = null;
      _userModel = null;
      debugPrint('User signed out');
    } catch (e) {
      _error = 'Signout failed: $e';
      debugPrint('Signout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      debugPrint('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent');
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleAuthException(e);
      debugPrint('Reset password error: $_error (code: ${e.code})');
      return false;
    } catch (e) {
      _error = 'Password reset failed: $e';
      debugPrint('Generic reset password error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'The password is invalid.';
      case 'email-already-in-use':
        return 'The email address is already in use.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
} 