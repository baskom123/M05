import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:pertemuan5/Movies.dart';


class DetailScreen extends StatelessWidget {
  final Movie movie;
  final String imgPath = 'https://image.tmdb.org/t/p/w500/';
  const DetailScreen(this.movie, {Key? key}) : super(key: key);

  Future<String> loadImage() async {
    await Future.delayed(Duration(seconds: 3)); // simulate delay
    if (movie.posterPath != null) {
      return imgPath + movie.posterPath;
    } else {
      return 'https://images.freeimages.com/images/large-previews/5eb/movie-clapboard-1184339.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16),
                child: FutureBuilder<String>(
                  future: loadImage(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else {
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      else
                        return Image.network(
                          snapshot.data!,
                          height: 300,
                        ); // image is loaded
                    }
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Text(movie.overview),
              ),
            ],
          ),
        ),
      ),
    );
  }
}