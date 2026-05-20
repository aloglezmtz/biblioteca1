import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

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

Future<Connection> _obtenerConexion() async {
  return await Connection.open(
    Endpoint(
      host: '127.0.0.1', // localhost
      port: 5432,
      database: 'Biblioteca',
      username: 'postgres',
      password: '',
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );
}


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
      final conn = await _obtenerConexion();

      final result = await conn.execute(
        Sql.named('SELECT * FROM usuario WHERE nombre_del_usuario = @u AND contraseña = @p'),
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
      final conn = await _obtenerConexion();
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
      final conn = await _obtenerConexion();

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

class FormPrestamoScreen extends StatefulWidget {
  const FormPrestamoScreen({super.key});

  @override
  State<FormPrestamoScreen> createState() => _FormPrestamoScreenState();
}

class _FormPrestamoScreenState extends State<FormPrestamoScreen> {
  final _codigoEmpleado = TextEditingController();
  final _codigoLector = TextEditingController();
  final _isbn = TextEditingController();
  final _numEjemplar = TextEditingController();
  final _fechaPrestamo = TextEditingController();

  Future<void> _registrar() async {
    try {
      DateTime fechaPrestamoDt = DateTime.parse(_fechaPrestamo.text);
      DateTime fechaLimiteDt = fechaPrestamoDt.add(const Duration(days: 7));
      String fechaLimiteCalculada = "${fechaLimiteDt.year}-${fechaLimiteDt.month.toString().padLeft(2, '0')}-${fechaLimiteDt.day.toString().padLeft(2, '0')}";

      final conn = await _obtenerConexion();
      await conn.execute(
        Sql.named('INSERT INTO prestamo (codigo_empleado, codigo_lector, isbn, num_ejemplar, fecha_prestamo, fecha_limite) VALUES (@ce, @cl, @i, @ne, @fp, @fl)'),
        parameters: {
          'ce': int.parse(_codigoEmpleado.text),
          'cl': int.parse(_codigoLector.text),
          'i': _isbn.text,
          'ne': int.parse(_numEjemplar.text),
          'fp': _fechaPrestamo.text,
          'fl': fechaLimiteCalculada
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
              child: ElevatedButton.icon(onPressed: _registrar, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), icon: const Icon(Icons.save, color: Colors.white), label: const Text('REGISTRAR PRÉSTAMO', style: TextStyle(color: Colors.white, fontSize: 16))),
            )
          ],
        ),
      ),
    );
  }
}


class FormDevolverScreen extends StatefulWidget {
  const FormDevolverScreen({super.key});

  @override
  State<FormDevolverScreen> createState() => _FormDevolverScreenState();
}

class _FormDevolverScreenState extends State<FormDevolverScreen> {
  final _idPrestamo = TextEditingController();
  final _fechaEntrega = TextEditingController();

