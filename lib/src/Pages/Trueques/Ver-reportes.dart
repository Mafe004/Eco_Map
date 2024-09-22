import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ViewReportPage extends StatelessWidget {
  final DocumentSnapshot reportSnapshot;

  const ViewReportPage({Key? key, required this.reportSnapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = reportSnapshot.data() as Map<String, dynamic>;
    final List<String> imagePaths = List<String>.from(data['images'] ?? []);

    final timestamp = (data['timestamp'] as Timestamp).toDate();


    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 16),
            Text(
              'Descripción:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(data['Descripcion'] ?? 'No disponible'),
            const SizedBox(height: 16),
            Text(
              'Ubicación:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(data['ubicacion'] ?? 'No disponible'),
            const SizedBox(height: 16),
            Text(
              'Fecha y Hora:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),
            Text(
              'Más detalles:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDetailRow('Tipo de lugar', data['tipoLugar']),
                _buildDetailRow('Estado de las carreteras', data['estadoCarretera']),
                _buildDetailRow('Servicios básicos', data['serviciosBasicos']),
                _buildDetailRow('Estado de edificaciones', data['estadoEdificaciones']),
                _buildDetailRow('Calidad del agua', data['calidadAgua']),
                _buildDetailRow('Fuentes de agua', data['fuentesAgua']),
                _buildDetailRow('Problemas de agua', data['problemasAgua']),
                _buildDetailRow('Tipo de suministro de agua', data['tipoSuministros']),
                _buildDetailRow('Estado de instalaciones de agua', data['estadoInstalaciones']),
                _buildDetailRow('Cortes de agua', data['cortesAgua']),
                _buildDetailRow('Tipo de alcantarillado', data['tipoAlcantarillado']),
                _buildDetailRow('Estado del alcantarillado', data['estadoAlcantarillado']),
                _buildDetailRow('Problemas específicos', data['problemasEspecificos']),
                _buildDetailRow('Comentarios adicionales', data['comentarios']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
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

