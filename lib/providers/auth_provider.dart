import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserModel();
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserModel() async {
    if (_user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      print('Error loading user model: $e');
    }
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update last login time
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });

        await _loadUserModel();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e);
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      print('Unexpected error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerWithEmailPassword(
      String email,
      String password,
      String userName,
      ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user model with server timestamps
        final userModel = UserModel(
          uid: credential.user!.uid,
          email: email,
          userName: userName,
          displayName: userName,
          photoURL: null,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        // Save to Firestore with server timestamps
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'uid': credential.user!.uid,
          'email': email,
          'userName': userName,
          'displayName': userName,
          'photoURL': null,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });

        // Update display name
        await credential.user!.updateDisplayName(userName);

        _userModel = userModel;
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e);
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      print('Unexpected error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user exists in Firestore
        final doc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!doc.exists) {
          // Create new user model with server timestamps
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'uid': userCredential.user!.uid,
            'email': userCredential.user!.email ?? '',
            'userName': userCredential.user!.displayName ?? 'Google User',
            'displayName': userCredential.user!.displayName ?? 'Google User',
            'photoURL': userCredential.user!.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Update last login with server timestamp
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({'lastLoginAt': FieldValue.serverTimestamp()});
        }

        await _loadUserModel();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e);
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      _error = 'Google sign-in failed: $e';
      print('Google sign-in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _userModel = null;
      _user = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Method to create a dummy user for testing
  Future<void> createDummyUser() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      const email = 'test@example.com';
      const password = 'testpassword123';
      const userName = 'Test User';

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'uid': credential.user!.uid,
          'email': email,
          'userName': userName,
          'displayName': userName,
          'photoURL': null,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });

        await credential.user!.updateDisplayName(userName);
        print('Dummy user created successfully');
      }
    } catch (e) {
      print('Error creating dummy user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters)';
      case 'invalid-email':
        return 'Invalid email address format';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'invalid-credential':
        return 'Invalid credentials provided';
      case 'account-exists-with-different-credential':
        return 'Account exists with different sign-in method';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed: ${e.message ?? 'Unknown error'}';
    }
  }
}