import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../../Servisios/Image-Helper.dart';
import '../../Servisios/Image-Ser.dart';
import '../../Servisios/Localizacion.dart';
import '../../Servisios/strore.dart';


class FormExampleApp extends StatefulWidget {
  final String? initialAddress;
  const FormExampleApp({Key? key, this.initialAddress}) : super(key: key);

  @override
  State<FormExampleApp> createState() => _FormExampleAppState();
}

class _FormExampleAppState extends State<FormExampleApp> {
  final LocationService _locationService = LocationService();
  final ImageService _imageService = ImageService();
  final FirestoreService _firestoreService = FirestoreService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int currentStep = 0;

  bool get isFirstStep => currentStep == 0;

  bool get isLastStep => currentStep == steps().length - 1;

  final Direccion = TextEditingController();
  final TipoArticulo = TextEditingController();
  final DescripcionEstado= TextEditingController();
  final NombreContacto = TextEditingController();
  final TelefonoContacto = TextEditingController();
  final EmailContacto = TextEditingController();
  final TituloIntercambio = TextEditingController();
  final CondicionIntercambio = TextEditingController();


  List<File> selectedImages = [];
  bool isComplete = false;
  Position? currentPosition;
  String? currentAddress;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _initializeLocation() async {
    try {
      currentPosition = await _locationService.getCurrentPosition();
      currentAddress = await _locationService.getAddressFromCoordinates(
          currentPosition!.latitude, currentPosition!.longitude);
      setState(() {
        Direccion.text = currentAddress ?? '';
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void saveDataToFirestore() async {
    if (currentPosition != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final userSnapshot = await FirebaseFirestore.instance.collection(
              'Usuarios').doc(user.uid).get();
          if (userSnapshot.exists) {
            final userData = userSnapshot.data() as Map<String, dynamic>;
            final userName = userData['name'] ??
                'Usuario Desconocido'; // Obtener el nombre de usuario o establecer uno predeterminado
            final reportData = {
              'userId': user.uid,
              'userName': userName,
              // Guardar el nombre del usuario en el informe
              'Direccion': Direccion.text,
              'TipoArticulo': TipoArticulo.text,
              'DescripcionEstado': DescripcionEstado.text,
              'NombreContacto': NombreContacto.text,
              'TelefonoContacto': TelefonoContacto.text,
              'EmailContacto': EmailContacto.text,
              'TituloIntercambio': TituloIntercambio.text,
              'CondicionIntercambio': CondicionIntercambio.text,
              'images': selectedImages.map((image) => image.path).toList(),

            };
            await _firestoreService.saveReport(reportData);
            print('Data added successfully!');
          } else {
            print('User data not found in Firestore.');
          }
        } catch (error) {
          print('Failed to fetch user data: $error');
        }
      } else {
        print('No user currently signed in.');
      }
    }
    else {
      print('Current position is null. Cannot save data.');
    }
  }

  Future<void> _showImageOptions() async {
    final remainingImages = 5 - selectedImages.length;

    if (remainingImages <= 0) {
      // Si ya se han seleccionado 5 imágenes, mostrar un mensaje de error y no permitir agregar más.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No puedes subir más de 5 imágenes.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Mostrar opciones para seleccionar imágenes.
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Seleccionar de la galería'),
              onTap: () async {
                Navigator.pop(context);
                final newImages = await _imageService.pickImages(maxImages: remainingImages);
                _addImages(newImages);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Tomar una foto'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _imageService.takePhoto();
                if (image != null) {
                  _addImages([image]);
                }
              },
            ),
          ],
        );
      },
    );
  }


  void _addImages(List<File> newImages) {
    final totalImages = selectedImages.length + newImages.length;

    if (totalImages > 5) {
      // Si el número total de imágenes excede 5, mostrar un mensaje de error.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No puedes subir más de 5 imágenes.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Lista para almacenar imágenes válidas (resolución <= 1024x1024)
    List<File> validImages = [];

    // Verificar el tamaño y la resolución de cada imagen antes de agregarla a la lista de imágenes seleccionadas.
    for (final image in newImages) {
      final resolution = ImageHelper.getImageResolution(image);
      final width = int.parse(resolution.split('x')[0]);
      final height = int.parse(resolution.split('x')[1]);

      if (width > 800 || height > 800) {
        // Si la resolución de la imagen es mayor que 1024x1024, mostrar un mensaje de error.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(
                  'La imagen seleccionada tiene una resolución mayor que 1024x1024 y no puede ser agregada.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Si la imagen es válida (resolución <= 1024x1024), agregarla a la lista de imágenes válidas.
        validImages.add(image);
      }
    }
    // Si las imágenes cumplen con los requisitos, agregarlas a la lista de imágenes seleccionadas.
    selectedImages.addAll(validImages);
    // Mostrar el tamaño y la resolución de las imágenes
    setState(() {});
  }

  List<Step> steps() =>
      [
        Step(
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 0,
          title: const Text('Información General del lugar'),
          content: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  enabled: false,
                  // Deshabilitar el campo
                  controller: Direccion,
                  // Usar el controlador para la dirección
                  decoration: const InputDecoration(labelText: 'Dirección'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La dirección es obligatoria';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: TipoArticulo,
                  decoration: const InputDecoration(labelText: 'Tipo de articulo'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El tipo de articulo es obligatorio';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: DescripcionEstado,
                  decoration: const InputDecoration(labelText: 'Descripcion estado'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Descripcion de estado es obligatorio';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        Step(
          state: currentStep > 1 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 1,
          title: const Text('Contacto'),
          content: Column(
            children: [
              TextFormField(
                controller: NombreContacto,
                decoration: const InputDecoration(labelText: 'Nombre de contacto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre de contacto es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: TelefonoContacto,
                decoration: const InputDecoration(labelText: 'Telefono de contacto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El telefono de contacto es obligatoria';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: EmailContacto,
                decoration: const InputDecoration(
                    labelText: 'Email de contacto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El imail de contacto es obligatorio';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        Step(
          state: currentStep > 2 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 2,
          title: const Text('trueque'),
          content: Column(
            children: [
              TextFormField(
                controller: TituloIntercambio,
                decoration: const InputDecoration(
                    labelText: 'Titulo de intercambio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El titulo de intercambio es obligatoria';
                  }
                  return null;
                },
              ),
             //
          //TextFormField(
              //  controller: ubicacion,
               // decoration: const InputDecoration(
                  // labelText: 'Puntos de ubicación cercanas'),
              //  validator: (value) {
                 // if (value == null || value.isEmpty) {
                //    return 'Los puntos de ubicacion son obligatorias';
                //  }
                 // return null;
           //     },
             // ),
              TextFormField(
                controller: CondicionIntercambio,
                decoration: const InputDecoration(
                    labelText: 'Condiciones de intercambio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Las condiciones de intercambio son obligatorios';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),


        Step(
          state: currentStep > 5 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 5,
          title: const Text('informacion usuario'),
          content: Column(
            children: [
              ElevatedButton(
                onPressed: () => _showImageOptions(),
                child: Text('Adjuntar Fotos (${selectedImages.length}/5)'),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: selectedImages.map((image) {
                  return Stack(
                    children: [
                      Image.file(
                        image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImages.remove(image);
                            });
                          },
                          child: Container(
                            color: Colors.black54,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),

      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Trueque'),
      ),
      body: isComplete
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Éxito!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isComplete = false;
                  currentStep = 0;
                  selectedImages.clear();
                  Direccion.clear();
                  TipoArticulo.clear();
                  DescripcionEstado.clear();
                  NombreContacto.clear();
                  TelefonoContacto.clear();
                  EmailContacto.clear();
                  TituloIntercambio.clear();
                  Direccion.clear();
                  CondicionIntercambio.clear();
                });
              },
              child: const Text('Nuevo Trueque'),
            ),
          ],
        ),
      )
          : Stepper(
        type: StepperType.vertical,
        steps: steps(),
        currentStep: currentStep,
        onStepContinue: () {
          if (_formKey.currentState!.validate()) {
            if (isLastStep) {
              saveDataToFirestore();
              setState(() => isComplete = true);
            } else {
              setState(() => currentStep += 1);
            }
          }
        },
        onStepCancel: isFirstStep
            ? null
            : () => setState(() => currentStep -= 1),
        onStepTapped: (step) => setState(() => currentStep = step),
        controlsBuilder: (context, details) =>
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(isLastStep ? 'confirmar' : 'Siguiente'),
                    ),
                  ),
                  if (!isFirstStep)
                    const SizedBox(width: 12),
                  if (!isFirstStep)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Atrás'),
                      ),
                    ),
                ],
              ),
            ),
      ),
    );
  }
}

