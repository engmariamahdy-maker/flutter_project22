import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }

class TaskModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final Color color;
  final IconData icon;

  TaskModel({
    String? id,
    required this.title,
    DateTime? createdAt,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.color = const Color(0xFF4F46E5),
    this.icon = Icons.task_alt_rounded,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  TaskModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    Color? color,
    IconData? icon,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.index,
      'isCompleted': isCompleted,
      'color': color.value,
      'icon': icon.codePoint,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      priority: TaskPriority.values[json['priority'] as int],
      isCompleted: json['isCompleted'] as bool,
      color: Color(json['color'] as int),
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
    );
  }
}
