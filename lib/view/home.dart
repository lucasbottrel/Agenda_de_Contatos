import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatelessWidget {
  static String tag = '/home';
  @override
  Widget build(BuildContext context) {
    var tituloController = TextEditingController();
    var descricaoController = TextEditingController();
    FirebaseFirestore db = FirebaseFirestore.instance;
    var snap = db.collection("contatos").
    where('excluido', isEqualTo: false).
    snapshots();
    return Scaffold(
      appBar: AppBar(
        title: Text("AGENDA DE CONTATOS"),
      ),
      body: StreamBuilder(
        stream: snap,
        builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot
            ) {
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, i){
                var item = snapshot.data.docs[i];
                return ListTile(
                  title: Text(item['nome']),
                  subtitle: Text(item['telefone']),
                );
              },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  content: Form(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Nome"),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: "digite o nome",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            controller: tituloController,
                          ),
                          SizedBox(height: 20,),
                          Text("Telefone"),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: "digite o telefone",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            controller: descricaoController,
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
                          add({'nome': tituloController.text,
                            'telefone': descricaoController.text,
                            'concluido': false,
                            'excluido': false} );
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
  }
}