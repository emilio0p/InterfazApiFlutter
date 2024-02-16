import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_storage.dart'; // Importa el TokenStorage
import 'login_page.dart'; // Importa la LoginPage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _publications = [];

  @override
  void initState() {
    super.initState();
    _fetchPublications(); // Llama a la función para obtener las publicaciones cuando se inicializa la página
  }

  Future<void> _fetchPublications() async {
    final token = await tokenStorage.getToken(); // Obtiene el token del TokenStorage
    if (token == null) {
      // Si no hay token, muestra un mensaje y retorna
      print('No hay token disponible');
      return;
    }

    final url = Uri.parse('http://localhost:8080/api/v1/publications');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token', // Adjunta el token en el encabezado de la solicitud
      },
    );

    if (response.statusCode == 200) {
      // Si la solicitud fue exitosa, analiza la respuesta JSON
      final List<dynamic> publications = jsonDecode(response.body);
      setState(() {
        _publications = publications; // Actualiza la lista de publicaciones
      });
    } else {
      // Si la solicitud falla, muestra un mensaje de error
      print('Error al obtener las publicaciones: ${response.statusCode}');
    }
  }

  Future<void> _logout() async {
    await tokenStorage.deleteToken(); // Elimina el token del TokenStorage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Redirige al usuario a la página de inicio de sesión (LoginPage)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Llama a la función _logout al presionar el botón
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _publications.length,
        itemBuilder: (context, index) {
          final publication = _publications[index];
          return Card(
            child: ListTile(
              title: Text(publication['text']),
              subtitle: Text('Author: ${publication['author']['username']}'),
            ),
          );
        },
      ),
    );
  }
}
