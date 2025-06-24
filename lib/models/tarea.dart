class Tarea {
  final int? id;
  final String titulo;
  final String descripcion;
  final double prioridad;
  final bool completado;
  final DateTime fecha;
  final String categoria;

  Tarea({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    required this.completado,
    required this.fecha,
    required this.categoria,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad,
      'completado': completado ? 1 : 0,
      'fecha': fecha.toIso8601String(),
      'categoria': categoria,
    };
  }

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      prioridad: map['prioridad'],
      completado: map['completado'] == 1,
      fecha: DateTime.parse(map['fecha']),
      categoria: map['categoria'],
    );
  }
}
