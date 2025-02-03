import 'package:reservas_app/models/image.dart';
import 'package:reservas_app/services/db_service.dart';

class ImageService {
  final DatabaseService _databaseService = DatabaseService();

  Future<int> insertImage(ImageCustom image) async {
    final db = await _databaseService.getDatabaseInstance();
    return await db.insert('images', image.toMap());
  }

  Future<void> updateImage(ImageCustom image) async {
    final db = await _databaseService.getDatabaseInstance();
    await db.update(
      'images',
      image.toMap(),
      where: 'id = ?',
      whereArgs: [image.id],
    );
  }

  Future<void> deleteImage(int id) async {
    final db = await _databaseService.getDatabaseInstance();
    await db.delete(
      'images',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ImageCustom>> getImagesByPropertyId(int propertyId) async {
    final db = await _databaseService.getDatabaseInstance();
    final List<Map<String, dynamic>> maps = await db.query(
      'images',
      where: 'property_id = ?',
      whereArgs: [propertyId],
    );
    return maps.map((map) => ImageCustom.fromMap(map)).toList();
  }
}
