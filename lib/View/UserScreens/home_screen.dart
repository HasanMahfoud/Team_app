// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:team_app/Controller/UserController/user_notification_controller.dart';
// import 'package:team_app/View/HomePages/AcademicCalendarScreen.dart';
// import 'package:team_app/View/UserScreens/about_university_screen.dart';
// import 'package:team_app/View/UserScreens/selectRoutePage.dart';
// import '../../core/theme/app_theme.dart';



// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _heroController;
//   late final Animation<double> _heroFade;
//   late final Animation<Offset> _heroSlide;

//   // 💡 حقن الـ HomeController ليعمل بمجرد تشغيل الشاشة الرئيسية
  
//   final HomeController _homeController = Get.put(HomeController());

//   final List<_QuickAction> _quickActions = const [
//     _QuickAction(
//       icon: Icons.calendar_month_rounded,
//       label: 'التقويم الجامعي',
//       color: Color(0xFF3B82F6),
//     ),
//     _QuickAction(
//       icon: Icons.info_rounded,
//       label: 'معلومات',
//       color: Color(0xFFF59E0B),
//     ),
//   ];

//   final List<_CollegeCardData> _collegeCards = const [
//     _CollegeCardData(name: 'كلية الهندسة المعلوماتية', asset: 'assets/it.jpg'),
//     _CollegeCardData(name: 'كلية طب الأسنان', asset: 'assets/dentisy.jpg'),
//     _CollegeCardData(name: 'كلية الحقوق', asset: 'assets/low.jpg'),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _heroController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeOut);
//     _heroSlide = Tween<Offset>(
//       begin: const Offset(0, 0.04),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOut));

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _heroController.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _heroController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final topPad = MediaQuery.of(context).padding.top;

//     return Material(
//       color: Theme.of(context).scaffoldBackgroundColor,
//       child: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             FadeTransition(
//               opacity: _heroFade,
//               child: SlideTransition(
//                 position: _heroSlide,
//                 child: _HeroHeader(topPad: topPad),
//               ),
//             ),

//             const SizedBox(height: 50),

//             // الوصول السريع
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const _SectionTitle(title: 'الوصول السريع'),
//                   const SizedBox(height: 16),
//                   Wrap(
//                     spacing: 14,
//                     runSpacing: 14,
//                     children: _quickActions
//                         .map((a) => SizedBox(
//                               width:
//                                   (MediaQuery.of(context).size.width - 68) / 2,
//                               child: _QuickActionCard(action: a),
//                             ))
//                         .toList(),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 50),

//             // الكليات
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const _SectionTitle(title: 'الكليات'),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     height: 220,
//                     child: ListView.separated(
//                       padding: const EdgeInsets.only(left: 20, right: 16),
//                       scrollDirection: Axis.horizontal,
//                       physics: const BouncingScrollPhysics(),
//                       itemCount: _collegeCards.length,
//                       separatorBuilder: (context, index) =>
//                           const SizedBox(width: 14),
//                       itemBuilder: (context, index) {
//                         return _CollegeCard(college: _collegeCards[index]);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // المساحة السفلية لضمان عدم تداخل التصميم مع الـ Navigation Bar المرتفع
//             const SizedBox(height: 220),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── باقي الـ Widgets التابعة للشاشة بدون تغيير بنيوي لتجنب الأخطاء ─────────────────

// class _HeroHeader extends StatelessWidget {
//   final double topPad;
//   const _HeroHeader({required this.topPad});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//       child: Column(
//         children: [
//           SizedBox(height: topPad + 8),
//           const SizedBox(height: 20),
//           _SearchBar(),
//           const SizedBox(height: 20),
//           _HeroBanner(),
//         ],
//       ),
//     );
//   }
// }

