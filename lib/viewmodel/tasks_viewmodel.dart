import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:todo_app/model/task_model.dart';

class TaskViewmodel extends ChangeNotifier {
  List<Task> tasks = [];

  String? taskName;
  final dateCont = TextEditingController();
  final timeCont = TextEditingController();

  bool get isValid =>
      taskName != null && dateCont.text.isNotEmpty && timeCont.text.isNotEmpty;

  setTaskName(String? value) {
    taskName = value;
    log(value.toString());
    notifyListeners();
  }

  setDate(DateTime? date) {
    if (date == null) {
      return;
    }
    log(date.toString());

    DateTime currentDate = DateTime.now();
    DateTime now =
    DateTime(currentDate.year, currentDate.month, currentDate.day);

    int diff = date.difference(now).inDays;

    if (diff == 0) {
      dateCont.text = "Today";
    } else if (diff == 1) {
      dateCont.text = "Tommorrow";
    } else {
      dateCont.text = "${date.day}-${date.month}-${date.year}";
    }

    notifyListeners();
  }

  settime(TimeOfDay? time) {
    log(time.toString());
    if (time == null) {
      return;
    }

    if (time.hour == 0) {
      timeCont.text = "12:${time.minute} AM";
    } else if (time.hour < 12) {
      timeCont.text = "${time.hour}:${time.minute} AM";
    } else if (time.hashCode == 12) {
      timeCont.text = "${time.hour}:${time.minute} PM";
    } else {
      timeCont.text = "${time.hour - 12}:${time.minute} PM";
    }

    notifyListeners();
  }

  addTask() {
    if (!isValid) {
      return;
    }

    final task = Task(taskName!, dateCont.text, timeCont.text);
    tasks.add(task);
    timeCont.clear();
    dateCont.clear();
    log(tasks.length.toString());

    notifyListeners();
  }
  void updateTask(int index, Task updatedTask) {
    if (index >= 0 && index < tasks.length) {
      tasks[index] = updatedTask;
      notifyListeners();
    }
  }
  void deleteTask(Task task) {
    tasks.removeWhere((t) =>
    t.taskName == task.taskName &&
        t.date == task.date &&
        t.time == task.time
    );
    notifyListeners();
  }


}