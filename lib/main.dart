import 'package:agenda_de_contatos/view/login.dart';
import 'package:agenda_de_contatos/view/signUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:agenda_de_contatos/view/home.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}  // main

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: login.tag,
      routes: {
        Home.tag: (context) => Home(),
        login.tag: (context) => login(),
        signUp.tag: (context) => signUp()
      },  // routes
    );
  }  // build
}  // MyApp