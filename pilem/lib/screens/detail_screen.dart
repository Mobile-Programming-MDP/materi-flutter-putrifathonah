import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pilem/models/movie.dart';

class DetailScreen extends StatefulWidget {
  // Menerima data movie yang dikirim dari halaman sebelumnya
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Menyimpan status apakah film ini sudah difavoritkan atau belum
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    // Saat halaman pertama kali dibuka,
    // cek apakah film ini sudah ada di daftar favorit
    _checkIsFavorite();
  }

  // Method untuk mengecek apakah movie saat ini sudah ada di SharedPreferences
  Future<void> _checkIsFavorite() async {
    // Mengambil instance SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Mengambil daftar movie favorit yang tersimpan
    // Jika belum ada, gunakan list kosong
    final List<String> favoriteMovies =
        prefs.getStringList('favorite_movies') ?? [];

    // Mengecek apakah id movie saat ini ada di daftar favorit
    final isExist = favoriteMovies.any((movieString) {
      final movieMap = jsonDecode(movieString);
      return movieMap['id'] == widget.movie.id;
    });

    // Mengubah nilai _isFavorite sesuai hasil pengecekan
    setState(() {
      _isFavorite = isExist;
    });
  }

  // Method untuk menambah atau menghapus movie dari favorit
  Future<void> _toggleFavorite() async {
    // Mengambil instance SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Mengambil daftar movie favorit yang tersimpan
    final List<String> favoriteMovies =
        prefs.getStringList('favorite_movies') ?? [];

    // Mengubah object movie menjadi JSON string
    final movieJson = jsonEncode(widget.movie.toJson());

    // Jika movie sudah favorit, hapus dari daftar favorit
    if (_isFavorite) {
      favoriteMovies.removeWhere((movieString) {
        final movieMap = jsonDecode(movieString);
        return movieMap['id'] == widget.movie.id;
      });
    } else {
      // Jika belum favorit, tambahkan ke daftar favorit
      favoriteMovies.add(movieJson);
    }

    // Simpan kembali daftar favorit ke SharedPreferences
    await prefs.setStringList('favorite_movies', favoriteMovies);

    // Ubah status favorit pada tampilan
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mempermudah pemanggilan data movie
    final movie = widget.movie;

    return Scaffold(
      // AppBar menampilkan judul film
      appBar: AppBar(title: Text(movie.title)),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          // SingleChildScrollView agar halaman bisa discroll jika isi panjang
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stack digunakan agar gambar dan tombol favorit bisa ditumpuk
              Stack(
                children: [
                  // Menampilkan gambar backdrop film
                  Image.network(
                    'https://image.tmdb.org/t/p/w500${movie.backdropPath}',
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  // Meletakkan tombol favorit di kanan bawah gambar
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: IconButton(
                      // Saat ditekan, jalankan method toggle favorite
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        // Jika sudah favorit tampilkan icon hati penuh
                        // Jika belum, tampilkan icon hati outline
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Judul bagian overview
              const Text(
                'Overview:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // Menampilkan deskripsi film
              Text(movie.overview),

              const SizedBox(height: 20),

              // Menampilkan informasi tanggal rilis
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.blue),
                  const SizedBox(width: 10),
                  const Text(
                    'Release Date:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),

                  // Expanded dipakai agar teks tanggal rilis tidak overflow
                  Expanded(child: Text(movie.releaseDate)),
                ],
              ),

              const SizedBox(height: 20),

              // Menampilkan rating film
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 10),
                  const Text(
                    'Rating:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),

                  // Menampilkan nilai rating film
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
