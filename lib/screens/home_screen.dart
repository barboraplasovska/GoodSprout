import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:sqlite_plant_app/constants.dart';
import 'package:sqlite_plant_app/models/plant.dart';
import 'package:sqlite_plant_app/screens/add_plant_screen.dart';
import 'package:sqlite_plant_app/screens/edit_plant_screen.dart';
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
  final ScrollController _scrollControllerDashboard = ScrollController();
  bool dashboardHasData = false;

  // database setup
  final db = PlantDatabase();
  List<Plant> plants = [];
  Plant plant;

  // constants for the watering logic
  int streak = 0;
  String lastDayWatered = '';
  static var time = DateTime.now();
  String today = DateFormat('EEEE dd.MM.yyyy').format(time);
  String weekday = DateFormat('EEEE').format(time);

  @override
  void initState() {
    super.initState();
    setupList();
    print('Welcome, today is $today');
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return AddPlantScreen();
                },
              ),
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
    print(plantsList);
    // WATERING ALGORIMTH

    // reset streak -> only if there is a new week
    void resetStreak(int index) {
      setState(() {
        plantsList[index].streak = 0;
      });
    }

    checkWeekday(int index) {
      if (weekday == 'Monday') {
        resetStreak(index);
        print(
            'It\'s monday, resetting streak. Streak of ${plantsList[index].plantName}: ${plantsList[index].streak}.');
      } else {
        print(
            'It\'s $weekday today. Reseting streak NOT needed!Streak of ${plantsList[index].plantName}: ${plantsList[index].streak}.');
      }
    }

// // check if goal is done
//     void checkGoal(int index) {
//       print('${plantsList[index].plantName}: CHECKING GOAL ...');

//       if (plantsList[index].streak == plantsList[index].wateringFrequency) {
//         print('streak == wateringFrequency');
//         print('Disabling switch..');

