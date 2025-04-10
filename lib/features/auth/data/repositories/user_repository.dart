import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');
  
  // Current user
  User? get currentUser => _auth.currentUser;
  
  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final docSnapshot = await _usersCollection.doc(uid).get();
      
      if (docSnapshot.exists) {
        return UserModel.fromFirestore(docSnapshot);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }
  
  // Get current user model
  Future<UserModel?> getCurrentUserModel() async {
    if (currentUser == null) return null;
    return getUserById(currentUser!.uid);
  }
  
  // Create or update user
  Future<bool> saveUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
      return false;
    }
  }
  
  // Update user role
  Future<bool> updateUserRole(String uid, UserRole role) async {
    try {
      await _usersCollection.doc(uid).update({'role': role.name});
      return true;
    } catch (e) {
      debugPrint('Error updating user role: $e');
      return false;
    }
  }
  
  // Get all users (admin only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _usersCollection.get();
      
      return querySnapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }
  
  // Get sellers
  Future<List<UserModel>> getSellers() async {
    try {
      final querySnapshot = await _usersCollection
          .where('role', isEqualTo: UserRole.seller.name)
          .get();
      
      return querySnapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting sellers: $e');
      return [];
    }
  }
  
  // Delete user
  Future<bool> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }
  
  // Disable/enable user account
  Future<bool> setUserActiveStatus(String uid, bool isActive) async {
    try {
      await _usersCollection.doc(uid).update({'is_active': isActive});
      return true;
    } catch (e) {
      debugPrint('Error updating user active status: $e');
      return false;
    }
  }
} 