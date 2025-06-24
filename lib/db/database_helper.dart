import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tarea.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tareas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tareas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        prioridad REAL NOT NULL,
        completado INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        categoria TEXT NOT NULL
      )
    ''');
  }

  // Insertar nueva tarea
  Future<int> insertTarea(Tarea tarea) async {
    final db = await instance.database;
    return await db.insert('tareas', tarea.toMap());
  }

  // Obtener todas las tareas
  Future<List<Tarea>> getTareas() async {
    final db = await instance.database;
    final result = await db.query('tareas', orderBy: 'fecha ASC');
    return result.map((map) => Tarea.fromMap(map)).toList();
  }

  // Actualizar una tarea existente
  Future<int> updateTarea(Tarea tarea) async {
    final db = await instance.database;
    return await db.update(
      'tareas',
      tarea.toMap(),
      where: 'id = ?',
      whereArgs: [tarea.id],
    );
  }

  // Eliminar una tarea por id
  Future<int> deleteTarea(int id) async {
    final db = await instance.database;
    return await db.delete('tareas', where: 'id = ?', whereArgs: [id]);
  }

  // Filtrar tareas por categoría
  Future<List<Tarea>> getTareasByCategoria(String categoria) async {
    final db = await instance.database;
    final result = await db.query(
      'tareas',
      where: 'categoria = ?',
      whereArgs: [categoria],
      orderBy: 'fecha ASC',
    );
    return result.map((map) => Tarea.fromMap(map)).toList();
  }

  // Filtrar tareas por fecha específica
  Future<List<Tarea>> getTareasByFecha(DateTime fecha) async {
    final db = await instance.database;
    final formatted = fecha.toIso8601String().split('T')[0]; // solo YYYY-MM-DD
    final result = await db.rawQuery('''
      SELECT * FROM tareas WHERE DATE(fecha) = ?
    ''', [formatted]);

    return result.map((map) => Tarea.fromMap(map)).toList();
  }

  // Cerrar conexión
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
