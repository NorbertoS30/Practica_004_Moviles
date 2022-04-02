import 'package:flutter/material.dart';
import 'package:practica_04_detalle_pelicula/src/models/popular_movies_model.dart';
import 'package:practica_04_detalle_pelicula/src/network/api_popular.dart';
import 'package:practica_04_detalle_pelicula/src/utils/colors_palette.dart';
import 'package:practica_04_detalle_pelicula/src/widgets/card_popular.dart';

class PopularScreen extends StatefulWidget {
  PopularScreen({Key? key}) : super(key: key);

  @override
  _PopularScreenState createState() => _PopularScreenState();
}

class _PopularScreenState extends State<PopularScreen> {
  
  ApiPopular? apiPopular;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiPopular = ApiPopular();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: ColorPalette.colorBlack,
        title: Text("Movies List"),
        backgroundColor: ColorPalette.colorPrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/listFavorites').whenComplete(
                () { setState(() {}); }
              );
            }, 
            icon: Icon(Icons.list_alt_rounded)
          )
        ]
      ),
      body: Container(
        color: ColorPalette.colorMovie_bg,
        child: FutureBuilder(
          future: apiPopular!.getAllPopular(),
          builder: (BuildContext context, AsyncSnapshot<List<PopularMoviesModel>?> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Hay un error en la petición")
              );
            }
            else {
              if (snapshot.connectionState == ConnectionState.done) {
                return _listPopularMovies(snapshot.data);
              }
              else {
                return CircularProgressIndicator();
              }
            }
          }
        ),
      ),
    );
  }

  Widget _listPopularMovies(List<PopularMoviesModel>? movies) {
    return ListView.separated(
      itemBuilder: (context, index) {
        PopularMoviesModel popular = movies![index];
        return CardPopularView(popular: popular);
      }, 
      separatorBuilder: (_, __) => Divider(height: 10), 
      itemCount: movies!.length
    );
  }
}