//         plantsList[index].goalDone = true;
//         disableSwitch(index);
//       } else if (plantsList[index].streak !=
//           plantsList[index].wateringFrequency) {
//         plantsList[index].goalDone = false;
//         plantsList[index].isEnabled = true;
//         print('streak != wateringFrequency');
//       }
//     }

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

    Widget _showDashboard() {
      return Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              shape: BoxShape.rectangle,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.topRight,
                          child: Text(
                            today,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Today',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: darkGreenColor,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: dashboardHasData
                            ? Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  'Plants to water today ..',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  'No plants to water today ..',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Scrollbar(
                          isAlwaysShown: false,
                          controller: _scrollControllerDashboard,
                          child: ListView.builder(
                            controller: _scrollControllerDashboard,
                            itemCount: plantsList.length,
                            itemBuilder: (BuildContext context, int index) {
                              print('Building dashboard');
                              print('DASHBOARD: $dashboardHasData');

                              switch (weekday) {
                                case 'Monday':
                                  if (plantsList[index].monday == true) {
                                    print(
                                        'Its monday and ${plantsList[index].plantName} wants to be watered');
                                    dashboardHasData = true;
                                    print(
                                        '${plantsList[index].plantName} is not watered yet');
                                    print(
                                        'DASHBOARD has data: $dashboardHasData');
                                    return Row(
                                      children: <Widget>[
                                        Text(
                                          '— ${plantsList[index].plantName}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Container(
                                            child: plantsList[index].isWatered
                                                ? Icon(
                                                    Icons.done,
                                                    color: darkGreenColor,
                                                    size: 20,
                                                  )
                                                : null),
                                      ],
                                    );
                                  }
                                  break;
                                case 'Tuesday':
                                  if (plantsList[index].tuesday == true) {
                                    print(
                                        'Its tuesday and ${plantsList[index].plantName} wants to be watered');
                                    dashboardHasData = true;
                                    print(
                                        '${plantsList[index].plantName} is not watered yet');
                                    print(
                                        'DASHBOARD has data: $dashboardHasData');
                                    return Row(
                                      children: <Widget>[
                                        Text(
                                          '— ${plantsList[index].plantName}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Container(
                                            child: plantsList[index].isWatered
                                                ? Icon(
                                                    Icons.done,
                                                    color: darkGreenColor,
                                                    size: 20,
                                                  )
                                                : null),
                                      ],
                                    );
                                  }
                                  break;
                                case 'Wednesday':
                                  if (plantsList[index].wednesday == true) {
                                    print(
                                        'Its wednesday and ${plantsList[index].plantName} wants to be watered');
                                    dashboardHasData = true;
                                    print(
                                        '${plantsList[index].plantName} is not watered yet');
                                    print(
                                        'DASHBOARD has data: $dashboardHasData');
                                    return Row(
                                      children: <Widget>[
                                        Text(
                                          '— ${plantsList[index].plantName}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Container(
                                            child: plantsList[index].isWatered
                                                ? Icon(
                                                    Icons.done,
                                                    color: darkGreenColor,
                                                    size: 20,
                                                  )
                                                : null),
                                      ],
                                    );
                                  }
                                  break;
                                case 'Thursday':
                                  if (plantsList[index].thursday == true) {
                                    print(
                                        'Its thursday and ${plantsList[index].plantName} wants to be watered');
                                    dashboardHasData = true;
                                    print(
                                        '${plantsList[index].plantName} is not watered yet');
                                    print(
                                        'DASHBOARD has data: $dashboardHasData');
                                    return Row(
                                      children: <Widget>[
                                        Text(
                                          '— ${plantsList[index].plantName}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Container(
                                            child: plantsList[index].isWatered
                                                ? Icon(
                                                    Icons.done,
                                                    color: darkGreenColor,
                                                    size: 20,
                                                  )
                                                : null),
                                      ],
                                    );
                                  }
                                  break;
                                case 'Friday':
                                  if (plantsList[index].friday == true) {
                                    print(
                                        'Its friday and ${plantsList[index].plantName} wants to be watered');
                                    dashboardHasData = true;
                                    print(
                                        '${plantsList[index].plantName} is not watered yet');
                                    print(
                                        'DASHBOARD has data: $dashboardHasData');

                                    return Row(
                                      children: <Widget>[
                                        Text(
                                          '— ${plantsList[index].plantName}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Container(
                                            child: plantsList[index].isWatered
                                                ? Icon(
                                                    Icons.done,
                                                    color: darkGreenColor,
                                                    size: 20,
                                                  )
                                                : null),
                                      ],
                                    );
                                  } else if (plantsList[index].friday ==
                                      false) {
                                    dashboardHasData = false;
                                  }
                                  break;
                                case 'Saturday':
                                  if (plantsList[index].saturday == true) {
                                    print(
                                        'Its saturday and ${plantsList[index].plantName} wants to be watered');
                                    dashboardHasData = true;
                                    print(
                                        '${plantsList[index].plantName} is not watered yet');
                                    print(
                                        'DASHBOARD has data: $dashboardHasData');
                                    return Row(
                                      children: <Widget>[
                                        Text(
                                          '— ${plantsList[index].plantName}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Container(
                                            child: plantsList[index].isWatered
                                                ? Icon(
                                                    Icons.done,
                                                    color: darkGreenColor,
                                                    size: 20,
                                                  )
                                                : null),
                                      ],
                                    );
                                  }
                                  break;
                                case 'Sunday':
                                  if (plantsList[index].sunday == true) {
                                    print(
                                        'Its sunday and ${plantsList[index].plantName} wants to be watered');
                                    dashboardHasData = true;
                                    print(
                                        '${plantsList[index].plantName} is not watered yet');
                                    print(
                                        'DASHBOARD has data: $dashboardHasData');
                                    return Row(
                                      children: <Widget>[
                                        Text(
                                          '— ${plantsList[index].plantName}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Container(
                                            child: plantsList[index].isWatered
                                                ? Icon(
                                                    Icons.done,
                                                    color: darkGreenColor,
                                                    size: 20,
                                                  )
                                                : null),
                                      ],
                                    );
                                  }
                                  break;
                              }

                              return Container();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (plantsList.length > 0) {
      print('plantsList is longer than 0');

      return Column(
        children: [
          _showDashboard(),
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
            flex: 2,
            child: Scrollbar(
              isAlwaysShown: false,
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: plantsList.length,
                itemBuilder: (BuildContext context, int index) {
                  // run functions before building the listview
                  //
                  // checking if its monday and the streak should be reseted
                  checkWeekday(index);
                  // checking wether goal was met and when user last watered the plant
                  checkStatus(index);

                  print('plantsList.lenght: ${plantsList.length}');
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
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return EditPlantScreen(
                                            plant: plantsList[index],
                                            id: plantsList[index].id,
                                            plantName:
                                                plantsList[index].plantName,
                                            plantType:
                                                plantsList[index].plantType,
                                            wateringFrequency: plantsList[index]
                                                .wateringFrequency,
                                            monday: plantsList[index].monday,
                                            tuesday: plantsList[index].tuesday,
                                            wednesday:
                                                plantsList[index].wednesday,
                                            thursday:
                                                plantsList[index].thursday,
                                            friday: plantsList[index].friday,
                                            saturday:
                                                plantsList[index].saturday,
                                            sunday: plantsList[index].sunday,
                                            isWatered:
                                                plantsList[index].isWatered,
                                            lastDayWatered: plantsList[index]
                                                .lastDayWatered,
                                            streak: plantsList[index].streak,
                                          );
                                        },
                                      ),
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
                                  onChanged: plantsList[index].streak ==
                                          plantsList[index].wateringFrequency
                                      ? null
                                      : (bool newValue) {
                                          setState(() {
                                            plantsList[index].isWatered =
                                                !plantsList[index].isWatered;
                                          });

                                          print(newValue);
                                          print(plantsList[index].isWatered);

                                          if (plantsList[index].isWatered ==
                                              false) {
                                            print('is watered is false');
                                            plantsList[index].streak--;
                                            plantsList[index].lastDayWatered =
                                                null;
                                            print(
                                                'Streak: ${plantsList[index].streak}');
                                          } else if (plantsList[index]
                                                  .isWatered ==
                                              true) {
                                            print('is watered is true');
                                            plantsList[index].streak++;

                                            plantsList[index].lastDayWatered =
                                                today;
                                            print(
                                                'streak: ${plantsList[index].streak}');
                                          }
                                          _updatePlant(
                                            plantsList[index].id,
                                            plantsList[index].plantName,
                                            plantsList[index].plantType,
                                            plantsList[index].wateringFrequency,
                                            plantsList[index].monday,
                                            plantsList[index].tuesday,
                                            plantsList[index].wednesday,
                                            plantsList[index].thursday,
                                            plantsList[index].friday,
                                            plantsList[index].saturday,
                                            plantsList[index].sunday,
                                            plantsList[index].isWatered,
                                            plantsList[index].lastDayWatered,
                                            plantsList[index].streak,
                                          );
                                          if (plantsList[index].streak ==
                                              plantsList[index]
                                                  .wateringFrequency) {
                                            showDialog(
                                              context: context,
                                              builder: (_) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  title:
                                                      Text('Congratulations!'),
                                                  content: Text(
                                                      'You\'ve met your weekly goal. Try to repeat it next week!'),
                                                );
                                              },
                                            );
                                          }
                                        },
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
          SizedBox(
            height: 60,
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
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
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
                SizedBox(
                  height: 10,
                ),
                FlatButton.icon(
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.delete_forever),
                  label: Text('Delete all my plants'),
                  onPressed: () {
                    if (plants.length > 0) {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Text('Are you sure?'),
                            content: Text('There is no turning back!'),
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
                                  db.deletePlants();
                                  setupList();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Text('Add plants!'),
                            content:
                                Text('You have no plants to delete, add some!'),
                          );
                        },
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkGreenColor,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Allow notifications',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 1,
                      child: Switch(
                        activeColor: darkGreenColor,
                        value: true,
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // delete plant
  void onDelete(int id) async {
    await db.removePlant(id);
    db.fetchAll().then((plantDb) => plants = plantDb);
    setState(() {});
  }

// setup list
  void setupList() async {
    var _plants = await db.fetchAll();

    setState(() {
      plants = _plants;
    });
  }

  // update plant
  Future<void> _updatePlant(
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
  }
}
