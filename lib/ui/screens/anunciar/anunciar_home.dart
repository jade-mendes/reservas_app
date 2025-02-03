import 'package:flutter/material.dart';
import 'package:reservas_app/models/property.dart';
import 'package:reservas_app/models/user.dart';
import 'package:reservas_app/services/property_service.dart';
import 'package:reservas_app/ui/screens/anunciar/add_property.dart';
import 'package:reservas_app/ui/screens/anunciar/edit_property.dart';

class AnunciarHome extends StatefulWidget {
  const AnunciarHome({super.key});
  static String route = '/anunciar-home';

  @override
  State<StatefulWidget> createState() => _AnunciarHomeState();
}

class _AnunciarHomeState extends State<AnunciarHome> {
  late User _currentUser;
  final PropertyService _propertyService = PropertyService();
  late Future<List<Property>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    // Removemos o carregamento do usuário daqui
    _propertiesFuture = Future.value([]); // Inicializa com lista vazia
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Movemos para didChangeDependencies
    _currentUser = ModalRoute.of(context)!.settings.arguments as User;
    _loadProperties();
  }

  void _loadProperties() {
    setState(() {
      _propertiesFuture =
          _propertyService.getPropertiesByUserId(_currentUser.id!);
    });
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToEdit(Property property) {
    Navigator.pushNamed(
      context,
      EditProperty.route,
      arguments: property,
    );
  }

  Future<void> _deleteProperty(int propertyId) async {
    try {
      await _propertyService.deletePropertyById(propertyId);
      _loadProperties(); // Recarrega a lista após exclusão
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Propriedade excluída com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir propriedade: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel do Anunciante"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, AddProperty.route,
                arguments: _currentUser.id),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_currentUser.name),
              accountEmail: Text(_currentUser.email),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Property>>(
          future: _propertiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            final properties = snapshot.data!;

            return ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    // Nova seção de thumbnail
                    leading: SizedBox(
                      width: 80,
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          property.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    // Título e informações
                    title: Text(property.title),
                    subtitle: Text(
                      'R\$ ${property.price.toStringAsFixed(2)}\n'
                      'Hóspedes: ${property.maxGuest}',
                    ),
                    // Botões de ação
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _navigateToEdit(property),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProperty(property.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
