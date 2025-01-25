import 'package:reservas_app/models/booking.dart';
import 'package:reservas_app/services/db_service.dart';

class BookingService {
  final DatabaseService _databaseService = DatabaseService();

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
