class Booking {
  final int? id; // Pode ser nulo para novos registros
  final int userId;
  final int propertyId;
  final String checkinDate; // Armazenado como string no formato 'yyyy-MM-dd'
  final String checkoutDate; // Armazenado como string no formato 'yyyy-MM-dd'
  final int totalDays;
  final double totalPrice;
  final int amountGuest;
  final double? rating; // Opcional, pois pode ser nulo

  Booking({
    this.id,
    required this.userId,
    required this.propertyId,
    required this.checkinDate,
    required this.checkoutDate,
    required this.totalDays,
    required this.totalPrice,
    required this.amountGuest,
    this.rating,
  });

  // Converte um Map (como os resultados de uma consulta ao banco) para um objeto Booking
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      propertyId: map['property_id'] as int,
      checkinDate: map['checkin_date'] as String,
      checkoutDate: map['checkout_date'] as String,
      totalDays: map['total_days'] as int,
      totalPrice: map['total_price'] as double,
      amountGuest: map['amount_guest'] as int,
      rating: map['rating'] != null ? map['rating'] as double : null,
    );
  }

  // Converte o objeto Booking para um Map para ser salvo no banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'property_id': propertyId,
      'checkin_date': checkinDate,
      'checkout_date': checkoutDate,
      'total_days': totalDays,
      'total_price': totalPrice,
      'amount_guest': amountGuest,
      'rating': rating,
    };
  }
}
