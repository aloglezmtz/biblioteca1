import 'package:flutter/material.dart';
import 'funciones/autenticacion/pantalla_login.dart';

void main() {
  runApp(const BibliotecaApp());
}

String rolActivo = "";
String usuarioActivo = "";

class BibliotecaApp extends StatelessWidget {
  const BibliotecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BiblioTech Virtual',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        fontFamily: 'Segoe UI',
      ),
      home: const LoginScreen(),
    );
  }
}