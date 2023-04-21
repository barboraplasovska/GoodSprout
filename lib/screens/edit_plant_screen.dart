import 'package:flutter/material.dart';
import 'package:sqlite_plant_app/constants.dart';
import 'package:sqlite_plant_app/models/plant.dart';
import 'package:sqlite_plant_app/screens/home_screen.dart';
import 'package:sqlite_plant_app/services/database.dart';

class EditPlantScreen extends StatefulWidget {
  @required
  Plant plant;
  @required
  int id;
  @required
  String plantName;
  @required
  String plantType;
  @required
  int wateringFrequency;
  @required
  bool monday;
  @required
  bool tuesday;
  @required
  bool wednesday;
  @required
  bool thursday;
  @required
  bool friday;
  @required
  bool saturday;
  @required
  bool sunday;
  @required
  bool isWatered;
  @required
  String lastDayWatered;
  @required
  int streak;
  EditPlantScreen(
      {Key key,
      this.plant,
      this.id,
      this.plantName,
      this.plantType,
      this.wateringFrequency,
      this.monday,
      this.tuesday,
      this.wednesday,
      this.thursday,
      this.friday,
      this.saturday,
      this.sunday,
      this.isWatered,
      this.lastDayWatered,
      this.streak})
      : super(key: key);

  @override
  _EditPlantScreenState createState() => _EditPlantScreenState(
        plant,
        id,
        plantName,
        plantType,
        wateringFrequency,
        monday,
        tuesday,
        wednesday,
        thursday,
        friday,
        saturday,
        sunday,
        isWatered,
        lastDayWatered,
        streak,
      );
}

class _EditPlantScreenState extends State<EditPlantScreen> {
// database setup
  final db = PlantDatabase();
  List<Plant> plants = [];
  Plant plant;

// form values
  final _formKey = GlobalKey<FormState>();
  final List<String> plantTypes = ['ornamental plant', 'corp', 'tree'];

  // We start with all days selected.
  List<bool> values = List.filled(7, false);
  bool selectedDay = false;

  // constants for the watering logic
  int streak = 0;
  String lastDayWatered;
  static var time = DateTime.now().toUtc();
  String today =
      DateTime.utc(time.year, time.day, time.month).toIso8601String();

  _EditPlantScreenState(
    Plant plant,
    int id,
    String plantName,
    String plantType,
    int wateringFrequency,
    bool monday,
    bool tuesday,
    bool wednesday,
    bool thursday,
    bool friday,
    bool saturday,
    bool sunday,
    bool isWatered,
    String lastDayWatered,
    int streak,
  );

