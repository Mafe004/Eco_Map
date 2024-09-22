import 'package:flutter/material.dart';

class Bnavigator extends StatefulWidget {
  final Function currentIndex;
  const Bnavigator({super.key, required this.currentIndex});

  @override
  _BnavigatorState createState() => _BnavigatorState();
}

class _BnavigatorState extends State<Bnavigator> {
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
          label: 'Noti',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.accessibility),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Repo',

        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_alert),
          label: 'Noti',
        ),
      ],
    );
  }
}