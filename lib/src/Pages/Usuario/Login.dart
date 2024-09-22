
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _formKey = GlobalKey<FormState>(); // Agregar clave global para validar el formulario
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? _errorText; // Variable para mostrar mensajes de error

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      // Validar los campos de correo electrónico y contraseña
      try {
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        final User? user = userCredential.user;

        if (user != null) {
          // Verifica si el usuario está en la colección de Entidades
          final entityDoc = await FirebaseFirestore.instance.collection('DatosEntidad').doc(user.uid).get();
          if (entityDoc.exists) {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()), // Cambiar a la página de entidad
            );
          } else {
            // Verifica si el usuario está en la colección de Usuarios
            final userDoc = await FirebaseFirestore.instance.collection('Usuarios').doc(user.uid).get();
            if (userDoc.exists) {
              // Navega a la página específica de usuarios
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()), // Cambiar a HomePage
              );
            } else {
              setState(() {
                _errorText = 'No se encontró el tipo de usuario.';
              });
            }
          }
        }
      } catch (e) {
        setState(() {
          _errorText = 'Error al iniciar sesión. Por favor, verifica tus credenciales.';
        });
        print(e.toString());
      }
    }
  }

  Future<void> _resetPassword() async {
    if (emailController.text.isEmpty) {
      setState(() {
        _errorText = 'Por favor, ingresa tu correo electrónico para restablecer la contraseña.';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
      setState(() {
        _errorText = 'Se ha enviado un correo para restablecer la contraseña.';
      });
    } catch (e) {
      setState(() {
        _errorText = 'Error al enviar el correo de restablecimiento de contraseña.';
      });
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Form(
            key: _formKey, // Usar la clave global para validar el formulario
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.water,
                  size: 100,
                ),
                const SizedBox(height: 50),
                const Text("Bienvenido a Eco-Mapa "),
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
                if (_errorText != null) // Mostrar mensaje de error si existe
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _signIn,
                  child: const Text('Ingresar'),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¿No tienes usuario?",
                      style: TextStyle(),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        // Navegar a la página de registro cuando se toque el texto
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
                  onTap: () {
                    // Navegar a la página de restablecimiento de contraseña cuando se toque el texto
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Restablecer contraseña"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                hintText: 'Correo electrónico',
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () {
                              _resetPassword();
                              Navigator.of(context).pop();
                            },
                            child: const Text("Enviar"),
                          ),
                        ],
                      ),
                    );
                  },
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
