import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './navigation_service.dart';
import 'dart:io'; // <─ NEW
import 'package:shared_preferences/shared_preferences.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  final NavigationService _navigationService = NavigationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /* ──────────────────────────  REGISTER  ────────────────────────── */

  Future<User?> register({
    required String fullename,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final creds = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(creds.user!.uid)
          .set({
            'uid': creds.user!.uid,
            'email': email,
            'phone': phone,
            'fullname': fullename,
            'role': 'user',
          });

      return creds.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    } on SocketException {
      // NEW
      throw AuthException('No internet connection.');
    } catch (_) {
      throw AuthException('An unknown error occurred.');
    }
  }

  /* ───────────────────────────  SIGN-IN  ─────────────────────────── */

  Future<User?> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final creds = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (creds.user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(creds.user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          final userRole = userData?['role'] as String?;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('uid', creds.user!.uid);
          await prefs.setString('email', email.trim());
          await prefs.setString('role', userRole!);
          if (context.mounted) {
            _navigationService.navigateBasedOnRole(context, "$userRole");
          }
        }
      }

      return creds.user;
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'No user found for that email.';
          break;
        case 'wrong-password':
          msg = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          msg = 'The email address is not valid.';
          break;
        default:
          msg = _mapFirebaseError(e.code); // fallback to existing error mapper
      }
      _showSnack(context, msg);
      throw AuthException(msg);
    } on SocketException {
      const msg = 'No internet connection.';
      _showSnack(context, msg);
      throw AuthException(msg);
    } catch (e) {
      const msg = 'An unknown error occurred.';
      _showSnack(context, msg);
      throw AuthException(msg);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /* ───────────────────────  HELPERS  ─────────────────────── */

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password provided.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  void _showSnack(BuildContext ctx, String msg) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }
}
