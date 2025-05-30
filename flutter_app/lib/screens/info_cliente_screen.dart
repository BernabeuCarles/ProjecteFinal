import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InfoClienteScreen extends StatefulWidget {
  final int clienteId;
  final String clienteNombre;
  final String token;

  const InfoClienteScreen({
    required this.clienteId,
    required this.clienteNombre,
    required this.token,
  });

  @override
  _InfoClienteScreenState createState() => _InfoClienteScreenState();
}

class _InfoClienteScreenState extends State<InfoClienteScreen> {
  Map<String, dynamic>? cliente;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarInformacionCliente();
  }

  Future<void> cargarInformacionCliente() async {
    final url = Uri.parse(
        'http://10.0.2.2:3000/api/clientes/${widget.clienteId}/informacion');

    final respuesta = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (respuesta.statusCode == 200) {
      final data = json.decode(respuesta.body);
      setState(() {
        cliente = data;
        cargando = false;
      });
    } else {
      setState(() {
        cargando = false;
        cliente = {'error': 'Error al cargar información del cliente'};
      });
    }
  }

  String limpiarHtml(String htmlText) {
    final exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlText.replaceAll(exp, '').trim();
  }

  Widget _buildInfoItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue[700],
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : 'No disponible',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información de ${widget.clienteNombre}'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: cargando
          ? Center(child: CircularProgressIndicator())
          : cliente == null || cliente!['error'] != null
              ? Center(
                  child: Text(
                    cliente!['error'] ?? 'Error desconocido',
                    style: TextStyle(fontSize: 18, color: Colors.redAccent),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildInfoItem('Nombre', cliente!['nombre']),
                              _buildInfoItem('Email', cliente!['email']),
                              _buildInfoItem('Teléfono', cliente!['telefono']),
                              _buildInfoItem('Móvil', cliente!['movil']),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildInfoItem('Calle', cliente!['calle']),
                              _buildInfoItem('Ciudad', cliente!['ciudad']),
                              _buildInfoItem(
                                  'Provincia', cliente!['provincia']),
                              _buildInfoItem(
                                  'Código Postal', cliente!['codigo_postal']),
                              _buildInfoItem('País', cliente!['pais']),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notas internas:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue[700],
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                cliente!['notas']?.isNotEmpty == true
                                    ? limpiarHtml(cliente!['notas'])
                                    : 'Sin notas disponibles.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