// class _SearchBar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 52,
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           const SizedBox(width: 16),
//           Icon(Icons.search_rounded,
//               color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
//               size: 22),
//           const SizedBox(width: 10),
//           Expanded(
//             child: TextField(
//               onSubmitted: (query) async {
//                 if (query.trim().isEmpty) return;

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => SelectRoutePage(),
//                   ),
//                 );
//               },
//               decoration: const InputDecoration(
//                 hintText: 'ابحث عن قاعة دراسية...',
//                 border: InputBorder.none,
//               ),
//               textAlign: TextAlign.right,
//             ),
//           ),
//           Container(
//             margin: const EdgeInsets.all(8),
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               gradient: AppColors.primaryGradient,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child:
//                 const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HeroBanner extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.18,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         gradient: AppColors.heroGradient,
//         boxShadow: AppColors.buttonShadow,
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             right: -20,
//             top: -20,
//             child: Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.06),
//               ),
//             ),
//           ),
//           Positioned(
//             right: 30,
//             bottom: -30,
//             child: Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.06),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     'دليل القاعات الدراسية',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'ابحث عن قاعات الدراسة',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         height: 1.3,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'حدد موقع قاعة الدراسة الخاصة بك بسهولة',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.8),
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _QuickAction {
//   final IconData icon;
//   final String label;
//   final Color color;
//   const _QuickAction(
//       {required this.icon, required this.label, required this.color});
// }

// class _QuickActionCard extends StatefulWidget {
//   final _QuickAction action;
//   const _QuickActionCard({required this.action});

//   @override
//   State<_QuickActionCard> createState() => _QuickActionCardState();
// }

// class _CollegeCardData {
//   final String name;
//   final String asset;
//   const _CollegeCardData({required this.name, required this.asset});
// }

// class _CollegeCard extends StatelessWidget {
//   final _CollegeCardData college;
//   const _CollegeCard({required this.college});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         if (college.name == 'كلية الهندسة المعلوماتية') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => SelectRoutePage(),
//             ),
//           );
//         }
//       },
//       child: Container(
//         width: 212,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(22),
//           image: DecorationImage(
//             image: AssetImage(college.asset),
//             fit: BoxFit.cover,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.12),
//               blurRadius: 18,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(22),
//             gradient: LinearGradient(
//               colors: [Colors.black.withOpacity(0.52), Colors.transparent],
//               begin: Alignment.bottomCenter,
//               end: Alignment.topCenter,
//             ),
//           ),
//           padding: const EdgeInsets.all(16),
//           child: Align(
//             alignment: Alignment.bottomLeft,
//             child: Text(
//               college.name,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//                 height: 1.2,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _QuickActionCardState extends State<_QuickActionCard> {
//   bool _pressed = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => setState(() => _pressed = true),
//       onTapUp: (_) => setState(() => _pressed = false),
//       onTapCancel: () => setState(() => _pressed = false),
//       onTap: () {
//         final label = widget.action.label;

//         if (label == 'معلومات') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AboutUniversityScreen()),
//           );
//         }

//         if (label == 'التقويم الجامعي') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AcademicCalendarScreen()),
//           );
//         }
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         transform: Matrix4.identity()..scale(_pressed ? 0.93 : 1.0),
//         transformAlignment: Alignment.center,
//         width: (MediaQuery.of(context).size.width - 72) / 4,
//         child: Column(
//           children: [
//             Container(
//               width: 54,
//               height: 54,
//               decoration: BoxDecoration(
//                 color: widget.action.color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(18),
//                 border: Border.all(
//                   color: widget.action.color.withOpacity(0.15),
//                 ),
//               ),
//               child: Icon(widget.action.icon,
//                   color: widget.action.color, size: 26),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               widget.action.label,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: Theme.of(context).colorScheme.onSurface,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SectionTitle extends StatelessWidget {
//   final String title;
//   const _SectionTitle({required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 17,
//             fontWeight: FontWeight.w800,
//             color: Theme.of(context).colorScheme.onBackground,
//           ),
//         ),
//       ],
//     );
//   }
// }