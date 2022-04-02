

import 'package:flutter/material.dart';
import 'package:practica_04_detalle_pelicula/src/database/database_helper.dart';
import 'package:practica_04_detalle_pelicula/src/models/favorite_movies_model.dart';
import 'package:practica_04_detalle_pelicula/src/utils/colors_palette.dart';

class FavoriteScreen extends StatefulWidget {
  FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {

  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: ColorPalette.colorBlack,
        backgroundColor: ColorPalette.colorPrimary,
        title: Text("List of favorite movies "),
      ),
      body: Container(
        color: ColorPalette.colorMovie_bg,
        child: FutureBuilder(
          future: _databaseHelper.getAllFavititesMovies(),
          builder: (BuildContext context, AsyncSnapshot<List<FavoriteModel>> snapshot) {
            if(snapshot.hasError) {
              return Center(
                child: Text("Hubo un Error :C"),
              );
            }
            else {
              if(snapshot.connectionState == ConnectionState.done) {
                return _listFavoritesMovies(snapshot.data!);
              }
              else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Widget _listFavoritesMovies(List<FavoriteModel> favoritesMovies) {
    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
          Duration(seconds: 2),
          () {
            //Refresh with setState
            setState(() {});
          }
        );
      },
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          FavoriteModel movie = favoritesMovies[index];
          return Padding(
            padding: EdgeInsets.only(right: 50, left: 50, top: 10, bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87,
                    offset: Offset(0.0, 5.0),
                    blurRadius: 2.5
                  )
                ]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      child: FadeInImage(
                        placeholder: AssetImage('assets/images/activity_indicator.gif'),
                        image: NetworkImage("https://image.tmdb.org/t/p/w500/${movie.posterpath}"),
                        fadeInDuration: Duration(milliseconds: 200),
                      )
                    ),
                    Opacity(
                      opacity: 0.5,
                      child: Container(
                        padding: EdgeInsets.only(left: 15.0),
                        height: 60.0,
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              movie.title,
                              style: TextStyle(color: Colors.white, fontSize: 20.0),
                            ),
                            MaterialButton(
                              onPressed: () {
                                setState(() {
                                  _databaseHelper.delete(movie.id);
                                });
                              },
                              child: Icon(Icons.delete, color: Colors.white,),
                            )
                          ],
                        ),
                      ),
                    )
                  ]
                ),
              )
            ),
          );
        },
        itemCount: favoritesMovies.length,
      ),
    );
  }
}