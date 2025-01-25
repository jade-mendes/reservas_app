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

  /// Filtra propriedades com base em checkinDate, checkoutDate, uf, localidade e bairro.
  Future<List<Property>> filterProperties({
    String? checkinDate,
    String? checkoutDate,
    String? uf,
    String? localidade,
    String? bairro,
  }) async {
    final db = await _databaseService.getDatabaseInstance();

    // Montar a query base e os argumentos dinamicamente
    final StringBuffer queryBuffer = StringBuffer("""
      SELECT property.* 
      FROM property
      INNER JOIN address ON property.address_id = address.id
      LEFT JOIN booking ON property.id = booking.property_id
      WHERE 1 = 1
    """);

    final List<dynamic> args = [];

    // Adiciona filtros dinamicamente
    if (checkinDate != null && checkoutDate != null) {
      queryBuffer.write("""
        AND (booking.checkin_date IS NULL OR (booking.checkin_date > ? AND booking.checkin_date > ?) ) OR (booking.checkout_date < ? AND booking.checkout_date < ?)
      """);
      args.add(checkinDate);
      args.add(checkoutDate);
      args.add(checkinDate);
      args.add(checkoutDate);
    }

    if (uf != null) {
      queryBuffer.write(" AND address.uf = ?");
      args.add(uf);
    }

    if (localidade != null) {
      queryBuffer.write(" AND address.localidade = ?");
      args.add(localidade);
    }

    if (bairro != null) {
      queryBuffer.write(" AND address.bairro = ?");
      args.add(bairro);
    }

    // Executa a consulta com os filtros aplicados
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      queryBuffer.toString(),
      args,
    );

    // Converte os resultados para objetos Property
    return maps.map((map) => Property.fromMap(map)).toList();
  }
}
