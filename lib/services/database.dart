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
    // table plant
    db.execute('''
      CREATE TABLE plant(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plant_name STRING,
        plant_type STRING,
        watering_frequency INTEGER,
        monday INTEGER,
        tuesday INTEGER,
        wednesday INTEGER,
        thursday INTEGER,
        friday INTEGER,
        saturday INTEGER,
        sunday INTEGER,
        events_id INTEGER,
        is_watered INTEGER,
        last_day_watered STRING,
        streak INTEGER)
    ''');

    // print('Table plant done');

    // // table events
    // db.execute('''
    //   CREATE TABLE events(
    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     is_watered INTEGER,
    //     last_day_watered STRING,
    //     streak INTEGER)
    // ''');

    // print('table events done');
    // print(Events);

    // //print('joined together');

    print("Database was created!");
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // Run migration according database versions
  }

  Future<int> addPlant(Plant plant) async {
    var client = await db;
    // CONSOLE CHECKS
    print('''!!! DATABASE CHECK !!!
    ID: ${plant.id},
    NAME: ${plant.plantName},
    TYPE: ${plant.plantType},
    FREQUENCY: ${plant.wateringFrequency}
    WEEKLY: ${plant.monday}, ${plant.tuesday}, ${plant.wednesday}, ${plant.thursday}, ${plant.friday}, ${plant.saturday}, ${plant.sunday},
    IS WATERED: ${plant.isWatered},
    LAST DAY WATERED: ${plant.lastDayWatered},
    STREAK: ${plant.streak}''');
    return client.insert('plant', plant.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Plant> fetchPlant(int id) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps = client.query(
      'plant',
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
    FREQUENCY: ${newPlant.wateringFrequency}
    WEEKLY: ${newPlant.monday}, ${newPlant.tuesday}, ${newPlant.wednesday}, ${newPlant.thursday}, ${newPlant.friday}, ${newPlant.saturday}, ${newPlant.sunday},
    IS WATERED: ${newPlant.isWatered},
    LAST DAY WATERED: ${newPlant.lastDayWatered},
    STREAK: ${newPlant.streak}''');

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

  Future<void> deletePlants() async {
    var client = await db;
    return client.delete('plant');
  }

  Future closeDb() async {
    var client = await db;
    client.close();
  }
}
