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

  bool isWatered;

  int streak;

  String lastDayWatered;

  bool goalDone;

  bool isEnabled;

  Plant({
    this.id,
    this.plantName,
    this.plantType,
    this.wateringFrequency,
    this.isWatered = false,
    this.streak = 0,
    this.lastDayWatered,
    this.goalDone = false,
    this.isEnabled = true,
  });

  Plant.fromDb(Map<String, dynamic> map)
      : id = map['id'],
        plantName = map['plant_name'],
        plantType = map['plant_type'],
        wateringFrequency = map['watering_frequency'],
        isWatered = map['is_watered'] == 1,
        streak = map['streak'],
        lastDayWatered = map['last_day_watered'],
        goalDone = map['goal_done'] == 1,
        isEnabled = map['is_enabled'] == 1;

  Map<String, dynamic> toMapForDb() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['plant_name'] = plantName;
    map['plant_type'] = plantType;
    map['watering_frequency'] = wateringFrequency;
    map['is_watered'] = isWatered ? 1 : 0;
    map['streak'] = streak;
    map['last_day_watered'] = lastDayWatered;
    map['goal_done'] = goalDone ? 1 : 0;
    map['is_enabled'] = isEnabled ? 1 : 0;
    return map;
  }
}
