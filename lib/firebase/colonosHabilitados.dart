import 'package:cloud_firestore/cloud_firestore.dart';

class ColonosHabilitados {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _usersCollection;

  ColonosHabilitados() {
    _usersCollection = _firestore.collection('colonosHabilitados');
  }

  Future<void> insUser(Map<String, dynamic> map, String id) async {
    return _usersCollection!.doc(id).set(map);
  }

  Future<bool> checkUserEnabled(String email) async {
    final querySnapshot =
        await _usersCollection!.where('email', isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> checkUserRegistered(String email) async {
    final querySnapshot =
        await _usersCollection!.where('email', isEqualTo: email).get();

    if (querySnapshot.docs.isNotEmpty) {
      bool registered = querySnapshot.docs.first.get('registrado');
      return registered;
    } else {
      return false;
    }
  }

  Future<void> updateUser(Map<String, dynamic> map, String id) async {
    return _usersCollection!.doc(id).update(map);
  }

  Future<String?> getUserIdByEmail(String email) async {
    final querySnapshot =
        await _usersCollection!.where('email', isEqualTo: email).limit(1).get();

    if (querySnapshot.size > 0) {
      return querySnapshot.docs[0].id;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('colonosHabilitados')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final documentSnapshot = querySnapshot.docs.first;
      final data = documentSnapshot.data();
      return data;
    } else {
      return {};
    }
  }
}
