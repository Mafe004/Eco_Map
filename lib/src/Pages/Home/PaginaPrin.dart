import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Position? _currentPosition;
  String? _currentAddress;
  String selectedType = 'Todos'; // Tipo seleccionado por defecto

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final address = await _getAddressFromLatLng(position);
    setState(() {
      _currentPosition = position;
      _currentAddress = address;
    });
    _getMarkersFromFirebase(); // Llama a los marcadores después de obtener la ubicación
  }

  Future<String> _getAddressFromLatLng(Position position) async {
    final coordinates = LatLng(position.latitude, position.longitude);
    final List<Placemark> placemarks = await placemarkFromCoordinates(coordinates.latitude, coordinates.longitude);
    final Placemark place = placemarks[0];
    return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<double> _getMarkerColor(String tipo) async {
    switch (tipo) {
      case "Pilas":
        return BitmapDescriptor.hueYellow; // Color amarillo para Pilas
      case "Eléctricos":
        return BitmapDescriptor.hueBlue; // Color azul para Eléctricos
      default:
        return BitmapDescriptor.hueRed; // Color rojo por defecto
    }
  }

  Future<void> _getMarkersFromFirebase() async {
    QuerySnapshot reportes = await FirebaseFirestore.instance.collection('Marcadores').get();

    final List<Marker> loadedMarkers = [];

    for (var doc in reportes.docs) {
      GeoPoint? geoPoint = doc['Ubicacion'];
      String tipo = doc['Tipo'];

      if (geoPoint != null && (selectedType == 'Todos' || selectedType == tipo)) {
        final markerColor = await _getMarkerColor(tipo);
        Marker marker = Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(geoPoint.latitude, geoPoint.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
          onTap: () {
            _showMarkerDetails(doc);
          },
        );

        loadedMarkers.add(marker);
      }
    }

    // Usar setState una vez para actualizar todos los marcadores
    setState(() {
      markers = {for (var m in loadedMarkers) m.markerId: m};
    });
  }

  void _filterMarkers(String type) {
    setState(() {
      selectedType = type; // Actualiza el tipo seleccionado
      markers.clear(); // Limpia los marcadores actuales
    });

    _getMarkersFromFirebase(); // Llama a los marcadores nuevamente
  }

  void _showMarkerDetails(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${doc['N-Lugar']}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Dirección: ${doc['Dirección']}', style: TextStyle(fontSize: 16)),
                Text('Localidad: ${doc['Localidad']}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('Descripción: ${doc['Detalle']}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('Tipo: ${doc['Tipo']}', style: TextStyle(fontSize: 16)),
              Text('Horario: ${doc['Horario']}', style: TextStyle(fontSize: 16)),

              ],

            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialPosition = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : LatLng(0, 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Eco-Mapa',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: _currentPosition != null
          ? Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 16.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: Set<Marker>.of(markers.values),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: _buildFilterDropdown(), // Cambiar aquí
          ),
          Positioned(
            top: 16,
            right: 16,
            child: _buildMarkerLegend(),
          ),
        ],
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          // Acción para realizar al presionar el botón flotante
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedType,
        items: <String>['Todos', 'Pilas', 'Eléctricos'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            _filterMarkers(newValue);
          }
        },
      ),
    );
  }

  Widget _buildMarkerLegend() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Pilas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Eléctricos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Otros',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}