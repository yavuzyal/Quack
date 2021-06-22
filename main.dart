import 'package:cs308_project/screens/ForgotPasswordScreen.dart';
import 'package:cs308_project/screens/RegisterScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cs308_project/screens/MainTemplate.dart';
import 'package:cs308_project/screens/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //FirebaseMessaging messaging = FirebaseMessaging.instance;

  //String token = await messaging.getToken();
  //print('Notification token is $token');

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Template(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/forgotPassword': (context) => ForgotPasswordScreen(),
      }));
}



