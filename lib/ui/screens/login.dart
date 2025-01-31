import 'package:flutter/material.dart';
import 'package:reservas_app/ui/screens/sign_up.dart';
import 'package:reservas_app/services/user_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  static String route = '/login';  

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

void _displayLoginDialog(String userType) {
  // Mostra uma DialogBox para o usuário digitar email e senha em vez de criar uma tela nova só para isso
  UserService currentUser = UserService();
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Entrar como $userType'),
        content: SizedBox(
          width: 300, 
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(hintText: "Email"),
              ),
              TextField(
                obscureText: true,
                obscuringCharacter: '*',
                controller: _passwordController,
                decoration: InputDecoration(hintText: "Senha"),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              currentUser.authenticateUser(_emailController.text, _passwordController.text);
              // TERMINAR ISSO
            },
            child: Text("Entrar"),
          ),
        ],
      );
    },
  );
}


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
            Text("O que você deseja?", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: (){ _displayLoginDialog('hóspede');}, 
              child: Text("Alugar imóvel")),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: (){_displayLoginDialog('anfitrião');}, 
              child: Text("Anunciar imóvel")),
            const SizedBox(height: 15),
            TextButton(
              onPressed: (){
                Navigator.pushNamed(context, SignUp.route);
              },
              child: Text("Cadastrar-se")),
          ]
        )
      )
    );
  }
}
