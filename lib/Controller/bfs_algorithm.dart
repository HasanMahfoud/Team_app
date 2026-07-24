

List<String> bfs(String start, String goal, Map<String, List<String>> graph) {
  // إذا العقدة غير موجودة بالـ graph
  if (!graph.containsKey(start)) {
    print("❌ BFS Error: start node '$start' not found in graph");
    return [];
  }

  if (!graph.containsKey(goal)) {
    print("❌ BFS Error: goal node '$goal' not found in graph");
    return [];
  }

  // قائمة الانتظار
  final queue = <String>[start];

  // تتبع الزيارات
  final visited = <String>{start};

  // تتبع المسار
  final parent = <String, String?>{};
  parent[start] = null;

  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);

    // إذا وصلنا للهدف → أعد بناء المسار
    if (current == goal) {
      final path = <String>[];
      String? node = goal;

      while (node != null) {
        path.add(node);
        node = parent[node];
      }

      return path.reversed.toList();
    }

    // جيران العقدة الحالية (آمن ضد null)
    final neighbors = graph[current] ?? [];

    for (final next in neighbors) {
      if (!visited.contains(next)) {
        visited.add(next);
        parent[next] = current;
        queue.add(next);
      }
    }
  }

  print("⚠️ BFS: No path found from $start to $goal");
  return [];
}
