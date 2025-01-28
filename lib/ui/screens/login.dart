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
      body: Padding(
        padding: const EdgeInsets.all(100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            Text("Como deseja entrar?", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: (){}, child: Text("Locador")),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: (){}, child: Text("Locatário")),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(onPressed: (){}, child: Text("Cadastre-se")),
            ),
          ]
        )
      )
    );
  }
}
