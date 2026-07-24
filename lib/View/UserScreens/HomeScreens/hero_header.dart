import 'package:flutter/material.dart';
// import 'package:team_app/View/UserScreens/selectRoutePage.dart';
import '../../../core/theme/app_theme.dart';

class HeroHeader extends StatelessWidget {
  final double topPad;

  const HeroHeader({super.key, required this.topPad});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          SizedBox(height: topPad + 8),
          const SizedBox(height: 20),
          // const HomeSearchBar(),
          const SizedBox(height: 20),
          const HeroBanner(),
        ],
      ),
    );
  }
}

// class HomeSearchBar extends StatelessWidget {
//   const HomeSearchBar({super.key});

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
//           Icon(
//             Icons.search_rounded,
//             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
//             size: 22,
//           ),
//           const SizedBox(width: 10),
//           // Expanded(
//           //   child: TextField(
//           //     onSubmitted: (query) async {
//           //       if (query.trim().isEmpty) return;

//           //       Navigator.push(
//           //         context,
//           //         MaterialPageRoute(
//           //           builder: (_) => SelectRoutePage(),
//           //         ),
//           //       );
//           //     },
//           //     decoration: const InputDecoration(
//           //       hintText: 'ابحث عن قاعة دراسية...',
//           //       border: InputBorder.none,
//           //     ),
//           //     textAlign: TextAlign.right,
//           //   ),
//           // ),
//           Container(
//             margin: const EdgeInsets.all(8),
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               gradient: AppColors.primaryGradient,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
//           ),
//         ],
//       ),
//     );
//   }
// }

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.18,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppColors.heroGradient,
        boxShadow: AppColors.buttonShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'دليل القاعات الدراسية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ابحث عن قاعات الدراسة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'حدد موقع قاعة الدراسة الخاصة بك بسهولة',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}