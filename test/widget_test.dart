import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:examen_parcial_2/main.dart'; // Asegúrate de importar el archivo principal de tu aplicación

void main() {
  testWidgets('Task item displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp()); // No necesitas el 'const' aquí

    // Agrega una tarea ficticia para probar
    final taskTitle = 'Tarea de ejemplo';
    final taskDescription = 'Descripción de la tarea de ejemplo';

    // Verifica que la tarea se muestre en la lista
    expect(find.text(taskTitle), findsOneWidget);
    expect(find.text(taskDescription), findsOneWidget);

    // También puedes agregar pruebas para marcar como completada, editar y eliminar tareas.
  });
}
