import 'package:flutter/material.dart';
import 'package:reservas_app/models/booking.dart';
import 'package:reservas_app/services/booking_service.dart';
import 'package:reservas_app/ui/screens/sign_up.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  static String route = '/login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  /*  Mudar isso aqui de lugar, mas não sei pra onde */
  /* final BookingService _bookingService = BookingService();

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
      setState(() {
        _isLoading = false;
      });
    }
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reservas App"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            Text("Como deseja entrar?", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: (){}, 
              child: Text("Locador")),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: (){}, 
              child: Text("Locatário")),
            const SizedBox(height: 10),
            TextButton(
              onPressed: (){
                Navigator.pushNamed(context, SignUp.route);
              },
              child: Text("Cadastre-se")),
          ]
        )
      )
    );
  }
}