  Future<void> _generarPdfMultaYEnviarCorreo(String id, int dias, double monto, String correoDestino, String libroInfo, String tipoLector) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text("BIBLIOTECA - NOTIFICACION DE MULTA", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
              ),
              pw.SizedBox(height: 25),
              pw.Text("Detalles de la Cuenta:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text("ID de Préstamo: $id", style: const pw.TextStyle(fontSize: 12)),
              pw.Text("Tipo de Usuario: $tipoLector", style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 15),
              pw.Text("Información de Libros Entregados con Retraso:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(libroInfo, style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 15),
              pw.Text("Detalle del Cálculo:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text("Días de retraso: $dias días", style: const pw.TextStyle(fontSize: 12)),
              pw.Text("Cuota por día: \$${(monto / dias).toStringAsFixed(2)} MXN", style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text("Monto Total a Pagar: \$${monto.toStringAsFixed(2)} MXN", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
              ),
              pw.SizedBox(height: 35),
              pw.Center(
                child: pw.Text("Favor de pasar a pagar a caja. Este recibo fue enviado a su correo.", style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic)),
              ),
            ],
          ),
        ),
      ),
    );

    final pdfBytes = await doc.save();
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes, name: 'multa_$id.pdf');

    String emailRemitente = 'bibliotechescuela@gmail.com';
    String passwordApp = 'uofvydxkvcuddpal';

    final smtpServer = gmail(emailRemitente, passwordApp);

    final message = Message()
      ..from = Address(emailRemitente, 'BiblioTech Sistema')
      ..recipients.add(correoDestino)
      ..subject = 'Notificación de Multa por Retraso - BiblioTech'
      ..text = 'Estimado usuario,\n\nAdjunto encontrará el recibo detallado de su multa por el retraso en la devolución de su préstamo con ID $id.\n\nDetalles del libro: $libroInfo\nTotal a Liquidar: \$$monto MXN.\n\nPor favor pase a caja a regularizar su situación.\n\nSaludos.'
      ..attachments.add(
        StreamAttachment(
          Stream.value(pdfBytes),
          'application/pdf',
          fileName: 'multa_retraso_$id.pdf',
        )
      );

    try {
      final sendReport = await send(message, smtpServer);
      debugPrint('Mensaje enviado: $sendReport');
    } catch (e) {
      debugPrint('El correo no se pudo enviar. Error: $e');
    }
  }

  Future<void> _devolver() async {
    try {
      final conn = await _obtenerConexion();

      final res = await conn.execute(Sql.named('SELECT fecha_limite, isbn, num_ejemplar, codigo_lector FROM prestamo WHERE id_prestamo = @id'), parameters: {'id': int.parse(_idPrestamo.text)});
      if (res.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El ID del préstamo no existe'), backgroundColor: Colors.red));
        await conn.close();
        return;
      }

      DateTime limiteRaw;
      if (res.first[0] is DateTime) {
        limiteRaw = res.first[0] as DateTime;
      } else {
        limiteRaw = DateTime.parse(res.first[0].toString());
      }

      String isbn = res.first[1].toString();
      int numEjemplar = int.tryParse(res.first[2].toString()) ?? 0;
      int codLector = int.tryParse(res.first[3].toString()) ?? 0;

      DateTime entregaRaw = DateTime.parse(_fechaEntrega.text);
      DateTime limite = DateTime(limiteRaw.year, limiteRaw.month, limiteRaw.day);
      DateTime entrega = DateTime(entregaRaw.year, entregaRaw.month, entregaRaw.day);

      await conn.execute(Sql.named('UPDATE prestamo SET fecha_entrega = @fe WHERE id_prestamo = @id'), parameters: {'fe': _fechaEntrega.text, 'id': int.parse(_idPrestamo.text)});

      if (entrega.isAfter(limite)) {
        int dias = entrega.difference(limite).inDays;

        final resLibro = await conn.execute(Sql.named('SELECT titulo FROM libro WHERE isbn = @isbn LIMIT 1'), parameters: {'isbn': isbn});
        String tituloLibro = resLibro.isNotEmpty ? resLibro.first[0].toString() : "Libro Desconocido";
        String libroInfo = "$tituloLibro (ISBN: $isbn, Ejemplar No: $numEjemplar)";

        String correoDestino = "";
        double tarifaPorDia = 0.0;
        String tipoLector = "";

        var resCorreo = await conn.execute(Sql.named('SELECT correo FROM alumno WHERE codigo = @cod'), parameters: {'cod': codLector});

        if (resCorreo.isNotEmpty) {
          correoDestino = resCorreo.first[0].toString();
          tarifaPorDia = 5.0; 
          tipoLector = "Alumno";
        } else {
          resCorreo = await conn.execute(Sql.named('SELECT correo FROM profesor WHERE codigo = @cod'), parameters: {'cod': codLector});

          if (resCorreo.isNotEmpty) {
            correoDestino = resCorreo.first[0].toString();
            tarifaPorDia = 10.0; 
            tipoLector = "Profesor";
          }
        }
        
        double multa = dias * tarifaPorDia;

        await conn.close(); 

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generando multa y enviando correo...'), backgroundColor: Colors.orange));
        
        await _generarPdfMultaYEnviarCorreo(_idPrestamo.text, dias, multa, correoDestino, libroInfo, tipoLector);
      } else {
        await conn.close();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Devuelto a tiempo. Sin multa.'), backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devolver préstamo'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            TextField(controller: _idPrestamo, decoration: InputDecoration(labelText: 'ID del Préstamo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))), const SizedBox(height: 15),
            TextField(controller: _fechaEntrega, decoration: InputDecoration(labelText: 'Fecha de Entrega (YYYY-MM-DD)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))), const SizedBox(height: 25),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(onPressed: _devolver, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), icon: const Icon(Icons.assignment_return, color: Colors.white), label: const Text('PROCESAR DEVOLUCIÓN', style: TextStyle(color: Colors.white, fontSize: 16))),
            )
          ],
        ),
      ),
    );
  }
}
