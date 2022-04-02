import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:practica_04_detalle_pelicula/src/database/database_helper.dart';
import 'package:practica_04_detalle_pelicula/src/models/actors_movies_model.dart';
import 'package:practica_04_detalle_pelicula/src/models/favorite_movies_model.dart';
import 'package:practica_04_detalle_pelicula/src/models/trailer_movie_model.dart';
import 'package:practica_04_detalle_pelicula/src/network/api_popular.dart';
import 'package:practica_04_detalle_pelicula/src/utils/colors_palette.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class DetailScreen extends StatefulWidget {
  DetailScreen({Key? key}) : super(key: key);
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {

  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
  final apiPopular = ApiPopular();
  final movie = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  final title = movie['title'];
  final id = movie['id'];
  final overview = movie['overview'];
  final posterpath = movie['posterpath'];

    return Scaffold(
      appBar: AppBar(
        foregroundColor: ColorPalette.colorBlack,
        title: Text('$title',
          style: TextStyle(
            color: ColorPalette.colorBlack
          )),
        backgroundColor: ColorPalette.colorPrimary,
        actions: [
          buttonFavorite(id, title, posterpath, _databaseHelper)
        ]
      ),
      body: Container(
        color: ColorPalette.colorMovie_bg,
        child: ListView(
          padding: EdgeInsets.only(left: 5, right: 5, bottom: 10, top: 3),
          children: [
            posterMovie(id, posterpath),
            SizedBox(height: 5),
            overviewMovie(id, overview),
            SizedBox(height: 8),
            SizedBox(
              height: 200.0,
              child: getActors(id, apiPopular),
            ),
            SizedBox(height: 10),
            SizedBox(
              child: getTrailer(id, apiPopular)
            )
          ]
        ),
      )
    );
  }

  Widget buttonFavorite(int id, String title, String posterpath, DatabaseHelper db)
  {
    return FutureBuilder(
      future: db.checkFavorite(id) ,
      builder: (BuildContext contex, AsyncSnapshot<bool> snapshot ) {
        if(snapshot.hasError){
          return Center(
            child: Text('Hay un error en la petición'),
          );
        }
        else {
          if(snapshot.connectionState == ConnectionState.done){
            return IconButton(
              icon: snapshot.data!
              ? Icon(
                  Icons.favorite,
                  color: ColorPalette.colorFruitAppElement,
                )
              : Icon(
                  Icons.favorite_border,
                  color: ColorPalette.colorFruitAppElement,
              ), 
              onPressed: () {
                setState(() {
                  if (snapshot.data!)
                  {
                    db.delete(id);
                  }
                  else
                  {
                    FavoriteModel favoriteElement = FavoriteModel(
                      id: id,
                      title: title,
                      posterpath: posterpath,
                    );

                    db.insert(favoriteElement.toMap());
                  }
                });
              },
            );
          }
          else{
            return CircularProgressIndicator();
          }
        }
      }
    );
  }

  Widget posterMovie(int id, String poster) {
    return Card(     
      child: Container(                                                                 
        child: Hero(
          tag: '$id',
          child: FadeInImage(
            placeholder: AssetImage('assets/images/activity_indicator.gif'),
            image: NetworkImage("https://image.tmdb.org/t/p/w500/$poster"),
            fadeInDuration: Duration(milliseconds: 200),
          )
        ),
      ),
    );  
  }

  Widget overviewMovie(int id, String overview)
  {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: ColorPalette.colorPrimary,
        borderRadius: BorderRadius.circular(3),
        border: Border.all( color:  ColorPalette.colorBlack),
      ),
      child: Column(              
        children: [
          Text('Descripción',
            style: TextStyle(
              color: ColorPalette.colorBlack,
              fontSize: 20)),
          Divider(color: ColorPalette.colorBlack,),
          Text(
            overview, 
            style: TextStyle(color: ColorPalette.colorFont),
            textAlign: TextAlign.justify,)
        ],
      )
    );
  }

  Widget getActors(int id, ApiPopular API)
  {
    return FutureBuilder(
      future: API.getActors(id) ,
      builder: (BuildContext contex, AsyncSnapshot<dynamic> snapshot ) {
        if(snapshot.hasError){
          return Center(
            child: Text('Hay un error en la petición'),
          );
        }
        else {
          if(snapshot.connectionState == ConnectionState.done){
            return listActors(snapshot.data);
          }
          else{
            return CircularProgressIndicator();
          }
        }
      }
    );
  }

  Widget listActors(List<ActorsMoviesModel> listActors){
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: listActors.length,
      itemBuilder: (context, index,){
      ActorsMoviesModel actors = listActors[index];
      return WidgetActorMovie(actors);
    });
  }

  Widget WidgetActorMovie(ActorsMoviesModel actor) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: ColorPalette.colorPrimary,
        borderRadius: BorderRadius.circular(5),
        border: Border.all( color:  ColorPalette.colorBlack),
      ),                            
      margin: EdgeInsets.all(4),      
      child: Column(   
        mainAxisAlignment: MainAxisAlignment.spaceAround,     
          children: [                           
            CircleAvatar(
              radius: 40,
              backgroundImage: actor.photo == '' ? NetworkImage('https://cdn-icons-png.flaticon.com/512/3409/3409455.png')  : NetworkImage('https://image.tmdb.org/t/p/w300/${actor.photo}'),                
            ),
            Text(                                
              actor.name!,
              textAlign: TextAlign.center,
              style: TextStyle(color: ColorPalette.colorFont, fontSize: 16),
            )
          ],
        )
    );
  }

  Widget getTrailer(int id, ApiPopular API)
  {
    // Variable para el video del trailer, filtrado por type = "Trailer"
    var ListTrailers = TrailerMovieModel();

    return FutureBuilder(
      future: API.getTrailer("https://api.themoviedb.org/3/movie/$id/videos?api_key=91a52cf1dd78065ff1fdf9c6c0d9194c&language=en-US"),
      builder: (BuildContext context, AsyncSnapshot<List<TrailerMovieModel>?> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Hay un error en la petición")
          );
        }
        else {
          if (snapshot.connectionState == ConnectionState.done) {
            snapshot.data!.forEach((trailer) {
              ListTrailers = trailer;
            });
            return WidgetTrailerMovie(context, ListTrailers);
          }
          else {
            return CircularProgressIndicator();
          }
        }
      }
    );
  }

  Widget WidgetTrailerMovie(BuildContext context, TrailerMovieModel trailer) {
    return YoutubePlayer(
      aspectRatio: 16 / 9,
      controller: YoutubePlayerController(
        initialVideoId: trailer.key.toString(),
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          forceHD: true
        )
      ),      
      showVideoProgressIndicator: true,
      progressIndicatorColor: ColorPalette.colorPrimary,
      progressColors: ProgressBarColors(
        playedColor: ColorPalette.colorMovie_001,
        handleColor: ColorPalette.colorMovie_002
      ),
      onReady: () {
        print('Player is Ready');
      },      
    );
  }
}