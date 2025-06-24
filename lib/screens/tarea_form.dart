import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/tarea.dart';

class TareaFormScreen extends StatefulWidget {
  final Tarea? tarea;

  TareaFormScreen({this.tarea});

  @override
  _TareaFormScreenState createState() => _TareaFormScreenState();
}

class _TareaFormScreenState extends State<TareaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _prioridadController = TextEditingController();
  String _categoriaSeleccionada = 'Personal';
  bool _completado = false;
  DateTime _fechaSeleccionada = DateTime.now();

  final List<String> _categorias = ['Personal', 'Trabajo', 'Estudio', 'Casa'];

  @override
  void initState() {
    super.initState();

    // Si es edición, precargar valores
    if (widget.tarea != null) {
      final tarea = widget.tarea!;
      _tituloController.text = tarea.titulo;
      _descripcionController.text = tarea.descripcion;
      _prioridadController.text = tarea.prioridad.toString();
      _completado = tarea.completado;
      _fechaSeleccionada = tarea.fecha;
      _categoriaSeleccionada = tarea.categoria;
    }
  }

  Future<void> _guardarTarea() async {
    if (_formKey.currentState!.validate()) {
      final tarea = Tarea(
        id: widget.tarea?.id,
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        prioridad: double.tryParse(_prioridadController.text) ?? 1.0,
        completado: _completado,
        fecha: _fechaSeleccionada,
        categoria: _categoriaSeleccionada,
      );

      if (widget.tarea == null) {
        await DatabaseHelper.instance.insertTarea(tarea);
      } else {
        await DatabaseHelper.instance.updateTarea(tarea);
      }

      Navigator.pop(context);
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _prioridadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.tarea != null;

    return Scaffold(
      appBar: AppBar(title: Text(esEdicion ? 'Editar Tarea' : 'Nueva Tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _prioridadController,
                decoration: InputDecoration(labelText: 'Prioridad (1.0 - 5.0)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final val = double.tryParse(value ?? '');
                  if (val == null || val < 1.0 || val > 5.0) {
                    return 'Debe estar entre 1.0 y 5.0';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                items: _categorias
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Categoría'),
              ),
              SizedBox(height: 10),
              SwitchListTile(
                title: Text('Completado'),
                value: _completado,
                onChanged: (value) {
                  setState(() {
                    _completado = value;
                  });
                },
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text('Fecha límite: ${_fechaSeleccionada.toLocal().toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _seleccionarFecha,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarTarea,
                child: Text(esEdicion ? 'Actualizar' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
