import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile/utils/string_utils.dart';

enum AuthError {
  unknown,
  invalidCredentials,
}

class AuthManager {
  final _auth = FirebaseAuth.instance;

  /// Returns a widget that listens for authentications changes.
  Widget getAuthStateListenerWidget({
    @required Widget loading,
    @required Widget authenticate,
    @required Widget finished
  }) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading;
        } else {
          return snapshot.hasData ? finished : authenticate;
        }
      },
    );
  }

  Future<void> logout() async {
    return await _auth.signOut();
  }

  Future<AuthError> login(String email, String password) async {
    try {
      FirebaseUser user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      return _isUserValid(user) ? null : AuthError.unknown;
    } catch (error) {
      return AuthError.invalidCredentials;
    }
  }

  Future<AuthError> signUp(String email, String password) async {
    try {
      FirebaseUser user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      return _isUserValid(user) ? null : AuthError.unknown;
    } catch (error) {
      return AuthError.unknown;
    }
  }

  bool _isUserValid(FirebaseUser user) {
    return user != null && !StringUtils.isEmpty(user.uid);
  }
}