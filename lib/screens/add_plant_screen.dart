import 'package:flutter/material.dart';
import 'package:sqlite_plant_app/constants.dart';
import 'package:sqlite_plant_app/models/plant.dart';
import 'package:sqlite_plant_app/screens/home_screen.dart';
import 'package:sqlite_plant_app/services/database.dart';
import 'package:string_validator/string_validator.dart';

class AddPlantScreen extends StatefulWidget {
  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  // database setup
  final db = PlantDatabase();
  List<Plant> plants = [];
  Plant plant;

  // form values
  final _formKey = GlobalKey<FormState>();
  final List<String> plantTypes = ['ornamental plant', 'corp', 'tree'];
  String _plantName;
  String _plantType;
  int _wateringFrequency = 0;
  int _id;

  // We start with all days selected.
  List<bool> values = List.filled(7, false);
  bool _monday = false;
  bool _tuesday = false;
  bool _wednesday = false;
  bool _thursday = false;
  bool _friday = false;
  bool _saturday = false;
  bool _sunday = false;

  // constants for the watering logic
  int streak = 0;
  String lastDayWatered;
  static var time = DateTime.now().toUtc();
  String today =
      DateTime.utc(time.year, time.day, time.month).toIso8601String();

  @override
  Widget build(BuildContext context) {
    //
    // add plant
    Future<void> addPlant(
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
        bool _sunday) async {
      if (_formKey.currentState.validate()) {
        if (_wateringFrequency > 0) {
          _formKey.currentState.save();

          print('name: $_plantName');
          print('type: $_plantType');
          print('num: $_wateringFrequency');
          // print('is watered: ${plant.isWatered}');

          await db.addPlant(
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
            ),
          );
          setupList();
          // Navigator.of(context).pop();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return HomeScreen();
          }));
        } else if (_wateringFrequency == 0) {
          print('_wateringfrequency is zero');
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Text('Error'),
                content: Text(
                    'Watering frequency has to be set to at least once a week.'),
              );
            },
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: new IconThemeData(color: darkGreenColor),
        backgroundColor: Colors.white,
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Create your plant . .',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                      } else if (value.startsWith(RegExp('[0-9]'))) {
                        return 'Please enter a plant name without numbers';
                      } else if (value.contains(RegExp('[0-9]'))) {
                        return 'Please enter a plant name without numbers';
                      }
                      return null;
                    },
                    onChanged: (String value) {
                      setState(() {
                        _plantName = value;
                      });
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
                    hintText: 'Select plant type',
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
                    setState(() {
                      _plantType = value;
                    });
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
                      '${_wateringFrequency}x a week',
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
                           style: ElevatedButton.styleFrom(
                            primary: _monday ? lightGreenColor : Colors.white,
                            shape: MaterialStateProperty.all<CircleBorder>(
                              CircleBorder(
                                side: BorderSide(color: Colors.white12),
                              )
                            )
                          ),
                          //elevation: 10,
                          //shape: CircleBorder(
                          //  side: BorderSide(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(5),
                          onPressed: () {
                            setState(() {
                              _monday = !_monday;
                            });
                            print('Monday: $_monday');

                            if (_monday == false) {
                              print('monday is false');
                              _wateringFrequency--;

                              print('Frequency: $_wateringFrequency');
                            } else if (_monday == true) {
                              print('monday is true');
                              _wateringFrequency++;

                              print('Frequency: $_wateringFrequency');
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
                          style: ElevatedButton.styleFrom(
                            primary: _tuesday ? lightGreenColor : Colors.white,
                          ),
                          //elevation: 10,
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(5),
                          onPressed: () {
                            setState(() {
                              _tuesday = !_tuesday;
                            });
                            print('Tuesday: $_tuesday');
                            if (_tuesday == false) {
                              print('tuesday is false');
                              _wateringFrequency--;
                              print('Frequency: $_wateringFrequency');
                            } else if (_tuesday == true) {
                              print('tuesday is true');
                              _wateringFrequency++;
                              print('Frequency: $_wateringFrequency');
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
                          style: ElevatedButton.styleFrom(
                            primary: _wednesday ? lightGreenColor : Colors.white,
                          ),
                          //elevation: 10,
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(5),
                          onPressed: () {
                            setState(() {
                              _wednesday = !_wednesday;
                            });
                            print('Wednesday: $_wednesday');
                            if (_wednesday == false) {
                              print('wednesday is false');
                              _wateringFrequency--;
                              print('Frequency: $_wateringFrequency');
                            } else if (_wednesday == true) {
                              print('wednesday is true');
                              _wateringFrequency++;
                              print('Frequency: $_wateringFrequency');
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
                          style: ElevatedButton.styleFrom(
                            primary: _thursday ? lightGreenColor : Colors.white,
                          ),
                         //elevation: 10,
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(5),
                          onPressed: () {
                            setState(() {
                              _thursday = !_thursday;
                            });
                            print('Thursday: $_thursday');
                            if (_thursday == false) {
                              print('thursday is false');
                              _wateringFrequency--;
                              print('Frequency: $_wateringFrequency');
                            } else if (_thursday == true) {
                              print('thursday is true');
                              _wateringFrequency++;
                              print('Frequency: $_wateringFrequency');
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
                          style: ElevatedButton.styleFrom(
                            primary: _friday ? lightGreenColor : Colors.white,
                          ),
                          //elevation: 10,
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(5),
                          onPressed: () {
                            setState(() {
                              _friday = !_friday;
                            });
                            print('Friday: $_friday');
                            if (_friday == false) {
                              print('friday is false');
                              _wateringFrequency--;
                              print('Frequency: $_wateringFrequency');
                            } else if (_friday == true) {
                              print('friday is true');
                              _wateringFrequency++;
                              print('Frequency: $_wateringFrequency');
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
                          style: ElevatedButton.styleFrom(
                            primary: _saturday ? lightGreenColor : Colors.white,
                          ),
                          //elevation: 10,
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(5),
                          onPressed: () {
                            setState(() {
                              _saturday = !_saturday;
                            });
                            print('Saturday: $_saturday');
                            if (_saturday == false) {
                              print('saturday is false');
                              _wateringFrequency--;
                              print('Frequency: $_wateringFrequency');
                            } else if (_saturday == true) {
                              print('saturday is true');
                              _wateringFrequency++;
                              print('Frequency: $_wateringFrequency');
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
                          style: ElevatedButton.styleFrom(
                            primary: _sunday ? lightGreenColor : Colors.white,
                          ),
                         // elevation: 10,
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white12),
                          ),
                          padding: EdgeInsets.all(5),
                          onPressed: () {
                            setState(() {
                              _sunday = !_sunday;
                            });
                            print('Sunday: $_sunday');
                            if (_sunday == false) {
                              print('sunday is false');
                              _wateringFrequency--;
                              print('Frequency: $_wateringFrequency');
                            } else if (_sunday == true) {
                              print('sunday is true');
                              _wateringFrequency++;
                              print('Frequency: $_wateringFrequency');
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
                      'ADD PLANT',
                      style: TextStyle(
                          color: darkGreenColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      addPlant(
                          _id,
                          _plantName,
                          _plantType,
                          _wateringFrequency,
                          _monday,
                          _tuesday,
                          _wednesday,
                          _thursday,
                          _friday,
                          _saturday,
                          _sunday);
                      setupList();
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

  void setupList() async {
    var _plants = await db.fetchAll();

    plants = _plants;
  }
}
