import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/screens/detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // List untuk menyimpan movie favorit
  List<Movie> _favoriteMovies = [];

  @override
  void initState() {
    super.initState();

    // Saat halaman pertama kali dibuka,
    // langsung load data movie favorit dari SharedPreferences
    _loadFavoriteMovies();
  }

  // Method untuk mengambil data movie favorit dari SharedPreferences
  Future<void> _loadFavoriteMovies() async {
    // Mengambil instance SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Mengambil list movie favorit yang tersimpan
    // Jika belum ada, gunakan list kosong
    final List<String> favoriteMoviesString =
        prefs.getStringList('favorite_movies') ?? [];

    // Mengubah data JSON string menjadi object Movie
    setState(() {
      _favoriteMovies = favoriteMoviesString
          .map((movieString) => Movie.fromJson(jsonDecode(movieString)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar pada halaman Favorite
      appBar: AppBar(title: const Text('Favorite Movies'), centerTitle: true),

      // Jika belum ada movie favorit
      body: _favoriteMovies.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    // Icon hati kosong sebagai ilustrasi
                    Icon(
                      Icons.favorite_border,
                      size: 90,
                      color: Colors.redAccent,
                    ),

                    SizedBox(height: 16),

                    // Pesan jika belum ada movie favorit
                    Text(
                      'Belum ada yang film favorite',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    // Penjelasan tambahan
                    Text(
                      'Tambahkan film ke favorit dari halaman detail film.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          // Jika sudah ada movie favorit
          : ListView.builder(
              padding: const EdgeInsets.all(12),

              // Jumlah item sesuai jumlah movie favorit
              itemCount: _favoriteMovies.length,

              itemBuilder: (context, index) {
                // Mengambil movie berdasarkan index
                final movie = _favoriteMovies[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),

                  // Efek bayangan card
                  elevation: 4,

                  // Membuat sudut card melengkung
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: InkWell(
                    // Supaya efek ripple mengikuti bentuk card
                    borderRadius: BorderRadius.circular(16),

                    // Jika card ditekan, buka DetailScreen
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(movie: movie),
                        ),
                      );

                      // Reload data setelah kembali dari DetailScreen
                      _loadFavoriteMovies();
                    },

                    child: Padding(
                      padding: const EdgeInsets.all(10),

                      child: Row(
                        children: [
                          // Menampilkan poster movie
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                              height: 80,
                              width: 60,
                              fit: BoxFit.cover,

                              // Jika gambar gagal dimuat
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 80,
                                  width: 60,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.broken_image),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Judul movie
                          Expanded(
                            child: Text(
                              movie.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),

                              // Maksimal 2 baris
                              maxLines: 2,

                              // Jika terlalu panjang, tambahkan ...
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Icon panah ke kanan
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
