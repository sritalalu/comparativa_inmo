import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generarYDescargarPDF(
      List<dynamic> resultados, 
      Map<String, String> infoPropiedad
  ) async {
    final pdf = pw.Document();
    
    final ByteData bytes = await rootBundle.load('assets/logo.png');
    final pw.MemoryImage logoImage = pw.MemoryImage(bytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(logoImage, infoPropiedad['agente'] ?? "Agente no asignado"),
              pw.SizedBox(height: 10),

              pw.Center(
                child: pw.Text("ANÁLISIS COMPARATIVO DE MERCADO",
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
              ),
              pw.SizedBox(height: 10),
              _buildSectionTitle("INFORMACIÓN PROPIEDAD ANALIZADA"),
              _buildFixedInfoRow([
                'DIRECCIÓN: ${infoPropiedad['direccion'] ?? "-"}',
                'PISO/DPTO: ${infoPropiedad['piso'] ?? "-"}',                
              ]),
              _buildFixedInfoRow([
                'LOCALIDAD: ${infoPropiedad['localidad'] ?? "-"}',
                'BARRIO: ${infoPropiedad['barrio'] ?? "-"}',
              ]),
              _buildFixedInfoRow([
                'TIPO PROPIEDAD: ${infoPropiedad['tipo'] ?? "-"}',
                'EXPENSAS: ${infoPropiedad['expensas'] ?? "-"}'
              ]),
              pw.SizedBox(height: 5),          
              _buildSectionTitle("DESCRIPCIÓN DE LA PROPIEDAD"),
              _buildFixedInfoRow([
                'ALQUILADO: ${infoPropiedad['alquilado'] ?? "-"}',
                'M2 CUBIERTOS: ${infoPropiedad['m2_cubiertos'] ?? "-"}',
                'M2 TERRENO: ${infoPropiedad['m2_terreno'] ?? "-"}',
                'ANTIGÜEDAD: ${infoPropiedad['antiguedad'] ?? "-"}'
              ]),
              _buildFixedInfoRow([
                'UBICACIÓN: ${infoPropiedad['ubicacion'] ?? "-"}',
                'CONSERV: ${infoPropiedad['conserv'] ?? "-"}',
                'LUZ: ${infoPropiedad['luz'] ?? "-"}',
                'AGUA: ${infoPropiedad['agua'] ?? "-"}',
                'GAS: ${infoPropiedad['gas'] ?? "-"}',
                'CLOACA: ${infoPropiedad['cloaca'] ?? "-"}'

              ]),
              _buildFixedInfoRow([
                'ORIENTACIÓN: ${infoPropiedad['orientacion'] ?? "-"}',
                'TÍTULO: ${infoPropiedad['titulo'] ?? "-"}'
              ]),
              pw.SizedBox(height: 20),

              pw.Text("COMPARATIVOS DETECTADOS", 
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              pw.SizedBox(height: 8),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: resultados.take(4).map((res) {
                  return pw.Container(
                    width: (PdfPageFormat.a4.width - 65) / 4,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.blue100, width: 0.5),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(3),
                          decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                          child: pw.Text("COMPARATIVO", 
                              textAlign: pw.TextAlign.center, 
                              style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          height: 50, 
                          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                          child: pw.Center(child: pw.Icon(pw.IconData(0xe3f4), size: 15, color: PdfColors.grey500))
                        ),
                        _buildDataField("DIRECCIÓN:", res['direccion'] ?? "S/D"),
                        _buildDataField("PRECIO:", "${res['moneda'] ?? ""} ${res['precio'] ?? "-"}"),
                        _buildDataField("M2 CUB:", "${res['superficieCubierta'] ?? "-"} m²"),
                        _buildDataField("TERRENO:", "${res['m2_terreno'] ?? "-"} m²"),
                        _buildDataField("PRECIO:", "${res['moneda'] ?? ""} ${res['precio'] ?? "-"}"),
                        _buildDataField("PRECIO M2:", "${res['moneda'] ?? ""} ${res['precio'] ?? "-"}"),
                        _buildDataField("COEFICIENTE:", "${res['moneda'] ?? ""} ${res['precio'] ?? "-"}"),
                        _buildDataField("AMBIENTES:", res['ambientes']?.toString() ?? "-"),
                        _buildDataField("ANTIGÜEDAD:", res['antiguedad']?.toString() ?? "-"),
                        _buildDataField("FUENTE:", res['fuente']?.toUpperCase() ?? "WEB"),
                        _buildDataField("DESCRIPCIÓN:", res['descripcion']?.toUpperCase() ?? "WEB"),
                      ],
                    ),
                  );
                }).toList(),
              ),
               pw.SizedBox(height: 20),

              pw.Text("GRÁFICO DE COMPARATIVOS", 
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            //  pw.SizedBox(height: 8),

              pw.Spacer(),
                            pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Informe generado por Chain Inmobiliaria", style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                  pw.Text("Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}", style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                ],
              )
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Tasacion_${infoPropiedad['propietario'] ?? "Inmueble"}.pdf',
    );
  }


  static pw.Widget _buildHeader(pw.MemoryImage logo, String nombreAgente) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue900, width: 1.5))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Image(logo, width: 60),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text("CHAIN INMOBILIARIA", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              pw.Text("AGENTE: $nombreAgente", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Text("Paseo Quattro, Torre 4, Local 1", style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        border: pw.Border.all(color: PdfColors.blue100, width: 0.5)
      ),
      child: pw.Center(child: pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
    );
  }

  static pw.Widget _buildFixedInfoRow(List<String> cells) {
    return pw.Row(
      children: cells.map((text) => pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue100, width: 0.5)),
          child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
        ),
      )).toList(),
    );
  }

  static pw.Widget _buildDataField(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 7), maxLines: 1, overflow: pw.TextOverflow.clip),
          pw.Divider(thickness: 0.2, color: PdfColors.grey300),
        ],
      ),
    );
  }
}