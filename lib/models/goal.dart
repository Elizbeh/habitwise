import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String id;
  late final String title;
  late final String description;
  late final String category;
  final int priority;
  final int progress;
  late final int target;
  final DateTime targetDate;
  late final DateTime? endDate;
  final bool isCompleted;
  late final int groupProgress;
  String? userId;

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
    this.groupProgress = 0,
    this.userId
    
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
    int? groupProgress,
    String? userId
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
      groupProgress: groupProgress ?? this.groupProgress,
      userId: userId ?? this.userId
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
    'targetDate': Timestamp.fromDate(targetDate),
    'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    'isCompleted': isCompleted,
    'groupProgress': groupProgress,
    'userId': userId, // Ensure this is included
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
    targetDate: (map['targetDate'] as Timestamp).toDate(),
    endDate: map['endDate'] != null ? (map['endDate'] as Timestamp).toDate() : null,
    isCompleted: map['isCompleted'],
    groupProgress: map['groupProgress'] ?? 0,
    userId: map['userId']
  );
}

}
