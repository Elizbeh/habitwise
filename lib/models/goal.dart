import 'dart:convert';

class Goal {
  final String id;
  final String title;
  final String description;
  final String category;
  final int priority;
  final int progress;
  final int target;
  final DateTime targetDate;
  final DateTime? endDate;
  final bool isCompleted;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.progress,
    required this.target,
    required this.targetDate,
    required this.endDate,
    required this.isCompleted,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? priority,
    int? progress,
    int? target,
    DateTime? targetDate,
    DateTime? endDate,
    bool? isCompleted,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      targetDate: targetDate ?? this.targetDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'progress': progress,
      'target': target,
      'targetDate': targetDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      priority: map['priority'],
      progress: map['progress'],
      target: map['target'],
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['targetDate']),
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
          : null,
      isCompleted: map['isCompleted'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Goal.fromJson(String source) => Goal.fromMap(json.decode(source));
}
