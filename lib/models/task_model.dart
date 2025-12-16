class Task {
  String id;
  String title;
  String? description;
  DateTime dueDate;
  bool isCompleted;
  List<String> tags;
  DateTime createdAt;
  DateTime? updatedAt;
  bool isCarriedForward;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
    this.isCarriedForward = false,
  });

  Task.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        description = json['description'],
        dueDate = DateTime.parse(json['dueDate']),
        isCompleted = json['isCompleted'] ?? false,
        tags = List<String>.from(json['tags'] ?? []),
        createdAt = DateTime.parse(json['createdAt']),
        updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        isCarriedForward = json['isCarriedForward'] ?? false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'isCompleted': isCompleted,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'isCarriedForward': isCarriedForward,
      };
}