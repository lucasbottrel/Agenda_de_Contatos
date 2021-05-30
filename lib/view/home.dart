import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  static String tag = '/home';
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var nomeController = TextEditingController();
  var telefoneController = TextEditingController();
  var emailController = TextEditingController();
  var enderecoController = TextEditingController();
  var CEPController = TextEditingController();

  _recuperaCep() async {
    String cepDigitado = CEPController.text;
    var uri = Uri.parse("https://viacep.com.br/ws/${cepDigitado}/json/");
    http.Response response;
    response = await http.get(uri);
    Map<String, dynamic> retorno = json.decode(response.body);
    String logradouro = retorno["logradouro"];
    String complemento = retorno["complemento"];
    String bairro = retorno["bairro"];
    String localidade = retorno["localidade"];
    setState(() { //configurar o _resultado
      enderecoController.text = logradouro + "  " + bairro + "  " + localidade;
    });
    print("Logradouro: ${logradouro} "
        " complemento: ${complemento}"
        " bairro: ${bairro}"
        " localidade: ${localidade}");
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var snap = db.collection("contatos").where('excluido', isEqualTo: false).snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("AGENDA DE CONTATOS"),
      ),
      body: StreamBuilder(
        stream: snap,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, i) {
              var item = snapshot.data.docs[i];
              return Dismissible(
                key: Key(item.id),
                onDismissed: (direction) {
                  setState(() async {
                    await db.collection("contatos").doc(item.id).delete();
                  });
                },
                direction: DismissDirection.endToStart,
                background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    color: Colors.red,
                    child: Icon(Icons.delete, color: Colors.white)
                ),
                child: ListTile(
                  title: Text(item['nome']),
                  subtitle: Text(item['telefone']),
                  trailing: TextButton.icon(
                    icon: Icon(Icons.edit, size: 18),
                    label: Text(''),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Form(
                                  child: ListView(
                                    children: <Widget>[
                                      Text("Nome"),
                                      Container(
                                        height: 30,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          controller: nomeController,
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Text("Telefone"),
                                      Container(
                                        height: 30,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          controller: telefoneController,
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Text("E-mail"),
                                      Container(
                                        height: 30,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          controller: emailController,
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Text("Endereço"),
                                      Container(
                                        height: 30,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          controller: enderecoController,
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Text("CEP"),
                                      Container(
                                        height: 30,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: CEPController,
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                    ],
                                  )
                              ),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text("Cancelar"
                                    )
                                ),
                                TextButton(
                                    onPressed: () async {
                                      await db.collection("contatos").doc(
                                          item.id).update
                                        ({'nome': nomeController.text,
                                        'telefone': telefoneController.text,
                                        'email': emailController.text,
                                        'endereço': enderecoController.text,
                                        'CEP': CEPController.text,
                                        'concluido': false,
                                        'excluido': false});
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Salvar"
                                    )
                                ),
                              ],
                            );
                          }
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Form(
                      child: ListView(
                        children: <Widget>[
                          Text("Nome"),
                          Container(
                            height: 30,
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              controller: nomeController,
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text("Telefone"),
                          Container(
                            height: 30,
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              controller: telefoneController,
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text("E-mail"),
                          Container(
                            height: 30,
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              controller: emailController,
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text("CEP"),
                          Container(
                            height: 30,
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              controller: CEPController,
                            ),
                          ),
                          TextButton(
                            onPressed: _recuperaCep,
                            child: Text("CONSULTAR"),
                          ),
                          Text("Endereço"),
                          Container(
                            height: 30,
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              controller: enderecoController,
                            ),
                          ),
                        ],
                      )
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancelar"
                        )
                    ),
                    TextButton(
                        onPressed: () async {
                          await db.collection("contatos").
                          add({'nome': nomeController.text,
                            'telefone': telefoneController.text,
                            'email': emailController.text,
                            'endereço': enderecoController.text,
                            'CEP': CEPController.text,
                            'concluido': false,
                            'excluido': false});
                          Navigator.of(context).pop();
                        },
                        child: Text("Salvar"
                        )
                    ),
                  ],
                );
              }
          );
        },
        tooltip: "Adicionar novo",
        child: Icon(Icons.add),
      ),
    );
  } // build
}