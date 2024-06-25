import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'package:share_care/screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use platform-specific options
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Share Care',
      theme: ThemeData(
        primarySwatch: Colors.green,
        iconTheme: const IconThemeData(
          color: Colors.green, // Set the icon color to match the theme
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.green), // Customize focused border color
          ),
          labelStyle: TextStyle(
            color: Colors.black, // Set label color to match the theme
          ),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.black, // Set the button color to match the theme
          textTheme: ButtonTextTheme.primary, // Use primary color for button text
        ),
        // Define other theme settings here
        // fontFamily: 'Roboto',
        // textTheme: TextTheme(
        //   bodyText1: TextStyle(fontSize: 16.0),
        //   headline6: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        // ),
      ),
      home: SplashScreen(),
    );
  }
}
