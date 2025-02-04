import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reservas_app/models/booking.dart';
import 'package:reservas_app/models/property.dart';
import 'package:reservas_app/services/booking_service.dart';

class SinglePropertyScreen extends StatefulWidget {
  static String route = '/singleProperty'; 
  final Property property;
  final int? userId;

  const SinglePropertyScreen({
    super.key,
    required this.property, required this.userId
  });
  
  @override
  SinglePropertyScreenState createState() => SinglePropertyScreenState();
}

class SinglePropertyScreenState extends State<SinglePropertyScreen> {
  late Property _property; 
  late int _userId; 
  List<Booking> _bookings = []; // Lista filtrada para exibição
  final List<DateTime> _datesBookings = []; // Lista filtrada para exibição
  DateTime? checkinDate;
  DateTime? checkoutDate;
  double totalPrice = 0.0;
  final TextEditingController guestsController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _property = widget.property;
    _userId = widget.userId!;
    loadBookings();
  }

  Future<void> loadBookings() async{
    final bookingservice = BookingService();
    _bookings = await bookingservice.getBookingsByPropertyId(_property.id!);
    for (var booking in _bookings) {
      DateTime checkin = DateTime.parse(booking.checkinDate);
      DateTime checkout = DateTime.parse(booking.checkoutDate);

      for (
        DateTime date = checkin;
        date.isBefore(checkout) || date.isAtSameMomentAs(checkout);
        date = date.add(Duration(days: 1))
      ) {
        _datesBookings.add(date);
      }
    }
    print(_datesBookings);
  }
  
  bool isNullOrEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    return false;
  }

  double calculateTotalPrice() {
    if (checkinDate == null || checkoutDate == null) return 0.0;
    final difference = checkoutDate!.difference(checkinDate!).inDays;
    return difference * _property.price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20)
        ),
        title: Text("Propriedade"),
      ),
      body: Padding(padding: EdgeInsets.all(10), 
        child: Column(
          children: [
            Container(
              width: double.infinity, // Garante que o container ocupe toda a largura disponível
              height: 200, // Ajuste a altura conforme necessário
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[300], // Cor de fundo para quando a imagem falhar
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  _property.thumbnail,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200, // Mantém a altura do container
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Fundo cinza para erro
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(_property.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
            Text(_property.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Center(
              child: Text(
                '${_property.address?.uf}, ${_property.address?.localidade}, ${_property.address?.bairro}', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)
              ),
            ),
            SizedBox(height: 0),
            Center(
              child: Text(
                '${_property.address?.logradouro}, ${_property.number}', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Máximo de pessoas: ${_property.maxGuest}', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                'Valor da Diária: R\$${_property.price.toStringAsFixed(2).replaceAll(".", ",")}', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: ElevatedButton(onPressed: () {
                  _showFilterDialog(context);
                }, child: Text("Reservar")),
            )
          ],
        )
      )
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reservar'),
          insetPadding: EdgeInsets.all(0),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                // Calcula o preço total
                final totalPrice = calculateTotalPrice();
                return Column(
                  children: [
                    TextField(
                      controller: guestsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(labelText: 'Quantidade de Pessoas'),
                      onChanged: (val) {
                        if (val == "") return;
                        if (int.tryParse(val)! > _property.maxGuest) guestsController.text = _property.maxGuest.toString();
                      },
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
                          selectableDayPredicate: (DateTime val) {
                            return !_datesBookings.contains(val);
                          }
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
                            selectableDayPredicate: (DateTime val) {
                            return !_datesBookings.contains(val);
                          }
                        );
                        if (selectedDate != null) {
                          setState(() {
                            checkoutDate = selectedDate;
                          });
                        }
                      },
                    ),   
                    Text('R\$$totalPrice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                  ],
                );
              }
            )
          ),
          actions: [
            TextButton(
              onPressed: () {
                guestsController.clear();
                checkinDate = null;
                checkoutDate = null;
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (checkinDate == null || checkoutDate == null || guestsController.text.isEmpty) {
                  return;
                }
                Booking newbookin = Booking(
                  userId: _userId, 
                  propertyId: _property.id!, 
                  checkinDate: "${checkinDate?.toLocal()}".split(' ')[0], 
                  checkoutDate: "${checkoutDate?.toLocal()}".split(' ')[0], 
                  totalDays: checkoutDate!.difference(checkinDate!).inDays, 
                  totalPrice: calculateTotalPrice(), 
                  amountGuest: int.tryParse(guestsController.text)!
                );
                try{
                  final bookingservice = BookingService();
                  bookingservice.insertBooking(newbookin);
                }catch (e){
                  print("Erro ao inserir Booking");
                }

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