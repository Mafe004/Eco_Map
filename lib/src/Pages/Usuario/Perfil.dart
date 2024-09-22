import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Login.dart';

class ProfilePage extends StatefulWidget {
  final String userName;

  const ProfilePage({Key? key, required this.userName}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'Cargando...';

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  Future<void> loadUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Primero intenta obtener el nombre de usuario de la colección Usuarios
        final userSnapshot = await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(user.uid)
            .get();
        if (userSnapshot.exists) {
          final userData = userSnapshot.data();
          if (userData != null) {
            setState(() {
              userName = userData['name'] ?? 'Usuario Desconocido';
            });
            return; // Si encontramos el nombre en Usuarios, no necesitamos buscar en DatosEntidad
          }
        }

        // Si no está en Usuarios, intenta obtener el nombre de usuario de la colección DatosEntidad
        final entitySnapshot = await FirebaseFirestore.instance
            .collection('DatosEntidad')
            .doc(user.uid)
            .get();
        if (entitySnapshot.exists) {
          final entityData = entitySnapshot.data();
          if (entityData != null) {
            setState(() {
              userName = entityData['nombre'] ?? 'Entidad Desconocida';
            });
          }
        }
      }
    } catch (e) {
      print("Error loading user name: $e");
    }
  }

  Future<void> editField(String field) async {
    // Lógica para editar el campo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil"),
        backgroundColor: Colors.lightGreen,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          SizedBox(height: 50),
          // Foto de perfil
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/profile_picture.png'),
          ),
          SizedBox(height: 20),
          // Nombre de usuario
          Center(
            child: Text(
              userName,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ),
          SizedBox(height: 50),
          // Detalles
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              'Detalles',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          // Usuario

          SizedBox(height: 20),
          // Setting Notification
          // Elemento de perfil
          itemProfile("Notificación", Icons.add_alert_sharp, () {
            // Navegar a la pantalla de ajustes

          }),
          SizedBox(height: 20),
          // Elemento para cerrar sesión
          itemProfile("Cerrar sesión", Icons.exit_to_app, () {
            // Cerrar sesión del usuario
            FirebaseAuth.instance.signOut();
            // Navegar de vuelta a la pantalla de inicio de sesión
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
            );
          }),
        ],
      ),
    );
  }

  Widget itemProfile(String title, IconData iconData, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            offset: Offset(0, 3),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        title: Text(title),
        leading: Icon(iconData, color: Colors.lightGreen),
        trailing: Icon(Icons.arrow_forward_ios_outlined),
        onTap: onPressed,
      ),
    );
  }
}
