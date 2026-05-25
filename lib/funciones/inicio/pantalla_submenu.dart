import 'package:flutter/material.dart';
import '../catalogos/pantalla_formulario.dart';
import '../catalogos/pantalla_tabla.dart';
import '../prestamos/pantalla_registro_prestamo.dart';
import '../prestamos/pantalla_devolucion.dart';

class SubMenuScreen extends StatelessWidget {
  final String modulo;
  const SubMenuScreen({super.key, required this.modulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de $modulo'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: modulo == 'PRÉSTAMOS'
            ? [
          _opcion(context, 'Registrar préstamo', Icons.add_circle_outline, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FormPrestamoScreen()))),
          _opcion(context, 'Devolver préstamo', Icons.assignment_return, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FormDevolverScreen()))),
          _opcion(context, 'Consulta de préstamo', Icons.person_search, () {}),
          _opcion(context, 'Consultas de préstamos', Icons.format_list_bulleted, () => Navigator.push(context, MaterialPageRoute(builder: (context) => TablaScreen(tipo: modulo)))),
        ]
            : [
          _opcion(context, 'Registrar $modulo', Icons.add_circle_outline, () => Navigator.push(context, MaterialPageRoute(builder: (context) => FormularioScreen(tipo: modulo)))),
          _opcion(context, 'Consulta Individual', Icons.person_search, () {}),
          _opcion(context, 'Consulta General', Icons.format_list_bulleted, () => Navigator.push(context, MaterialPageRoute(builder: (context) => TablaScreen(tipo: modulo)))),
          _opcion(context, 'Modificar', Icons.edit_note, () {}),
          _opcion(context, 'Eliminar', Icons.delete_sweep, () {}),
        ],
      ),
    );
  }

  Widget _opcion(BuildContext context, String t, IconData i, VoidCallback fn) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.indigo.shade100),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(i, color: Colors.indigo),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: fn,
      ),
    );
  }
}

// Pantalla de submenú. Muestra las acciones disponibles para cada módulo
// (registrar, consultar, modificar, eliminar) según el módulo seleccionado.