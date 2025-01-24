class Address {
  final int? id; // Pode ser nulo para novos registros
  final String cep;
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;
  final String estado;

  Address({
    this.id,
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
    required this.estado,
  });

  // Converte um Map (como os resultados de uma consulta ao banco) para um objeto Address
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as int?,
      cep: map['cep'] as String,
      logradouro: map['logradouro'] as String,
      bairro: map['bairro'] as String,
      localidade: map['localidade'] as String,
      uf: map['uf'] as String,
      estado: map['estado'] as String,
    );
  }

  // Converte o objeto Address para um Map para ser salvo no banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cep': cep,
      'logradouro': logradouro,
      'bairro': bairro,
      'localidade': localidade,
      'uf': uf,
      'estado': estado,
    };
  }
}
