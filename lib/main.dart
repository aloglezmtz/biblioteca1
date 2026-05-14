import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

void main() => runApp(const BiblioTechProApp());

// Variables globales para la sesión
String usuarioActivo = "";
String rolActivo = "";

class BiblioTechProApp extends StatelessWidget {
  const BiblioTechProApp({super.key});

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
        fontFamily: 'Segoe UI', // Estilo más limpio
      ),
      home: const LoginScreen(),
    );
  }
}

// --- CONEXIÓN A BASE DE DATOS ---
Future<Connection> _conectarDB() async {
  return await Connection.open(
    Endpoint(
      host: '127.0.0.1',
      port: 5432,
      database: 'Biblioteca',
      username: 'postgres',
      password: 'taco123',
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );
}

// ==========================================================
// 1. LOGIN SCREEN (Elegante)
// ==========================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _u = TextEditingController();
  final _p = TextEditingController();

  Future<void> _entrar() async {
    try {
      final conn = await _conectarDB();
      final res = await conn.execute(
        Sql.named(
          'SELECT * FROM Usuario WHERE nombre_del_usuario = @u AND contraseña = @p',
        ),
        parameters: {'u': _u.text, 'p': _p.text},
      );
      await conn.close();

      if (res.isNotEmpty) {
        usuarioActivo = _u.text;
        rolActivo = (usuarioActivo == 'administrador') ? 'ADMIN' : 'EMPLEADO';
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardHome()),
        );
      } else {
        _aviso("Acceso Incorrecto", Colors.redAccent);
      }
    } catch (e) {
      _aviso("Error: $e", Colors.orange);
    }
  }

  void _aviso(String m, Color c) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(m), backgroundColor: c));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
            begin: Alignment.topCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_stories,
                  size: 60,
                  color: Color(0xFF1e3c72),
                ),
                const SizedBox(height: 10),
                const Text(
                  'BIBLIOTECH VIRTUAL',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1e3c72),
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _u,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _p,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _entrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1e3c72),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('INGRESAR'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// 2. DASHBOARD (Presentación + Menús Cuadrados)
// ==========================================================
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Sesión iniciada: $usuarioActivo',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.power_settings_new, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: [
          // SECCIÓN DE PRESENTACIÓN
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              children: [
                const Icon(Icons.account_balance, size: 50, color: Colors.teal),
                const SizedBox(height: 15),
                const Text(
                  'BIENVENIDO A LA BIBLIOTECA VIRTUAL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Gestión inteligente de recursos educativos',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'SELECCIONE UN APARTADO',
            style: TextStyle(
              letterSpacing: 2,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 20),
          // MENÚS CUADRADOS CON BORDES CIRCULARES
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                if (rolActivo == 'ADMIN') ...[
                  _menuSquare(
                    context,
                    'ALUMNOS',
                    Icons.school,
                    Colors.blue,
                    const SubMenuScreen(modulo: 'ALUMNOS', color: Colors.blue),
                  ),
                  _menuSquare(
                    context,
                    'PROFESORES',
                    Icons.work,
                    Colors.teal,
                    const SubMenuScreen(
                      modulo: 'PROFESORES',
                      color: Colors.teal,
                    ),
                  ),
                  _menuSquare(
                    context,
                    'EMPLEADOS',
                    Icons.badge,
                    Colors.orange,
                    const SubMenuScreen(
                      modulo: 'EMPLEADOS',
                      color: Colors.orange,
                    ),
                  ),
                ],
                if (rolActivo == 'EMPLEADO') ...[
                  _menuSquare(
                    context,
                    'LIBROS',
                    Icons.menu_book,
                    Colors.deepPurple,
                    const SubMenuScreen(
                      modulo: 'LIBROS',
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuSquare(
    BuildContext context,
    String t,
    IconData i,
    Color c,
    Widget next,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => next),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: c.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: c.withOpacity(0.1),
              child: Icon(i, color: c),
            ),
            const SizedBox(height: 10),
            Text(
              t,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 3. SUBMENÚS (Registrar, Consultar, etc)
// ==========================================================
class SubMenuScreen extends StatelessWidget {
  final String modulo;
  final Color color;
  const SubMenuScreen({super.key, required this.modulo, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de $modulo'),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _option(
            context,
            'Registrar',
            Icons.add_circle_outline,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormularioScreen(tipo: modulo),
              ),
            ),
          ),
          _option(context, 'Consulta Individual', Icons.person_search, () {}),
          _option(
            context,
            'Consulta General',
            Icons.format_list_bulleted,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TablaScreen(tipo: modulo),
              ),
            ),
          ),
          _option(context, 'Modificar', Icons.edit_note, () {}),
          _option(context, 'Eliminar', Icons.delete_sweep, () {}),
        ],
      ),
    );
  }

  Widget _option(BuildContext context, String t, IconData i, VoidCallback fn) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(i, color: color),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: fn,
      ),
    );
  }
}

