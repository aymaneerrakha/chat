import 'package:flutter/material.dart';
import 'package:flutter_application_err/forgotpassword.dart';
import 'package:flutter_application_err/home.dart';
//import 'package:myproject/home.dart';
import 'package:flutter_application_err/signup.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  //access and lié application to firebase
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: const FirebaseOptions(
     apiKey: 'AIzaSyA9h72GuE8DRdUPc-alEh1sbAIjo7X8Az0',
     appId: '1:584730029649:android:4a22f11d03a0b6805b1270', 
     messagingSenderId: '584730029649', 
     projectId: 'demo1-27d4c')
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chatgpt',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
        routes: {
          'signin': (context) => const LoginPage(),
          'signup': (context) => const SignupPage(),
          'forgotpassword': (context) => const ForgotPassword(),

        });
  }
}
