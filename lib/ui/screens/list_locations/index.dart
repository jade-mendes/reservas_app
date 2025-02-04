import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<String> validUFs = [];
  List<String> validlocalidades = [];
  TextEditingController searchController = TextEditingController();
  DateTime? checkinDate;
  DateTime? checkoutDate;
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController guestsController = TextEditingController();
  final ValueNotifier<String?> ufNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> localidadeNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<RangeValues?> priceRangeNotifier = ValueNotifier<RangeValues?>(null);
  bool isLoading = false;
  bool isFiltered = false;

  @override
  void initState(){
    super.initState();
    // Aqui você pode carregar as locações do banco de dados
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {isLoading = true;});
    final propertyService = PropertyService(); // Instância de PropertyService
    locacoes = await propertyService.getAllProperties(); // Chamada do método de instância
    setState(() {
      filteredLocacoes = locacoes;
      isLoading = false;
    });
  }
  
  void _searchProperties(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredLocacoes = locacoes;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();

    // Função para calcular a pontuação de uma propriedade
    int calculateScore(Property property) {
      int score = 0;
      if (property.title.toLowerCase().contains(lowerQuery)) {
        score += 5; // Peso 5 para o título
      }
      if (property.address.uf.toLowerCase().contains(lowerQuery)) {
        score += 4; // Peso 4 para o UF
      }
      if (property.address.localidade.toLowerCase().contains(lowerQuery)) {
        score += 3; // Peso 3 para a cidade
      }
      if (property.address.bairro.toLowerCase().contains(lowerQuery)) {
        score += 2; // Peso 2 para o bairro
      }
      if (property.address.logradouro.toLowerCase().contains(lowerQuery)) {
        score += 1; // Peso 1 para a rua
      }
      return score;
    }

    // Filtra e ordena as propriedades com base na pontuação
    final results = locacoes.map((property) {
      return {
        'property': property,
        'score': calculateScore(property),
      };
    })
    .where((result) => result['score'] as int > 0) // Remove propriedades sem correspondência
    .toList();

    // Ordena os resultados pela pontuação (do maior para o menor)
    results.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    // Atualiza a lista filtrada
    setState(() {
      filteredLocacoes = results.map((result) => result['property'] as Property).toList();
    });
  }
  
  void _applyFilters(Map<String, dynamic> filters) async {
    setState(() {
      isLoading = true;
      isFiltered = filters.values.any((value) => !isNullOrEmpty(value));
    });


    final propertyService = PropertyService(); // Instância de PropertyService
    filteredLocacoes = await propertyService.filterProperties(filters);
    locacoes = filteredLocacoes;
    setState(() {isLoading = false;});
  }

  bool isNullOrEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    return false;
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
            suffixIcon: searchController.text != "" ? IconButton(
              onPressed: searchController.clear,
              icon: Icon(Icons.clear),
            ) : Text(""),
          ),
          onChanged: _searchProperties,
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                ),
                onPressed: () {
                  _showFilterDialog(context);
                },
              ),
              if (isFiltered)
                Positioned(
                  left: 5,
                  bottom: 5,
                  child: Container(
                    // padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading ? 
      Center(
        child: CircularProgressIndicator(), // Indicador de carregamento
      )
      : filteredLocacoes.isNotEmpty ?
      ListView.builder(
        itemCount: filteredLocacoes.length,
        itemBuilder: (context, index) {
          final property = filteredLocacoes[index];
          return ListTile(
            leading: Image.network(
              property.thumbnail,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
            ), // URL da imagem
            title: Text(property.title,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Color(0xff333333)
              ),
            ),
            subtitle: Text(
              '${property.address.uf} - ${property.address.localidade}',
              style: TextStyle(fontSize: 16),
            ),
            trailing: Text(
              'R\$ ${property.price.toStringAsFixed(2).replaceAll(".", ",")}', 
              style: const TextStyle(fontSize: 14)
            ),
            onTap: () {
              // Navegar para a página da locação
              // Navigator.push(...);
            },
          );
        },
      ) :
      Center(
        child: Text("Nenhuma locação encontrada!"),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filtrar Locações'),
          insetPadding: EdgeInsets.all(0),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    ValueListenableBuilder<String?>(
                      valueListenable: ufNotifier,
                      builder: (context, value, child) {
                        return DropdownButtonFormField<String>(
                          value: value,
                          decoration: InputDecoration(labelText: 'Estado'),
                          items: ['Todos', 'SP', 'RJ', 'MG'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value == 'Todos' ? null : value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            ufNotifier.value = value;
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder<String?>(
                      valueListenable: localidadeNotifier,
                      builder: (context, value, child) {
                        return DropdownButtonFormField<String>(
                          value: value,
                          decoration: InputDecoration(labelText: 'Cidade'),
                          items: ['Todos', 'São Paulo', 'Rio de Janeiro', 'Belo Horizonte'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value == 'Todos' ? null : value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            localidadeNotifier.value = value;
                          },
                        );
                      },
                    ),
                    TextField(
                      controller: bairroController,
                      decoration: InputDecoration(labelText: 'Bairro'),
                    ),
                    TextField(
                      controller: guestsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(labelText: 'Quantidade de Pessoas'),
                    ),
                    ListTile(
                      title: Text('Data de Entrada'),
                      contentPadding: EdgeInsets.only(left: 5.0, right: 5.0),
                      subtitle: Text(checkinDate != null ? 
                        "${checkinDate!.day.toString().padLeft(2, '0')}/${checkinDate!.month.toString().padLeft(2, '0')}/${checkinDate!.year}" 
                        : 'Selecione a data',
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: checkinDate != null ? 
                        IconButton(
                          onPressed: () => {
                            setState(() {checkinDate = null;}),
                          }, 
                          icon: Icon(Icons.delete_forever) 
                        ) : Text(''),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: checkinDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: checkoutDate ?? DateTime(DateTime.now().year + 5),
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
                      contentPadding: EdgeInsets.only(left: 5.0, right: 5.0),
                      subtitle: Text(checkoutDate != null ? 
                        "${checkoutDate!.day.toString().padLeft(2, '0')}/${checkoutDate!.month.toString().padLeft(2, '0')}/${checkoutDate!.year}" 
                        : 'Selecione a data',
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: checkoutDate != null ? 
                        IconButton(
                          onPressed: () => {
                            setState(() {checkoutDate = null;}),
                          }, 
                          icon: Icon(Icons.delete_forever) 
                        ) : Text(''),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: checkoutDate ?? checkinDate ?? DateTime.now(),
                          firstDate: checkinDate ?? DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 5),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            checkoutDate = selectedDate;
                          });
                        }
                      },
                    ),   
                    ValueListenableBuilder<RangeValues?>(
                      valueListenable: priceRangeNotifier,
                      builder: (context, value, child) {
                        return ListTile(
                          title: Text("Faixa de preço"),
                          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                          subtitle: RangeSlider(
                            values: value ?? RangeValues(0, 1000),
                            min: 0,
                            max: 1000,
                            divisions: 20,
                            labels: RangeLabels(
                              'R\$ ${value?.start.round() ?? 0}',
                              'R\$ ${value?.end.round() ?? 1000}',
                            ),
                            onChanged: (values) {
                              priceRangeNotifier.value = values;
                              if (values.start == 0 && values.end == 1000) priceRangeNotifier.value = null;
                            },
                          ),
                        );
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
                bairroController.clear();
                guestsController.clear();
                ufNotifier.value = null;
                localidadeNotifier.value = null;
                priceRangeNotifier.value = null;
                checkinDate = null;
                checkoutDate = null;
                isFiltered = false;
                _applyFilters({});
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text('Resetar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final filters = {
                  'checkinDate': checkinDate,
                  'checkoutDate': checkoutDate,
                  'uf': ufNotifier.value,
                  'localidade': localidadeNotifier.value,
                  'bairro': bairroController.text,
                  'guests': int.tryParse(guestsController.text),
                  'priceRange': priceRangeNotifier.value,
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
}