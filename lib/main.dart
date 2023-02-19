import 'package:agistaofficial/screens/home_screen.dart';
import 'package:agistaofficial/screens/login_screen.dart';
import 'package:agistaofficial/util/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  MyHomePage(),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSplash = true;

  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 3)).then((_) {
      setState(() {
        isSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    /// cek apakah pengguna sudah login sebelumnya atau belum, jika sudah langsung masuk ke homepage, jika belum masuk ke login
    User? user = FirebaseAuth.instance.currentUser;
    if (isSplash) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Image.asset(
            'assets/smaller_logo.PNG',
            fit: BoxFit.fill,
          ),
        ),
      );
    } else {
      if (user != null) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Themes(),
          home: HomeScreen(),
        );
      } else {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Themes(),
          home: LoginScreen(),
        );
      }
    }
  }
}

