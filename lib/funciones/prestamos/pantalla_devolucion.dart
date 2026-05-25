import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../../nucleo/conexion_bd.dart';
import 'package:postgres/postgres.dart';

class FormDevolverScreen extends StatefulWidget {
  const FormDevolverScreen({super.key});

  @override
  State<FormDevolverScreen> createState() => _FormDevolverScreenState();
}

class _FormDevolverScreenState extends State<FormDevolverScreen> {
  final _idPrestamo   = TextEditingController();
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
    String passwordApp    = 'uofvydxkvcuddpal';

    final smtpServer = gmail(emailRemitente, passwordApp);
    final message    = Message()
      ..from = Address(emailRemitente, 'BiblioTech Sistema')
      ..recipients.add(correoDestino)
      ..subject = 'Notificación de Multa por Retraso - BiblioTech'
      ..text    = 'Estimado usuario,\n\nAdjunto encontrará el recibo detallado de su multa por el retraso en la devolución de su préstamo con ID $id.\n\nDetalles del libro: $libroInfo\nTotal a Liquidar: \$$monto MXN.\n\nPor favor pase a caja a regularizar su situación.\n\nSaludos.'
      ..attachments.add(
        StreamAttachment(
          Stream.value(pdfBytes),
          'application/pdf',
          fileName: 'multa_retraso_$id.pdf',
        ),
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
      final conn = await obtenerConexion();

      final res = await conn.execute(
        Sql.named('SELECT fecha_limite, isbn, num_ejemplar, codigo_lector FROM prestamo WHERE id_prestamo = @id'),
        parameters: {'id': int.parse(_idPrestamo.text)},
      );

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

      String isbn       = res.first[1].toString();
      int numEjemplar   = int.tryParse(res.first[2].toString()) ?? 0;
      int codLector     = int.tryParse(res.first[3].toString()) ?? 0;

      DateTime entregaRaw = DateTime.parse(_fechaEntrega.text);
      DateTime limite     = DateTime(limiteRaw.year, limiteRaw.month, limiteRaw.day);
      DateTime entrega    = DateTime(entregaRaw.year, entregaRaw.month, entregaRaw.day);

      await conn.execute(
        Sql.named('UPDATE prestamo SET fecha_entrega = @fe WHERE id_prestamo = @id'),
        parameters: {'fe': _fechaEntrega.text, 'id': int.parse(_idPrestamo.text)},
      );

      if (entrega.isAfter(limite)) {
        int dias = entrega.difference(limite).inDays;

        final resLibro = await conn.execute(
          Sql.named('SELECT titulo FROM libro WHERE isbn = @isbn LIMIT 1'),
          parameters: {'isbn': isbn},
        );
        String tituloLibro = resLibro.isNotEmpty ? resLibro.first[0].toString() : "Libro Desconocido";
        String libroInfo   = "$tituloLibro (ISBN: $isbn, Ejemplar No: $numEjemplar)";

        String correoDestino  = "";
        double tarifaPorDia   = 0.0;
        String tipoLector     = "";

        var resCorreo = await conn.execute(
          Sql.named('SELECT correo FROM alumno WHERE codigo = @cod'),
          parameters: {'cod': codLector},
        );

        if (resCorreo.isNotEmpty) {
          correoDestino = resCorreo.first[0].toString();
          tarifaPorDia  = 5.0;
          tipoLector    = "Alumno";
        } else {
          resCorreo = await conn.execute(
            Sql.named('SELECT correo FROM profesor WHERE codigo = @cod'),
            parameters: {'cod': codLector},
          );
          if (resCorreo.isNotEmpty) {
            correoDestino = resCorreo.first[0].toString();
            tarifaPorDia  = 10.0;
            tipoLector    = "Profesor";
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
              child: ElevatedButton.icon(
                onPressed: _devolver,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.assignment_return, color: Colors.white),
                label: const Text('PROCESAR DEVOLUCIÓN', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Pantalla para procesar devoluciones. Compara la fecha de entrega con la fecha
// límite; si hay retraso, calcula la multa, genera un PDF y lo envía por correo.
