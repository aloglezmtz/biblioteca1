import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

void main() {
  runApp(const BibliotecaApp());
}

// Variable global para saber quién inició sesión
String usuarioActivo = "";

class BibliotecaApp extends StatelessWidget {
  const BibliotecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema Biblioteca',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const LoginScreen(),
    );
  }
}

// =====================================================================
// PASO 5: CONEXIÓN A POSTGRES (Código fuente para tu captura)
// =====================================================================
Future<Connection> _obtenerConexion() async {
  return await Connection.open(
    Endpoint(
      host: '127.0.0.1', // localhost
      port: 5432,
      database: 'Biblioteca',
      username: 'postgres',
      password: 'taco123', // <-- Tu nueva contraseña
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );
}

// =====================================================================
// PASO 6: VENTANA DE INICIO DE SESIÓN (IGU)
// =====================================================================
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

      // Consulta SQL empotrada para validar usuario
      final result = await conn.execute(
        Sql.named('SELECT * FROM Usuario WHERE nombre_del_usuario = @u AND contraseña = @p'),
        parameters: {
          'u': _userController.text,
          'p': _passwordController.text,
        },
      );
      await conn.close();

      if (result.isNotEmpty && _userController.text == 'administrador') {
        usuarioActivo = _userController.text;
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _mostrarAlerta('Credenciales incorrectas o no es el administrador.', Colors.red);
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

// =====================================================================
// PASO 7: VENTANA PRINCIPAL DE LA BIBLIOTECA
// =====================================================================
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
              child: Text('Usuario logeado: $usuarioActivo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
      // PASO 8: MENÚ EMPLEADOS
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text('MENÚ EMPLEADOS', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Registrar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrarScreen()));
              },
            ),
            ListTile(leading: const Icon(Icons.search), title: const Text('Consulta Individual'), onTap: () {}),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Consulta General'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConsultaGeneralScreen()));
              },
            ),
            ListTile(leading: const Icon(Icons.edit), title: const Text('Cambiar'), onTap: () {}),
            ListTile(leading: const Icon(Icons.delete), title: const Text('Eliminar'), onTap: () {}),
            const Divider(),
            // PASO 11: CERRAR SESIÓN
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
            // Imagen empotrada
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
}

// =====================================================================
// PASOS 8 Y 9: FORMULARIO DE REGISTRO (Ivonne y Blas)
// =====================================================================
class RegistrarScreen extends StatefulWidget {
  const RegistrarScreen({super.key});

  @override
  State<RegistrarScreen> createState() => _RegistrarScreenState();
}

class _RegistrarScreenState extends State<RegistrarScreen> {
  final _codigoCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _sexoCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _turnoCtrl = TextEditingController();

  Future<void> _guardarEmpleado() async {
    try {
      final conn = await _obtenerConexion();

      // Instrucciones SQL empotradas
      final sql = '''
        INSERT INTO Empleado (Codigo, Nombre, Direccion, Telefono, Sexo, Fecha_nac, Turno) 
        VALUES (@c, @n, @d, @t, @s, @f, @tu)
      ''';

      await conn.execute(
        Sql.named(sql),
        parameters: {
          'c': int.parse(_codigoCtrl.text),
          'n': _nombreCtrl.text,
          'd': _direccionCtrl.text,
          't': _telefonoCtrl.text,
          's': _sexoCtrl.text,
          'f': _fechaCtrl.text,
          'tu': _turnoCtrl.text,
        },
      );
      await conn.close();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Empleado registrado en BD exitosamente'), backgroundColor: Colors.green));

      _codigoCtrl.clear(); _nombreCtrl.clear(); _direccionCtrl.clear();
      _telefonoCtrl.clear(); _sexoCtrl.clear(); _fechaCtrl.clear(); _turnoCtrl.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Empleado')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Llene los campos (Ej. 777, Ivonne Lopez, Olivos 234)', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(controller: _codigoCtrl, decoration: const InputDecoration(labelText: 'Código')),
            TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: _direccionCtrl, decoration: const InputDecoration(labelText: 'Dirección')),
            TextField(controller: _telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono')),
            TextField(controller: _sexoCtrl, decoration: const InputDecoration(labelText: 'Sexo (F/M)')),
            TextField(controller: _fechaCtrl, decoration: const InputDecoration(labelText: 'Fecha de nac (AAAA-MM-DD)')),
            TextField(controller: _turnoCtrl, decoration: const InputDecoration(labelText: 'Turno')),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              onPressed: _guardarEmpleado,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Dar de Alta', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// PASO 10: CONSULTA GENERAL EN TABLA
// =====================================================================
class ConsultaGeneralScreen extends StatefulWidget {
  const ConsultaGeneralScreen({super.key});

  @override
  State<ConsultaGeneralScreen> createState() => _ConsultaGeneralScreenState();
}

class _ConsultaGeneralScreenState extends State<ConsultaGeneralScreen> {
  List<List<dynamic>> _empleados = [];

  Future<void> _cargarDatos() async {
    try {
      final conn = await _obtenerConexion();

      // SQL empotrada
      final result = await conn.execute('SELECT * FROM Empleado ORDER BY Codigo ASC');

      setState(() {
        _empleados = result.map((row) => row.toList()).toList();
      });
      await conn.close();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta General de Empleados')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.indigo.withOpacity(0.2)),
                columns: const [
                  DataColumn(label: Text('Código', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Dirección', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Teléfono', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Sexo', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Fecha Nac.', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Turno', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _empleados.map((emp) {
                  return DataRow(cells: emp.map((cell) {
                    String valor = cell is DateTime ? "${cell.year}-${cell.month.toString().padLeft(2, '0')}-${cell.day.toString().padLeft(2, '0')}" : cell.toString();
                    return DataCell(Text(valor));
                  }).toList());
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}