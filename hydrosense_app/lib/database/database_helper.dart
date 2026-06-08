import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/leitura_model.dart';
import '../models/alerta_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hydrosense.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE leituras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        umidade_solo INTEGER NOT NULL,
        pressao_hpa REAL NOT NULL,
        nivel_reserv_cm INTEGER NOT NULL,
        chuva_detectada INTEGER NOT NULL,
        valvula_ativa INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE alertas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        tipo TEXT NOT NULL,
        descricao TEXT NOT NULL
      )
    ''');
  }

  Future<int> inserirLeitura(LeituraModel leitura) async {
    final db = await instance.database;
    return await db.insert('leituras', leitura.toMap());
  }

  Future<List<LeituraModel>> buscarTodasLeituras() async {
    final db = await instance.database;
    final result = await db.query('leituras', orderBy: 'timestamp DESC');
    return result.map((json) => LeituraModel.fromMap(json)).toList();
  }

  Future<int> inserirAlerta(AlertaModel alerta) async {
    final db = await instance.database;
    return await db.insert('alertas', alerta.toMap());
  }

  Future<List<AlertaModel>> buscarTodosAlertas() async {
    final db = await instance.database;
    final result = await db.query('alertas', orderBy: 'timestamp DESC');
    return result.map((json) => AlertaModel.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}