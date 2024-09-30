import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Ver-reportes.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Historial Trueques'),
            Tab(text: 'Truques'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MyReportsPage(),
          GeneralReportsPage(),
        ],
      ),
    );
  }
}

class MyReportsPage extends StatelessWidget {
  const MyReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Usuario no autenticado'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final userData = snapshot.data?.data() as Map<String, dynamic>?;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Trueques')
              .where('userId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final reports = snapshot.data?.docs ?? [];
            if (reports.isEmpty) {
              return const Center(child: Text('No hay Trueques disponibles.'));
            }
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final data = reports[index].data() as Map<String, dynamic>;
                final List<String> imagePaths = List<String>.from(data['images'] ?? []);

                final timestamp = (data['timestamp'] as Timestamp).toDate();


                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewReportPage(reportSnapshot: reports[index]),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: user.photoURL != null
                                    ? NetworkImage(user.photoURL!)
                                    : AssetImage('assets/default_profile_picture.png') as ImageProvider,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${userData?['name'] ?? 'Usuario Desconocido'}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ubicación: ${data['ubicacion'] ?? 'No disponible'}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text('Descripción: ${data['Descripcion'] ?? 'No disponible'}'),
                          const SizedBox(height: 8),

                          if (imagePaths.isNotEmpty)
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: imagePaths.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(imagePaths[index]),
                                        width: 200,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}



class GeneralReportsPage extends StatelessWidget {
  const GeneralReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Reportes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final reports = snapshot.data?.docs ?? [];
        if (reports.isEmpty) {
          return const Center(child: Text('No hay reportes disponibles.'));
        }
        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final data = reports[index].data() as Map<String, dynamic>;
            final List<String> imagePaths = List<String>.from(data['images'] ?? []);

            final timestamp = (data['timestamp'] as Timestamp).toDate();


            // Obtener el nombre de usuario del informe
            final userName = data['userName'] ?? 'Usuario Desconocido';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewReportPage(reportSnapshot: reports[index]),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            // Muestra una imagen predeterminada si no hay foto de perfil del usuario
                            backgroundImage: AssetImage('assets/default_profile_picture.png'),
                          ),
                          const SizedBox(width: 10),
                          // Muestra el nombre de usuario
                          Text(
                            '$userName',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ubicación: ${data['ubicacion'] ?? 'No disponible'}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text('Descripción: ${data['Descripcion'] ?? 'No disponible'}'),
                      const SizedBox(height: 8),

                      if (imagePaths.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imagePaths.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(imagePaths[index]),
                                    width: 200,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}