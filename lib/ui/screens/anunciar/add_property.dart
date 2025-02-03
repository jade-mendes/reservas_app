import 'package:flutter/material.dart';
import 'package:reservas_app/models/image.dart';
import 'package:flutter/services.dart';
import 'package:reservas_app/models/property.dart';
import 'package:reservas_app/services/address_service.dart';
import 'package:reservas_app/services/image_service.dart';
import 'package:reservas_app/services/property_service.dart';

class AddProperty extends StatefulWidget {
  const AddProperty({super.key});
  static String route = '/add-property';

  @override
  State<AddProperty> createState() => _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  late int _userId;

  final _formKey = GlobalKey<FormState>();
  final _addressService = AddressService();
  final _propertyService = PropertyService();
  final _imageService = ImageService();

  // Controllers for form fields
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _localidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final _estadoController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxGuestController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _image1 = TextEditingController();
  final _image2 = TextEditingController();

  bool _isLoading = false;
  int? _addressId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Obtém os argumentos após o widget estar na árvore
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is int) {
      _userId = args;

      // Força a reconstrução do widget
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _cepController.dispose();
    _logradouroController.dispose();
    _bairroController.dispose();
    _localidadeController.dispose();
    _ufController.dispose();
    _estadoController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _maxGuestController.dispose();
    _thumbnailController.dispose();
    _image1.dispose();
    _image2.dispose();
    super.dispose();
  }

  Future<void> _searchCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) return;

    setState(() => _isLoading = true);

    try {
      final address = await _addressService.getAddress(cep);
      setState(() {
        _addressId = address.id;
        _logradouroController.text = address.logradouro;
        _bairroController.text = address.bairro;
        _localidadeController.text = address.localidade;
        _ufController.text = address.uf;
        _estadoController.text = address.estado;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar CEP: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _addressId == null) return;

    try {
      final property = Property(
        userId: _userId,
        addressId: _addressId!,
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

      int propertyId = await _propertyService.insertProperty(property);

      if (_image1.text != '') {
        print("cadastrando imagem 1");
        final image1 = ImageCustom(
          propertyId: propertyId,
          path: _image1.text,
        );
        try {
          await _imageService.insertImage(image1);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao cadastrar imagem 1: $e')),
          );
        }
      }

      if (_image2.text != '') {
        print("cadastrando imagem 1");
        final image2 = ImageCustom(
          propertyId: propertyId,
          path: _image2.text,
        );
        try {
          await _imageService.insertImage(image2);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao cadastrar imagem 2: $e')),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Propriedade cadastrada com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar propriedade: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Propriedade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _cepController,
                decoration: const InputDecoration(
                  labelText: 'CEP',
                  hintText: '00000-000',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                onChanged: (value) {
                  if (value.length == 8) _searchCep();
                },
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 8) {
                    return 'Digite um CEP válido';
                  }
                  return null;
                },
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              TextFormField(
                controller: _logradouroController,
                decoration: const InputDecoration(labelText: 'Logradouro'),
                readOnly: true,
              ),
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(labelText: 'Bairro'),
                readOnly: true,
              ),
              TextFormField(
                controller: _localidadeController,
                decoration: const InputDecoration(labelText: 'Cidade'),
                readOnly: true,
              ),
              TextFormField(
                controller: _ufController,
                decoration: const InputDecoration(labelText: 'UF'),
                readOnly: true,
              ),
              TextFormField(
                controller: _estadoController,
                decoration: const InputDecoration(labelText: 'Estado'),
                readOnly: true,
              ),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: 'Número'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o número';
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
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o título';
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
                    return 'Digite a descrição';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço por noite',
                  prefixText: 'R\$ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o preço';
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
                    return 'Digite o número máximo de hóspedes';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _thumbnailController,
                decoration:
                    const InputDecoration(labelText: 'URL da imagem principal'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a URL da imagem';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _image1,
                decoration: const InputDecoration(labelText: 'URL da imagem 1'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a URL da imagem';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _image2,
                decoration: const InputDecoration(labelText: 'URL da imagem 2'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a URL da imagem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Cadastrar Propriedade'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
