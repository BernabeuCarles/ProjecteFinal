import 'package:flutter/material.dart';
import 'package:interficie/screens/info_cliente_screen.dart';
import 'pedidos_screen.dart';
import 'realizar_pedido_screen.dart';
import 'login_screen.dart'; // Para redirigir al cerrar sesión
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClienteMenuScreen extends StatelessWidget {
  final Map<String, dynamic> cliente;
  final String token;

  const ClienteMenuScreen({
    required this.cliente,
    required this.token,
  });

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cerrar sesión'),
        content: Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
            child: Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cliente: ${cliente['name']}'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildButton(context, Icons.add_shopping_cart, 'Realizar Pedido',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RealizarPedidoScreen(
                      cliente: cliente,
                      token: token,
                    ),
                  ),
                );
              }),
              buildButton(context, Icons.receipt, 'Últimos Pedidos', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PedidosScreen(
                      clienteId: cliente['id'],
                      token: token,
                    ),
                  ),
                );
              }),
              buildButton(context, Icons.info_outline, 'Mostrar Info Cliente',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfoClienteScreen(
                      clienteId: cliente['id'],
                      clienteNombre: cliente['name'],
                      token: token,
                    ),
                  ),
                );
              }),
              buildButton(context, Icons.note_add, 'Añadir Nota Rápida',
                  () async {
                final notaRapida = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    final controller = TextEditingController();
                    return AlertDialog(
                      title: Text('Escribir nota'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        maxLines: 3,
                        decoration:
                            InputDecoration(hintText: 'Escribe una nota'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, null),
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, controller.text.trim()),
                          child: Text('Guardar'),
                        ),
                      ],
                    );
                  },
                );

                if (notaRapida != null && notaRapida.isNotEmpty) {
                  final url = Uri.parse(
                      'http://10.0.2.2:3000/api/clientes/${cliente['id']}/notas');

                  final respuesta = await http.post(
                    url,
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                    body: json.encode({'nota': notaRapida}),
                  );

                  if (respuesta.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Nota añadida con éxito')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al añadir nota')),
                    );
                  }
                }
              }),
              buildButton(context, Icons.logout, 'Cerrar sesión', () {
                _confirmarCerrarSesion(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        width: 220,
        height: 60,
        child: ElevatedButton.icon(
          icon: Icon(icon),
          label: Text(label, style: TextStyle(fontSize: 18)),
          onPressed: onTap,
        ),
      ),
    );
  }
}
