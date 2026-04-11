import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_app/Controller/authLoginController.dart';
import 'package:team_app/View/homeScreen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();

  final email = TextEditingController();
  final password = TextEditingController();
  final rePassword = TextEditingController();

  final auth = Get.put(AuthController());

  String message = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                
                Text(
                  'Create Account',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF003A8C), 
                  ),
                ),

                const SizedBox(height: 50),

              
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextFormField(
                    controller: email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Color(0xFF003A8C)),
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF003A8C)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: auth.validateEmail,
                  ),
                ),

                const SizedBox(height: 20),

                
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextFormField(
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Color(0xFF003A8C)),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF003A8C)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: auth.validatePassword,
                  ),
                ),

                const SizedBox(height: 20),

                
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextFormField(
                    controller: rePassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Re-Type Password',
                      labelStyle: const TextStyle(color: Color(0xFF003A8C)),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF003A8C)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value != password.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 50),

                
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                       Color(0xFF001366),
                      Color(0xFF0095A4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final result =
                            await auth.signUp(email.text, password.text);

                        setState(() => message = result ?? "");

                        if (message == 'success') {
                          Get.to(() => HomeScreen());
                        }
                      }
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Text(
                //   message,
                //   style: const TextStyle(color: Colors.green),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
