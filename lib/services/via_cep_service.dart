import 'package:reservas_app/models/address.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViaCepService {
  Future<Address> viaCep(String cep) async {
    // Remove caracteres não numéricos

    final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Falha ao buscar CEP: ${response.statusCode}');
    }

    final jsonResponse = json.decode(response.body);

    if (jsonResponse.containsKey('erro') && jsonResponse['erro']) {
      throw Exception('CEP não encontrado');
    }

    return Address.fromJson(jsonResponse);
  }
}
