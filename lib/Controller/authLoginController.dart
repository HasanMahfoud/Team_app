import 'package:firebase_auth/firebase_auth.dart';

import 'package:get/get.dart';

class AuthController extends GetxController {

  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // دالة التحقق من الإيميل
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email cannot be empty";
    }
    if (!value.contains("@") || !value.contains(".")) {
      return "Enter a valid email";
    }
    return null;
  }

  // دالة التحقق من كلمة المرور 
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password cannot be empty";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  // إنشاء حساب
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // تسجيل دخول
  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> authState() {
    return _auth.authStateChanges();
  }
}
