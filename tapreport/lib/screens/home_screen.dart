import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Future<void> signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => SignInScreen()),
    (route) => false, //hapus semua route sebelumnya
  );
}

class _HomeScreenState extends State<HomeScreen> {
  String? _idToken = "";
  String? _uid = "";
  String? _email = "";
  Future<void> getFirebasAuthUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _uid = user.uid;
      _email = user.email;
      await user
          .getIdToken(true)
          .then(
            (v) => {
              setState(() {
                _idToken = v;
              }),
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              signOut(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text("You have been signed in with token id : ${_idToken!}"),
            Text("CUrent User : ${_uid!}"),
            Text("Current Email : ${_email}"),
          ],
        ),
      ),
    );
  }
}
