//import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:practica_04_detalle_pelicula/src/models/favorite_movies_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  
  static final _nombreBD = "MOVIES-1";
  static final _versionBD = 1;
  static final _nombreTBLMovies = "tblMovies";

  bool? isFavorited;


  static Database? _database;

  Future<Database?> get  database async{
    if(_database != null)
      return _database;

    _database = await _initDatabase();
    return _database;
  }

  Future<Database?> _initDatabase() async {
    Directory carpeta = await getApplicationDocumentsDirectory();
    String rutaBD = join(carpeta.path, _nombreBD);
    
    return openDatabase(
      rutaBD, 
      version: _versionBD,
      onCreate: _crearTabla
    );
  }

  Future<void> _crearTabla(Database db, int version) async {
    await db.execute("CREATE TABLE $_nombreTBLMovies (id INTEGER PRIMARY KEY, title TEXT, posterpath TEXT)");
  }

  //CRUD de Movies
  Future<int> insert(Map<String, dynamic> row) async {
    var conexion = await database;
    return conexion!.insert(_nombreTBLMovies, row);
  }

  Future<int> update(Map<String, dynamic> row) async {
    var conexion = await database;
    return conexion!.update(_nombreTBLMovies, row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> delete(int id) async {
    var conexion = await database;
    return await conexion!.delete(_nombreTBLMovies, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<FavoriteModel>> getAllFavititesMovies() async {
    var conexion = await database;
    var result = await conexion!.query(_nombreTBLMovies);
    return  result.map((moviesMap) => FavoriteModel.fromMap(moviesMap)).toList();
  }

  Future<bool> checkFavorite(int id) async {
    var conexion = await database;
    var result = await conexion!.rawQuery(
      'SELECT id FROM $_nombreTBLMovies WHERE id = $id');
    if(result.isEmpty){
      return false;
    }
    else {
      return true;
    } 
    
  }
}