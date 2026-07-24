import 'package:get/get.dart';
import 'package:team_app/Controller/bfs_algorithm.dart';
// قم باستيراد الملف الذي يحتوي على دالة bfs الخارجية هنا
// import 'path_to_your_bfs_file.dart';

class NetworkCheckService extends GetxController {
  
  /// محاكاة مسار التنقل باستخدام خوارزمية BFS الخارجية
  List<String> runPathSimulation({
    required Map<String, List<String>> graph,
    required String? startNodeId,
    required String? endNodeId,
  }) {
    // التحقق من المدخلات الأساسية
    if (startNodeId == null || endNodeId == null) {
      print("❌ Simulation Error: Start or Goal node is null");
      return [];
    }

    // استدعاء دالة BFS الخارجية الموحدة مباشرة
    return bfs(startNodeId, endNodeId, graph);
  }

  /// التحقق من جودة الرسم البياني (العقد المعزولة والروابط المكسورة)
  Map<String, dynamic> validateGraph(List<dynamic> nodesDocs) {
    List<String> isolatedNodes = [];
    List<Map<String, String>> brokenLinks = [];

    // استخراج جميع IDs الموجودة في قاعدة البيانات
    final Set<String> existingNodeIds = nodesDocs
        .map((doc) => (doc.data() as Map<String, dynamic>)["id"]?.toString() ?? "")
        .where((id) => id.isNotEmpty)
        .toSet();

    for (var doc in nodesDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final String nodeId = data["id"]?.toString() ?? "";
      final List<dynamic> neighbors = data["neighbors"] ?? [];

      if (nodeId.isEmpty) continue;

      // 1. فحص العقد المعزولة
      if (neighbors.isEmpty) {
        isolatedNodes.add(nodeId);
      }

      // 2. فحص الروابط المكسورة (التي تشير لـ ID غير موجود)
      for (var neighborId in neighbors) {
        final String neighborStr = neighborId.toString();
        if (!existingNodeIds.contains(neighborStr)) {
          brokenLinks.add({
            "from": nodeId,
            "to": neighborStr,
          });
        }
      }
    }

    return {
      "isolatedNodes": isolatedNodes,
      "brokenLinks": brokenLinks,
      "isValid": isolatedNodes.isEmpty && brokenLinks.isEmpty,
    };
  }
}