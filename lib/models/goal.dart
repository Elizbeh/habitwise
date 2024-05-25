import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String id;
  final String title;
  final String description;
  int progress;
  final int target;
  final DateTime targetDate;
  final String category;
  bool isCompleted;
  int priority;
  final DateTime? endDate;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    this.progress = 0,
    required this.target,
    required this.targetDate,
    required this.category,
    this.isCompleted = false,
    this.priority = 0,
    this.endDate,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    int? progress,
    int? target,
    DateTime? targetDate,
    String? category,
    bool? isCompleted,
    int? priority,
    DateTime? endDate,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      endDate: endDate ?? this.endDate,
    );
  }

  // Add fromJson and toJson methods for Firestore conversion
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      progress: json['progress'],
      target: json['target'],
      targetDate: (json['targetDate'] as Timestamp).toDate(),
      category: json['category'],
      isCompleted: json['isCompleted'],
      priority: json['priority'],
      endDate: json['endDate'] != null ? (json['endDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'progress': progress,
      'target': target,
      'targetDate': targetDate,
      'category': category,
      'isCompleted': isCompleted,
      'priority': priority,
      'endDate': endDate,
    };
  }
}
