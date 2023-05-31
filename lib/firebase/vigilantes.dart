import 'package:cloud_firestore/cloud_firestore.dart';

class Vigilantes{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _usersCollection;

  Vigilantes(){
    _usersCollection = _firestore.collection('vigilantes');
  }

  Future<void> insUser(Map<String, dynamic> map, String id) async{
    return _usersCollection!.doc(id).set(map);
  }

  Future<bool> checkUserExists(String email) async {
    final querySnapshot = await _usersCollection!
      .where('correo', isEqualTo: email)
      .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> updateUser(Map<String, dynamic> map, String id) async{
    return _usersCollection!.doc(id).update(map);
  }

  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('vigilantes')
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