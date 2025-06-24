import 'package:flutter/material.dart';
import 'screens/tarea_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Tareas',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: TareaListScreen(),
    );
  }
}
