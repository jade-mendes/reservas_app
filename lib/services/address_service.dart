import 'package:reservas_app/models/address.dart';
import 'package:reservas_app/services/db_service.dart';

class AddressService {
  final DatabaseService _databaseService = DatabaseService();

  /// Insere um novo registro de endereço no banco de dados.
  Future<int> insertAddress(Address address) async {
    final db = await _databaseService.getDatabaseInstance();

    final int id = await db.insert(
      'address',
      address.toMap(), // Dados do endereço convertidos para Map
    );

    print('Endereço inserido com sucesso com ID $id.');
    return id;
  }

  Future<List<String>> getUFs() async {
    final db = await _databaseService.getDatabaseInstance();

    final StringBuffer queryBuffer = StringBuffer("""
      SELECT DISTINCT address.uf 
      FROM address
    """);

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      queryBuffer.toString(),
    );

    return maps.map((map) => map['uf'] as String).toList();
  }

  Future<List<String>> getLocalidades(String uf) async {
    final db = await _databaseService.getDatabaseInstance();

    final StringBuffer queryBuffer = StringBuffer("""
      SELECT DISTINCT address.localidade 
      FROM address
      WHERE address.uf = ?
    """);

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      queryBuffer.toString(), [uf]
    );

    return maps.map((map) => map['localidade'] as String).toList();
  }
}
