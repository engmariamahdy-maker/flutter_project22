import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  List<TaskModel> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  List<TaskModel> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  int get totalTasks => _tasks.length;
  int get completedCount => completedTasks.length;
  int get pendingCount => pendingTasks.length;

  double get completionPercentage {
    if (totalTasks == 0) return 0.0;
    return completedCount / totalTasks;
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('tasks');
      if (tasksJson != null) {
        final List<dynamic> decoded = json.decode(tasksJson);
        _tasks = decoded.map((e) => TaskModel.fromJson(e)).toList();
      }
    } catch (e) {
      _tasks = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> tasksJson =
          _tasks.map((e) => e.toJson()).toList();
      await prefs.setString('tasks', json.encode(tasksJson));
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }

  void addTask(TaskModel task) {
    _tasks.insert(0, task);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(TaskModel task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      _saveTasks();
      notifyListeners();
    }
  }

  void clearCompletedTasks() {
    _tasks.removeWhere((t) => t.isCompleted);
    _saveTasks();
    notifyListeners();
  }
}
