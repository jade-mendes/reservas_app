import 'package:flutter/material.dart';
import 'package:reservas_app/models/property.dart';
import 'package:reservas_app/services/property_service.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});
  static String route = '/listProperty'; 
  @override
  PropertyListScreenState createState() => PropertyListScreenState();
}

class PropertyListScreenState extends State<PropertyListScreen> {
  List<Property> locacoes = []; // Lista de locações (você vai popular isso com dados do banco)
  List<Property> filteredLocacoes = []; // Lista filtrada para exibição
  TextEditingController searchController = TextEditingController();
  DateTime? checkinDate;
  DateTime? checkoutDate;
  String? uf;
  String? localidade;
  String? bairro;
  int? guests;
  RangeValues? priceRange;

  @override
  void initState(){
    super.initState();
    // Aqui você pode carregar as locações do banco de dados
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    final propertyService = PropertyService(); // Instância de PropertyService
    locacoes = await propertyService.getAllProperties(); // Chamada do método de instância
    setState(() {
      filteredLocacoes = locacoes;
    });
  }

  void filterLocacoes(String query) {
    setState(() {
      filteredLocacoes = locacoes
          .where((property) =>
              property.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Pesquisar...',
            border: InputBorder.none,
          ),
          onChanged: filterLocacoes,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Abrir caixa de diálogo de filtros
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredLocacoes.length,
        itemBuilder: (context, index) {
          final property = filteredLocacoes[index];
          return ListTile(
            // leading: Image.network(property.thumbnail), // URL da imagem
            title: Text(property.title),
            subtitle: Text('${property.addressId} - R\$ ${property.price}'),
            onTap: () {
              // Navegar para a página da locação
              // Navigator.push(...);
            },
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filtrar Locações'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: uf,
                      decoration: InputDecoration(labelText: 'Estado'),
                      items: ['Todos','SP', 'RJ', 'MG'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value == 'Todos' ? null : value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        uf = value;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: localidade,
                      decoration: InputDecoration(labelText: 'Cidade'),
                      items: ['Todos','São Paulo', 'Rio de Janeiro', 'Belo Horizonte'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value == 'Todos' ? null : value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        localidade = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Bairro'),
                      onChanged: (value) {
                        bairro = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Quantidade de Pessoas'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        guests = int.tryParse(value);
                      },
                    ),
                    ListTile(
                      title: Text('Data de Entrada'),
                      subtitle: Text(checkinDate != null ? "${checkinDate!.toLocal()}".split(' ')[0] : 'Selecione a data',),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            checkinDate = selectedDate;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text('Data de Saída'),
                      subtitle: Text(checkoutDate != null ? "${checkoutDate!.toLocal()}".split(' ')[0] : 'Selecione a data',),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            checkoutDate = selectedDate;
                          });
                        }
                      },
                    ),
                    RangeSlider(
                      values: priceRange ?? RangeValues(0, 1000),
                      min: 0,
                      max: 1000,
                      divisions: 10,
                      labels: RangeLabels(
                        'R\$ ${priceRange?.start.round() ?? 0}',
                        'R\$ ${priceRange?.end.round() ?? 1000}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          priceRange = values;
                        });
                      },
                    ),
                  ],
                );
              }
            )
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Aplicar filtros
                final filters = {
                  'checkinDate': checkinDate,
                  'checkoutDate': checkoutDate,
                  'uf': uf,
                  'localidade': localidade,
                  'bairro': bairro,
                  'guests': guests,
                  'priceRange': priceRange,
                };
                _applyFilters(filters);
                Navigator.of(context).pop();
              },
              child: Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  void _applyFilters(Map<String, dynamic> filters) async {
    final propertyService = PropertyService(); // Instância de PropertyService
    filteredLocacoes = await propertyService.filterProperties(filters);
    setState(() {});
  }
}