import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/Anotacao.dart';

class AnotacaoHelper{

  static final String nomeTabela = "anotacao";
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database ?_db;

  factory AnotacaoHelper(){
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal(){

  }

  get db async{
    if(_db != null){
      return _db;
    }else{
      _db = await inicializarDb();
      return _db;
    }
  }

  inicializarDb() async{
    final pathDb = await getDatabasesPath();
    final localDb = join(pathDb, "banco_minhas_anotacoes.db");
    var db = await openDatabase(localDb,version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int?> salvarAnotacao(Anotacao anotacao) async{
    var bancoDados = await db;
    int resultado = await bancoDados.insert(nomeTabela, anotacao.getMap());
    return resultado;
  }

  Future<int?> atualizarAnotacao(Anotacao anotacao) async{
    var bancoDados = await db;
    await bancoDados.update(
      nomeTabela,
      anotacao.getMap(),
      where: "id = ?",
      whereArgs: [anotacao.id]
    );
  }

  Future<int?> removerAnotacao(int id) async{
    var bancoDados = await db;
    return await bancoDados.delete(
      nomeTabela,
      where:"id = ?",
      whereArgs: [id]
    );
  }
  recuperarAnotacoes() async{
    var bancoDados = await db;
    String sql = "SELECT * FROM $nomeTabela ORDER BY data DESC";
    List anotacoes = await bancoDados.rawQuery(sql);
    return anotacoes;
  }

  _onCreate(Database db, version) async {
    String sql = "CREATE TABLE $nomeTabela"
        "("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "titulo VARCHAR,"
        "descricao TEXT,"
        "data DATETIME"
        ")";
    await db.execute(sql);
  }

}

