import 'package:flutter/material.dart';

class Bnavigator extends StatefulWidget {
  final Function currentIndex;
  const Bnavigator({super.key, required this.currentIndex});

  @override
  BnavigatorState createState() => BnavigatorState();
}

class BnavigatorState extends State<Bnavigator> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: (int i){
        setState(() {
          index = i;
          widget.currentIndex(i);
        });


      },



      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.lightGreen,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Historial',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.accessibility),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Formulario',

        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'Información',  // la etiqueta de "Información"
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_alert),
          label: 'Notificaciones',
        ),
      ],
    );
  }
}