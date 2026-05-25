import 'package:postgres/postgres.dart';

Future<Connection> obtenerConexion() async {
  return await Connection.open(
    Endpoint(
      host: '127.0.0.1',
      port: 5432,
      database: 'Biblioteca',
      username: 'postgres',
      password: '',
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );
}

// aqui guardamos la conexion con la base de datos postgres de manera local
// ademas en el pubspec.yaml tenemos la dependencia de postgres