import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Pages/Usuario/Login.dart';

class InactivityWrapper extends StatefulWidget {
  final Widget child;

  const InactivityWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<InactivityWrapper> createState() => _InactivityWrapperState();
}

class _InactivityWrapperState extends State<InactivityWrapper> {
  Timer? _inactivityTimer;

  // Inicia el temporizador de inactividad
  void _startInactivityTimer() {
    _inactivityTimer = Timer(const Duration(seconds: 30), _showInactivityDialog);
  }

  // Reinicia el temporizador en cada interacción del usuario
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _startInactivityTimer();
  }

  // Muestra advertencia de cierre de sesión
  void _showInactivityDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Inactividad detectada'),
          content: const Text('La sesión se cerrará automáticamente por inactividad.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                _signOut();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Función para cerrar sesión
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _resetInactivityTimer, // Detecta interacción y reinicia temporizador
      onPanDown: (_) => _resetInactivityTimer(), // Detecta cualquier movimiento táctil
      child: widget.child,
    );
  }
}
