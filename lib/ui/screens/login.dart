import 'package:flutter/material.dart';
import 'package:reservas_app/models/user.dart';
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
              onPressed: () {
                _emailController.clear();
                _passwordController.clear();
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                User? user = await currentUser.authenticateUser(
                  _emailController.text,
                  _passwordController.text,
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(user == null
                        ? 'Email ou senha incorretos'
                        : 'Login realizado com sucesso!'),
                    backgroundColor: user == null ? Colors.red : Colors.green,
                  ),
                );
                print("vai navegar");
                if (user != null) {
                  Navigator.pop(context);
                }

                if (userType == "anfitrião" && mounted) {
                  Navigator.pushReplacementNamed(
                    context,
                    '/anunciar-home',
                    arguments: user,
                  );
                }
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
                children: [
                  Text("O que você deseja?",
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {
                        _displayLoginDialog('hóspede');
                      },
                      child: Text("Alugar imóvel")),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {
                        _displayLoginDialog('anfitrião');
                      },
                      child: Text("Anunciar imóvel")),
                  const SizedBox(height: 15),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, SignUp.route);
                      },
                      child: Text("Cadastrar-se")),
                ])));
  }
}
