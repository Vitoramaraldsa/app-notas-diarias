import 'package:app_notas_diarias/model/Anotacao.dart';
import 'package:flutter/material.dart';

import 'helper/AnotacaoHelper.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  List<Anotacao> listaAnotacoes = [];
  String textoSalvarAtualizar = "";

  var _db = AnotacaoHelper();

  _exibirTelaCadastro({Anotacao ?anotacao}) async {

    if (anotacao == null) {
      //salvando
      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizar = "Salvar";
    } else {
      //atualizando
      _tituloController.text = anotacao.titulo!;
      _descricaoController.text = anotacao.descricao!;
      textoSalvarAtualizar = "Atualizar";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("${textoSalvarAtualizar} anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Titulo", hintText: "Digite o título..."),
                ),
                TextField(
                  controller: _descricaoController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Descrição",
                      hintText: "Digite a descrição..."),
                )
              ],
            ),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")),
              FlatButton(
                  //implementação para salvar
                  onPressed: () {
                    setState(() {
                      _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                      _recuperarAnotacoes();
                    });
                    Navigator.pop(context);
                  },
                  child: Text(textoSalvarAtualizar)),
            ],
          );
        });
  }

  _salvarAtualizarAnotacao({Anotacao ?anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if(anotacaoSelecionada == null){//salvar
      Anotacao objAnotacao = Anotacao(titulo, descricao, DateTime.now().toString());
      int? resultado = await _db.salvarAnotacao(objAnotacao);
      _tituloController.clear();
      _descricaoController.clear();
    }else{//atualizar
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      int? resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
      _tituloController.clear();
      _descricaoController.clear();
    }
  }

  _removerAnotacao(int ?id) async{
   await _db.removerAnotacao(id!);
   _recuperarAnotacoes();
  }

  _recuperarAnotacoes() async {
    List<Anotacao> listaTemporaria = [];
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();
    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.getMap(item);
      listaTemporaria.add(anotacao);
    }
    setState(() {
      listaAnotacoes = listaTemporaria;
    });
  }

  /*
  _formatarData(String data) {
    var dataTime = DateTime.parse(data);
    var dataFinal = DateUtils.dateOnly(dataTime);
    return "${dataFinal.day}/${dataFinal.month}/${dataFinal.year}";
  }*/

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas anotações"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: listaAnotacoes.length,
            itemBuilder: (context, index) {
              final anotacaodata = listaAnotacoes[index];
              return Card(
                child: ListTile(
                    title: Text("${anotacaodata.titulo}",
                        style: TextStyle(fontSize: 20)),
                    subtitle: Text(
                        "${anotacaodata.data.toString()} - ${anotacaodata.descricao}",
                        style: TextStyle(fontSize: 16)),
                    trailing: Container(
                      height: 50,
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _exibirTelaCadastro(anotacao: anotacaodata);
                              setState(() {

                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _removerAnotacao(anotacaodata.id);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
              );
            },
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () {
          _exibirTelaCadastro();
        },
      ),
    );
  }
}
