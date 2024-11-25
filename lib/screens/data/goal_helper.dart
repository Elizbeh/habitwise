import 'package:flutter/material.dart';

class GoalTemplate {
  final String title;
  final String description;
  final String category;
  final int target;
  final DateTime startDate;
  final DateTime endDate;

  GoalTemplate({
    required this.title,
    required this.description,
    required this.category,
    required this.target,
    required this.startDate,
    required this.endDate,
  });
}

class CategoryIconData {
  final String category;
  final IconData iconData;

  CategoryIconData({
    required this.category,
    required this.iconData,
  });
}

class GoalHelper {
  static List<GoalTemplate> goalTemplates = [
    GoalTemplate(
      title: 'Exercise Daily',
      description: 'Go for a 30-minute walk or run every day.',
      category: 'Health & Fitness',
      target: 30,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 30)),
    ),
    GoalTemplate(
      title: 'Read More Books',
      description: 'Read at least 10 pages of a book every day.',
      category: 'Personal Development',
      target: 10,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 30)),
    ),
    GoalTemplate(
      title: 'Save Money',
      description: 'Save \$50 each week for your future.',
      category: 'Finance',
      target: 200,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 30 * 4)),
    ),
    GoalTemplate(
    title: 'Meditate Daily',
    description: 'Practice meditation for 10 minutes every morning to start your day with mindfulness.',
    category: 'Self Care',
    target: 10,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(days: 30)),
    ),
    GoalTemplate(
      title: 'Learn a New Language',
      description: 'Spend 20 minutes each day studying a new language to expand your horizons.',
      category: 'Personal Development',
      target: 20,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 60)),
    ),
    GoalTemplate(
      title: 'Cook Healthy Meals',
      description: 'Prepare a healthy dinner at home at least four times a week to improve your diet.',
      category: 'Health & Fitness',
      target: 4,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 30 * 2)),
    ),

  ];

  static Map<String, IconData> categoryIcons = {
    'Health & Fitness': Icons.fitness_center,
    'Work & Productivity': Icons.work,
    'Personal Development': Icons.lightbulb_outline,
    'Self Care': Icons.spa,
    'Finance': Icons.attach_money,
    'Education': Icons.school,
    'Relationships': Icons.favorite,
    'Hobbies': Icons.star,
  };
}