  @override
  void initState() {
    super.initState();
    print('${widget.id}' + '${widget.plantName}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: new IconThemeData(color: darkGreenColor),
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: Container(
          height: 600,
          color: Colors.white,
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Plant name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: darkGreenColor,
                  ),
                ),
                Theme(
                  data: ThemeData(),
                  child: TextFormField(
                    initialValue: widget.plantName,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: darkGreenColor,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: lightGreenColor,
                          width: 1.5,
                        ),
                      ),
                      hintText: 'Name your plant',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a plant name';
                      }
                      return null;
                    },
                    onChanged: (String value) {
                      setState(
                        () {
                          widget.plantName = value;
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Plant type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: darkGreenColor,
                  ),
                ),
                DropdownButtonFormField(
                  validator: (value) {
                    if (value == null) {
                      return 'Please choose a plant type';
                    } else {
                      return null;
                    }
                  },
                  isExpanded: false,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: darkGreenColor,
                  ),
                  value: widget.plantType,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: darkGreenColor,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: lightGreenColor,
                        width: 1.5,
                      ),
                    ),
                    fillColor: Colors.white,
                  ),
                  items: plantTypes.map((plantType) {
                    return DropdownMenuItem(
                      value: plantType,
                      child: Container(
                        child: Text('$plantType'),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(
                      () {
                        widget.plantType = value;
                      },
                    );
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Watering frequency',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: darkGreenColor,
                  ),
                ),
                Text(
                  'Select days on which you want to water your plants.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Selected frequency: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.wateringFrequency}x a week',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          color: widget.monday ? lightGreenColor : Colors.white,
                          elevation: 10,
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(5),
                          onPressed: () {
                            setState(() {
                              widget.monday = !widget.monday;
                            });
                            print('Monday: ${widget.monday}');

                            if (widget.monday == false) {
                              print('monday is false');
                              widget.wateringFrequency--;
                              print('Frequency: ${widget.wateringFrequency}');
                            } else if (widget.monday == true) {
                              print('monday is true');
                              widget.wateringFrequency++;
                              print('Frequency: ${widget.wateringFrequency}');
                            }
                          },
                          child: Text(
                            'M',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          color:
                              widget.tuesday ? lightGreenColor : Colors.white,
                          elevation: 10,
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(5),
                          onPressed: () {
                            setState(() {
                              widget.tuesday = !widget.tuesday;
                            });
                            print('Tuesday: ${widget.tuesday}');
                            if (widget.tuesday == false) {
                              print('tuesday is false');
                              widget.wateringFrequency--;
                              print('Frequency: ${widget.wateringFrequency}');
                            } else if (widget.tuesday == true) {
                              print('tuesday is true');
                              widget.wateringFrequency++;
                              print('Frequency: ${widget.wateringFrequency}');
                            }
                          },
                          child: Text(
                            'T',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          color:
                              widget.wednesday ? lightGreenColor : Colors.white,
                          elevation: 10,
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(5),
                          onPressed: () {
                            setState(() {
                              widget.wednesday = !widget.wednesday;
                            });
                            print('Wednesday: ${widget.wednesday}');
                            if (widget.wednesday == false) {
                              print('wednesday is false');
                              widget.wateringFrequency--;
                              print('Frequency: ${widget.wateringFrequency}');
                            } else if (widget.wednesday == true) {
                              print('wednesday is true');
                              widget.wateringFrequency++;
                              print('Frequency: ${widget.wateringFrequency}');
                            }
                          },
                          child: Text(
                            'W',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          color:
                              widget.thursday ? lightGreenColor : Colors.white,
                          elevation: 10,
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(5),
                          onPressed: () {
                            setState(() {
                              widget.thursday = !widget.thursday;
                            });
                            print('Thursday: ${widget.thursday}');
                            if (widget.thursday == false) {
                              print('thursday is false');
                              widget.wateringFrequency--;
                              print('Frequency: ${widget.wateringFrequency}');
                            } else if (widget.thursday == true) {
                              print('thursday is true');
                              widget.wateringFrequency++;
                              print('Frequency: ${widget.wateringFrequency}');
                            }
                          },
                          child: Text(
                            'T',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          color: widget.friday ? lightGreenColor : Colors.white,
                          elevation: 10,
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(5),
                          onPressed: () {
                            setState(() {
                              widget.friday = !widget.friday;
                            });
                            print('Friday: ${widget.friday}');
                            if (widget.friday == false) {
                              print('friday is false');
                              widget.wateringFrequency--;
                              print('Frequency: ${widget.wateringFrequency}');
                            } else if (widget.friday == true) {
                              print('friday is true');
                              widget.wateringFrequency++;
                              print('Frequency: ${widget.wateringFrequency}');
                            }
                          },
                          child: Text(
                            'F',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          color:
                              widget.saturday ? lightGreenColor : Colors.white,
                          elevation: 10,
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(5),
                          onPressed: () {
                            setState(() {
                              widget.saturday = !widget.saturday;
                            });
                            print('Saturday: ${widget.saturday}');
                            if (widget.saturday == false) {
                              print('saturday is false');
                              widget.wateringFrequency--;
                              print('Frequency: ${widget.wateringFrequency}');
                            } else if (widget.saturday == true) {
                              print('saturday is true');
                              widget.wateringFrequency++;
                              print('Frequency: ${widget.wateringFrequency}');
                            }
                          },
                          child: Text(
                            'S',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          color: widget.sunday ? lightGreenColor : Colors.white,
                          elevation: 10,
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(5),
                          onPressed: () {
                            setState(() {
                              widget.sunday = !widget.sunday;
                            });
                            print('Sunday: ${widget.sunday}');
                            if (widget.sunday == false) {
                              print('sunday is false');
                              widget.wateringFrequency--;
                              print('Frequency: ${widget.wateringFrequency}');
                            } else if (widget.sunday == true) {
                              print('sunday is true');
                              widget.wateringFrequency++;
                              print('Frequency: ${widget.wateringFrequency}');
                            }
                          },
                          child: Text(
                            'S',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  child: FlatButton(
                    child: Text(
                      'EDIT PLANT',
                      style: TextStyle(
                          color: darkGreenColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      editPlant(
                        widget.id,
                        widget.plantName,
                        widget.plantType,
                        widget.wateringFrequency,
                        widget.monday,
                        widget.tuesday,
                        widget.wednesday,
                        widget.thursday,
                        widget.friday,
                        widget.saturday,
                        widget.sunday,
                        widget.isWatered,
                        widget.lastDayWatered,
                        widget.streak,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// setup list
  void setupList() async {
    var _plants = await db.fetchAll();

    setState(() {
      plants = _plants;
    });
  }

// edit plant
  Future<void> editPlant(
    int _id,
    String _plantName,
    String _plantType,
    int _wateringFrequency,
    bool _monday,
    bool _tuesday,
    bool _wednesday,
    bool _thursday,
    bool _friday,
    bool _saturday,
    bool _sunday,
    bool _isWatered,
    String _lastDayWatered,
    int _streak,
  ) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('''Edit plant(),
    ID: $_id,
    NAME: $_plantName,
    TYPE: $_plantType,
    FREQUENCY: $_wateringFrequency,
    WEEKLY: $_monday, $_tuesday, $_wednesday, $_thursday, $_friday, $_saturday, $_sunday''');

      await db.updatePlant(
        Plant(
          id: _id,
          plantName: _plantName,
          plantType: _plantType,
          wateringFrequency: _wateringFrequency,
          monday: _monday,
          tuesday: _tuesday,
          wednesday: _wednesday,
          thursday: _thursday,
          friday: _friday,
          saturday: _saturday,
          sunday: _sunday,
          isWatered: _isWatered,
          lastDayWatered: _lastDayWatered,
          streak: _streak,
        ),
      );
      setupList();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return HomeScreen();
          },
        ),
      );
    }
  }

  String valuesToEnglishDays(List<bool> values, bool searchedValue) {
    final days = <String>[];
    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      // Use v == true, as the value could be null, as well (disabled days).
      if (v == searchedValue) days.add(intDayToEnglish(i));
    }
    if (days.isEmpty) return 'NONE';
    return days.join(', ');
  }

  /// Print the integer value of the day and the day that it corresponds to in English.
  ///
  /// It's added to the example so that you can always see and verify that the
  /// code is correct.
  // printIntAsDay(int day) {
  //   print(
  //       'Received integer: $day. Corresponds to day: ${intDayToEnglish(day)}');
  // }

  String intDayToEnglish(int day) {
    if (day % 7 == DateTime.monday % 7) return 'Monday';
    if (day % 7 == DateTime.tuesday % 7) return 'Tueday';
    if (day % 7 == DateTime.wednesday % 7) return 'Wednesday';
    if (day % 7 == DateTime.thursday % 7) return 'Thursday';
    if (day % 7 == DateTime.friday % 7) return 'Friday';
    if (day % 7 == DateTime.saturday % 7) return 'Saturday';
    if (day % 7 == DateTime.sunday % 7) return 'Sunday';
    throw '🐞 This should never have happened: $day';
  }
}
