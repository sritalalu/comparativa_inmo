import 'package:comparative/features/pdf.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<TextEditingController> _linkControllers = [
    TextEditingController(),
  ];

  final Map<String, TextEditingController> _dataControllers = {
    'propietario': TextEditingController(),
    'prop_tel': TextEditingController(),
    'prop_email': TextEditingController(),
    'agente': TextEditingController(),
    'ag_tel': TextEditingController(),
    'ag_email': TextEditingController(),
    'direccion': TextEditingController(),
    'localidad': TextEditingController(),
    'tipo': TextEditingController(),
    'alquilado': TextEditingController(),
    'ubicacion': TextEditingController(),
    'orientacion': TextEditingController(),
    'titulo': TextEditingController(),
    'cloaca': TextEditingController(),
    'gas': TextEditingController(),
    'agua': TextEditingController(),
    'luz': TextEditingController(),
    'conserv': TextEditingController(),
    'antiguedad': TextEditingController(),
    'm2_cubiertos': TextEditingController(),
    'm2_terreno': TextEditingController(),
    'expensas': TextEditingController(),
    'barrio': TextEditingController(),
    'piso': TextEditingController(),

  };

  bool _loading = false;

  void _addUrlField() {
    setState(() => _linkControllers.add(TextEditingController()));
  }

  void _removeUrlField(int index) {
    if (_linkControllers.length > 1) {
      setState(() => _linkControllers.removeAt(index));
    }
  }

  Future<List<dynamic>> obtenerPrecios(List<String> urls) async {
    final response = await http.post(
      Uri.parse('http://localhost:5225/extraer-precios'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'urls': urls}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al procesar los links');
    }
  }

  Future<void> _procesarLinks() async {
    final links = _linkControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (links.isEmpty) return;

    setState(() => _loading = true);

    try {
      final resultados = await obtenerPrecios(links);

      final Map<String, String> infoPropiedad = _dataControllers.map(
        (key, controller) => MapEntry(key, controller.text),
      );

      await PdfService.generarYDescargarPDF(resultados, infoPropiedad);

      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _linkControllers.forEach((c) => c.dispose());
    _dataControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasación inmobiliaria')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionTitle("Datos de contacto"),
            _buildVerticalForm([
              _buildField('agente', 'Nombre agente'),
              _buildField('ag_tel', 'Teléfono agente'),
              _buildField('ag_email', 'Email agente'),
            ]),
            const SizedBox(height: 20),
             _buildSectionTitle("Datos del propietario"),
            _buildVerticalForm([
              _buildField('propietario', 'Nombre propietario'),
              _buildField('prop_tel', 'Teléfono propietario'),
              _buildField('prop_email', 'Email propietario'),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle("Información propiedad analizada"),
            _buildVerticalForm([
              _buildField('direccion', 'Dirección'),
              _buildField('localidad', 'Localidad'),
              _buildField('tipo', 'Tipo propiedad'),
              _buildField('piso', 'Piso'),
              _buildField('barrio', 'Barrio'),
              _buildField('expensas', 'Expensas'),
              _buildField('alquilado', 'Alquilado (Si/No)'),
              _buildField('m2_cubiertos', 'm2 cubiertos'),  
              _buildField('m2_terreno', 'm2 terreno'),           
              _buildField('antiguedad', 'Antigüedad'),
              _buildField('ubicacion', 'Ubicación'),
              _buildField('conserv', 'Conserv'),
              _buildField('luz', 'Luz'),
              _buildField('agua', 'Agua'),
              _buildField('gas', 'Gas'),
              _buildField('cloaca', 'Cloaca'),
              _buildField('orientacion', 'Orientación'),
              _buildField('titulo', 'Título'),
              
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle("Links comparativos"),
            ..._linkControllers.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          labelText: 'URL Comparativa ${entry.key + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeUrlField(entry.key),
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addUrlField,
              icon: const Icon(Icons.add),
              label: const Text("Añadir otra URL"),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _procesarLinks,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("PROCESAR Y GENERAR PDF"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

 Widget _buildVerticalForm(List<Widget> children) {
    return Column(
      children: children,
    );
  }

  Widget _buildField(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8), 
      child: TextField(
        controller: _dataControllers[key],
        style: const TextStyle(fontSize: 14), 
        decoration: InputDecoration(
          labelText: label,
          isDense: true, 
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
