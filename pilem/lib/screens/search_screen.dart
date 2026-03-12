import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/screens/detail_screen.dart';
import 'package:pilem/services/api_services.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  // Membuat object ApiService untuk mengambil data pencarian dari API
  final ApiService _apiService = ApiService();

  // Controller untuk mengambil dan mengontrol isi TextField pencarian
  final TextEditingController _searchController = TextEditingController();

  // Menyimpan hasil pencarian movie
  List<Movie> _searchResults = [];

  @override
  void initState() {
    super.initState();

    // Menambahkan listener ke TextField
    // Setiap isi text berubah, method _searchMovies akan dijalankan
    _searchController.addListener(_searchMovies);
  }

  @override
  void dispose() {
    // Menghapus controller saat widget dihancurkan
    // supaya tidak terjadi memory leak
    _searchController.dispose();
    super.dispose();
  }

  // Method untuk mencari movie berdasarkan input user
  void _searchMovies() async {
    // Jika text kosong, hasil pencarian dikosongkan
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    // Mengambil data hasil pencarian dari API
    final List<Map<String, dynamic>> searchData = await _apiService.searchMovie(
      _searchController.text,
    );

    // Mengubah data JSON hasil pencarian menjadi object Movie
    setState(() {
      _searchResults = searchData.map((e) => Movie.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar untuk halaman pencarian
      appBar: AppBar(title: const Text('Search')),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Container untuk membungkus kolom pencarian
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                children: [
                  // TextField untuk input pencarian
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search movies...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  // Tombol clear hanya muncul jika text tidak kosong
                  Visibility(
                    visible: _searchController.text.isNotEmpty,
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        // Menghapus isi pencarian
                        _searchController.clear();

                        // Menghapus hasil pencarian
                        setState(() {
                          _searchResults.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Expanded agar ListView mengisi sisa ruang layar
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  // Mengambil movie berdasarkan index
                  final Movie movie = _searchResults[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      // Menampilkan poster film
                      leading: Image.network(
                        'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),

                      // Menampilkan judul film
                      title: Text(movie.title),

                      // Saat item ditekan, pindah ke DetailScreen
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(movie: movie),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
