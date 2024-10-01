import 'package:flutter/material.dart';
import '../Pages/Formulario/Form.dart';
import '../Pages/Home/PaginaPrin.dart';
import '../Pages/Parte_Edu/informacion.dart';
import '../Pages/Trueques/Publicacion-trueque.dart';
import '../Pages/Usuario/Perfil.dart';

class Routes extends StatelessWidget {
  final int index;
  final String userName;

  const Routes({super.key, required this.index, required this.userName}); // Usamos super.key

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
