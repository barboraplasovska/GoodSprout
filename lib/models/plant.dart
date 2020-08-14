import 'package:meta/meta.dart';

class Plant {
  @required
  int id;
  @required
  String plantName;
  @required
  String plantType;
  @required
  int wateringFrequency;
  bool monday;
  bool tuesday;
  bool wednesday;
  bool thursday;
  bool friday;
  bool saturday;
  bool sunday;
  bool isWatered;
  String lastDayWatered;
  int streak;

  Plant({
    this.id,
    this.plantName,
    this.plantType,
    this.wateringFrequency,
    this.monday = false,
    this.tuesday = false,
    this.wednesday = false,
    this.thursday = false,
    this.friday = false,
    this.saturday = false,
    this.sunday = false,
    this.isWatered = false,
    this.lastDayWatered,
    this.streak = 0,
  });

  Plant.fromDb(Map<String, dynamic> map)
      : id = map['id'],
        plantName = map['plant_name'],
        plantType = map['plant_type'],
        wateringFrequency = map['watering_frequency'],
        monday = map['monday'] == 1,
        tuesday = map['tuesday'] == 1,
        wednesday = map['wednesday'] == 1,
        thursday = map['thursday'] == 1,
        friday = map['friday'] == 1,
        saturday = map['saturday'] == 1,
        sunday = map['sunday'] == 1,
        isWatered = map['is_watered'] == 1,
        lastDayWatered = map['last_day_watered'],
        streak = map['streak'];

  Map<String, dynamic> toMapForDb() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['plant_name'] = plantName;
    map['plant_type'] = plantType;
    map['watering_frequency'] = wateringFrequency;
    map['monday'] = monday ? 1 : 0;
    map['tuesday'] = tuesday ? 1 : 0;
    map['wednesday'] = wednesday ? 1 : 0;
    map['thursday'] = thursday ? 1 : 0;
    map['friday'] = friday ? 1 : 0;
    map['saturday'] = saturday ? 1 : 0;
    map['sunday'] = sunday ? 1 : 0;
    map['is_watered'] = isWatered ? 1 : 0;
    map['last_day_watered'] = lastDayWatered;
    map['streak'] = streak;
    return map;
  }
}
