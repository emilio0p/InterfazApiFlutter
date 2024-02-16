import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = FlutterSecureStorage();

  // Guardar token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  // Obtener token
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Eliminar token
  Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }
}

// Uso de TokenStorage
final tokenStorage = TokenStorage();
