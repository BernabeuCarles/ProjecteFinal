import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class NuevoClienteScreen extends StatefulWidget {
  final int comercialId;
  final String token;

  const NuevoClienteScreen({
    Key? key,
    required this.comercialId,
    required this.token,
  }) : super(key: key);

  @override
  _NuevoClienteScreenState createState() => _NuevoClienteScreenState();
}

class _NuevoClienteScreenState extends State<NuevoClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _empresaController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _calleController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _provinciaController = TextEditingController();
  final _paisController = TextEditingController();
  final _cpController = TextEditingController();
  bool _isLoading = false;

  Future<void> crearCliente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('http://10.0.2.2:3000/api/clientes');
    final payload = {
      'name': _nombreController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _telefonoController.text.trim(),
      'company_name': _empresaController.text.trim(),
      'street': _calleController.text.trim(),
      'city': _ciudadController.text.trim(),
      'state': _provinciaController.text.trim(),
      'country': _paisController.text.trim(),
      'zip': _cpController.text.trim(),
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode(payload),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newId = data['id'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cliente creado (ID: $newId)'),
          backgroundColor: Colors.lightBlue[300],
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } else {
      final error = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error['error'] ?? 'Desconocido'}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _empresaController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _calleController.dispose();
    _ciudadController.dispose();
    _provinciaController.dispose();
    _paisController.dispose();
    _cpController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.lightBlue[700]),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.lightBlue.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.lightBlue.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Cliente'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: _inputDecoration('Nombre'),
                validator: (v) => v!.isEmpty ? 'Ingrese un nombre' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _empresaController,
                decoration: _inputDecoration('Nombre de Empresa'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingrese un email';
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!regex.hasMatch(v)) return 'Email no válido';
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _telefonoController,
                decoration: _inputDecoration('Teléfono'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v!.isEmpty ? 'Ingrese un teléfono' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _calleController,
                decoration: _inputDecoration('Calle'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _ciudadController,
                decoration: _inputDecoration('Ciudad'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _provinciaController,
                decoration: _inputDecoration('Provincia'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _paisController,
                decoration: _inputDecoration('País'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _cpController,
                decoration: _inputDecoration('Código Postal'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: SizedBox(
                        width: 220,
                        height: 60,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.person_add),
                          label: Text('Crear Cliente',
                              style: TextStyle(fontSize: 18)),
                          onPressed: crearCliente,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
