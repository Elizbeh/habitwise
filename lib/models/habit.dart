import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isCompleted;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isCompleted = false,
  });

  // Method to copy a habit with optional parameters
  Habit copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Method to convert a Habit object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Factory constructor creates a Habit object from Firestore document
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? ''),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  // Returns a string representation of the habit object
  @override
  String toString() {
    return 'Habit(id: $id, title: $title, description: $description, createdAt: $createdAt, isCompleted: $isCompleted)';
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
        other.isCompleted == isCompleted;
  }

  // Generates a hash code for the habit object
  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        isCompleted.hashCode;
  }
}
