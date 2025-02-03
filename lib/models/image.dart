class ImageCustom {
  final int? id; // Pode ser nulo para novos registros
  final int propertyId;
  final String path;

  ImageCustom({
    this.id,
    required this.propertyId,
    required this.path,
  });

  // Converte um Map (como os resultados de uma consulta ao banco) para um objeto ImageCustom
  factory ImageCustom.fromMap(Map<String, dynamic> map) {
    return ImageCustom(
      id: map['id'] as int?,
      propertyId: map['property_id'] as int,
      path: map['path'] as String,
    );
  }

  // Converte o objeto ImageCustom para um Map para ser salvo no banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'path': path,
    };
  }
}
