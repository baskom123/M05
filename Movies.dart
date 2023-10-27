import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pertemuan5/Screen.dart';


class Movie {
  final int id;
  final String title;
  final double voteAverage;
  final String releaseDate;
  final String overview;
  final String posterPath;

  Movie(this.id, this.title, this.voteAverage, this.releaseDate, this.overview,
      this.posterPath);

  factory Movie.fromJson(Map<String, dynamic> parsedJson) {
    final id = parsedJson['id'] as int;
    final title = parsedJson['title'] as String;
    final voteAverage = parsedJson['vote_average'] * 1.0 as double;
    final releaseDate = parsedJson['release_date'] as String;
    final overview = parsedJson['overview'] as String;
    final posterPath = parsedJson['poster_path'] as String;

    return Movie(id, title, voteAverage, releaseDate, overview, posterPath);
  }
}

class HttpHelper {
  final String _urlKey = "?api_key=fd32ea8d9e92f032a1073ac1418330b9";
  final String _urlBase = "https://api.themoviedb.org/";

  Stream<List?> getMovies(MovieCategory category) async* {
    String categoryStr;
    switch (category) {
      case MovieCategory.latest:
        categoryStr = 'upcoming'; //latest but error 401 api
        break;

      case MovieCategory.nowPlaying:
        categoryStr = 'now_playing';
        break;

      case MovieCategory.popular:
        categoryStr = 'popular';
        break;

      case MovieCategory.topRated:
        categoryStr = 'top_rated';
        break;

      case MovieCategory.upcoming:
        categoryStr = 'upcoming';
        break;
    }
    var url = Uri.parse(_urlBase + '/3/movie/' + categoryStr + _urlKey);
    http.Response result = await http.get(url);
    if (result.statusCode == HttpStatus.ok) {
      final jsonResponse = json.decode(result.body);
      final moviesMap = jsonResponse['results'];
      List movies = moviesMap.map((i) => Movie.fromJson(i)).toList();
      yield movies;
    } else if (result.statusCode == HttpStatus.unauthorized) {
      throw Exception('API Telah Mengalami Masalah Silahkan cek kembali');
    } else {
      yield null;
    }
  }
}