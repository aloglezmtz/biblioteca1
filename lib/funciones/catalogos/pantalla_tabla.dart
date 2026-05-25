import 'package:flutter/material.dart';
import '../../nucleo/conexion_bd.dart';

class TablaScreen extends StatefulWidget {
  final String tipo;
  const TablaScreen({super.key, required this.tipo});

  @override
  State<TablaScreen> createState() => _TablaScreenState();
}

class _TablaScreenState extends State<TablaScreen> {
  List<List<dynamic>> _filas = [];
  List<String> _cabecera = [];

  Future<void> _read() async {
    try {
      final conn = await obtenerConexion();

      String t = "";
      if (widget.tipo == 'ALUMNOS') {
        t = 'alumno';
      } else if (widget.tipo == 'PROFESORES') t = 'profesor';
      else if (widget.tipo == 'EMPLEADOS') t = 'empleado';
      else if (widget.tipo == 'LIBROS') t = 'libro';
      else if (widget.tipo == 'PRÉSTAMOS') t = 'prestamo';

      final res = await conn.execute('SELECT * FROM $t');

      setState(() {
        _filas = res.map((r) => r.toList()).toList();

        if (widget.tipo == 'ALUMNOS') {
          _cabecera = ['Cod', 'Nom', 'Car', 'Mail', 'Dir', 'Tel', 'S', 'Nac'];
        } else if (widget.tipo == 'PROFESORES') {
          _cabecera = ['Cod', 'Nom', 'Dir', 'Tel', 'S', 'Nac', 'Dep', 'Mail'];
        } else if (widget.tipo == 'EMPLEADOS') {
          _cabecera = ['Cod', 'Nom', 'Dir', 'Tel', 'S', 'Nac', 'Tur'];
        } else if (widget.tipo == 'LIBROS') {
          _cabecera = ['ISBN', 'Tit', 'Aut', 'Edi', 'Año', 'Ej'];
        } else if (widget.tipo == 'PRÉSTAMOS') {
          _cabecera = ['ID', 'C.Emp', 'C.Lector', 'ISBN', 'Ej', 'F.Prestamo', 'F.Límite', 'F.Entrega'];
        }
      });
      await conn.close();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  void initState() {
    super.initState();
    _read();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Listado General de ${widget.tipo}'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _filas.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.indigo.withOpacity(0.2)),
                columns: _cabecera.map((c) => DataColumn(label: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                rows: _filas.map((f) {
                  return DataRow(
                    cells: f.map((celda) {
                      String valor = "";
                      if (celda != null) {
                        valor = celda is DateTime ? "${celda.year}-${celda.month.toString().padLeft(2, '0')}-${celda.day.toString().padLeft(2, '0')}" : celda.toString();
                      }
                      return DataCell(Text(valor));
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla de consulta general. Obtiene todos los registros de la tabla
// correspondiente en la BD y los muestra en una tabla con scroll horizontal.