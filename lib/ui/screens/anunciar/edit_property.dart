import 'package:flutter/material.dart';
import 'package:reservas_app/models/property.dart';
import 'package:reservas_app/services/property_service.dart';

class EditProperty extends StatefulWidget {
  const EditProperty({super.key});
  static String route = '/edit-property';

  @override
  State<StatefulWidget> createState() => _EditPropertyState();
}

class _EditPropertyState extends State<EditProperty> {
  final _formKey = GlobalKey<FormState>();
  late Property _property;
  final PropertyService _propertyService = PropertyService();

  // Controladores para os campos do formulário
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _numberController;
  late TextEditingController _complementController;
  late TextEditingController _priceController;
  late TextEditingController _maxGuestController;
  late TextEditingController _thumbnailController;

  @override
  void initState() {
    super.initState();

    // Inicializa os controladores com valores vazios
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _numberController = TextEditingController();
    _complementController = TextEditingController();
    _priceController = TextEditingController();
    _maxGuestController = TextEditingController();
    _thumbnailController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Obtém os argumentos após o widget estar na árvore
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Property) {
      _property = args;

      // Atualiza os controladores com os valores reais
      _titleController.text = _property.title;
      _descriptionController.text = _property.description;
      _numberController.text = _property.number.toString();
      _complementController.text = _property.complement ?? '';
      _priceController.text = _property.price.toString();
      _maxGuestController.text = _property.maxGuest.toString();
      _thumbnailController.text = _property.thumbnail;

      // Força a reconstrução do widget
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _saveProperty() async {
    if (_formKey.currentState!.validate()) {
      final updatedProperty = Property(
        id: _property.id,
        userId: _property.userId,
        addressId: _property.addressId,
        title: _titleController.text,
        description: _descriptionController.text,
        number: int.parse(_numberController.text),
        complement: _complementController.text.isEmpty
            ? null
            : _complementController.text,
        price: double.parse(_priceController.text),
        maxGuest: int.parse(_maxGuestController.text),
        thumbnail: _thumbnailController.text,
      );

      try {
        await _propertyService.updateProperty(updatedProperty);
        Navigator.pop(context, true); // Retorna indicando sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Propriedade atualizada com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar propriedade"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProperty,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor insira um título';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor insira uma descrição';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: 'Número'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor insira o número';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Número inválido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _complementController,
                decoration:
                    const InputDecoration(labelText: 'Complemento (opcional)'),
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor insira o preço';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Preço inválido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _maxGuestController,
                decoration:
                    const InputDecoration(labelText: 'Máximo de hóspedes'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor insira o número de hóspedes';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Número inválido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _thumbnailController,
                decoration: const InputDecoration(labelText: 'Thumbnail (URL)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor insira uma URL para a imagem';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _priceController.dispose();
    _maxGuestController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }
}
