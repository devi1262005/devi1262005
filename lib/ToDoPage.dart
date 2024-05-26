import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({Key? key}) : super(key: key);

  @override
  _ToDoPageState createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final _form = GlobalKey<FormState>();
  String toDoTitle = "To-Do Title";
  List<Map<String, dynamic>> tasks = [];
  Color randomBackgroundColor = Colors.amber;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    readData();
  }

  Future<void> readData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedTasks = prefs.getString('tasks');

    if (storedTasks != null) {
      setState(() {
        tasks = json.decode(storedTasks).cast<Map<String, dynamic>>();
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> addTask(String taskName, bool isChecked) async {
    final newTask = {
      'task': taskName,
      'isChecked': isChecked,
      'dateTime': DateTime.now().toString(),
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    setState(() {
      tasks.add(newTask);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', json.encode(tasks));
  }

  Future<void> deleteTask(String taskId) async {
    setState(() {
      tasks.removeWhere((task) => task['id'] == taskId);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', json.encode(tasks));
  }

  Future<void> updateTask(String taskId, {required bool isChecked}) async {
    final index = tasks.indexWhere((task) => task['id'] == taskId);
    if (index != -1) {
      setState(() {
        tasks[index]['isChecked'] = isChecked;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('tasks', json.encode(tasks));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "To Do",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: randomBackgroundColor,
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              toDoTitle,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                child: Text(
                  "No tasks yet",
                  style: TextStyle(fontSize: 18.0),
                ),
              )
                  : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final taskName = task['task'] ?? '';
                  final isChecked = task['isChecked'] ?? false;
                  final dateTime = task['dateTime'] ?? '';

                  return ListTile(
                    title: Text(
                      taskName,
                      style: TextStyle(
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteTask(task['id']);
                          },
                        ),
                        Checkbox(
                          value: isChecked,
                          onChanged: (bool? value) {
                            updateTask(task['id'],
                                isChecked: value ?? false);
                          },
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Added on: $dateTime',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTaskInputDialog(context);
        },
        tooltip: 'Add Task',
        child: Icon(Icons.add),
        backgroundColor: Colors.amber,
      ),
    );
  }

  void _showTaskInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String taskName = "";
        bool isChecked = false;

        return AlertDialog(
          title: const Text('Enter Task:'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  taskName = value;
                },
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                addTask(taskName, isChecked);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ToDoPage(),
  ));
}
