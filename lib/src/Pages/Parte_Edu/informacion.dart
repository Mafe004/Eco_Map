import 'package:flutter/material.dart';

class InformacionPage extends StatelessWidget {
  const InformacionPage({super.key}); // Agregar `key` y `const`

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
              const SizedBox(height: 20),

              // Sección 2: Beneficios del reciclaje
              Text(
                'Beneficios del reciclaje',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              const Text(
                'Reciclar ayuda a conservar recursos naturales, reduce la cantidad de residuos en vertederos '
                    'y contribuye a disminuir la contaminación. Cada pequeño esfuerzo suma para el medio ambiente.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/images/beneficios/beneficios-del-reciclaje.jpg',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
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
            ],
          ),
        ),
      ),
    );
  }
}
