import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class Home extends StatefulWidget {
  static String tag = '/home';
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var nomeController = TextEditingController();
  var telefoneController = TextEditingController();
  var emailController = TextEditingController();
  var logradouroController = TextEditingController();
  var complementoController = TextEditingController();
  var bairroController = TextEditingController();
  var localidadeController = TextEditingController();
  var CEPController = TextEditingController();
  var aniversarioController = TextEditingController();
  DateTime _dateTime;

  _recuperaCep() async {
    String cepDigitado = CEPController.text;
    var uri = Uri.parse("https://viacep.com.br/ws/${cepDigitado}/json/");
    http.Response response;
    response = await http.get(uri);
    Map<String, dynamic> retorno = json.decode(response.body);
    logradouroController.text = retorno["logradouro"];
    complementoController.text = retorno["complemento"];
    bairroController.text = retorno["bairro"];
    localidadeController.text = retorno["localidade"];
  }

  _limparControllers(){
    nomeController.text = "";
    telefoneController.text = "";
    emailController.text = "";
    logradouroController.text = "";
    complementoController.text = "";
    bairroController.text = "";
    localidadeController.text = "";
    CEPController.text = "";
    aniversarioController.text="";
  }

  _recuperaValores(String nome, String telefone, String email, String logradouro, String complemento, String bairro, String localidade, String CEP, String aniversario){
    //print(aniversario);
    nomeController.text = nome;
    telefoneController.text = telefone;
    emailController.text = email;
    logradouroController.text = logradouro;
    complementoController.text = complemento;
    bairroController.text = bairro;
    localidadeController.text = localidade;
    CEPController.text = CEP;
    aniversarioController.text = aniversario;
  }

  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  List<UploadTask> uploadedTasks = List();
  List<File> selectedFiles = List();
  String imagem='assets/profile.jpg';

  uploadFileToStorage(File file) {
    UploadTask task = _firebaseStorage
        .ref()
        .child("images/${DateTime.now().toString()}")
        .putFile(file);
    return task;
  }

  writeImageUrlToFireStore(imageUrl) {
    db.collection("images").add({"url": imageUrl}).whenComplete(
            () => print("$imageUrl is saved in Firestore"));
  }

  saveImageUrlToFirebase(UploadTask task) {
    task.snapshotEvents.listen((snapShot) {
      if (snapShot.state == TaskState.success) {
        snapShot.ref
            .getDownloadURL()
            .then((imageUrl) => writeImageUrlToFireStore(imageUrl));
      }
    });
  }

  Future<String> selectFileToUpload() async {
    try {
      FilePickerResult result = await FilePicker.platform
          .pickFiles(allowMultiple: true, type: FileType.image);

      if (result != null) {
        selectedFiles.clear();

        result.files.forEach((selectedFile) {
          File file = File(selectedFile.path);
          selectedFiles.add(file);
        });

        selectedFiles.forEach((file) {
          final UploadTask task = uploadFileToStorage(file);
          saveImageUrlToFirebase(task);

          setState(() {
            uploadedTasks.add(task);
          });
        });
      } else {
        print("User has cancelled the selection");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var snap = db.collection("contatos").snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("AGENDA DE CONTATOS"),
      ),
      body: StreamBuilder(
        stream: snap,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  leading: CircleAvatar(
                  foregroundImage: AssetImage(imagem),
                  ),
                  trailing: TextButton.icon(
                    icon: Icon(Icons.edit, size: 18),
                    label: Text(''),
                    onPressed: () {
                      _recuperaValores(
                        item['nome'],
                        item['telefone'],
                        item['email'],
                        item['logradouro'],
                        item['complemento'],
                        item['bairro'],
                        item['localidade'],
                        item['CEP'],
                        item['aniversario']
                      );
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Form(
                                  child: ListView(
                                    children: <Widget>[
                                      Image.asset(imagem, height: 100, width: 100,),
                                      TextButton(
                                          onPressed: () {
                                            selectFileToUpload();
                                          },
                                          child: Text("upload image", style: TextStyle(fontSize: 10))),
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
                                      Text("Data de Nascimento"),
                                      Container(
                                        height: 30,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          controller: aniversarioController,
                                          onTap: () {
                                            showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime(2222)
                                            ).then((date) {
                                              setState(() {
                                                  aniversarioController.text = DateFormat('dd/MM/yyyy').format(date);
                                              });
                                            });
                                          }),
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
                                      TextButton(
                                        onPressed: _recuperaCep,
                                        child: Text("CONSULTAR"),
                                      ),
                                      SizedBox(height: 10,),
                                      Text("Logradouro"),
                                      Container(
                                        height: 30,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          controller: logradouroController,
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Text("Complemento"),
                                      Container(
                                        height: 30,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          controller: complementoController,
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Text("Bairro"),
                                      Container(
                                        height: 30,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          controller: bairroController,
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Text("Localidade"),
                                      Container(
                                        height: 30,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          controller: localidadeController,
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
                                      await db.collection("contatos").doc(item.id).update
                                        ({'nome': nomeController.text,
                                        'telefone': telefoneController.text,
                                        'email': emailController.text,
                                        'logradouro': logradouroController.text,
                                        'complemento': complementoController.text,
                                        'bairro': bairroController.text,
                                        'localidade': localidadeController.text,
                                        'CEP': CEPController.text,
                                        'aniversario': aniversarioController.text,
                                        });
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
          _limparControllers();
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Form(
                      child: ListView(
                        children: <Widget>[
                          Image.asset(imagem, height: 100, width: 100),
                          TextButton(
                              onPressed: () {
                                selectFileToUpload();
                              },
                              child: Text("upload image", style: TextStyle(fontSize: 10))),
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
                          Text("Data de Nascimento"),
                          Container(
                            height: 30,
                            child: TextFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius
                                        .circular(15),
                                  ),
                                ),
                                controller: aniversarioController,
                                onTap: () {
                                  showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2222)
                                  ).then((date) {
                                    setState(() {
                                      aniversarioController.text = DateFormat('dd/MM/yyyy').format(date);
                                    });
                                  });
                                }),
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
                          SizedBox(height: 10,),
                          Text("Logradouro"),
                          Container(
                            height: 30,
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius
                                      .circular(15),
                                ),
                              ),
                              controller: logradouroController,
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text("Complemento"),
                          Container(
                            height: 30,
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius
                                      .circular(15),
                                ),
                              ),
                              controller: complementoController,
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text("Bairro"),
                          Container(
                            height: 30,
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius
                                      .circular(15),
                                ),
                              ),
                              controller: bairroController,
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text("Localidade"),
                          Container(
                            height: 30,
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius
                                      .circular(15),
                                ),
                              ),
                              controller: localidadeController,
                            ),
                          ),
                          SizedBox(height: 10,),
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
                            'logradouro': logradouroController.text,
                            'complemento':complementoController.text,
                            'bairro':bairroController.text,
                            'localidade':localidadeController.text,
                            'CEP': CEPController.text,
                            'aniversario': aniversarioController.text,
                            });
                          Navigator.of(context).pop();
                          _limparControllers();
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