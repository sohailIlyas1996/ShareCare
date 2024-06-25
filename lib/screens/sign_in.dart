import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/home.dart';
import '../screens/signup.dart'; // Import your sign-up screen file

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  bool isLoading = false;
  Color emailBorderColor = Colors.grey; // Define default border color for email
  Color passwordBorderColor = Colors.grey; // Define default border color for password

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // User successfully logged in, navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      print(userCredential);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      }

      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Error'),
            content: Text(errorMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomForm()), // Replace CustomForm with your sign-up screen widget
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              focusNode: emailFocusNode,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: emailBorderColor), // Use email border color
                  borderRadius:const  BorderRadius.all(Radius.circular(10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: emailBorderColor), // Use email border color
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor), // Change to theme color when focused
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
              ),
              controller: emailController,
              onTap: () {
                setState(() {
                  emailBorderColor = Theme.of(context).primaryColor; // Update email border color when clicked
                  passwordBorderColor = Colors.grey; // Reset password border color
                  emailFocusNode.requestFocus();
                });
              },
              onEditingComplete: () {
                setState(() {
                  emailBorderColor = Colors.grey; // Reset email border color when focus is lost
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              focusNode: passwordFocusNode,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: passwordBorderColor), // Use password border color
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: passwordBorderColor), // Use password border color
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor), // Change to theme color when focused
                  borderRadius:const  BorderRadius.all(Radius.circular(10)),
                ),
              ),
              controller: passwordController,
              obscureText: true,
              onTap: () {
                setState(() {
                  passwordBorderColor = Theme.of(context).primaryColor; // Update password border color when clicked
                  emailBorderColor = Colors.grey; // Reset email border color
                  passwordFocusNode.requestFocus();
                });
              },
              onEditingComplete: () {
                setState(() {
                  passwordBorderColor = Colors.grey; // Reset password border color when focus is lost
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () {
                      signInWithEmailAndPassword(context);
                    },
              icon: const Icon(color: Colors.green, Icons.login_outlined),
              label:const Text('Login', style: TextStyle(color: Colors.green)),
            ),
            if (isLoading) const CircularProgressIndicator(),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                navigateToSignUp(context);
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
