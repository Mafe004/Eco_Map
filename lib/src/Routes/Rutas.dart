import 'package:flutter/material.dart';
import '../Pages/Formulario/Form.dart';
import '../Pages/Home/PaginaPrin.dart';
import '../Pages/Trueques/Publicacion-trueque.dart';
import '../Pages/Usuario/Perfil.dart';
import '../Pages/Parte_Edu/informacion.dart';  // Importacion de Información

class Routes extends StatelessWidget {
  final int index;
  final String userName;

  const Routes({Key? key, required this.index, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> mylist = [
      const InfoPage(),
      const HomeScreen(),
      const FormExampleApp(),
      const InformacionPage(),  // Aquí agregamos la página de Información

      ProfilePage(userName: userName),
    ];
    return mylist[index];
  }
}
