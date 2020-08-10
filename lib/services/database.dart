import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_plant_app/models/plant.dart';

class PlantDatabase {
  static final PlantDatabase _instance = PlantDatabase._();
  static Database _database;

  PlantDatabase._();

  factory PlantDatabase() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) {
      print("Database is not null, returning database.");
      return _database;
    }

    _database = await init();
    print("Creating database . . .");

    return _database;
  }

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = join(directory.path, 'database.db');
    var database = openDatabase(dbPath,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    print('dbPath: $dbPath');
    print('func init()');
    return database;
  }

  void _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE plant(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plant_name STRING,
        plant_type STRING,
        watering_frequency INTEGER,
        is_watered INTEGER,
        streak INTEGER,
        last_day_watered STRING,
        goal_done INTEGER,
        is_enabled INTEGER)
    ''');

    print("Database was created!");
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // Run migration according database versions
  }

  Future<int> addPlant(Plant plant) async {
    var client = await db;
    return client.insert('plant', plant.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Plant> fetchPlant(int id) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps = client.query(
      'plant',
      // columns: [
      //   'id',
      //   'plant_name',
      //   'plant_type',
      //   'watering_frequency',
      //   'is_watered',
      //   'streak',
      //   'last_day_watered',
      // ],
      where: 'id = ?',
      whereArgs: [id],
    );
    var maps = await futureMaps;

    if (maps.length != 0) {
      return Plant.fromDb(maps.first);
    }

    return null;
  }

  Future<List<Plant>> fetchAll() async {
    var client = await db;
    var res = await client.query('plant');

    if (res.isNotEmpty) {
      var plants = res.map((plantMap) => Plant.fromDb(plantMap)).toList();
      print('Number of plants: ${plants.length}');
      return plants;
    }
    return [];
  }

  Future<int> updatePlant(Plant newPlant) async {
    var client = await db;

    // CONSOLE CHECKS
    print('''!!! DATABASE CHECK !!!
    ID: ${newPlant.id},
    NAME: ${newPlant.plantName},
    TYPE: ${newPlant.plantType},
    FREQUENCY: ${newPlant.wateringFrequency},
    WATERED: ${newPlant.isWatered},
    STREAK: ${newPlant.streak},
    LAST DAY WATERED: ${newPlant.lastDayWatered},
    GOAL DONE: ${newPlant.goalDone}''');

    return client.update('plant', newPlant.toMapForDb(),
        where: 'id = ?',
        whereArgs: [newPlant.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removePlant(int id) async {
    var client = await db;
    return client.delete(
      'plant',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future closeDb() async {
    var client = await db;
    client.close();
  }
}
