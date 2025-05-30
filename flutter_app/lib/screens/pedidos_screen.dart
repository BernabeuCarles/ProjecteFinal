import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'detalle_pedido_screen.dart';

class PedidosScreen extends StatefulWidget {
  final int clienteId;
  final String token;

  PedidosScreen({required this.clienteId, required this.token});

  @override
  _PedidosScreenState createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  List<dynamic> pedidos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPedidos();
  }

  Future<void> fetchPedidos() async {
    final url = Uri.parse(
        'http://10.0.2.2:3000/api/clientes/${widget.clienteId}/pedidos');

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
          pedidos = data;
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar pedidos');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Icon getEstadoIcono(String estado, bool pagado) {
    if (estado == 'cancel') {
      return Icon(Icons.cancel, color: Colors.red);
    } else if (estado == 'sale' || estado == 'done') {
      return pagado
          ? Icon(Icons.attach_money, color: Colors.green)
          : Icon(Icons.check_circle_outline, color: Colors.orange);
    } else {
      return Icon(Icons.hourglass_empty, color: Colors.grey);
    }
  }

  Widget buildPedidoCard(Map<String, dynamic> pedido) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: getEstadoIcono(pedido['estado'], pedido['pagado']),
        title: Text(
          pedido['name'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Total: ${pedido['total'].toStringAsFixed(2)}€\nFecha: ${pedido['fecha'].substring(0, 10)}',
        ),
        isThreeLine: true,
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetallePedidoScreen(
                pedidoId: pedido['id'],
                token: widget.token,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Últimos Pedidos'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pedidos.isEmpty
              ? Center(child: Text('No hay pedidos para mostrar'))
              : ListView.builder(
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) =>
                      buildPedidoCard(pedidos[index]),
                ),
    );
  }
}
