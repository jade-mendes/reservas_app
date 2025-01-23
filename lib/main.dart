import 'package:flutter/material.dart';
import 'package:reservas_app/login.dart';

void main() {
  runApp(
    MaterialApp(
      title: "Reservas App",
      debugShowCheckedModeBanner: false,
      initialRoute: Login.route,
      routes: {
        Login.route: (context) => Login(),
        
      }
    )
  );
}

