import 'package:flutter/material.dart';
import '../../nucleo/conexion_bd.dart';
import 'package:postgres/postgres.dart';

class FormPrestamoScreen extends StatefulWidget {
  const FormPrestamoScreen({super.key});

  @override
  State<FormPrestamoScreen> createState() => _FormPrestamoScreenState();
}

class _FormPrestamoScreenState extends State<FormPrestamoScreen> {
  final _codigoEmpleado = TextEditingController();
  final _codigoLector   = TextEditingController();
  final _isbn           = TextEditingController();
  final _numEjemplar    = TextEditingController();
  final _fechaPrestamo  = TextEditingController();

  Future<void> _registrar() async {
    try {
      DateTime fechaPrestamoDt = DateTime.parse(_fechaPrestamo.text);
      DateTime fechaLimiteDt   = fechaPrestamoDt.add(const Duration(days: 7));
      String fechaLimiteCalculada = "${fechaLimiteDt.year}-${fechaLimiteDt.month.toString().padLeft(2, '0')}-${fechaLimiteDt.day.toString().padLeft(2, '0')}";

      final conn = await obtenerConexion();
      await conn.execute(
        Sql.named('INSERT INTO prestamo (codigo_empleado, codigo_lector, isbn, num_ejemplar, fecha_prestamo, fecha_limite) VALUES (@ce, @cl, @i, @ne, @fp, @fl)'),
        parameters: {
          'ce': int.parse(_codigoEmpleado.text),
          'cl': int.parse(_codigoLector.text),
          'i':  _isbn.text,
          'ne': int.parse(_numEjemplar.text),
          'fp': _fechaPrestamo.text,
          'fl': fechaLimiteCalculada,
        },
      );
      await conn.close();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Préstamo registrado. Límite: $fechaLimiteCalculada'), backgroundColor: Colors.green));

      _codigoEmpleado.clear(); _codigoLector.clear(); _isbn.clear(); _numEjemplar.clear(); _fechaPrestamo.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar préstamo'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Text(
              'Nota: La fecha límite se asignará automáticamente a 7 días a partir de la fecha de préstamo.',
              style: TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(controller: _codigoEmpleado, decoration: InputDecoration(labelText: 'Código Empleado', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))), const SizedBox(height: 15),
            TextField(controller: _codigoLector, decoration: InputDecoration(labelText: 'Código Lector (Profe/Alumno)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))), const SizedBox(height: 15),
            TextField(controller: _isbn, decoration: InputDecoration(labelText: 'ISBN', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))), const SizedBox(height: 15),
            TextField(controller: _numEjemplar, decoration: InputDecoration(labelText: 'No. Ejemplar', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))), const SizedBox(height: 15),
            TextField(controller: _fechaPrestamo, decoration: InputDecoration(labelText: 'Fecha Préstamo (YYYY-MM-DD)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))), const SizedBox(height: 25),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: _registrar,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('REGISTRAR PRÉSTAMO', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Pantalla para registrar un préstamo. Guarda los datos del préstamo en la BD
// y calcula automáticamente la fecha límite de devolución (7 días después).