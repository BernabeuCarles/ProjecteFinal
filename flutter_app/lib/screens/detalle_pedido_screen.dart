import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetallePedidoScreen extends StatefulWidget {
  final int pedidoId;
  final String token;

  DetallePedidoScreen({required this.pedidoId, required this.token});

  @override
  _DetallePedidoScreenState createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  List<dynamic> detalles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetallePedido();
  }

  Future<void> fetchDetallePedido() async {
    final url =
        Uri.parse('http://10.0.2.2:3000/api/pedidos/${widget.pedidoId}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          detalles = data;
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar detalle del pedido');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildDetalleCard(Map<String, dynamic> item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          item['nombre_producto'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(item['descripcion']),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Cantidad: ${item['cantidad']}'),
            SizedBox(height: 4),
            Text('Total: €${item['total'].toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Pedido'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : detalles.isEmpty
              ? Center(child: Text('No hay detalles para mostrar'))
              : ListView.builder(
                  itemCount: detalles.length,
                  itemBuilder: (context, index) =>
                      buildDetalleCard(detalles[index]),
                ),
    );
  }
}
