import 'package:reservas_app/models/address.dart';
import 'package:reservas_app/services/db_service.dart';
import 'package:reservas_app/services/via_cep_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AddressService {
  final DatabaseService _databaseService = DatabaseService();
  final ViaCepService _viaCepService = ViaCepService();

  Future<Address> getAddress(String cep) async {
    final cleanedCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanedCep.length != 8) {
      throw ArgumentError('CEP inválido');
    }

    Address newAddress = await _viaCepService.viaCep(cleanedCep);
    int addressId = await insertAddress(newAddress);

    return newAddress.copyWith(id: addressId);
  }

  /// Insere um novo registro de endereço no banco de dados.
  Future<int> insertAddress(Address address) async {
    final db = await _databaseService.getDatabaseInstance();

    final int id = await db.insert(
        'address', address.toMap(), // Dados do endereço convertidos para Map
        conflictAlgorithm: ConflictAlgorithm.ignore);

    print('Endereço inserido com sucesso com ID $id.');
    return id;
  }
}
