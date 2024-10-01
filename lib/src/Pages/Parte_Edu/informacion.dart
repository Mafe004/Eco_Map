import 'package:flutter/material.dart';
import '../../Components/carrusel_videos.dart';  // Importa el archivo donde está el carrusel de videos
import 'package:url_launcher/url_launcher.dart'; // Importamos url_launcher para abrir PDFs

class InformacionPage extends StatelessWidget {
  const InformacionPage({super.key}); // Agregar `key` y `const`

  // Método para abrir PDFs usando url_launcher
  Future<void> _openPDF(String pdfPath) async {
    final Uri pdfUri = Uri.parse(pdfPath);  // Convertimos la ruta a un objeto Uri
    if (await canLaunchUrl(pdfUri)) {
      await launchUrl(pdfUri);
    } else {
      throw 'No se puede abrir $pdfUri';

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección 1: Separación de Residuos
              Text(
                'Separación de residuos',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),

              Image.asset(
                'assets/images/separacion_residuos/photo.jpg',
                width: double.infinity,
                height: 200, // Ajusta la altura si es necesario
                fit: BoxFit.cover, // Ajuste para llenar el espacio de manera adecuada
              ),
              const SizedBox(height: 20),

              const Text(
                'Aquí aprenderás sobre la separación correcta de residuos. '
                    'Recuerda siempre separar materiales reciclables como papel, '
                    'plástico, vidrio, y baterías de los desechos orgánicos y no reciclables.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/images/separacion_residuos/RECICLAJE.jpg',
                width: double.infinity,
                height: 200, // Ajusta la altura si es necesario
                fit: BoxFit.cover, // Ajuste para llenar el espacio de manera adecuada
              ),

              // Sección 2: Beneficios del reciclaje
              Text(
                'Beneficios del reciclaje',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),

              Image.asset(
                'assets/images/beneficios/beneficios-del-reciclaje.jpg',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),

              const Text(
                'Reciclar ayuda a conservar recursos naturales, reduce la cantidad de residuos en vertederos '
                    'y contribuye a disminuir la contaminación. Cada pequeño esfuerzo suma para el medio ambiente.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),

              Image.asset(
                'assets/images/beneficios/grafico.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),

              // Sección 3: Puntos de reciclaje cercanos
              Text(
                'Puntos de reciclaje cercanos',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              const Text(
                'Encuentra los puntos de reciclaje más cercanos a tu ubicación en Bogotá. '
                    'Consulta el mapa interactivo para saber dónde puedes reciclar materiales como '
                    'baterías, electrónicos y aceite usado.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/images/separacion_residuos/recycle-bin.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),

              // Nueva Sección: Carrusel de Videos
              Text(
                'Videos Educativos',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              const SizedBox(
                height: 250, // Ajusta la altura del carrusel
                child: CarruselVideos(), // Aquí integramos el carrusel de videos
              ),
              const SizedBox(height: 20),

              const Text(
                'Aquí encontrarás mas material para aprender.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),

              // Botón para descargar PDF sobre separación de residuos
              ElevatedButton.icon(
                onPressed: () {
                  _openPDF('assets/pdfs/guia_reciclaje.pdf');  // Aquí debes usar la URI del PDF
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Descargar Guía de Separación de Residuos (PDF)'),
              ),
              const SizedBox(height: 20),

              // Botón para descargar PDF sobre los beneficios del reciclaje
              ElevatedButton.icon(
                onPressed: () {
                  _openPDF('assets/pdfs/reciclaje.pdf');  // Aquí debes usar la URI del PDF
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Descargar Beneficios del Reciclaje (PDF)'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
