import 'package:flutter/material.dart';
import 'package:reservas_app/ui/screens/anunciar/add_property.dart';
import 'package:reservas_app/ui/screens/anunciar/anunciar_home.dart';
import 'package:reservas_app/ui/screens/anunciar/edit_property.dart';
import 'package:reservas_app/ui/screens/login.dart';
import 'package:reservas_app/services/db_service.dart';
import 'package:reservas_app/ui/screens/sign_up.dart'; // Substitua pelo caminho correto
import 'package:reservas_app/ui/screens/list_locations/index.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Garante que os serviços Flutter estejam prontos
  await _initializeDatabase(); // Inicializa o banco de dados
  runApp(
    MaterialApp(
      title: "Reservas App",
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Colors.indigo,
          textTheme: TextTheme(
            bodyMedium: TextStyle(fontSize: 18, color: Colors.black),
          )),
      debugShowCheckedModeBanner: false,
      initialRoute: Login.route,
      routes: {
        PropertyListScreen.route: (context) => const PropertyListScreen(),
        Login.route: (context) => const Login(),
        SignUp.route: (context) => const SignUp(),
        AnunciarHome.route: (context) => const AnunciarHome(),
        EditProperty.route: (context) => const EditProperty(),
        AddProperty.route: (context) => const AddProperty(),
      },
    ),
  );
}

Future<void> _initializeDatabase() async {
  final databaseService = DatabaseService();
  try {
    await databaseService.initDatabase(); // Inicializa o banco de dados
    print("Banco de dados inicializado com sucesso.");
  } catch (e) {
    print("Erro ao inicializar o banco de dados: $e");
  }
}
