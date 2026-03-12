import 'package:flutter/material.dart';
import 'package:pilem/screens/favorite_screen.dart';
import 'package:pilem/screens/home_screen.dart';
import 'package:pilem/screens/search_screen.dart';

void main() {
  // Fungsi utama yang pertama kali dijalankan saat aplikasi dibuka
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Widget root / widget utama dari aplikasi
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Judul aplikasi
      title: 'Pilem',

      // Pengaturan tema aplikasi
      theme: ThemeData(
        // Membuat color scheme dari warna dasar deepPurple
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),

        // Mengaktifkan Material Design 3
        useMaterial3: true,
      ),

      // Halaman pertama yang dibuka adalah MainScreen
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Menyimpan index menu yang sedang aktif
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan pada BottomNavigationBar
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const FavoriteScreen(),
  ];

  // Method untuk mengubah halaman saat item bottom navigation ditekan
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menampilkan halaman sesuai index yang dipilih
      body: _screens[_selectedIndex],

      // Navigasi bawah untuk berpindah halaman
      bottomNavigationBar: BottomNavigationBar(
        // Menandai item yang sedang aktif
        currentIndex: _selectedIndex,

        // Saat item ditekan, jalankan method _onItemTapped
        onTap: _onItemTapped,

        // Daftar menu pada bottom navigation
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
      ),
    );
  }
}
