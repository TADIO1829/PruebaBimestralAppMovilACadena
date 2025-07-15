import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool loading = false;

  final Color negroVolcan = const Color(0xFF0d0404);
  final Color marronProfundo = const Color(0xFF370b05);
  final Color naranjaFuego = const Color(0xFFe43606);
  final Color rojoVolcan = const Color(0xFFda5238);
  final Color naranjaIntenso = const Color(0xFFdc5414);

  void login() async {
    setState(() => loading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception:", "").trim()}')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [negroVolcan, naranjaFuego],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 18,
              color: marronProfundo.withOpacity(0.92),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: naranjaIntenso.withOpacity(0.14),
                      child: Icon(Icons.person, size: 46, color: naranjaIntenso),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Bienvenido',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: naranjaFuego,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Accede para continuar',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: rojoVolcan.withOpacity(0.88),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: TextStyle(color: naranjaFuego),
                        prefixIcon: Icon(Icons.email_outlined, color: naranjaIntenso),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: rojoVolcan.withOpacity(0.38), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: naranjaFuego, width: 1.8),
                        ),
                        filled: true,
                        fillColor: negroVolcan.withOpacity(0.20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(color: naranjaFuego),
                        prefixIcon: Icon(Icons.lock_outline, color: naranjaIntenso),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: rojoVolcan.withOpacity(0.38), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: naranjaFuego, width: 1.8),
                        ),
                        filled: true,
                        fillColor: negroVolcan.withOpacity(0.20),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                          backgroundColor: naranjaIntenso,
                          foregroundColor: negroVolcan,
                        ),
                        child: loading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
