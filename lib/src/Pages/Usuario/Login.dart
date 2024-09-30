import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../main.dart';
import 'Registrarse.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? _errorText;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        final User? user = userCredential.user;
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'user-not-found') {
            _errorText = 'No se encontró ningún usuario con ese correo.';
          } else if (e.code == 'wrong-password') {
            _errorText = 'Contraseña incorrecta. Intenta de nuevo.';
          } else if (e.code == 'invalid-email') {
            _errorText = 'Correo electrónico no válido.';
          }
        });
      } catch (e) {
        setState(() {
          _errorText = 'Error desconocido. Inténtalo de nuevo.';
        });
      }
    }
  }

  // Función para mostrar el diálogo de "Olvidaste tu contraseña"
  Future<void> _showPasswordResetDialog() async {
    final resetEmailController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restablecer contraseña'),
          content: TextField(
            controller: resetEmailController,
            decoration: const InputDecoration(
              labelText: 'Ingresa tu correo electrónico',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Enviar'),
              onPressed: () async {
                if (resetEmailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor ingresa tu correo.')),
                  );
                } else {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: resetEmailController.text.trim(),
                    );
                    Navigator.of(context).pop(); // Cerrar el diálogo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Se envió un correo para restablecer tu contraseña.')),
                    );
                  } on FirebaseAuthException catch (e) {
                    Navigator.of(context).pop(); // Cerrar el diálogo
                    if (e.code == 'user-not-found') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se encontró ningún usuario con ese correo.')),
                      );
                    } else if (e.code == 'invalid-email') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Correo electrónico no válido.')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.message}')),
                      );
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 100,
                ),
                const SizedBox(height: 50),
                const Text("Eco Mapa"),
                const SizedBox(height: 25),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu correo electrónico.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: 'Correo electrónico',
                    hintStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu contraseña.';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: 'Contraseña',
                    hintStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _signIn,
                  child: const Text('Ingresar'),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿No tienes usuario?"),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        "Regístrate ahora",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _showPasswordResetDialog,
                  child: const Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


