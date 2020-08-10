import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sqlite_plant_app/constants.dart';
import 'package:sqlite_plant_app/models/plant.dart';
import 'package:sqlite_plant_app/services/database.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class HomeScreen extends StatefulWidget {
  final Plant plant;

  final int id;

  const HomeScreen({
    Key key,
    this.plant,
    this.id,
  }) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState(plant);
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState(this.plant);

  // scrollbar
  final ScrollController _scrollController = ScrollController();

  // database setup
  final db = PlantDatabase();
  List<Plant> plants = [];
  Plant plant;

  // form values
  final _formKey = GlobalKey<FormState>();
  final List<String> plantTypes = ['ornamental plant', 'corp', 'tree'];
  String _plantName;
  String _plantType;
  int _wateringFrequency;
  bool _isWatered;

  // constants for the watering logic
  bool isEnabled = true;
  bool goalDone = false;
  int streak = 0;
  String lastDayWatered;
  static var time = DateTime.now().toUtc();
  String today =
      DateTime.utc(time.year, time.day, time.month).toIso8601String();

  @override
  void initState() {
    super.initState();
    setupList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreenColor,
      drawer: _buildDrawer(),
      appBar: AppBar(
        iconTheme: new IconThemeData(color: darkGreenColor),
        backgroundColor: Colors.white,
        elevation: 2.0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/goodsprout.svg',
                  allowDrawingOutsideViewBox: true,
                  alignment: Alignment.topCenter,
                  height: 55,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(plants),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 20),
        child: new FloatingActionButton(
          backgroundColor: Colors.white,
          elevation: 10,
          onPressed: () {
            showModalBottomSheet(
              isDismissible: true,
              context: context,
              builder: (_) => _buildAddPlantSheet(),
            );
          },
          tooltip: 'Add plant',
          child: new Icon(
            Icons.add,
            color: darkGreenColor,
            size: 33,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<Plant> plantsList) {
    // WATERING ALGORIMTH

    // reset streak -> only if there is a new week
    void resetStreak() {
      setState(() {
        streak = 0;
      });
    }

// disable switch

    void disableSwitch(int index) {
      setState(() {
        plantsList[index].isEnabled = false;
      });
    }

// check if goal is done
    void checkGoal(int index) {
      print('${plantsList[index].plantName}: CHECKING GOAL ...');

      if (plantsList[index].streak == plantsList[index].wateringFrequency) {
        print('streak == wateringFrequency');
        print('Disabling switch..');

        plantsList[index].goalDone = true;
        disableSwitch(index);
      } else if (plantsList[index].streak !=
          plantsList[index].wateringFrequency) {
        plantsList[index].goalDone = false;
        plantsList[index].isEnabled = true;
        print('streak != wateringFrequency');
      }
    }

// check when was the plant watered and the streak
    void checkStatus(int index) {
      print('${plantsList[index].plantName}: CHECKING STATUS ...');

      if (plantsList[index].lastDayWatered == null) {
        print('lastDayWatered == null');
        if (plantsList[index].streak == plantsList[index].wateringFrequency) {
          plantsList[index].isWatered = true;
          print('streak == wateringFrequency');
          print('isWatered == true');
          print(
              'STATS-> streak: ${plantsList[index].streak}, goal: ${plantsList[index].wateringFrequency}');
        } else if (plantsList[index].streak !=
            plantsList[index].wateringFrequency) {
          plantsList[index].isWatered = false;
          print('streak != wateringFrequency');
          print('isWatered == false');
          print(
              'STATS-> streak: ${plantsList[index].streak}, goal: ${plantsList[index].wateringFrequency}');
        }
      } else if (plantsList[index].lastDayWatered == today) {
        plantsList[index].isWatered = true;
        print('lastDayWatered == today');
        print('isWatered == true');
        print(
            'STATS-> streak: ${plantsList[index].streak}, goal: ${plantsList[index].wateringFrequency}');
      } else if (plantsList[index].lastDayWatered != today) {
        print('lastDayWatered != today');
        if (plantsList[index].streak == plantsList[index].wateringFrequency) {
          plantsList[index].isWatered = true;
          print('streak == wateringFrequency');
          print('isWatered == true');
          print(
              'STATS-> streak: ${plantsList[index].streak}, goal: ${plantsList[index].wateringFrequency}');
        } else if (plantsList[index].streak !=
            plantsList[index].wateringFrequency) {
          plantsList[index].isWatered = false;
          print('streak != wateringFrequency');
          print('isWatered == false');
          print(
              'STATS-> streak: ${plantsList[index].streak}, goal: ${plantsList[index].wateringFrequency}');
        }
      }
    }

    // intrement streak
    void incrementStreak(int index) {
      setState(() {
        plantsList[index].streak++;
      });
      print(
          'Streak incremented ${plantsList[index].plantName}, streak: ${plantsList[index].streak}.');
    }

    // decrement streak

    void decrementStreak(int index) {
      setState(() {
        plantsList[index].streak--;
      });
      print(
          'Streak decremented ${plantsList[index].plantName}, streak: ${plantsList[index].streak}.');
    }

    /// update streak
    void updateStreak(int index) {
      if (plantsList[index].isWatered == true) {
        incrementStreak(index);
        // saveStreak(index);
        setState(() {
          plantsList[index].lastDayWatered = today;
        });
        print('Streak updated.');
      } else if (plantsList[index].isWatered == false) {
        print('_isWatered == false');
        decrementStreak(index);
      } else if (plantsList[index].isWatered == null) {
        print('_isWatered == null');
      }
    }

    void alterPlant(bool value, int index) async {
      bool isNowWatered = value;
      setState(() {
        plantsList[index].isWatered = isNowWatered;
      });

      if (plantsList[index].isWatered == true) {
        if (plantsList[index].lastDayWatered != today) {
          updateStreak(index); // check if streak should be incremented
          await db.updatePlant(
            new Plant(
              id: plantsList[index].id,
              plantName: plantsList[index].plantName,
              plantType: plantsList[index].plantType,
              wateringFrequency: plantsList[index].wateringFrequency,
              isWatered: isNowWatered,
              streak: plantsList[index].streak,
              lastDayWatered: plantsList[index].lastDayWatered,
            ),
          );
        } else if (plantsList[index].lastDayWatered == today) {
          print('LastDayWatered is today! Cannot water anymore!');
        } else {
          print('unknown lastdaywatered');
        }
      } else if (plantsList[index].isWatered == false &&
          plantsList[index].lastDayWatered == today) {
        print('User switched from true back to false');

        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Text('Are you sure?'),
                content:
                    Text('You won\'t be able to water this plant again today.'),
                actions: [
                  FlatButton(
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        _isWatered = true;
                        plantsList[index].isWatered = true;
                      });
                      print('User changed his mind, plant is watered');
                      await db.updatePlant(
                        new Plant(
                          id: plantsList[index].id,
                          plantName: plantsList[index].plantName,
                          plantType: plantsList[index].plantType,
                          wateringFrequency:
                              plantsList[index].wateringFrequency,
                          isWatered: _isWatered,
                          streak: plantsList[index].streak,
                          lastDayWatered: plantsList[index].lastDayWatered,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'I AM SURE',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () async {
                      updateStreak(index);

                      await db.updatePlant(
                        new Plant(
                          id: plantsList[index].id,
                          plantName: plantsList[index].plantName,
                          plantType: plantsList[index].plantType,
                          wateringFrequency:
                              plantsList[index].wateringFrequency,
                          isWatered: isNowWatered,
                          streak: plantsList[index].streak,
                          lastDayWatered: plantsList[index].lastDayWatered,
                        ),
                      );
                      setState(() {
                        plantsList[index].isEnabled = false;
                      });
                      Navigator.of(context).pop();
                      print('User decided not to water the plant today');
                    },
                  ),
                ],
              );
            });
      }
    }

    if (plantsList.length > 0) {
      return Column(
        children: [
          // Expanded(
          //   flex: 1,
          //   child: Container(
          //     width: double.infinity,
          //     decoration: BoxDecoration(
          //       color: darkGreenColor,
          //       borderRadius: BorderRadius.circular(20),
          //       shape: BoxShape.rectangle,
          //     ),
          //     child: Center(
          //       child: Text(
          //         'DASHBOARD HERE',
          //         style: TextStyle(
          //           color: Colors.white,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 14, top: 5),
            child: Text(
              'My plants',
              style: TextStyle(
                fontSize: 30,
                color: darkGreenColor,
              ),
            ),
          ),
          Expanded(
            // flex: 1,
            child: Scrollbar(
              isAlwaysShown: true,
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: plantsList.length,
                itemBuilder: (BuildContext context, int index) {
                  // run functions before building the listview
                  checkStatus(index);

                  // building it now ...
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Text('Are you sure?'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text(
                                  'CANCEL',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                onPressed: () {
                                  setupList();
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text(
                                  'DELETE',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                                onPressed: () {
                                  onDelete(plantsList[index].id);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    background: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'DELETE',
                            style: TextStyle(
                              color: Theme.of(context).errorColor,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.delete,
                            color: Theme.of(context).errorColor,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 12, left: 12, top: 5),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: GestureDetector(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plantsList[index].plantName,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: darkGreenColor,
                                        ),
                                      ),
                                      Text(
                                        '${plantsList[index].plantType}, ${plantsList[index].wateringFrequency}x a week',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    showModalBottomSheet(
                                      isDismissible: true,
                                      context: context,
                                      builder: (_) {
                                        return _buildEditPlantSheet(
                                          plantsList[index].id,
                                          plantsList[index].plantName,
                                          plantsList[index].plantType,
                                          plantsList[index].wateringFrequency,
                                          plantsList[index].isWatered,
                                          plantsList[index].streak,
                                          plantsList[index].lastDayWatered,
                                          plantsList[index].goalDone,
                                          plantsList[index].isEnabled,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SleekCircularSlider(
                                  appearance: CircularSliderAppearance(
                                    size: 50,
                                    startAngle: 270,
                                    angleRange: 360,
                                    customColors: CustomSliderColors(
                                      trackColor: lightGreenColor,
                                      progressBarColor: darkGreenColor,
                                    ),
                                    infoProperties: InfoProperties(
                                      modifier: (double value) {
                                        final num = (value /
                                                plantsList[index]
                                                    .wateringFrequency) *
                                            100;
                                        final streak = num.floor().toInt();

                                        return '$streak %';
                                      },
                                      mainLabelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  min: 0,
                                  max: plantsList[index]
                                      .wateringFrequency
                                      .toDouble(),
                                  initialValue:
                                      plantsList[index].streak.toDouble(),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Switch(
                                  activeColor: darkGreenColor,
                                  value: plantsList[index].isWatered == false
                                      ? false
                                      : true,
                                  onChanged: isEnabled
                                      ? (bool newValue) {
                                          // setState(() {
                                          //   plantsList[index].isWatered = newValue;
                                          // });
                                          alterPlant(newValue, index);

                                          print(newValue);
                                          checkGoal(index);
                                        }
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Expanded(
          //   flex: 1,
          //   child: Container(
          //     width: double.infinity,
          //     decoration: BoxDecoration(
          //       color: darkGreenColor,
          //       borderRadius: BorderRadius.circular(20),
          //       shape: BoxShape.rectangle,
          //     ),
          //   ),
          // ),
        ],
      );
    } else if (plantsList.length == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 4,
              child: Container(
                alignment: Alignment.center,
                child: Image.asset('assets/images/waiting_white.png',
                    fit: BoxFit.cover),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'No plants added yet...',
                style: TextStyle(
                  color: darkGreenColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: darkGreenColor,
        ),
      );
    }
  }

  Widget _buildAddPlantSheet() {
    return SingleChildScrollView(
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
                        _plantName = value;
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
                  setState(
                    () {
                      _plantType = value;
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
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 150,
                    child: Theme(
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
                          hintText: 'Enter a number',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter a valid number';
                          } else if (int.parse(value) == 0) {
                            return 'Enter a valid number';
                          } else if (int.parse(value) > 7) {
                            return 'Enter a smaller number';
                          }
                          return null;
                        },
                        onChanged: (String value) {
                          setState(
                            () {
                              _wateringFrequency = int.parse(value);
                            },
                          );
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(1),
                          WhitelistingTextInputFormatter.digitsOnly
                        ], // Only numbers can be entered
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 100,
                      child: Text('x a week'),
                    ),
                  ),
                ],
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
                      _plantName,
                      _plantType,
                      _wateringFrequency,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditPlantSheet(
      int _id,
      String _plantName,
      String _plantType,
      int _wateringFrequency,
      bool _isWatered,
      int _streak,
      String _lastDayWatered,
      bool _goalDone,
      bool _isEnabled) {
    return SingleChildScrollView(
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
                  initialValue: _plantName,
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
                        _plantName = value;
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
                value: _plantType,
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
                      _plantType = value;
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
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 150,
                    child: Theme(
                      data: ThemeData(),
                      child: TextFormField(
                        initialValue: _wateringFrequency.toString(),
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
                          hintText: 'Enter a number',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter a valid number';
                          } else if (int.parse(value) == 0) {
                            return 'Enter a valid number';
                          } else if (int.parse(value) > 7) {
                            return 'Enter a smaller number';
                          }
                          return null;
                        },
                        onChanged: (String value) {
                          setState(
                            () {
                              _wateringFrequency = int.parse(value);
                            },
                          );
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(1),
                          WhitelistingTextInputFormatter.digitsOnly
                        ], // Only numbers can be entered
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 100,
                      child: Text('x a week'),
                    ),
                  ),
                ],
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
                        _id,
                        _plantName,
                        _plantType,
                        _wateringFrequency,
                        _isWatered,
                        _streak,
                        _lastDayWatered,
                        _goalDone,
                        _isEnabled);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20),
            color: lightGreenColor,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Settings',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.white),
              ),
            ),
          ),
          Container(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(26.0),
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      'My plants: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkGreenColor,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '${plants.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                // SizedBox(
                //   height: 10,
                // ),
                // FlatButton.icon(
                //     onPressed: () {
                //       db.cleanDb();
                //     },
                //     icon: Icon(Icons.delete_forever),
                //     label: Text('Delete all my plants')),
                // SizedBox(
                //   height: 10,
                // ),
                // Row(
                //   children: <Widget>[
                //     Text(
                //       'Watered: ',
                //       style: TextStyle(
                //         fontWeight: FontWeight.bold,
                //         color: darkGreenColor,
                //         fontSize: 20,
                //       ),
                //     ),
                //     Text(
                //       '',
                //       style: TextStyle(
                //         fontWeight: FontWeight.bold,
                //         color: Colors.black,
                //         fontSize: 22,
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addPlant(
      String _plantName, String _plantType, int _wateringFrequency) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      print('name: $_plantName');
      print('type: $_plantType');
      print('num: $_wateringFrequency');
      // print('is watered: ${plant.isWatered}');

      await db.addPlant(
        Plant(
          plantName: _plantName,
          plantType: _plantType,
          wateringFrequency: _wateringFrequency,
          isWatered: false,
          goalDone: false,
        ),
      );
      setupList();
      Navigator.of(context).pop();
    }
  }

  Future<void> editPlant(
      int _id,
      String _plantName,
      String _plantType,
      int _wateringFrequency,
      bool _isWatered,
      int _streak,
      String _lastDayWatered,
      bool _goalDone,
      bool _isEnabled) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('id: $_id');
      print('name: $_plantName');
      print('type: $_plantType');
      print('num: $_wateringFrequency');
      print('is watered: $_isWatered');
      print('streak: $_streak');
      print('last day watered: $_lastDayWatered');
      print('goal done: $_goalDone');

      await db.updatePlant(
        Plant(
          id: _id,
          plantName: _plantName,
          plantType: _plantType,
          wateringFrequency: _wateringFrequency,
          isWatered: _isWatered,
          streak: _streak,
          lastDayWatered: _lastDayWatered,
          goalDone: _goalDone,
          isEnabled: _isEnabled,
        ),
      );
      setupList();
      Navigator.of(context).pop();
    }
  }

  void onDelete(int id) async {
    await db.removePlant(id);
    db.fetchAll().then((plantDb) => plants = plantDb);
    setState(() {});
  }

  void setupList() async {
    var _plants = await db.fetchAll();

    setState(() {
      plants = _plants;
    });
  }
}
