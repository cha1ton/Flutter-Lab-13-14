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

  final List<String> _categorias = [
    'Todas',
    'Personal',
    'Trabajo',
    'Estudio',
    'Casa',
  ];

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  Future<void> _cargarTareas() async {
    List<Tarea> tareas;

    if (_categoriaSeleccionada != 'Todas') {
      tareas = await DatabaseHelper.instance.getTareasByCategoria(
        _categoriaSeleccionada,
      );
    } else if (_fechaSeleccionada != null) {
      tareas = await DatabaseHelper.instance.getTareasByFecha(
        _fechaSeleccionada!,
      );
    } else {
      tareas = await DatabaseHelper.instance.getTareas();
    }

    setState(() {
      _tareas = tareas;
    });
  }

  Future<void> _eliminarTareaConfirmada(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmar'),
        content: Text('¿Deseas eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteTarea(id);
      _cargarTareas();
    }
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.lightBlue[400]!, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
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

  Color _getPrioridadColor(double prioridad) {
    if (prioridad >= 4.0) return Colors.lightBlue.shade700;
    if (prioridad >= 2.5) return Colors.lightBlue.shade400;
    return Colors.lightBlue.shade200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Tareas', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.lightBlue.shade300,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            tooltip: 'Quitar filtros',
            icon: Icon(Icons.filter_alt_off),
            onPressed: _limpiarFiltros,
            color: Colors.white,
          ),
          IconButton(
            tooltip: 'Filtrar por fecha',
            icon: Icon(Icons.calendar_today),
            onPressed: _seleccionarFecha,
            color: Colors.white,
          ),
          SizedBox(width: 8),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              decoration: InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.category, color: Colors.lightBlue[400]),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _categoriaSeleccionada = value!;
                  _fechaSeleccionada = null;
                });
                _cargarTareas();
              },
              items: _categorias
                  .map(
                    (cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: _tareas.isEmpty
                ? Center(
                    child: Text(
                      'No hay tareas',
                      style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _tareas.length,
                    itemBuilder: (context, index) {
                      final tarea = _tareas[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        shadowColor: Colors.lightBlue.shade100,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: _getPrioridadColor(tarea.prioridad),
                            child: Text(
                              tarea.prioridad.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            tarea.titulo,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: tarea.completado ? TextDecoration.lineThrough : null,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Categoría: ${tarea.categoria}',
                                    style: TextStyle(color: Colors.grey[700])),
                                Text(
                                  'Fecha: ${DateFormat('yyyy-MM-dd').format(tarea.fecha)}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  tarea.descripcion,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: Colors.lightBlue[400]),
                            onSelected: (value) {
                              if (value == 'editar') {
                                _abrirFormulario(tarea: tarea);
                              } else if (value == 'eliminar') {
                                _eliminarTareaConfirmada(tarea.id!);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'editar',
                                child: Text('Editar'),
                              ),
                              PopupMenuItem(
                                value: 'eliminar',
                                child: Text('Eliminar'),
                              ),
                            ],
                          ),
                          onTap: () => _abrirFormulario(tarea: tarea),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.lightBlue[400],
        child: Icon(Icons.add),
        tooltip: 'Nueva tarea',
      ),
    );
  }
}
