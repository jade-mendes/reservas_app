class Image {
  final int? id; // Pode ser nulo para novos registros
  final int propertyId;
  final String path;

  Image({
    this.id,
    required this.propertyId,
    required this.path,
  });

  // Converte um Map (como os resultados de uma consulta ao banco) para um objeto Image
  factory Image.fromMap(Map<String, dynamic> map) {
    return Image(
      id: map['id'] as int?,
      propertyId: map['property_id'] as int,
      path: map['path'] as String,
    );
  }

  // Converte o objeto Image para um Map para ser salvo no banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'path': path,
    };
  }
}
