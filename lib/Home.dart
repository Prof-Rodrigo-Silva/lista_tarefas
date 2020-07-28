import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaTarefa = [];
  TextEditingController _controllerTarefa = TextEditingController();
  Map<String,dynamic> _ultimaTarefaRemovida = Map();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa(){
    String textoDigitado = _controllerTarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;
    setState(() {
      _listaTarefa.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.text="";

  }

  _salvarArquivo() async {

    var arquivo = await _getFile();

    String dados = json.encode(_listaTarefa);
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try{
      final arquivo = await _getFile();
      return arquivo.readAsString();

    }catch(e){
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lerArquivo().then((dados){
      setState(() {
        _listaTarefa = json.decode(dados);

      });
    });
  }

 Widget criarItemLista(context,index){
    
    //final item = _listaTarefa[index]['titulo'];
    
   return Dismissible(
       key: Key( DateTime.now().millisecondsSinceEpoch.toString()),
       direction: DismissDirection.endToStart,
       onDismissed: (direction){

         _ultimaTarefaRemovida = _listaTarefa[index];

         _listaTarefa.removeAt(index);
         _salvarArquivo();
         //Snackbar
         final snackbar = SnackBar(
           //backgroundColor: Colors.green,
             duration: Duration(seconds: 5),
             content: Text("Tarefa Removida!!"),
           action: SnackBarAction(
               label: "Desfazer",
               onPressed: (){
                 setState(() {
                   _listaTarefa.insert(index, _ultimaTarefaRemovida);
                 });
                 _salvarArquivo();

               }),
         );

         Scaffold.of(context).showSnackBar(snackbar);
       },
       background: Container(
         color: Colors.red,
         padding: EdgeInsets.all(16),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.end,
           children: <Widget>[
             Icon(
               Icons.delete,
               color: Colors.white,
             )
           ],
         ),
       ),
       child: CheckboxListTile(
         title: Text(_listaTarefa[index]['titulo']),
         value: _listaTarefa[index]['realizada'],
         onChanged: (valorAlterado){
           setState(() {
             _listaTarefa[index]['realizada'] = valorAlterado;
           });
           _salvarArquivo();
         },
       )/*ListTile(
                    title: Text(_listaTarefa[index]["titulo"]),
                  );*/);
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista de Tarefas"),
      backgroundColor: Colors.purple,),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        //floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          elevation: 6,
          /*icon: Icon(Icons.add_shopping_cart),
        label: Text("Adicionar"),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        ),
        mini: true,*/
          child: Icon(Icons.add),
          onPressed: (){
            showDialog(
                context: context,
            builder: (context){
              return AlertDialog(
                title: Text("Adicionar Tarefa"),
                content: TextField(
                  controller: _controllerTarefa,
                  decoration: InputDecoration(
                    labelText: "Digite sua Tarefa"
                  ),
                  onChanged: (Text){

                  },
                ),
                actions: <Widget>[
                  FlatButton(onPressed: () => Navigator.pop(context),
                      child: Text("Cancelar")),
                  FlatButton(onPressed: (){
                    _salvarTarefa();
                    Navigator.pop(context);
                  },
                      child: Text("Salvar"))
                ],
              );
            }
            );
          }
      ),
      /*bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: (){},
              icon: Icon(Icons.add),
            )
          ],
        ),
      ),*/
      body: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                itemCount: _listaTarefa.length,
                itemBuilder: criarItemLista
              )
          )
        ],
      ),
    );
  }
}
