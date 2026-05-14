import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

void main() {
  runApp(const BibliotecaApp());
}

// Variables globales para la sesión
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

// --- CONEXIÓN A BASE DE DATOS ---
Future<Connection> _obtenerConexion() async {
  return await Connection.open(
    Endpoint(
      host: '127.0.0.1', // localhost
      port: 5432,
      database: 'Biblioteca',
      username: 'postgres',
      password: 'taco123',
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );
}

// ==========================================================
// 1. PANTALLA DE LOGIN (Interfaz Principal)
// ==========================================================
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
        //////////////////////////////modificar contrasenia 
        Sql.named('SELECT * FROM "Usuario" WHERE nombre_del_usuario = @u AND contraseña = @p'),
        parameters: {
          'u': _userController.text,
          'p': _passwordController.text,
        },
      );
      await conn.close();

      if (result.isNotEmpty) {
        usuarioActivo = _userController.text;
        // Asignación de roles basada en el segundo código
        
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

// ==========================================================
// 2. DASHBOARD / HOME (Menú General con Drawer)
// ==========================================================
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
      // MENÚ GENERAL (Drawer de 3 líneas)
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
            
            // Opciones dinámicas según el rol
            if (rolActivo == 'ADMIN') ...[
              _crearItemMenu(context, 'Gestión de Alumnos', Icons.school, 'ALUMNOS'),
              _crearItemMenu(context, 'Gestión de Profesores', Icons.work, 'PROFESORES'),
              _crearItemMenu(context, 'Gestión de Empleados', Icons.badge, 'EMPLEADOS'),
            ],
            if (rolActivo == 'EMPLEADO' || rolActivo == 'ADMIN') ...[
              _crearItemMenu(context, 'Gestión de Libros', Icons.menu_book, 'LIBROS'),
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

  // Helper para generar las opciones del Drawer y navegar a sus respectivas pantallas
  Widget _crearItemMenu(BuildContext context, String titulo, IconData icono, String modulo) {
    return ListTile(
      leading: Icon(icono, color: Colors.indigo),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {
        Navigator.pop(context); // Cierra el Drawer
        Navigator.push(context, MaterialPageRoute(builder: (context) => SubMenuScreen(modulo: modulo)));
      },
    );
  }
}

// ==========================================================
// 3. PANTALLA DE SUBMENÚ (Cada menú tiene la suya)
// ==========================================================
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
        children: [
          _opcion(
            context,
            'Registrar $modulo',
            Icons.add_circle_outline,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => FormularioScreen(tipo: modulo))),
          ),
          _opcion(context, 'Consulta Individual', Icons.person_search, () {}),
          _opcion(
            context,
            'Consulta General',
            Icons.format_list_bulleted,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => TablaScreen(tipo: modulo))),
          ),
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

// ==========================================================
// 4. FORMULARIOS DINÁMICOS
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
        const SnackBar(content: Text('Guardado en la Base de Datos con éxito'), backgroundColor: Colors.green),
      );
      
      // Limpiar campos después de guardar
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

// ==========================================================
// 5. TABLAS DINÁMICAS
// ==========================================================
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
    try {
      final conn = await _obtenerConexion();
      
      String t = "";
      if (widget.tipo == 'ALUMNOS') t = 'Alumno';
      else if (widget.tipo == 'PROFESORES') t = 'Profesor';
      else if (widget.tipo == 'EMPLEADOS') t = 'Empleado';
      else if (widget.tipo == 'LIBROS') t = 'Libro';

      final res = await conn.execute('SELECT * FROM $t');
      
      setState(() {
        _filas = res.map((r) => r.toList()).toList();
        
        if (widget.tipo == 'ALUMNOS') {
          _cabecera = ['Cod', 'Nom', 'Car', 'Mail', 'Dir', 'Tel', 'S', 'Nac'];
        } else if (widget.tipo == 'PROFESORES') {
          _cabecera = ['Cod', 'Nom', 'Dir', 'Tel', 'S', 'Nac', 'Dep', 'Mail'];
        } else if (widget.tipo == 'EMPLEADOS') {
          _cabecera = ['Cod', 'Nom', 'Dir', 'Tel', 'S', 'Nac', 'Tur'];
        } else {
          _cabecera = ['ISBN', 'Tit', 'Aut', 'Edi', 'Año', 'Ej'];
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
    _leer();
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
                          String valor = celda is DateTime ? "${celda.year}-${celda.month.toString().padLeft(2, '0')}-${celda.day.toString().padLeft(2, '0')}" : celda.toString();
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

