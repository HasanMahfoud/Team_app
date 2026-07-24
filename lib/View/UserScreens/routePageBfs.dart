import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:team_app/Model/node_model.dart';
import '../../core/theme/app_theme.dart';

class RoutePageBFS extends StatefulWidget {
  final List<String> path;
  final Map<String, NodeModel> nodes;

  const RoutePageBFS({
    super.key,
    required this.path,
    required this.nodes,
  });

  @override
  State<RoutePageBFS> createState() => _RoutePageBFSState();
}

class _RoutePageBFSState extends State<RoutePageBFS> {
  int currentStep = 0;
  int currentImageIndex = 0;
  
  // متحكم الـ PageView لضمان تصفير الصور عند الانتقال بين الخطوات
  late PageController _pageController;
  final Color mainBlue = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // دالة مخصصة للانتقال بين خطوات الـ BFS بأمان مع تصفير مؤشر الصور
  void _changeStep(int newStep) {
    setState(() {
      currentStep = newStep;
      currentImageIndex = 0;
    });
    // إعادة الـ PageView إلى الصورة الأولى فوراً
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.path;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "المسار خطوة بخطوة",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: mainBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // عنوان الخطوة الحالية
            Text(
              "الخطوة ${currentStep + 1} من ${steps.length}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: mainBlue,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 12),

            // Progress Bar متناسق وانسيابي
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: steps.isNotEmpty ? (currentStep + 1) / steps.length : 0,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(mainBlue),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // بطاقة الخطوة المدعومة بالأنيميشن اللطيف
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) {
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.08, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
                      child: child,
                    ),
                  );
                },
                child: buildStepCard(steps[currentStep]),
              ),
            ),

            // أزرار التحكم والـ Navigation السفلية
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
              child: Row(
                children: [
                  // زر السابق (مبني بالطريقة التقليدية والنظيفة)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: currentStep == 0 ? null : () => _changeStep(currentStep - 1),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: AppColors.textTertiary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                      ),
                      child: const Text("السابق", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // زر التالي / إنهاء المسار
                  Expanded(
                    child: ElevatedButton(
                      onPressed: currentStep == steps.length - 1
                          ? () => Navigator.pop(context)
                          : () => _changeStep(currentStep + 1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentStep == steps.length - 1 ? Colors.green.shade600 : mainBlue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 2,
                        shadowColor: mainBlue.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        currentStep == steps.length - 1 ? "وصلت للوجهة" : "التالي",
                        style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت عرض الصور المطور بمؤشرات دائرية تفاعلية
  Widget buildImages(NodeModel node) {
    final images = node.images;

    if (images.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text("لا توجد صور توضيحية لهذه الغرفة"),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => currentImageIndex = index);
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image_not_supported_rounded,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // رقم الصورة (عداد عائم متناسق)
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "${currentImageIndex + 1}/${images.length}",
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // إضافة نقاط تصفح سفلية (Dots Indicator) لتأكيد إمكانية السحب
        if (images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: currentImageIndex == index ? 18 : 6,
                  decoration: BoxDecoration(
                    color: currentImageIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  // كرت الخطوة الحالي المستدعي للبيانات من الـ Node
  Widget buildStepCard(String nodeId) {
    final node = widget.nodes[nodeId]!;

    return Container(
      key: ValueKey(nodeId),
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            node.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: mainBlue,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(child: buildImages(node)),
          
          const SizedBox(height: 16),

        Text(
            "اتبع الصور الظاهرة أعلاه للوصول إلى ${node.title} بسلاسة.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}