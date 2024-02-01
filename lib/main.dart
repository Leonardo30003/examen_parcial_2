import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:examen_parcial_2/models/task.dart';
import 'package:examen_parcial_2/providers/task_provider.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        title: 'Examen Parcial 2',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: TaskListScreen(),
      ),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<TaskProvider>(context).tasks;

    // Función para navegar a la pantalla de edición de tareas
    void _navigateToEditTask(BuildContext context, Task task) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditTaskScreen(task: task),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tareas'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: Checkbox(
              value: task.isCompleted,
              onChanged: (_) {
                Provider.of<TaskProvider>(context, listen: false)
                    .toggleTaskCompletion(index);
              },
            ),
            onTap: () {
              _navigateToEditTask(context, task); // Navegar a la pantalla de edición de tareas
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Eliminar Tarea'),
                    content: Text('¿Seguro que quieres eliminar esta tarea?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Eliminar'),
                        onPressed: () {
                          // Eliminar la tarea del proveedor de tareas
                          Provider.of<TaskProvider>(context, listen: false)
                              .deleteTask(index);
                          Navigator.of(context).pop(); // Cerrar el diálogo
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isCompleted = false; // Estado inicial: tarea no completada

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Tarea'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            Row(
              children: <Widget>[
                Text('Estado:'),
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) {
                    setState(() {
                      isCompleted = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Obtener los valores ingresados en el formulario
                final String title = titleController.text;
                final String description = descriptionController.text;

                // Crear una nueva tarea con los valores ingresados
                final Task newTask = Task(
                  title: title,
                  description: description,
                  isCompleted: isCompleted,
                );

                // Agregar la nueva tarea al proveedor de tareas
                Provider.of<TaskProvider>(context, listen: false).addTask(newTask);

                // Volver a la pantalla de lista de tareas
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Liberar los controladores al cerrar la pantalla
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}


class EditTaskScreen extends StatefulWidget {
  final Task task;

  EditTaskScreen({required this.task});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.task.title;
    descriptionController.text = widget.task.description;
    isCompleted = widget.task.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Tarea'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            Row(
              children: <Widget>[
                Text('Estado:'),
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) {
                    setState(() {
                      isCompleted = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Obtener los valores editados
                final String updatedTitle = titleController.text;
                final String updatedDescription = descriptionController.text;

                // Actualizar la tarea en el proveedor de tareas
                final Task updatedTask = Task(
                  title: updatedTitle,
                  description: updatedDescription,
                  isCompleted: isCompleted,
                );

                Provider.of<TaskProvider>(context, listen: false).editTask(
                  Provider.of<TaskProvider>(context, listen: false)
                      .tasks
                      .indexWhere((t) => t == widget.task),
                  updatedTask,
                );

                // Volver a la pantalla de lista de tareas
                Navigator.pop(context);
              },
              child: Text('Guardar Cambios'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Eliminar la tarea actual del proveedor de tareas
                Provider.of<TaskProvider>(context, listen: false).deleteTask(
                  Provider.of<TaskProvider>(context, listen: false)
                      .tasks
                      .indexWhere((t) => t == widget.task),
                );

                // Volver a la pantalla de lista de tareas
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: Text('Eliminar Tarea'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
