import 'package:flutter/material.dart';
import 'package:reservas_app/models/property.dart';
import 'package:reservas_app/services/db_service.dart';

class PropertyService {
  final DatabaseService _databaseService = DatabaseService();

  /// Insere um novo registro de propriedade no banco de dados.
  Future<int> insertProperty(Property property) async {
    final db = await _databaseService.getDatabaseInstance();

    final int id = await db.insert(
      'property',
      property.toMap(), // Dados da propriedade convertidos para Map
    );

    print('Propriedade inserida com sucesso com ID $id.');
    return id;
  }

  /// Atualiza um registro de propriedade no banco de dados.
  Future<void> updateProperty(Property property) async {
    final db = await _databaseService.getDatabaseInstance();

    if (property.id == null) {
      throw ArgumentError(
          'A propriedade precisa de um ID para ser atualizada.');
    }

    await db.update(
      'property',
      property.toMap(), // Dados da propriedade convertidos para Map
      where: 'id = ?',
      whereArgs: [property.id],
    );

    print('Propriedade com ID ${property.id} foi atualizada com sucesso.');
  }

  /// Deleta uma propriedade do banco de dados pelo ID.
  Future<void> deletePropertyById(int propertyId) async {
    final db = await _databaseService.getDatabaseInstance();
    try {
      // Deleta todos os registros da tabela images relacionadas à propriedade.
      await db.delete(
        'images',
        where: 'property_id = ?',
        whereArgs: [propertyId],
      );
      print(
          'Images relacionados à propriedade com ID $propertyId foram deletados.');

      // Deleta todos os registros da tabela booking relacionados à propriedade.
      await db.delete(
        'booking',
        where: 'property_id = ?',
        whereArgs: [propertyId],
      );
      print(
          'Bookings relacionados à propriedade com ID $propertyId foram deletados.');

      await db.delete(
        'property',
        where: 'id = ?',
        whereArgs: [propertyId],
      );

      print('Propriedade com ID $propertyId foi deletada com sucesso.');
    } catch (e) {
      print("Erro ao deletar propriedade: $e");
    }
  }

  /// Busca propriedades associadas a um determinado userId.
  Future<List<Property>> getPropertiesByUserId(int userId) async {
    final db = await _databaseService.getDatabaseInstance();

    final List<Map<String, dynamic>> maps = await db.rawQuery("""
      SELECT DISTINCT property.*, address.* 
      FROM property
      INNER JOIN address ON property.address_id = address.id
      WHERE property.user_id = ?
    """, [userId]);

    // Converte a lista de mapas para uma lista de objetos Property.
    return maps.map((map) => Property.fromMap(map)).toList();
  }

  Future<List<Property>> getAllProperties() async {
    return filterProperties({});
  }

  /// Filtra propriedades com base em checkinDate, checkoutDate, uf, localidade e bairro.
  Future<List<Property>> filterProperties(Map<String, dynamic> filters) async {
    final checkinDate = filters['checkinDate'] as DateTime?;
    final checkoutDate = filters['checkoutDate'] as DateTime?;
    final uf = filters['uf'] as String?;
    final localidade = filters['localidade'] as String?;
    final bairro = filters['bairro'] as String?;
    final guests = filters['guests'] as int?;
    final priceRange = filters['priceRange'] as RangeValues?;

    final db = await _databaseService.getDatabaseInstance();

    // Montar a query base e os argumentos dinamicamente
    final StringBuffer queryBuffer = StringBuffer("""
      SELECT DISTINCT property.*, address.* 
      FROM property
      INNER JOIN address ON property.address_id = address.id
      LEFT JOIN booking ON property.id = booking.property_id
      WHERE 1 = 1
    """);

    final List<dynamic> args = [];

    // Adiciona filtros dinamicamente
    if (checkinDate != null && checkoutDate != null) {
      queryBuffer.write("""
        AND NOT EXISTS (
          SELECT 1
          FROM booking
          WHERE booking.property_id = property.id
            AND (
              (booking.checkin_date <= ? AND booking.checkout_date >= ?) OR
              (booking.checkin_date <= ? AND booking.checkout_date >= ?) OR
              (booking.checkin_date >= ? AND booking.checkout_date <= ?)
            )
        )
      """);
      args.addAll([
        "${checkoutDate.toLocal()}".split(' ')[0],
        "${checkinDate.toLocal()}".split(' ')[0],
        "${checkinDate.toLocal()}".split(' ')[0],
        "${checkoutDate.toLocal()}".split(' ')[0],
        "${checkinDate.toLocal()}".split(' ')[0],
        "${checkoutDate.toLocal()}".split(' ')[0],
      ]);
    }

    if (uf != null && uf.trim().isNotEmpty) {
      queryBuffer.write(""" AND address.uf = ? """);
      args.add(uf);
    }

    if (localidade != null && localidade.trim().isNotEmpty) {
      queryBuffer.write(""" AND address.localidade = ? """);
      args.add(localidade);
    }

    if (bairro != null && bairro.trim().isNotEmpty) {
      queryBuffer.write(""" AND address.bairro = ? """);
      args.add(bairro);
    }

    if (guests != null) {
      queryBuffer.write(""" AND property.max_guest >= ? """);
      args.add(guests);
    }

    if (priceRange != null) {
      queryBuffer.write("""
        AND (property.price <= ? AND property.price >= ?)
      """);
      args.add(priceRange.end);
      args.add(priceRange.start);
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
