import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:team_app/Controller/AdminController/network_check_controller.dart';

class PathManagementPage extends StatefulWidget {
  const PathManagementPage({super.key});

  @override
  State<PathManagementPage> createState() => _PathManagementPageState();
}

class _PathManagementPageState extends State<PathManagementPage> {
  final NetworkCheckService _networkService = Get.put(NetworkCheckService());

  String? startNodeId;
  String? endNodeId;
  List<String> simulatedPath = [];
  var isSimulating = false.obs;
  bool isValidating = false;
  List<String> isolatedNodes = [];
  List<String> brokenReferences = [];
  bool validationPerformed = false;

// 📱 1. التابع البديل للمحاكاة (BFS) المربوط بالـ setState المحلية

  void _runPathSimulation(Map<String, List<String>> graph) {
    if (startNodeId == null || endNodeId == null) return;

    isSimulating.value = true;
    // استدعاء الحساب من ملف الخدمة الخارجي
    final result = _networkService.runPathSimulation(
      graph: graph,
      startNodeId: startNodeId,
      endNodeId: endNodeId,
    );
    isSimulating.value = false;
    
    setState(() {
      simulatedPath = result;
    });
  }

// 📱 2. التابع البديل للفحص المربوط بالـ setState المحلية
  void _validateGraph(List<QueryDocumentSnapshot> docs) {
    setState(() {
      isValidating = true;
      isolatedNodes.clear();
      brokenReferences.clear();
    });

    // استدعاء الفحص من ملف الخدمة الخارجي
    final results = NetworkCheckService().validateGraph(docs);

    setState(() {
      isolatedNodes = results["isolated"] ?? [];
      brokenReferences = results["broken"] ?? [];
      isValidating = false;
      validationPerformed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color.fromARGB(255, 76, 175, 125);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "إدارة وتجربة المسارات",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("nodes").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("حدث خطأ في تحميل البيانات"));
          }
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: primaryColor));
          }

          final docs = snapshot.data!.docs;

          // بناء هيكل الجراف برمجياً من قاعدة البيانات واستخدامه في المحاكي
          Map<String, List<String>> graph = {};
          List<String> allNodeIds = [];

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final id = data["id"]?.toString() ?? "";

            //  تطبيق نفس التحويل الصريح هنا لبناء الجراف بدون مشاكل تايبنج
            final List<dynamic> neighborsData =
                data["neighbors"] is List ? data["neighbors"] : [];
            final List<String> neighbors =
                neighborsData.map((e) => e.toString()).toList();

            if (id.isNotEmpty) {
              graph[id] = neighbors;
              allNodeIds.add(id);
            }
          }

          // ترتيب الأسماء لتظهر بشكل منظم في حقول الاختيار
          allNodeIds.sort();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📡 القسم الأول: لوحة محاكاة وفحص الخوارزمية
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.alt_route, color: primaryColor),
                            SizedBox(width: 8),
                            Text(
                              "محاكي المسارات (Path Simulator)",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // اختيار نقطة البداية
                        DropdownButtonFormField<String>(
                          value: allNodeIds.contains(startNodeId)
                              ? startNodeId
                              : null,
                          decoration: const InputDecoration(
                            labelText: "نقطة البداية (من)",
                            prefixIcon:
                                Icon(Icons.location_on, color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          items: allNodeIds
                              .map((id) =>
                                  DropdownMenuItem(value: id, child: Text(id)))
                              .toList(),
                          onChanged: (val) => setState(() => startNodeId = val),
                        ),
                        const SizedBox(height: 16),

                        // اختيار نقطة النهاية
                        DropdownButtonFormField<String>(
                          value:
                              allNodeIds.contains(endNodeId) ? endNodeId : null,
                          decoration: const InputDecoration(
                            labelText: "نقطة الوجهة (إلى)",
                            prefixIcon: Icon(Icons.flag, color: Colors.blue),
                            border: OutlineInputBorder(),
                          ),
                          items: allNodeIds
                              .map((id) =>
                                  DropdownMenuItem(value: id, child: Text(id)))
                              .toList(),
                          onChanged: (val) => setState(() => endNodeId = val),
                        ),
                        const SizedBox(height: 16),

                        // زر تشغيل المحاكاة
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed:
                                (startNodeId != null && endNodeId != null)
                                    ? () {
                                        isSimulating.value = true;
                                        _runPathSimulation(graph);
                                      }
                                    : null,
                            icon: const Icon(Icons.play_arrow,
                                color: Colors.white),
                            label: const Text("احسب أقصر مسار برمجياً",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),

                        // عرض نتيجة المسار المحاكي
                        if (simulatedPath.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text("خطوات المسار المستخرج:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              runSpacing: 8,
                              children:
                                  simulatedPath.asMap().entries.map((entry) {
                                int idx = entry.key;
                                String node = entry.value;
                                bool isLast = idx == simulatedPath.length - 1;
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Chip(
                                      label: Text(node,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      backgroundColor: isLast
                                          ? Colors.blue.shade100
                                          : Colors.white,
                                    ),
                                    if (!isLast)
                                      const Icon(Icons.arrow_forward,
                                          size: 18, color: Colors.grey),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ] else if (validationPerformed &&
                            simulatedPath.isEmpty &&
                            startNodeId != null &&
                            endNodeId != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Text(
                                "⚠️ لا يوجد مسار يربط هاتين القاعتين! تأكد من إعداد الجيران بشكل صحيح.",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                //  القسم الثاني: فاحص سلامة هيكل البيانات وجاهزيتها
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.fact_check, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              "فاحص سلامة ترابط الشبكة",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        const Text(
                          "يساعدك هذا الفحص على اكتشاف أي أخطاء في ربط الغرف أو نسيان غرف معزولة تمنع الطلاب من الوصول لوجهاتهم.",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: isValidating
                                ? null
                                : () => _validateGraph(docs),
                            icon: isValidating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.analytics_outlined,
                                    color: primaryColor),
                            label: const Text("ابدأ الفحص الشامل للشبكة",
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),

                        // نتائج الفحص
                        if (validationPerformed) ...[
                          const SizedBox(height: 16),

                          // تقرير القاعات المعزولة
                          _buildReportSection(
                            title: "قاعات معزولة (ليس لها جيران إطلاقاً):",
                            items: isolatedNodes,
                            emptyMessage:
                                "✓ ممتاز! لا يوجد أي قاعة معزولة في مبانيك.",
                            isError: true,
                          ),
                          const SizedBox(height: 12),

                          // تقرير مراجع مكسورة
                          _buildReportSection(
                            title:
                                "روابط مكسورة (جار مكتوب بشكل خاطئ أو محذوف):",
                            items: brokenReferences,
                            emptyMessage:
                                "✓ ممتاز! جميع الجيران المعرفين موجودون فعلياً بالسيستم.",
                            isError: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ودجت فرعية لبناء أقسام التقارير بشكل نظيف ومقروء للأدمن
  Widget _buildReportSection({
    required String title,
    required List<String> items,
    required String emptyMessage,
    required bool isError,
  }) {
    bool hasItems = items.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasItems ? Colors.amber.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color:
                    hasItems ? Colors.amber.shade300 : Colors.green.shade200),
          ),
          child: hasItems
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items
                      .map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text("• $item",
                                style: TextStyle(
                                    color: isError
                                        ? Colors.red.shade900
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500)),
                          ))
                      .toList(),
                )
              : Text(emptyMessage,
                  style: TextStyle(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
