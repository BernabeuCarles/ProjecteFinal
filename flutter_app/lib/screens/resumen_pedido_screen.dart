import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:interficie/providers/pedido_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ResumenPedidoScreen extends StatelessWidget {
  final Map<String, dynamic> cliente;
  final String token;

  const ResumenPedidoScreen({
    required this.cliente,
    required this.token,
  });

  Future<void> _enviarPedido(BuildContext context) async {
    final pedidoProvider = Provider.of<PedidoProvider>(context, listen: false);
    final pedido = pedidoProvider.items;

    final lineas = pedido.map((item) {
      return {
        'productoId': item.producto.id,
        'nombreProducto': item.producto.name,
        'cantidad': item.cantidad,
        'precioUnitario': item.producto.listPrice,
      };
    }).toList();

    final payload = {
      'clienteId': cliente['id'],
      'lineas': lineas,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/pedidos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pedidoId = data['pedidoId'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Pedido enviado correctamente (ID: $pedidoId)')),
        );

        pedidoProvider.limpiarPedido();
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el pedido')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo conectar al servidor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = Provider.of<PedidoProvider>(context);
    final pedido = pedidoProvider.items;
    final total = pedidoProvider.total;

    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen del Pedido'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Cliente: ${cliente['name']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: pedido.length,
                itemBuilder: (context, index) {
                  final item = pedido[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.producto.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('Cantidad: ${item.cantidad}'),
                              ],
                            ),
                          ),
                          Text(
                            '${(item.producto.listPrice * item.cantidad).toStringAsFixed(2)}€',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Text(
              'Total: ${total.toStringAsFixed(2)}€',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: 220,
              height: 60,
              child: ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text('Confirmar Pedido', style: TextStyle(fontSize: 18)),
                onPressed: () => _enviarPedido(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
