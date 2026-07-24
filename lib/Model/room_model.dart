class RoomModel {
  final String room;
  final String college;
  final int floor;
  final String building;
  final List<StepModel> steps;

  RoomModel({
    required this.room,
    required this.college,
    required this.floor,
    required this.building,
    required this.steps,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      room: json["room"],
      college: json["college"],
      floor: json["floor"],
      building: json["building"],
      steps: (json["steps"] as List)
          .map((e) => StepModel.fromJson(e))
          .toList(),
    );
  }
}

class StepModel {
  final String title;
  final String icon;
  final String image;

  StepModel({
    required this.title,
    required this.icon,
    required this.image,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      title: json["title"],
      icon: json["icon"],
      image: json["image"],
    );
  }
}
