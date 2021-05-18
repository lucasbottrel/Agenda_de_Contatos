import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:agenda_de_contatos/view/home.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //FirebaseFirestore.instance.collection("tarefa").doc("2").set({"titulo": "fazer comida", "descricao": " todos os dias", "concluido": "false", "excluido":"false"});
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //_buscaDados();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: Home.tag,
      routes: {
        Home.tag: (context) => Home()
      },
    );
  }
}