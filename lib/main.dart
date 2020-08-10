import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_plant_app/constants.dart';
import 'package:sqlite_plant_app/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) exit(1);
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Good sprout',
      home: HomeScreen(),
      theme: ThemeData(
        textTheme: TextTheme(
          headline1: TextStyle(
            color: Colors.white,
            fontSize: 44,
            fontFamily: primaryFont,
            fontWeight: FontWeight.bold,
          ),
          headline3: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: primaryFont,
          ),
          headline4: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.normal,
            fontFamily: primaryFont,
          ),
          headline5: TextStyle(
            color: darkGreenColor,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            fontFamily: primaryFont,
          ),
          bodyText1: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: primaryFont,
          ),
          bodyText2: TextStyle(
              color: darkGreenColor,
              fontSize: 16.5,
              fontFamily: primaryFont,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
