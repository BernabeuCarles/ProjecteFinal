import 'package:flutter/material.dart';
import 'cliente_menu_screen.dart';
import 'nuevo_cliente_screen.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClientesScreen extends StatefulWidget {
  final int userId;
  final String token;

  const ClientesScreen({
    Key? key,
    required this.userId,
    required this.token,
  }) : super(key: key);

  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<Map<String, dynamic>> clientes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClientes();
  }

  Future<void> fetchClientes() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/clientes');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          clientes = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar clientes');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _confirmarCerrarSesion() {
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

  Widget buildClienteCard(Map<String, dynamic> cliente) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          cliente['name'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          cliente['phone'] is String ? cliente['phone'] : 'Sin teléfono',
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClienteMenuScreen(
                cliente: cliente,
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
        title: Text('Selecciona un Cliente'),
        backgroundColor: Colors.lightBlue[200],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _confirmarCerrarSesion,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ListView.builder(
                        itemCount: clientes.length,
                        itemBuilder: (context, index) =>
                            buildClienteCard(clientes[index]),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                width: 220,
                height: 60,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.person_add),
                  label: Text('Nuevo Cliente', style: TextStyle(fontSize: 18)),
                  onPressed: () async {
                    final creado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NuevoClienteScreen(
                          comercialId: widget.userId,
                          token: widget.token,
                        ),
                      ),
                    );
                    if (creado == true) {
                      fetchClientes();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
