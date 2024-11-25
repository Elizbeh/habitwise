import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? completionDate;
  final int progress;
  final int frequency; // Number of times the habit should be done
  bool isCompleted;
  final String? reminder; // e.g., "9:00 AM"
  final String? category;
  final int priority; // e.g., 1 for high, 2 for medium, 3 for low
  final String? groupId;
  List<String> achievements;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.startDate,
    this.endDate,
    this.completionDate,
    this.progress = 0,
    this.frequency = 1,
    this.isCompleted = false,
    this.reminder,
    this.category,
    this.priority = 2,
    this.groupId,
    this.achievements = const [],
  });

  // Method to copy a habit with optional parameters
  Habit copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? completionDate,
    int? progress,
    int? frequency,
    bool? isCompleted,
    String? reminder,
    String? category,
    int? priority,
    String? groupId,
    List<String>? achievements,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      completionDate: completionDate ?? this.completionDate,
      progress: progress ?? this.progress,
      frequency: frequency ?? this.frequency,
      isCompleted: isCompleted ?? this.isCompleted,
      reminder: reminder ?? this.reminder,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      groupId: groupId ?? this.groupId,
      achievements: achievements ?? this.achievements,
    );
  }

  // Method to convert a Habit object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'completionDate': completionDate != null ? Timestamp.fromDate(completionDate!) : null,
      'progress': progress,
      'frequency': frequency,
      'isCompleted': isCompleted,
      'reminder': reminder,
      'category': category,
      'priority': priority,
      'groupId': groupId,
      'achievements': achievements,
    };
  }

  // Factory constructor to create a Habit object from Firestore document
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null ? (map['endDate'] as Timestamp).toDate() : null,
      completionDate: map['completionDate'] != null ? (map['completionDate'] as Timestamp).toDate() : null,
      progress: map['progress'] ?? 0,
      frequency: map['frequency'] ?? 1,
      isCompleted: map['isCompleted'] ?? false,
      reminder: map['reminder'],
      category: map['category'],
      priority: map['priority'] ?? 2,
      groupId: map['groupId'],
      achievements: (map['achievements'] as List<dynamic>?)?.map((achievement) => achievement.toString()).toList() ?? [],
    );
  }

  // Method to mark the habit as completed
  Habit complete() {
    return copyWith(
      isCompleted: true,
      completionDate: DateTime.now(),
    );
  }

  // Method to increment progress
  Habit incrementProgress() {
    int newProgress = (progress + 1).clamp(0, frequency);
    bool newIsCompleted = newProgress >= frequency;
    return copyWith(
      progress: newProgress,
      isCompleted: newIsCompleted,
      completionDate: newIsCompleted ? DateTime.now() : null,
    );
  }
  // Method to reset progress
  Habit resetProgress() {
    return copyWith(
      progress: 0,
      isCompleted: false,
      completionDate: null,
    );
  }

  // Method to check if the habit is overdue (if endDate is passed)
  bool get isOverdue {
    return endDate != null && DateTime.now().isAfter(endDate!);
  }

  // Method to get remaining days until the end date
  int get daysRemaining {
    if (endDate == null) return -1;
    return endDate!.difference(DateTime.now()).inDays;
  }

  // Returns a string representation of the habit object
  @override
  String toString() {
    return 'Habit(id: $id, title: $title, description: $description, createdAt: $createdAt, startDate: $startDate, endDate: $endDate, completionDate: $completionDate, progress: $progress, frequency: $frequency, isCompleted: $isCompleted, reminder: $reminder, category: $category, priority: $priority, groupId: $groupId, achievements: $achievements)';
  }

  // Checks if two habit objects are equal
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Habit &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.completionDate == completionDate &&
        other.progress == progress &&
                other.frequency == frequency &&
        other.isCompleted == isCompleted &&
        other.reminder == reminder &&
        other.category == category &&
        other.priority == priority &&
        other.groupId == groupId &&
        other.achievements == achievements;
  }

  // Generates a hash code for the habit object
  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        completionDate.hashCode ^
        progress.hashCode ^
        frequency.hashCode ^
        isCompleted.hashCode ^
        reminder.hashCode ^
        category.hashCode ^
        priority.hashCode ^
        groupId.hashCode ^
        achievements.hashCode;
  }
}
