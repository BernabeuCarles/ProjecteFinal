import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'clientes_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  final String apiUrl = 'http://10.0.2.2:3000/api/login';

  void _showMessage(String message, {bool isError = false}) {
    final color = isError ? Colors.redAccent : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _login() async {
    final username = _userController.text.trim();
    final password = _passController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Por favor, completa todos los campos', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userId = data['userId'];

        if (token != null && userId != null) {
          _showMessage('Inicio de sesión exitoso', isError: false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ClientesScreen(
                token: token,
                userId: userId,
              ),
            ),
          );
        } else {
          _showMessage('Faltan datos en la respuesta del servidor',
              isError: true);
        }
      } else {
        String errorMessage = 'Error al iniciar sesión';

        try {
          final error = jsonDecode(response.body);
          if (error['error'] != null) {
            errorMessage = error['error'];
          }
        } catch (_) {}

        _showMessage(errorMessage, isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Error de red o servidor no disponible', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/Logo.png',
                height: 300,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 24),
              TextField(
                controller: _userController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text('Iniciar Sesión'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
