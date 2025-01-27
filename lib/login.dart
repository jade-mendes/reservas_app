import 'package:flutter/material.dart';
import 'package:reservas_app/models/booking.dart';
import 'package:reservas_app/services/booking_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  static String route = '/login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final BookingService _bookingService = BookingService();

  // Lista para armazenar as bookings buscadas
  List<Booking> _booking = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  // Método para carregar bookings de um userId
  Future<void> _loadProperties() async {
    try {
      // Substitua '1' pelo userId desejado para teste
      int userId = 4;
      List<Booking> bookings =
          await _bookingService.getBookingsByUserId(userId);

      setState(() {
        _booking = bookings;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar bookings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reservas App"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Mostra um loader enquanto carrega os dados
          : _booking.isEmpty
              ? Center(child: Text("Nenhuma propriedade encontrada."))
              : ListView.builder(
                  itemCount: _booking.length,
                  itemBuilder: (context, index) {
                    final booking = _booking[index];
                    return ListTile(
                      title: Text(booking.propertyId.toString()),
                      subtitle: Text(booking.totalDays.toString()),
                      trailing:
                          Text('R\$ ${booking.totalPrice.toStringAsFixed(2)}'),
                    );
                  },
                ),
    );
  }
}
