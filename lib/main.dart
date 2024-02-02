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
          primarySwatch: Colors.deepPurple, // Cambiado a un color más distintivo
          visualDensity: VisualDensity.adaptivePlatformDensity,
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.deepPurple,
            textTheme: ButtonTextTheme.primary,
          ),
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
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTaskScreen()),
              );
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(child: Text('No hay tareas, agrega una!'))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card( // Usando Card para un mejor aspecto visual
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(task.description),
              trailing: Checkbox(
                value: task.isCompleted,
                onChanged: (_) {
                  Provider.of<TaskProvider>(context, listen: false)
                      .toggleTaskCompletion(index);
                },
              ),
              onTap: () => _navigateToEditTask(context, task),
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
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: Text('Eliminar'),
                          onPressed: () {
                            Provider.of<TaskProvider>(context, listen: false)
                                .deleteTask(index);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
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
  bool isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Tarea'),
      ),
      body: SingleChildScrollView( // Para evitar overflow cuando el teclado está visible
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(), // Agregado para mejor visualización
                prefixIcon: Icon(Icons.title), // Icono para el título
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(), // Agregado para mejor visualización
                prefixIcon: Icon(Icons.description), // Icono para la descripción
              ),
              maxLines: 3, // Permitir múltiples líneas para la descripción
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Tarea Completada:', style: TextStyle(fontSize: 16)),
                Switch(
                  value: isCompleted,
                  onChanged: (value) {
                    setState(() {
                      isCompleted = value;
                    });
                  },
                  activeColor: Colors.deepPurple, // Color cuando está activo
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Guardar'),
                onPressed: () {
                  final String title = titleController.text;
                  final String description = descriptionController.text;
                  final Task newTask = Task(
                    title: title,
                    description: description,
                    isCompleted: isCompleted,
                  );
                  Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple, // Botón color principal
                  onPrimary: Colors.white, // Texto color
                ),
              ),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit), // Icono para editar
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note), // Icono para la descripción
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Tarea Completada:', style: TextStyle(fontSize: 16)),
                Switch(
                  value: isCompleted,
                  onChanged: (value) {
                    setState(() {
                      isCompleted = value;
                    });
                  },
                  activeColor: Colors.deepPurple,
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Guardar Cambios'),
                onPressed: () {
                  final String updatedTitle = titleController.text;
                  final String updatedDescription = descriptionController.text;
                  final Task updatedTask = Task(
                    title: updatedTitle,
                    description: updatedDescription,
                    isCompleted: isCompleted,
                  );
                  Provider.of<TaskProvider>(context, listen: false).editTask(
                    Provider.of<TaskProvider>(context, listen: false).tasks.indexWhere((t) => t == widget.task),
                    updatedTask,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.delete_forever),
                label: Text('Eliminar Tarea'),
                onPressed: () {
                  Provider.of<TaskProvider>(context, listen: false).deleteTask(
                    Provider.of<TaskProvider>(context, listen: false).tasks.indexWhere((t) => t == widget.task),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                ),
              ),
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
