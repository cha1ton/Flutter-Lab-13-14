import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/tarea.dart';
import 'tarea_form.dart';

class TareaListScreen extends StatefulWidget {
  @override
  _TareaListScreenState createState() => _TareaListScreenState();
}

class _TareaListScreenState extends State<TareaListScreen> {
  List<Tarea> _tareas = [];
  String _categoriaSeleccionada = 'Todas';
  DateTime? _fechaSeleccionada;

  final List<String> _categorias = ['Todas', 'Personal', 'Trabajo', 'Estudio', 'Casa'];

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  Future<void> _cargarTareas() async {
    List<Tarea> tareas;

    if (_categoriaSeleccionada != 'Todas') {
      tareas = await DatabaseHelper.instance.getTareasByCategoria(_categoriaSeleccionada);
    } else if (_fechaSeleccionada != null) {
      tareas = await DatabaseHelper.instance.getTareasByFecha(_fechaSeleccionada!);
    } else {
      tareas = await DatabaseHelper.instance.getTareas();
    }

    setState(() {
      _tareas = tareas;
    });
  }

  Future<void> _eliminarTarea(int id) async {
    await DatabaseHelper.instance.deleteTarea(id);
    _cargarTareas();
  }

  Future<void> _abrirFormulario({Tarea? tarea}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TareaFormScreen(tarea: tarea)),
    );
    _cargarTareas(); // Recargar lista al volver
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
      _cargarTareas();
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _categoriaSeleccionada = 'Todas';
      _fechaSeleccionada = null;
    });
    _cargarTareas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Tareas'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_off),
            tooltip: 'Quitar filtros',
            onPressed: _limpiarFiltros,
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            tooltip: 'Filtrar por fecha',
            onPressed: _seleccionarFecha,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _categoriaSeleccionada,
              onChanged: (value) {
                setState(() {
                  _categoriaSeleccionada = value!;
                  _fechaSeleccionada = null;
                });
                _cargarTareas();
              },
              items: _categorias
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text('Categoría: $cat'),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: _tareas.isEmpty
                ? Center(child: Text('No hay tareas'))
                : ListView.builder(
                    itemCount: _tareas.length,
                    itemBuilder: (context, index) {
                      final tarea = _tareas[index];
                      return Dismissible(
                        key: Key(tarea.id.toString()),
                        background: Container(color: Colors.redAccent),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _eliminarTarea(tarea.id!);
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(tarea.titulo),
                            subtitle: Text(
                              'Categoría: ${tarea.categoria} • Prioridad: ${tarea.prioridad} • Fecha: ${DateFormat('yyyy-MM-dd').format(tarea.fecha)}',
                            ),
                            trailing: Icon(
                              tarea.completado ? Icons.check_circle : Icons.circle_outlined,
                              color: tarea.completado ? Colors.green : Colors.grey,
                            ),
                            onTap: () => _abrirFormulario(tarea: tarea),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: Icon(Icons.add),
      ),
    );
  }
}
