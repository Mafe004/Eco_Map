import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_mapa_3/src/Routes/rutas.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'src/Components/boton_navegacion.dart';
import 'src/Pages/Usuario/Login.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Verificar datos de Firestore
  await _loadMarkers(); // Carga los marcadores antes de iniciar la app

  runApp(const MyApp());
}

Future<void> _loadMarkers() async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('Marcadores').get();

    debugPrint("Documentos recuperados: ${snapshot.docs.length}"); // Imprimir cantidad de documentos
    for (var doc in snapshot.docs) {
      GeoPoint geoPoint = doc['Ubicacion'];
      debugPrint('Marcador: ${doc.id}, Ubicacion: ${geoPoint.latitude}, ${geoPoint.longitude}'); // Depuración
    }
  } catch (e) {
    debugPrint("Error al cargar marcadores: $e"); // Captura de errores
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Eco-Mapa',
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key}); // Añadir `const` y `key`

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return user != null ? const HomePage() : const LoginPage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  Bnavigator? myBnb;
  String userName = 'Cargando...';

  @override
  void initState() {
    super.initState();
    myBnb = Bnavigator(currentIndex: (i) {
      setState(() {
        index = i;
      });
    });


    // Obtener el nombre de usuario
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    String? fetchedName = await getUserName();
    setState(() {
      userName = fetchedName ?? 'Usuario sin nombre';
    });
  }

  Future<String?> getUserName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Usuarios').doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data() != null && userDoc['name'] != null) {
        return userDoc['name'];
      } else {
        return null; // O un valor predeterminado, por ejemplo: 'Usuario sin nombre'
      }
    }
    else {
      return null;
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: myBnb,
      body: FutureBuilder<String?>(
        future: getUserName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Routes(index: index, userName: snapshot.data ?? "Usuario sin nombre");
          }
        },
      ),
    );
  }
}





