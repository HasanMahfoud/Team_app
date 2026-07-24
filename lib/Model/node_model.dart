class NodeModel {
  final String id;
  final String title;
  final List<String> neighbors;
  final List<String> images; 

  NodeModel({
    required this.id,
    required this.title,
    required this.neighbors,
    required this.images,
  });

  factory NodeModel.fromMap(Map<String, dynamic> map, String docId) {
    return NodeModel(
      id: docId,
      title: map['title'] ?? '',
      neighbors: List<String>.from(map['neighbors'] ?? []),

      // 🔥 أهم نقطة:
      // نقرأ من الحقل "image" لأنه موجود في Firestore
      // ونخزّنه داخل images لأنه List
      images: map['image'] != null
          ? List<String>.from(map['image'])
          : [],
    );
  }
}
