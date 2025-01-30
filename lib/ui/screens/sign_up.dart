import 'package:flutter/material.dart';
import 'package:reservas_app/services/user_service.dart';
import 'package:reservas_app/models/user.dart';
import 'package:reservas_app/ui/screens/login.dart';


class SignUp extends StatefulWidget{
  const SignUp({super.key});
  static String route = '/sign_up';
  
  @override
  State<StatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp>{
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _registerUser() async {
  final userService = UserService();
  
  final user = User(
    name: _nameController.text,
    email: _emailController.text,
    password: _passwordController.text, 
  );

  try {
    await userService.createUser(user);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cadastro realizado com sucesso!')),
    );
    Navigator.pushReplacementNamed(context, Login.route);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: ${e.toString()}')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            Text("Insira seus dados", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              maxLength: 32,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Nome"
              )
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Email"
              )
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              maxLength: 16,
              obscureText: true,
              obscuringCharacter: '*',
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Senha",
              ),
            ),
            ElevatedButton(
              onPressed: _registerUser, 
              child: Text("Cadastrar"))
          ]
        ))
    );
  }
  
}