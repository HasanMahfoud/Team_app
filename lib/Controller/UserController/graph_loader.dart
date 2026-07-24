
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_app/Model/node_model.dart';

Stream<Map<String, NodeModel>> streamNodes() {
  return FirebaseFirestore.instance
      .collection('nodes')
      .snapshots()
      .map((snapshot) {
        final nodes = <String, NodeModel>{};
        for (var doc in snapshot.docs) {
          nodes[doc.id] = NodeModel.fromMap(doc.data(), doc.id);
        }
        return nodes;
      });
}


Map<String, List<String>> buildGraph(Map<String, NodeModel> nodes) {
  final Map<String, List<String>> graph = {};

  nodes.forEach((id, node) {
    graph[id] = node.neighbors;
  });

  return graph;
}
