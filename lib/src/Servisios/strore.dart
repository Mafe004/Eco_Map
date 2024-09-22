import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> saveReport(Map<String, dynamic> reportData) async {
    await firestore.collection('Reportes').add(reportData);
  }
}
