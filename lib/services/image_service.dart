import 'package:reservas_app/models/image.dart';
import 'package:reservas_app/services/db_service.dart';

class ImageService {
  final DatabaseService _databaseService = DatabaseService();

  // Função para inserir uma imagem na tabela 'images'
  Future<int> insertImage(Image image) async {
    final db = await _databaseService.getDatabaseInstance();
    final int id = await db.insert(
      'images',
      image.toMap(), // Mapeia o objeto Image para um Map
    );

    print('Imagem inserida com sucesso com ID $id.');

    return id;
  }
}
