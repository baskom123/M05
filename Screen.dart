import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pertemuan5/DetailScreen.dart';
import 'package:pertemuan5/Movies.dart';
import 'package:pertemuan5/search.dart';

enum MovieCategory { latest, nowPlaying, popular, topRated, upcoming }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MovieCategory _selectedCategory = MovieCategory.nowPlaying;
  StreamController<List?> streamController = StreamController<List?>();

  HttpHelper? helper;
  List? movies;
  final String iconBase = 'https://image.tmdb.org/t/p/w92/';
  final String defaultImage =
      'https://images.freeimages.com/images/large-previes/5eb/movie-clapboard-1184339.jpg';

  void initialize() {
    helper?.getMovies(_selectedCategory).listen((movies) {
      streamController.add(movies);
    });
  }

  @override
  void initState() { 
    helper = HttpHelper();
    Timer.periodic(Duration(seconds: 5), (Timer t) => initialize());
    super.initState();
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NetworkImage image;
    String getAppBarTitle(MovieCategory category) {
      switch (category) {
        case MovieCategory.latest:
          return 'Latest';
        case MovieCategory.nowPlaying:
          return 'Now Playing';
        case MovieCategory.popular:
          return 'Popular';
        case MovieCategory.topRated:
          return 'Top Rated';
        case MovieCategory.upcoming:
          return 'Up Coming';
        default:
          return '';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(getAppBarTitle(_selectedCategory)),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              MaterialPageRoute route =
                  MaterialPageRoute(builder: (_) => const SearchMovie());
              Navigator.push(context, route);
            },
            icon: Icon(Icons.search),
          ),
          PopupMenuButton<MovieCategory>(
              onSelected: (MovieCategory result) {
                setState(() {
                  _selectedCategory = result;
                  initialize();
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<MovieCategory>>[
                    const PopupMenuItem(
                      value: MovieCategory.latest,
                      child: Text('Latest'),
                    ),
                    const PopupMenuItem(
                      value: MovieCategory.nowPlaying,
                      child: Text('Now Playing'),
                    ),
                    const PopupMenuItem(
                      value: MovieCategory.popular,
                      child: Text('Popular'),
                    ),
                    const PopupMenuItem(
                      value: MovieCategory.topRated,
                      child: Text('Top Rated'),
                    ),
                    const PopupMenuItem(
                      value: MovieCategory.upcoming,
                      child: Text('Up Coming'),
                    ),
                  ]),
        ],
      ),
      body: StreamBuilder<List?>(
        stream: streamController.stream,
        builder: (BuildContext context, AsyncSnapshot<List?> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (BuildContext context, int position) {
                    ImageProvider image;
                    if (snapshot.data![position].posterPath != null) {
                      image = NetworkImage(
                          iconBase + snapshot.data![position].posterPath);
                    } else {
                      image = NetworkImage(defaultImage);
                    }
                    return Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: ListTile(
                        onTap: () {
                          MaterialPageRoute route = MaterialPageRoute(
                              builder: (_) =>
                                  DetailScreen(snapshot.data![position]));
                          Navigator.push(context, route);
                        },
                        leading: CircleAvatar(
                          backgroundImage: image,
                        ),
                        title: Text(snapshot.data![position].title),
                        subtitle: Text('Released: ' +
                            snapshot.data![position].releaseDate +
                            ' - Vote: ' +
                            snapshot.data![position].voteAverage.toString()),
                      ),
                    );
                  },
                );
              } else {
                return Text('No data');
              }
          }
        },
      ),
    );
  }
}
