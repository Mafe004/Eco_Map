import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class ViewReportPage extends StatelessWidget {
  final DocumentSnapshot reportSnapshot;

  const ViewReportPage({super.key, required this.reportSnapshot});

  @override
  Widget build(BuildContext context) {
    final data = reportSnapshot.data() as Map<String, dynamic>;
    final List<String> imagePaths = List<String>.from(data['images'] ?? []);


    return Scaffold(
      appBar: AppBar(
        title: Text('Trueque'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mostrar las imágenes
            if (imagePaths.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imagePaths.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imagePaths[index], // Cambié a Image.network
                          width: 200,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            // Mostrar información de la publicación
            _buildInfoRow('Direccion', data['Direccion']),
            _buildInfoRow('TipoArticulo', data['TipoArticulo']),
            _buildInfoRow('DescripcionEstado', data['DescripcionEstado']),
            _buildInfoRow('NombreContacto', data['NombreContacto']),
            _buildInfoRow('TelefonoContacto', data['TelefonoContacto']),
            _buildInfoRow('EmailContacto', data['EmailContacto']),
            _buildInfoRow('TituloIntercambio', data['TituloIntercambio']),
            _buildInfoRow('CondicionIntercambio', data['CondicionIntercambio']),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? 'No disponible',
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}