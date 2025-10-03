import 'package:flutter/material.dart';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const TaskManagerHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TaskManagerHome extends StatefulWidget {
  const TaskManagerHome({Key? key}) : super(key: key);

  @override
  State<TaskManagerHome> createState() => _TaskManagerHomeState();
}

class _TaskManagerHomeState extends State<TaskManagerHome> {
  List<Task> tasks = [
    Task(
      id: '1',
      title: 'Complete Flutter Project',
      description: 'Finish the task management app with all features',
      isCompleted: false,
    ),
    Task(
      id: '2',
      title: 'Review Pull Requests',
      description: 'Check and merge pending PRs on GitHub',
      isCompleted: false,
    ),
    Task(
      id: '3',
      title: 'Team Meeting',
      description: 'Discuss project roadmap for Q4',
      isCompleted: true,
    ),
    Task(
      id: '4',
      title: 'Update Documentation',
      description: 'Add API documentation and user guides',
      isCompleted: false,
    ),
    Task(
      id: '5',
      title: 'Fix Critical Bugs',
      description: 'Address issues reported in production',
      isCompleted: false,
    ),
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context, Task task, int index) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteTask(task, index);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(Task task, int index) {
    setState(() {
      tasks.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${task.title} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              tasks.insert(index, task);
            });
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Task task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);
    });
  }

  void _showAddTaskDialog() {
    _titleController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  setState(() {
                    tasks.add(
                      Task(
                        id: DateTime.now().toString(),
                        title: _titleController.text,
                        description: _descriptionController.text,
                      ),
                    );
                  });
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager'), elevation: 2),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet!',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a new task',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: tasks.length,
              onReorder: _reorderTasks,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: Key(task.id),
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  secondaryBackground: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    _showDeleteConfirmation(context, task, index);
                    return false;
                  },
                  child: Card(
                    key: Key(task.id),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.drag_handle, color: Colors.grey[400]),
                          const SizedBox(width: 8),
                          Checkbox(
                            value: task.isCompleted,
                            onChanged: (bool? value) {
                              _toggleTaskCompletion(index);
                            },
                          ),
                        ],
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: task.description.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                task.description,
                                style: TextStyle(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        onPressed: () {
                          _showDeleteConfirmation(context, task, index);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
