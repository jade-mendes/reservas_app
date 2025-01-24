import 'package:reservas_app/models/property.dart';
import 'package:reservas_app/services/db_service.dart';

class PropertyService {
  final DatabaseService _databaseService = DatabaseService();

  /// Busca propriedades associadas a um determinado userId.
  Future<List<Property>> getPropertiesByUserId(int userId) async {
    final db = await _databaseService.getDatabaseInstance();

    // Query para buscar as propriedades associadas ao userId.
    final List<Map<String, dynamic>> maps = await db.query(
      'property', // Nome da tabela
      where: 'user_id = ?', // Condição para filtrar pelo userId
      whereArgs: [userId], // Argumentos da condição
    );

    // Converte a lista de mapas para uma lista de objetos Property.
    return maps.map((map) => Property.fromMap(map)).toList();
  }
}
