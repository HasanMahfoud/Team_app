import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:team_app/Controller/UserController/graph_loader.dart';
import 'package:team_app/Controller/bfs_algorithm.dart';
import 'package:team_app/Model/node_model.dart';
import 'package:team_app/View/UserScreens/routePageBfs.dart';
import '../../core/theme/app_theme.dart';

class SelectRoutePage extends StatefulWidget {
  const SelectRoutePage({super.key});

  @override
  State<SelectRoutePage> createState() => _SelectRoutePageState();
}

class _SelectRoutePageState extends State<SelectRoutePage>
    with SingleTickerProviderStateMixin {
  String? startNodeId;
  String? endNodeId;

  final TextEditingController _startSearchController = TextEditingController();
  final TextEditingController _endSearchController = TextEditingController();

  // 🎯 إضافة الـ FocusNodes للتحكم الدقيق بفتح وإغلاق القوائم
  final FocusNode _startFocusNode = FocusNode();
  final FocusNode _endFocusNode = FocusNode();

  bool _showStartSuggestions = false;
  bool _showEndSuggestions = false;

  late AnimationController _controller;
  late Animation<double> fadeIn;
  late Animation<Offset> slideIn;

  final Color mainBlue = AppColors.primary;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    slideIn = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // ربط المستمعات بالـ FocusNodes لتحديث الـ UI بسلاسة
    _startFocusNode.addListener(() {
      setState(() => _showStartSuggestions = _startFocusNode.hasFocus);
    });
    _endFocusNode.addListener(() {
      setState(() => _showEndSuggestions = _endFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _startSearchController.dispose();
    _endSearchController.dispose();
    _startFocusNode.dispose(); // 👈 تفريغ الذاكرة
    _endFocusNode.dispose();   // 👈 تفريغ الذاكرة
    super.dispose();
  }

  Widget buildSearchDropdown({
    required String label,
    required String hint,
    required IconData prefixIcon,
    required Color iconColor,
    required TextEditingController searchController,
    required FocusNode focusNode, 
    required bool showSuggestions,
    required List<String> nodeIds,
    required Map<String, NodeModel> nodes,
    required Function(String id, String title) onSelected,
  }) {
    final filteredIds = nodeIds.where((id) {
      final title = nodes[id]?.title.toLowerCase() ?? '';
      return title.contains(searchController.text.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            focusNode: focusNode, // 👈 ربط الـ FocusNode هنا لحل المشكلة
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textTertiary.withOpacity(0.6), fontSize: 14),
              labelStyle: TextStyle(color: mainBlue, fontWeight: FontWeight.bold),
              prefixIcon: Icon(prefixIcon, color: iconColor, size: 22),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        setState(() {
                          searchController.clear();
                          onSelected('', ''); 
                          // 🎯 السحر هنا: إجبار الحقل على البقاء نشطاً وطلب التركيز مجدداً لفتح الليست فوراً
                          focusNode.requestFocus(); 
                        });
                      },
                    )
                  : const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: mainBlue.withOpacity(0.2), width: 1.2),
                borderRadius: BorderRadius.circular(18),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: mainBlue, width: 1.8),
                borderRadius: BorderRadius.circular(18),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
        
        if (showSuggestions && filteredIds.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: filteredIds.length,
              separatorBuilder: (_, __) => Divider(color: Colors.grey.withOpacity(0.15), height: 1),
              itemBuilder: (context, index) {
                final id = filteredIds[index];
                final nodeTitle = nodes[id]?.title ?? '';
                return ListTile(
                  title: Text(
                    nodeTitle,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    searchController.text = nodeTitle;
                    onSelected(id, nodeTitle);
                    focusNode.unfocus(); // 👈 إغلاق الليست بأمان عند الاختيار
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // إغلاق الفوكس عند الضغط في أي مكان فارغ بالخلفية
        _startFocusNode.unfocus();
        _endFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            "تحديد المسار بالكلية",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 19),
          ),
          centerTitle: true,
          backgroundColor: mainBlue,
          elevation: 0,
        ),
        body: StreamBuilder<Map<String, NodeModel>>(
          stream: streamNodes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final nodes = snapshot.data!;
            final nodeIds = nodes.keys.toList();

            return FadeTransition(
              opacity: fadeIn,
              child: SlideTransition(
                position: slideIn,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      
                      // 1) حقل بحث الموقع الحالي
                      buildSearchDropdown(
                        label: "موقعك الحالي",
                        hint: "ابحث عن مدرج، مخبر، أو مكتب...",
                        prefixIcon: Icons.my_location_rounded,
                        iconColor: mainBlue,
                        searchController: _startSearchController,
                        focusNode: _startFocusNode, // 👈
                        showSuggestions: _showStartSuggestions,
                        nodeIds: nodeIds,
                        nodes: nodes,
                        onSelected: (id, title) {
                          startNodeId = id.isEmpty ? null : id;
                        },
                      ),

                      const SizedBox(height: 24),

                      // 2) حقل بحث الوجهة المطلوبة
                      buildSearchDropdown(
                        label: "الوجهة",
                        hint: "إلى أين تريد الذهاب؟",
                        prefixIcon: Icons.location_on_rounded,
                        iconColor: AppColors.error,
                        searchController: _endSearchController,
                        focusNode: _endFocusNode, // 👈
                        showSuggestions: _showEndSuggestions,
                        nodeIds: nodeIds,
                        nodes: nodes,
                        onSelected: (id, title) {
                          endNodeId = id.isEmpty ? null : id;
                        },
                      ),

                      const SizedBox(height: 40),

                      // 3) زر بدء حساب المسار والانتقال
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 3,
                          shadowColor: mainBlue.withOpacity(0.4),
                        ),
                        onPressed: () {
                          if (startNodeId == null || endNodeId == null) {
                            Get.snackbar(
                              "تنبيه",
                              "يرجى تحديد نقطة البداية والوجهة من القائمة المنسدلة",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.black87,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(15),
                            );
                            return;
                          }

                          final graph = buildGraph(nodes);
                          final path = bfs(startNodeId!, endNodeId!, graph);

                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 500),
                              pageBuilder: (_, __, ___) => RoutePageBFS(
                                path: path,
                                nodes: nodes,
                              ),
                              transitionsBuilder: (_, anim, __, child) {
                                return FadeTransition(
                                  opacity: anim,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: const Text(
                          "ابدأ المسار",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}