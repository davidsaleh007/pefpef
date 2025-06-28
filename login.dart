// lib/login.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('https://pefpef.com/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": _emailCtrl.text.trim(),
          "password": _passCtrl.text.trim(),
        }),
      );

      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        // navega a la pantalla principal, por ejemplo:
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _showMsg(data['error'] ?? 'Credenciales inválidas');
      }
    } catch (e) {
      _showMsg('Error de conexión');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMsg(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))
        ],
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: Colors.deepPurple[300]),
    filled: true,
    fillColor: Colors.deepPurple.shade50.withOpacity(0.4),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2),
        borderRadius: BorderRadius.circular(15)),
    labelStyle: TextStyle(color: Colors.deepPurple[400]),
  );

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F7),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[400],
        title: const Text("Iniciar Sesión",
            style: TextStyle(
                fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: isWide ? 400 : double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                  color: Colors.deepPurple.shade100.withOpacity(0.18),
                  blurRadius: 26,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("¡Bienvenido de nuevo!",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'PlayfairDisplay',
                        color: Colors.deepPurple[500])),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDec("Correo electrónico", Icons.email_outlined),
                  validator: (v) =>
                  v != null && v.contains("@") ? null : "Correo inválido",
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: _inputDec("Contraseña", Icons.lock_outline),
                  validator: (v) =>
                  v != null && v.length >= 6 ? null : "Mínimo 6 caracteres",
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[400],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _loading
                        ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                        : Text("Entrar", style: GoogleFonts.poppins(fontSize: 17)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // si quieres una página de recuperar contraseña
                  },
                  child: const Text("¿Olvidaste tu contraseña?"),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿No tienes cuenta? "),
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed('/registro'),
                      child: Text("Regístrate",
                          style: TextStyle(
                              color: Colors.deepPurple[600],
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}