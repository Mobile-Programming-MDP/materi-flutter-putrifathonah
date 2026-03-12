import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL utama dari API The Movie Database
  static const String baseUrl = 'https://api.themoviedb.org/3';

  // API key untuk mengakses TMDB
  // Sebaiknya jangan di-hardcode kalau project ingin dipakai serius / dipublish
  static const String apiKey = "ed6421778f77d9d8eb253f0fd6938e06";

  // 1. Mengambil daftar film yang sedang tayang di bioskop / now playing
  Future<List<Map<String, dynamic>>> getAllMovie() async {
    // Mengirim request GET ke endpoint now_playing
    final response = await http.get(
      Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey'),
    );

    // Mengubah response JSON menjadi object Dart
    final data = json.decode(response.body);

    // Mengambil bagian 'results' lalu mengubahnya menjadi List<Map<String, dynamic>>
    return List<Map<String, dynamic>>.from(data['results']);
  }

  // 2. Mengambil daftar film yang sedang trending minggu ini
  Future<List<Map<String, dynamic>>> getTrendingMovie() async {
    // Mengirim request GET ke endpoint trending movie per minggu
    final response = await http.get(
      Uri.parse('$baseUrl/trending/movie/week?api_key=$apiKey'),
    );

    // Mengubah response JSON menjadi object Dart
    final data = json.decode(response.body);

    // Mengambil data film dari field 'results'
    return List<Map<String, dynamic>>.from(data['results']);
  }

  // 3. Mengambil daftar film populer
  Future<List<Map<String, dynamic>>> getPopularMovie() async {
    // Mengirim request GET ke endpoint movie popular
    final response = await http.get(
      Uri.parse('$baseUrl/movie/popular?api_key=$apiKey'),
    );

    // Decode JSON response menjadi data Dart
    final data = json.decode(response.body);

    // Mengembalikan list film populer dari 'results'
    return List<Map<String, dynamic>>.from(data['results']);
  }

  // 4. Mencari film berdasarkan kata kunci yang dimasukkan user
  Future<List<Map<String, dynamic>>> searchMovie(String query) async {
    // Mengirim request GET ke endpoint pencarian movie
    // query berisi kata kunci pencarian, misalnya: "avatar"
    final response = await http.get(
      Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query'),
    );

    // Mengubah response JSON menjadi object Dart
    final data = json.decode(response.body);

    // Mengembalikan hasil pencarian film dari 'results'
    return List<Map<String, dynamic>>.from(data['results']);
  }
}
