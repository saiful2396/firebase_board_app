import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/board_screen.dart';

// ignore: non_constant_identifier_names
bool USE_FIRESTORE_EMULATOR = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (USE_FIRESTORE_EMULATOR) {
    FirebaseFirestore.instance.settings = Settings(
        host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BoardScreen(),
    );
  }
}
