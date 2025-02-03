import 'package:reservas_app/services/db_service.dart';
import '../models/user.dart';

class UserService {
  final DatabaseService _databaseService = DatabaseService();

  // Função para criar um novo usuário na tabela 'user'
  Future<int> createUser(User user) async {
    final db = await _databaseService.getDatabaseInstance();

    // Verifica se já existe um usuário com o mesmo email
    final existingUser = await db.query(
      'user',
      where: 'email = ?',
      whereArgs: [user.email],
    );

    if (existingUser.isNotEmpty) {
      throw Exception('Email já cadastrado!');
    }

    return await db.insert(
      'user',
      user.toMap(), // Mapeia o objeto User para um Map
    );
  }

  // Função para autenticar um usuário com base no email e senha
  Future<User?> authenticateUser(String email, String password) async {
    final db = await _databaseService.getDatabaseInstance();

    // Busca o usuário pelo email
    final result = await db.query(
      'user',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isEmpty) {
      throw Exception("Usuário não encontrado.");
    }

    final user = User.fromMap(result.first);

    // Verifica se a senha fornecida corresponde à senha armazenada no banco
    if (user.password == password) {
      return user;
    } else {
      throw Exception("Usuário não encontrado.");
    }
  }
}
