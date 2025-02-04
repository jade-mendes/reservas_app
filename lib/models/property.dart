import 'package:reservas_app/models/address.dart';

class Property {
  final int? id; // Pode ser nulo para novos registros
  final int userId;
  final int addressId;
  final String title;
  final String description;
  final int number;
  final String? complement; // Pode ser nulo
  final double price;
  final int maxGuest;
  final String thumbnail;
  final Address? address;

  Property({
    this.id,
    required this.userId,
    required this.addressId,
    required this.title,
    required this.description,
    required this.number,
    this.complement,
    required this.price,
    required this.maxGuest,
    required this.thumbnail,
    this.address,
  });

  // Converte um Map (como os resultados de uma consulta ao banco) para um objeto Property
  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      addressId: map['address_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      number: map['number'] as int,
      complement: map['complement'] as String?,
      price: map['price'] as double,
      maxGuest: map['max_guest'] as int,
      thumbnail: map['thumbnail'] as String,
      address: Address.fromMap(map),
    );
  }

  // Converte o objeto Property para um Map para ser salvo no banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'address_id': addressId,
      'title': title,
      'description': description,
      'number': number,
      'complement': complement,
      'price': price,
      'max_guest': maxGuest,
      'thumbnail': thumbnail,
    };
  }
}
