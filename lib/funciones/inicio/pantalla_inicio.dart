import 'package:flutter/material.dart';
import 'package:biblioteca1/main.dart';
import 'pantalla_submenu.dart';
import '../autenticacion/pantalla_login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiblioTech Software'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Text('Usuario: $usuarioActivo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('MENÚ PRINCIPAL', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Rol: $rolActivo', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
            if (rolActivo == 'ADMIN') ...[
              _crearItemMenu(context, 'Gestión de Alumnos', Icons.school, 'ALUMNOS'),
              _crearItemMenu(context, 'Gestión de Profesores', Icons.work, 'PROFESORES'),
              _crearItemMenu(context, 'Gestión de Empleados', Icons.badge, 'EMPLEADOS'),
            ],
            if (rolActivo == 'EMPLEADO') ...[
              _crearItemMenu(context, 'Gestión de Libros', Icons.menu_book, 'LIBROS'),
              _crearItemMenu(context, 'Gestión de Préstamos', Icons.assignment, 'PRÉSTAMOS'),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Panel de Administración', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.indigo, width: 5), borderRadius: BorderRadius.circular(15)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network('https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=600&q=80', width: 500, height: 300, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _crearItemMenu(BuildContext context, String titulo, IconData icono, String modulo) {
    return ListTile(
      leading: Icon(icono, color: Colors.indigo),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => SubMenuScreen(modulo: modulo)));
      },
    );
  }
}

// Pantalla principal del sistema. Muestra un menú lateral con opciones
// diferentes según el rol del usuario que haya iniciado sesión.