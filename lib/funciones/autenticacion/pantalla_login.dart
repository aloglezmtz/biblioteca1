import 'package:flutter/material.dart';
import '../../nucleo/conexion_bd.dart';
import '../inicio/pantalla_inicio.dart';
import 'package:postgres/postgres.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      final conn = await obtenerConexion();

      final result = await conn.execute(
        Sql.named('SELECT * FROM usuario WHERE nombre_del_usuario = @u AND contrasena = @p'),
        parameters: {
          'u': _userController.text,
          'p': _passwordController.text,
        },
      );
      await conn.close();

      if (result.isNotEmpty) {
        usuarioActivo = _userController.text;
        rolActivo = (usuarioActivo == 'administrador') ? 'ADMIN' : 'EMPLEADO';

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _mostrarAlerta('Credenciales incorrectas.', Colors.red);
      }
    } catch (e) {
      _mostrarAlerta('Error de base de datos: $e', Colors.red);
    }
  }

  void _mostrarAlerta(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_library, size: 80, color: Colors.indigo),
                    const SizedBox(height: 20),
                    const Text('Bienvenido', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _userController,
                      decoration: InputDecoration(labelText: 'Usuario', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Contraseña', prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: _login,
                        child: const Text('Iniciar Sesión', style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Pantalla de inicio de sesión. Valida usuario y contraseña contra la BD
// y asigna el rol correspondiente (ADMIN o EMPLEADO) antes de entrar al sistema.