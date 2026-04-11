// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class VerifyEmailScreen extends StatefulWidget {
//   @override
//   _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
// }

// class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
//   bool emailSent = false;

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser!;

//     return Scaffold(
//       appBar: AppBar(title: Text("Verify Email")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "A verification email has been sent to:",
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 10),
//             Text(
//               user.email!,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: () async {
//                 await user.sendEmailVerification();
//                 setState(() => emailSent = true);
//               },
//               child: Text("Resend Verification Email"),
//             ),

//             if (emailSent)
//               Text(
//                 "Verification email sent again!",
//                 style: TextStyle(color: Colors.green),
//               ),

//             SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: () async {
//                 await user.reload();
//                 if (user.emailVerified) {
//                   setState(() {});
//                 }
//               },
//               child: Text("I Verified, Continue"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
