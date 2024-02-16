import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'RegisterRequest.dart';
import 'register_page.dart'; // Importa la página de registro
import 'HomePage.dart';
import 'token_storage.dart'; // Importa el TokenStorage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de sesión'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de usuario',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  authService.login(LoginRequest(
                    username: _usernameController.text,
                    password: _passwordController.text,
                  )).then((response) {
                    // Guardar el token después del inicio de sesión exitoso
                    tokenStorage.saveToken(response.token);
                    // Redirigir a la página de inicio después del inicio de sesión exitoso
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  }).catchError((error) {
                    // Manejar errores
                  });
                },
                child: Text('Iniciar sesión'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text('Crear una cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
