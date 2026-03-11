import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pilem/models/movie.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIsFavorite();
  }

  Future<void> _checkIsFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoriteMovies =
        prefs.getStringList('favorite_movies') ?? [];

    final isExist = favoriteMovies.any((movieString) {
      final movieMap = jsonDecode(movieString);
      return movieMap['id'] == widget.movie.id;
    });

    setState(() {
      _isFavorite = isExist;
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoriteMovies =
        prefs.getStringList('favorite_movies') ?? [];

    final movieJson = jsonEncode(widget.movie.toJson());

    if (_isFavorite) {
      favoriteMovies.removeWhere((movieString) {
        final movieMap = jsonDecode(movieString);
        return movieMap['id'] == widget.movie.id;
      });
    } else {
      favoriteMovies.add(movieJson);
    }

    await prefs.setStringList('favorite_movies', favoriteMovies);

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    'https://image.tmdb.org/t/p/w500${movie.backdropPath}',
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: IconButton(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Overview:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(movie.overview),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.blue),
                  const SizedBox(width: 10),
                  const Text(
                    'Release Date:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(movie.releaseDate)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 10),
                  const Text(
                    'Rating:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Text(movie.voteAverage.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
