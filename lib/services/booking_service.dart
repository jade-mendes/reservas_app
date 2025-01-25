import 'package:reservas_app/models/booking.dart';
import 'package:reservas_app/services/db_service.dart';

class BookingService {
  final DatabaseService _databaseService = DatabaseService();

  /// Insere um novo registro de booking no banco de dados.
  Future<int> insertBooking(Booking booking) async {
    final db = await _databaseService.getDatabaseInstance();

    final int id = await db.insert(
      'booking',
      booking.toMap(), // Dados do booking convertidos para Map
    );

    print('Booking inserido com sucesso com ID $id.');
    return id;
  }

  /// Filtra os bookings associados a um determinado userId.
  Future<List<Booking>> getBookingsByUserId(int userId) async {
    final db = await _databaseService.getDatabaseInstance();

    final List<Map<String, dynamic>> maps = await db.query(
      'booking',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Converte a lista de mapas para uma lista de objetos Booking.
    return maps.map((map) => Booking.fromMap(map)).toList();
  }
}
