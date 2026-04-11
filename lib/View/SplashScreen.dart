// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:team_app/View/loginScreen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Timer(const Duration(seconds: 2), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFF8B2072),
//                    Color(0xFF25091E),
//                 ],
//               ),
//             ),
//           ),

       
//             Center(

//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 30.0),
//                 child: ClipOval(
                  
//                   child: Image.asset(
//                     'assets/rm373batch15-element-02.jpg',
                  
//                     width: 100,
//                     height: 100
//                     // fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//           ),
           
//         ],
//       ),
//     );
//   }
// }
