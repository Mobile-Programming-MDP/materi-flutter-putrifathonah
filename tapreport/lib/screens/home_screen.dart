import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _idToken = "";
  String? _uid = "";
  String? _email = "";

  // 1. Menambahkan initState agar data otomatis dimuat saat layar dibuka
  @override
  void initState() {
    super.initState();
    getFirebaseAuthUser();
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      ), // Pastikan menggunakan const jika SignInScreen mendukungnya
      (route) => false,
    );
  }

  Future<String?> getTokenAuth() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? idToken = await user.getIdToken(true);
      return idToken;
    }

    return null;
  }

  Future<void> getFirebaseAuthUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Mengambil data saat ini secara sinkron
      String uid = user.uid;
      String? email = user.email;

      // Mengambil token secara asinkron
      String? token = await user.getIdToken(true);

      // Memperbarui UI dalam satu setState
      setState(() {
        _uid = uid;
        _email = email;
        _idToken = token;
      });
    }
  }

  // 2. Memperbaiki null check operator (!) agar tidak error jika nama kosong
  String generateAvatarUrl(String? fullname) {
    final formattedName = (fullname ?? 'User').trim().replaceAll(' ', '+');
    return 'https://ui-avatars.com/api/?name=$formattedName&color=7F9CF5&background=EBF4FF';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            // 3. Tombol sign out sudah terhubung
            onPressed: () {
              signOut(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.network(
                generateAvatarUrl(
                  FirebaseAuth.instance.currentUser?.displayName,
                ),
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              const Text("Hello!"),
              Text("UID: $_uid"),
              Text("Email: $_email"),
              Text(
                "Token: ${_idToken != null && _idToken!.length > 15 ? _idToken!.substring(0, 15) + '...' : _idToken}",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