// ==========================================================
// 4. FORMULARIOS Y TABLAS (Lógica de Datos)
// ==========================================================
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
    if (widget.tipo == 'ALUMNOS')
      f = [
        'Código',
        'Nombre',
        'Carrera',
        'Correo',
        'Dirección',
        'Teléfono',
        'Sexo',
        'Fecha_nac',
      ];
    if (widget.tipo == 'PROFESORES')
      f = [
        'Código',
        'Nombre',
        'Dirección',
        'Teléfono',
        'Sexo',
        'Fecha_nac',
        'Depto',
        'Correo',
      ];
    if (widget.tipo == 'EMPLEADOS')
      f = [
        'Codigo',
        'Nombre',
        'Direccion',
        'Telefono',
        'Sexo',
        'Fecha_nac',
        'Turno',
      ];
    if (widget.tipo == 'LIBROS')
      f = ['ISBN', 'Título', 'Autores', 'Editorial', 'Año_pub', 'Num_ejemplar'];
    for (var x in f) {
      _ctrls[x] = TextEditingController();
    }
  }

  Future<void> _enviar() async {
    try {
      final conn = await _conectarDB();
      String sql = "";
      Map<String, dynamic> p = {};

      if (widget.tipo == 'ALUMNOS') {
        sql = "INSERT INTO Alumno VALUES (@c,@n,@ca,@co,@d,@t,@s,@f)";
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
        sql = "INSERT INTO Profesor VALUES (@c,@n,@d,@t,@s,@f,@de,@co)";
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
        sql = "INSERT INTO Libro VALUES (@i,@t,@a,@e,@y,@n)";
        p = {
          'i': _ctrls['ISBN']!.text,
          't': _ctrls['Título']!.text,
          'a': _ctrls['Autores']!.text,
          'e': _ctrls['Editorial']!.text,
          'y': int.parse(_ctrls['Año_pub']!.text),
          'n': int.parse(_ctrls['Num_ejemplar']!.text),
        };
      } else if (widget.tipo == 'EMPLEADOS') {
        sql = "INSERT INTO Empleado VALUES (@c,@n,@d,@t,@s,@f,@tu)";
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
        const SnackBar(
          content: Text('Guardado en la Nube con éxito'),
          backgroundColor: Colors.teal,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alta de ${widget.tipo}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            ..._ctrls.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: TextField(
                  controller: e.value,
                  decoration: InputDecoration(
                    labelText: e.key,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _enviar,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('PROCESAR ALTA'),
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

  Future<void> _leer() async {
    final conn = await _conectarDB();
    String t = widget.tipo == 'ALUMNOS'
        ? 'Alumno'
        : (widget.tipo == 'PROFESORES'
              ? 'Profesor'
              : (widget.tipo == 'EMPLEADOS' ? 'Empleado' : 'Libro'));
    final res = await conn.execute('SELECT * FROM $t');
    setState(() {
      _filas = res.map((r) => r.toList()).toList();
      if (widget.tipo == 'ALUMNOS')
        _cabecera = ['Cod', 'Nom', 'Car', 'Mail', 'Dir', 'Tel', 'S', 'Nac'];
      else if (widget.tipo == 'PROFESORES')
        _cabecera = ['Cod', 'Nom', 'Dir', 'Tel', 'S', 'Nac', 'Dep', 'Mail'];
      else if (widget.tipo == 'EMPLEADOS')
        _cabecera = ['Cod', 'Nom', 'Dir', 'Tel', 'S', 'Nac', 'Tur'];
      else
        _cabecera = ['ISBN', 'Tit', 'Aut', 'Edi', 'Año', 'Ej'];
    });
    await conn.close();
  }

  @override
  void initState() {
    super.initState();
    _leer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Listado ${widget.tipo}')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: _cabecera
              .map(
                (c) => DataColumn(
                  label: Text(
                    c,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
              .toList(),
          rows: _filas
              .map(
                (f) => DataRow(
                  cells: f
                      .map((celda) => DataCell(Text(celda.toString())))
                      .toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
