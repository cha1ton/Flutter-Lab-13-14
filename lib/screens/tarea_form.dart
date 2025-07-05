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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.lightBlue[400]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
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
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _prioridadController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.lightBlue[700])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.tarea != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Tarea' : 'Nueva Tarea'),
        backgroundColor: Colors.lightBlue.shade300,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Título'),
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: 'Ejemplo: Comprar leche',
                  prefixIcon: Icon(Icons.title, color: Colors.lightBlue[400]),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Requerido' : null,
              ),
              _buildSectionTitle('Descripción'),
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: 'Detalles de la tarea',
                  prefixIcon: Icon(Icons.description, color: Colors.lightBlue[400]),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              _buildSectionTitle('Prioridad (1.0 a 5.0)'),
              TextFormField(
                controller: _prioridadController,
                keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: 'Ejemplo: 3.5',
                  prefixIcon: Icon(Icons.flag, color: Colors.lightBlue[400]),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Requerido';
                  final val = double.tryParse(value);
                  if (val == null || val < 1.0 || val > 5.0) {
                    return 'Debe estar entre 1.0 y 5.0';
                  }
                  return null;
                },
              ),
              _buildSectionTitle('Categoría'),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.category, color: Colors.lightBlue[400]),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value!;
                  });
                },
                items: _categorias
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
              ),
              _buildSectionTitle('Fecha'),
              InkWell(
                onTap: _seleccionarFecha,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.calendar_today,
                        color: Colors.lightBlue[400]),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  child: Text(
                    '${_fechaSeleccionada.year}-${_fechaSeleccionada.month.toString().padLeft(2, '0')}-${_fechaSeleccionada.day.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SwitchListTile(
                title: Text(
                  'Completado',
                  style: TextStyle(color: Colors.lightBlue[700]),
                ),
                value: _completado,
                activeColor: Colors.lightBlue[400],
                onChanged: (val) {
                  setState(() {
                    _completado = val;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarTarea,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[400],
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  esEdicion ? 'Actualizar' : 'Guardar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
