import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_storage.dart'; // Importa el TokenStorage
import 'login_page.dart'; // Importa la página de inicio de sesión

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
        _publications.clear(); // Vacía la lista existente
        _publications.addAll(publications); // Llena la lista con los datos actualizados
      });
    } else {
      // Si la solicitud falla, muestra un mensaje de error
      print('Error al obtener las publicaciones: ${response.statusCode}');
    }
  }

  Future<void> _addPublication(String text, String imageUrl) async {
    final token = await tokenStorage.getToken(); // Obtiene el token del TokenStorage
    if (token == null) {
      // Si no hay token, muestra un mensaje y retorna
      print('No hay token disponible');
      return;
    }

    final url = Uri.parse('http://localhost:8080/api/v1/publications');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token', // Adjunta el token en el encabezado de la solicitud
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'text': text,
        'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode == 200) {
      // Si la solicitud fue exitosa, muestra un mensaje de éxito
      print('Publicación agregada correctamente');
      _fetchPublications(); // Vuelve a cargar todas las publicaciones después de agregar una nueva publicación
    } else {
      // Si la solicitud falla, muestra un mensaje de error
      print('Error al agregar la publicación: ${response.statusCode}');
    }
  }

  Future<void> _logout() async {
    await tokenStorage.deleteToken(); // Elimina el token almacenado
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Navega a la página de inicio de sesión
    );
  }

  Future<void> _addComment(int publicationId, String text) async {
    final token = await tokenStorage.getToken(); // Obtiene el token del TokenStorage
    if (token == null) {
      // Si no hay token, muestra un mensaje y retorna
      print('No hay token disponible');
      return;
    }

    final url = Uri.parse('http://localhost:8080/api/v1/comments/$publicationId');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token', // Adjunta el token en el encabezado de la solicitud
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'text': text,
      }),
    );

    if (response.statusCode == 200) {
      // Si la solicitud fue exitosa, muestra un mensaje de éxito
      print('Comentario agregado correctamente');
      _fetchPublications(); // Vuelve a cargar todas las publicaciones después de agregar un nuevo comentario
    } else {
      // Si la solicitud falla, muestra un mensaje de error
      print('Error al agregar el comentario: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPublications, // Configura la función de actualización al deslizar hacia abajo
        child: ListView.builder(
          itemCount: _publications.length,
          itemBuilder: (context, index) {
            final publication = _publications[index];
            return _PublicationCard(
              key: Key(publication['id'].toString()), // Utiliza un Key único para cada carta de publicación
              publication: publication,
              addComment: _addComment, // Pasa la función de agregar comentario al _PublicationCard
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Muestra un diálogo para ingresar detalles de la nueva publicación
          showDialog(
            context: context,
            builder: (context) {
              String text = '';
              String imageUrl = '';

              return AlertDialog(
                title: Text('Nueva Publicación'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) => text = value,
                      decoration: InputDecoration(labelText: 'Texto'),
                    ),
                    SizedBox(height: 10.0),
                    TextField(
                      onChanged: (value) => imageUrl = value,
                      decoration: InputDecoration(labelText: 'URL de la imagen (opcional)'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Cierra el diálogo sin hacer nada
                    },
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _addPublication(text, imageUrl); // Agrega la nueva publicación
                      Navigator.pop(context); // Cierra el diálogo
                    },
                    child: Text('Publicar'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue, // Fondo del botón en azul
      ),
    );
  }
}

class _PublicationCard extends StatelessWidget {
  final dynamic publication;
  final Function(int, String) addComment;

  const _PublicationCard({Key? key, required this.publication, required this.addComment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(publication['text']),
            subtitle: Text('Author: ${publication['author']['username']}'),
          ),
          SizedBox(height: 10.0),
          ..._buildComments(publication['comments']),
          SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              // Muestra un diálogo para ingresar un nuevo comentario
              showDialog(
                context: context,
                builder: (context) {
                  String commentText = '';

                  return AlertDialog(
                    title: Text('Nuevo Comentario'),
                    content: TextField(
                      onChanged: (value) => commentText = value,
                      decoration: InputDecoration(labelText: 'Comentario'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Cierra el diálogo sin hacer nada
                        },
                        child: Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          addComment(publication['id'], commentText); // Agrega el nuevo comentario
                          Navigator.pop(context); // Cierra el diálogo
                        },
                        child: Text('Enviar'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Añadir Comentario'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildComments(List<dynamic> comments) {
    return comments.map((comment) {
      return ListTile(
        title: Text(comment['text']),
        subtitle: Text('Author: ${comment['username']}'),
        trailing: Text(comment['creationDate']),
      );
    }).toList();
  }
}
