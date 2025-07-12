// lib/services/user_auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'rng_users';
  static const String _currentUserKey = 'current_user_id';
  static const String _currentPasswordKey = 'current_user_password';

  // Hash password for security
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserKey);
    return userId != null && userId.isNotEmpty;
  }

  // Get current user ID
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  // Register new user
  Future<Map<String, dynamic>> registerUser(String username, String password) async {
    try {
      // Validate input
      if (username.length < 3) {
        return {'success': false, 'message': 'Username must be at least 3 characters'};
      }
      if (password.length < 6) {
        return {'success': false, 'message': 'Password must be at least 6 characters'};
      }

      // Check if username already exists
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(username.toLowerCase())
          .get();

      if (userDoc.exists) {
        return {'success': false, 'message': 'Username already taken'};
      }

      // Create user document
      final hashedPassword = _hashPassword(password);
      await _firestore
          .collection(_usersCollection)
          .doc(username.toLowerCase())
          .set({
        'username': username,
        'password_hash': hashedPassword,
        'created_at': FieldValue.serverTimestamp(),
        'last_login': FieldValue.serverTimestamp(),
      });

      // Save login locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, username.toLowerCase());
      await prefs.setString(_currentPasswordKey, hashedPassword);

      if (kDebugMode) {
        print('✅ User registered successfully: $username');
      }

      return {'success': true, 'message': 'Account created successfully!'};
    } catch (e) {
      if (kDebugMode) {
        print('❌ Registration error: $e');
      }
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  // Login existing user
  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    try {
      // Get user document
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(username.toLowerCase())
          .get();

      if (!userDoc.exists) {
        return {'success': false, 'message': 'Username not found'};
      }

      // Verify password
      final userData = userDoc.data()!;
      final hashedPassword = _hashPassword(password);
      
      if (userData['password_hash'] != hashedPassword) {
        return {'success': false, 'message': 'Incorrect password'};
      }

      // Update last login
      await _firestore
          .collection(_usersCollection)
          .doc(username.toLowerCase())
          .update({
        'last_login': FieldValue.serverTimestamp(),
      });

      // Save login locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, username.toLowerCase());
      await prefs.setString(_currentPasswordKey, hashedPassword);

      if (kDebugMode) {
        print('✅ User logged in successfully: $username');
      }

      return {'success': true, 'message': 'Login successful!'};
    } catch (e) {
      if (kDebugMode) {
        print('❌ Login error: $e');
      }
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      await prefs.remove(_currentPasswordKey);

      if (kDebugMode) {
        print('✅ User logged out');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Logout error: $e');
      }
    }
  }

  // Auto-login if credentials saved
  Future<bool> autoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_currentUserKey);
      final passwordHash = prefs.getString(_currentPasswordKey);

      if (userId == null || passwordHash == null) {
        return false;
      }

      // Verify user still exists and password is correct
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        // User deleted, clear local storage
        await logoutUser();
        return false;
      }

      final userData = userDoc.data()!;
      if (userData['password_hash'] != passwordHash) {
        // Password changed elsewhere, require re-login
        await logoutUser();
        return false;
      }

      // Update last login
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'last_login': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Auto-login successful: $userId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Auto-login error: $e');
      }
      return false;
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) {
        return {'success': false, 'message': 'Not logged in'};
      }

      if (newPassword.length < 6) {
        return {'success': false, 'message': 'New password must be at least 6 characters'};
      }

      // Verify old password
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return {'success': false, 'message': 'User not found'};
      }

      final userData = userDoc.data()!;
      final oldHashedPassword = _hashPassword(oldPassword);
      
      if (userData['password_hash'] != oldHashedPassword) {
        return {'success': false, 'message': 'Current password is incorrect'};
      }

      // Update password
      final newHashedPassword = _hashPassword(newPassword);
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'password_hash': newHashedPassword,
        'password_changed_at': FieldValue.serverTimestamp(),
      });

      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentPasswordKey, newHashedPassword);

      if (kDebugMode) {
        print('✅ Password changed successfully for: $userId');
      }

      return {'success': true, 'message': 'Password changed successfully!'};
    } catch (e) {
      if (kDebugMode) {
        print('❌ Password change error: $e');
      }
      return {'success': false, 'message': 'Password change failed: $e'};
    }
  }

  // Get user profile info
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return null;

      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      return {
        'username': userData['username'],
        'created_at': userData['created_at'],
        'last_login': userData['last_login'],
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get profile error: $e');
      }
      return null;
    }
  }

  // Delete user account
  Future<bool> deleteUser(String password) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return false;

      // Verify password first
      final loginResult = await loginUser(userId, password);
      if (loginResult['success'] != true) {
        throw Exception('Incorrect password');
      }

      // Delete user data from Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .delete();

      // Clear local credentials
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      await prefs.remove(_currentPasswordKey);

      if (kDebugMode) {
        print('✅ User account deleted successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Delete user error: $e');
      }
      throw Exception('Failed to delete account: $e');
    }
  }

  // Change username
  Future<Map<String, dynamic>> changeUsername(String newUsername, String currentPassword) async {
    try {
      final currentUserId = await getCurrentUserId();
      if (currentUserId == null) {
        return {'success': false, 'message': 'Not logged in'};
      }

      // Validate new username
      if (newUsername.length < 3) {
        return {'success': false, 'message': 'Username must be at least 3 characters'};
      }

      // Normalize new username
      final normalizedNewUsername = newUsername.toLowerCase();
      
      // Check if new username is the same as current
      if (normalizedNewUsername == currentUserId) {
        return {'success': false, 'message': 'New username is the same as current username'};
      }

      // Check if new username already exists
      final existingUserDoc = await _firestore
          .collection(_usersCollection)
          .doc(normalizedNewUsername)
          .get();

      if (existingUserDoc.exists) {
        return {'success': false, 'message': 'Username already taken'};
      }

      // Verify current password
      final currentUserDoc = await _firestore
          .collection(_usersCollection)
          .doc(currentUserId)
          .get();

      if (!currentUserDoc.exists) {
        return {'success': false, 'message': 'Current user not found'};
      }

      final currentUserData = currentUserDoc.data()!;
      final hashedPassword = _hashPassword(currentPassword);
      
      if (currentUserData['password_hash'] != hashedPassword) {
        return {'success': false, 'message': 'Current password is incorrect'};
      }

      // Create new user document with new username
      await _firestore
          .collection(_usersCollection)
          .doc(normalizedNewUsername)
          .set({
        'username': newUsername, // Keep original case
        'password_hash': currentUserData['password_hash'],
        'created_at': currentUserData['created_at'],
        'last_login': FieldValue.serverTimestamp(),
        'username_changed_at': FieldValue.serverTimestamp(),
        'previous_username': currentUserId,
      });

      // Delete old user document
      await _firestore
          .collection(_usersCollection)
          .doc(currentUserId)
          .delete();

      // Update local storage with new username
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, normalizedNewUsername);

      if (kDebugMode) {
        print('✅ Username changed from $currentUserId to $normalizedNewUsername');
      }

      return {'success': true, 'message': 'Username changed successfully!'};
    } catch (e) {
      if (kDebugMode) {
        print('❌ Change username error: $e');
      }
      return {'success': false, 'message': 'Failed to change username: $e'};
    }
  }
}
