import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://smgkcwgeyotbjujruzuj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtZ2tjd2dleW90Ymp1anJ1enVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2MDY5MzQsImV4cCI6MjA2ODE4MjkzNH0.dl64I9eCBxnWajBy_s3rGMad5x03b40aVq8Rt5a7V-w',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Visitantes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}
