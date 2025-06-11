import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? get currentUser => auth.currentUser;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email, required String password
  }) async {
    return await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password, required String name, required String image, required int bodyTypeIndex, required List wardrobe, required List likedProds,
  }) async {
    return await auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> resetPassword({
    required String email
  }) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({
    required String username
  }) async {
    await currentUser?.updateDisplayName(username);
  }

  Future<void> deleteAccount({
    required String email, required String password
  }) async {
    AuthCredential credential = 
      EmailAuthProvider.credential(email: email, password: password);
    await currentUser?.reauthenticateWithCredential(credential);
    await currentUser?.delete();
    await auth.signOut();
  }

  Future<void> resetPasswordFromCurrentPass({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = 
      EmailAuthProvider.credential(email: email, password: currentPassword);
    await currentUser?.reauthenticateWithCredential(credential);
    await currentUser?.updatePassword(newPassword);
  }
}
