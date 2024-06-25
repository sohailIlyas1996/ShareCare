import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart'; // Import the Lottie package
import '../screens/home.dart'; 
import '../screens//signup.dart';
// Import your home screen file

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  Future<void> navigateToNextScreen() async {
    // Add a delay for a splash effect
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if the user is already logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is already logged in, navigate to the home screen
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      // User is not logged in, navigate to the sign-up screen
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) =>  CustomForm()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/anim.json', // Replace 'your_animation.json' with the path to your animation file
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
