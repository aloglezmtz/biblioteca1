import 'package:flutter/material.dart';
import '../../nucleo/conexion_bd.dart';
import 'package:postgres/postgres.dart';

class FormularioScreen extends StatefulWidget {
  final String tipo;
  const FormularioScreen({super.key, required this.tipo});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final Map<String, TextEditingController> _ctrls = {};

  @override
  void initState() {
    super.initState();
    List<String> f = [];
    if (widget.tipo == 'ALUMNOS') {
      f = ['Código', 'Nombre', 'Carrera', 'Correo', 'Dirección', 'Teléfono', 'Sexo', 'Fecha_nac'];
    } else if (widget.tipo == 'PROFESORES') {
      f = ['Código', 'Nombre', 'Dirección', 'Teléfono', 'Sexo', 'Fecha_nac', 'Depto', 'Correo'];
    } else if (widget.tipo == 'EMPLEADOS') {
      f = ['Codigo', 'Nombre', 'Direccion', 'Telefono', 'Sexo', 'Fecha_nac', 'Turno'];
    } else if (widget.tipo == 'LIBROS') {
      f = ['ISBN', 'Título', 'Autores', 'Editorial', 'Año_pub', 'Num_ejemplar'];
    }

    for (var x in f) {
      _ctrls[x] = TextEditingController();
    }
  }

  Future<void> _enviar() async {
    try {
      final conn = await obtenerConexion();
      String sql = "";
      Map<String, dynamic> p = {};

      if (widget.tipo == 'ALUMNOS') {
        sql = "INSERT INTO alumno VALUES (@c,@n,@ca,@co,@d,@t,@s,@f)";
        p = {
          'c': int.parse(_ctrls['Código']!.text),
          'n': _ctrls['Nombre']!.text,
          'ca': _ctrls['Carrera']!.text,
          'co': _ctrls['Correo']!.text,
          'd': _ctrls['Dirección']!.text,
          't': _ctrls['Teléfono']!.text,
          's': _ctrls['Sexo']!.text,
          'f': _ctrls['Fecha_nac']!.text,
        };
      } else if (widget.tipo == 'PROFESORES') {
        sql = "INSERT INTO profesor VALUES (@c,@n,@d,@t,@s,@f,@de,@co)";
        p = {
          'c': int.parse(_ctrls['Código']!.text),
          'n': _ctrls['Nombre']!.text,
          'd': _ctrls['Dirección']!.text,
          't': _ctrls['Teléfono']!.text,
          's': _ctrls['Sexo']!.text,
          'f': _ctrls['Fecha_nac']!.text,
          'de': _ctrls['Depto']!.text,
          'co': _ctrls['Correo']!.text,
        };
      } else if (widget.tipo == 'LIBROS') {
        sql = "INSERT INTO libro VALUES (@i,@t,@a,@e,@y,@n)";
        p = {
          'i': _ctrls['ISBN']!.text,
          't': _ctrls['Título']!.text,
          'a': _ctrls['Autores']!.text,
          'e': _ctrls['Editorial']!.text,
          'y': int.parse(_ctrls['Año_pub']!.text),
          'n': int.parse(_ctrls['Num_ejemplar']!.text),
        };
      } else if (widget.tipo == 'EMPLEADOS') {
        sql = "INSERT INTO empleado VALUES (@c,@n,@d,@t,@s,@f,@tu)";
        p = {
          'c': int.parse(_ctrls['Codigo']!.text),
          'n': _ctrls['Nombre']!.text,
          'd': _ctrls['Direccion']!.text,
          't': _ctrls['Telefono']!.text,
          's': _ctrls['Sexo']!.text,
          'f': _ctrls['Fecha_nac']!.text,
          'tu': _ctrls['Turno']!.text,
        };
      }

      await conn.execute(Sql.named(sql), parameters: p);
      await conn.close();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardado en la Base de Datos con éxito'), backgroundColor: Colors.green),
      );

      for (var key in _ctrls.keys) {
        _ctrls[key]!.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alta de ${widget.tipo}'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Text('Complete los campos para realizar el registro:', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            ..._ctrls.entries.map(
                  (e) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: TextField(
                  controller: e.value,
                  decoration: InputDecoration(
                    labelText: e.key,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.edit, color: Colors.indigo),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _enviar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('PROCESAR ALTA', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla de alta de registros. Genera el formulario dinámicamente según
// el módulo e inserta el nuevo registro en la tabla correspondiente de la BD.