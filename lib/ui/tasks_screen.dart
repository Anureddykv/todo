import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/colors/constants.dart';
import 'package:todo_app/model/task_model.dart';
import 'package:todo_app/viewmodel/tasks_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondary,
      appBar: AppBar(
        backgroundColor: primary,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.check,
                size: 20,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "To Do List",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ],
        ),
      ),
      body: Consumer<TaskViewmodel>(builder: (context, taskProvider, _) {
      return ListView.separated(
        itemBuilder: (context, index) {
          final task = taskProvider.tasks[index];
          return TaskWidget(
            task: task,
            onEdit: (updatedTask) {
              taskProvider.updateTask(index, updatedTask);
            },
            onDelete: (taskToDelete) {
              taskProvider.deleteTask(taskToDelete); // Ensure this is called
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(
          color: Colors.white,
          height: 1,
          thickness: 1,
        ),
        itemCount: taskProvider.tasks.length,
      );
    }),
          floatingActionButton: const CustomFAB(),
    );
  }
}


class TaskWidget extends StatefulWidget {
  const TaskWidget({Key? key, required this.task, required this.onEdit, this.onDelete}) : super(key: key);
  final Task task;
  final Function(Task) onEdit;
  final Function(Task)? onDelete;

  @override
  _TaskWidgetState createState() => _TaskWidgetState();

}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: const Offset(2, 3),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(
          widget.task.taskName,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${widget.task.date}, ${widget.task.time}",
          style: const TextStyle(color: Colors.blueAccent),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'edit') {
              _editTaskDialog(context);
            }else if (value == 'delete') {
              _confirmDeleteTask(context);
            }else if (value == 'email') {
              shareViaEmail();
            } else if (value == 'sms') {
              shareViaSMS();
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit Task')),
            const PopupMenuItem(value: 'delete', child: Text('Delete Task')),
            const PopupMenuItem(value: 'sms', child: Text('Share via SMS')),
            const PopupMenuItem(value: 'email', child: Text('Share via Email')),
          ],
        ),
      ),
    );
  }

  void _editTaskDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: widget.task.taskName);
    TextEditingController dateController = TextEditingController(text: widget.task.date);
    TextEditingController timeController = TextEditingController(text: widget.task.time);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text("Edit Task", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Task Name",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dateController,
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2017),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Due Date",
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeController,
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      timeController.text = pickedTime.format(context);
                    });
                  }
                },
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Time",
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Icon(Icons.timer, color: Colors.white),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Task updatedTask = Task(
                   nameController.text,
                   dateController.text,
                 timeController.text,
                );
                widget.onEdit(updatedTask);
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }
  void shareViaEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'anureddy952@gmail.com',
      queryParameters: {
        'subject': 'Task Reminder ',
        'body': ' Task: ${widget.task.taskName}\n Date: ${widget.task.date}\n Time: ${widget.task.time}',
      },
    );

    String emailUrl = emailUri.toString();

    print("Trying to open: $emailUrl");

    if (await canLaunchUrlString(emailUrl)) {
      await launchUrlString(emailUrl, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch Email. No email app found.");
    }
  }
  void shareViaSMS() async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: '',
      queryParameters: {
        'body': '📝 Task: ${widget.task.taskName}\n Date: ${widget.task.date}\n Time: ${widget.task.time}'
      },
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      print("Could not launch SMS");
    }
  }
  void _confirmDeleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              if (widget.onDelete != null) { // Null safety check
                widget.onDelete!(widget.task);
              }
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return const CustomDialog();
          },
        );
      },
      child: const Icon(
        Icons.add,
        size: 40,
      ),
    );
  }
}
class CustomDialog extends StatelessWidget {
  const CustomDialog({super.key});

  @override
  Widget build(BuildContext context) {
    double sh = MediaQuery.sizeOf(context).height;
    double sw = MediaQuery.sizeOf(context).width;
    final taskProvider = Provider.of<TaskViewmodel>(context, listen: false);

    return Dialog(
      backgroundColor: secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
      child: SizedBox(
        height: sh * 0.5,
        width: sw * 0.8,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sh * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "New Task",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              const Text("What has to be done?", style: TextStyle(color: textBlue)),
              CustomTextfield(
                hint: "Enter a Task",
                onChanged: (value) {
                  taskProvider.setTaskName(value);
                },
              ),
              const SizedBox(height: 50),
              const Text("Due Date", style: TextStyle(color: textBlue)),
              CustomTextfield(
                hint: "Enter a Date",
                readOnly: true,
                icon: Icons.calendar_month,
                controller: taskProvider.dateCont,
                onTap: () async {
                  DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2017),
                      lastDate: DateTime(2030));

                  taskProvider.setDate(date);
                },
              ),
              const SizedBox(height: 10),
              CustomTextfield(
                hint: "Enter a Time",
                readOnly: true,
                icon: Icons.timer,
                controller: taskProvider.timeCont,
                onTap: () async {
                  TimeOfDay? time = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());

                  taskProvider.settime(time);
                },
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () async {
                      await taskProvider.addTask();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Create",
                      style: TextStyle(color: primary),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
class CustomTextfield extends StatelessWidget {
  const CustomTextfield(
      {super.key,
        required this.hint,
        this.icon,
        this.onTap,
        this.readOnly = false,
        this.onChanged,
        this.controller});

  final String hint;
  final IconData? icon;
  final void Function()? onTap;
  final bool readOnly;
  final void Function(String)? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: TextField(
        readOnly: readOnly,
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            suffixIcon: InkWell(
                onTap: onTap,
                child: Icon(
                  icon,
                  color: Colors.white,
                )),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
