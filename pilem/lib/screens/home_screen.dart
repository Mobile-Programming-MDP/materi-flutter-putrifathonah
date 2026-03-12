import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/screens/detail_screen.dart';
import 'package:pilem/services/api_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Membuat object ApiService untuk mengambil data movie dari API
  final ApiService _apiService = ApiService();

  // Menyimpan data film berdasarkan kategori
  List<Movie> _allMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];

  // Method untuk mengambil semua data film dari API
  Future<void> _loadMovies() async {
    // Mengambil data all movies dari API
    final List<Map<String, dynamic>> allMoviesData = await _apiService
        .getAllMovie();

    // Mengambil data trending movies dari API
    final List<Map<String, dynamic>> trendingMoviesData = await _apiService
        .getTrendingMovie();

    // Mengambil data popular movies dari API
    final List<Map<String, dynamic>> popularMoviesData = await _apiService
        .getPopularMovie();

    // Mengubah data JSON menjadi object Movie lalu simpan ke state
    setState(() {
      _allMovies = allMoviesData.map((json) => Movie.fromJson(json)).toList();
      _trendingMovies = trendingMoviesData
          .map((json) => Movie.fromJson(json))
          .toList();
      _popularMovies = popularMoviesData
          .map((json) => Movie.fromJson(json))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();

    // Saat HomeScreen pertama kali dibuka,
    // langsung panggil method untuk load data movie
    _loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar pada halaman utama
      appBar: AppBar(title: const Text("Pilem")),

      // SingleChildScrollView digunakan agar seluruh isi halaman bisa discroll ke bawah
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan list untuk kategori All Movies
            _buildMoviesList("All Movies", _allMovies),

            // Menampilkan list untuk kategori Trending Movies
            _buildMoviesList("Trending Movies", _trendingMovies),

            // Menampilkan list untuk kategori Popular Movies
            _buildMoviesList("Popular Movies", _popularMovies),
          ],
        ),
      ),
    );
  }

  // Widget reusable untuk menampilkan 1 kategori film
  Widget _buildMoviesList(String title, List<Movie> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Menampilkan judul kategori movie
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        // Menampilkan daftar movie secara horizontal
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // arah scroll ke samping
            itemCount: movies.length, // jumlah item sesuai banyak data movie
            itemBuilder: (BuildContext build, int index) {
              // Mengambil data movie berdasarkan index
              final Movie movie = movies[index];

              return GestureDetector(
                // Saat item movie ditekan, pindah ke DetailScreen
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(movie: movie),
                  ),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Menampilkan poster film dari URL TMDB
                      Image.network(
                        "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                        width: 100,
                        height: 150,
                        fit: BoxFit.cover,
                      ),

                      // Menampilkan judul film
                      // Jika judul terlalu panjang, dipotong lalu ditambah ...
                      Text(
                        movie.title.length > 14
                            ? '${movie.title.substring(0, 10)}...'
                            : movie.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
