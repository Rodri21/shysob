import 'package:cloud_firestore/cloud_firestore.dart';

class Eventos{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _eventosCollection;

  Eventos(){
    _eventosCollection = _firestore.collection('eventos');
  }

  Future<String> insEvento(Map<String, dynamic> eventoData, List<Map<String, dynamic>> invitados) async {
    final docRef = _eventosCollection!.doc();
    await docRef.set(eventoData);

    CollectionReference invitadosCollection = docRef.collection('invitados');

    for (Map<String, dynamic> invitado in invitados) {
      await invitadosCollection.add(invitado);
    }

    return docRef.id;
  }

  Future<void> updEvento(Map<String, dynamic> map, String id) async {
    await _eventosCollection!.doc(id).update(map);
  }

  Future<void> updInvitados(String idEvento, List<Map<String, dynamic>> invitados) async {
    CollectionReference invitadosCollection = _eventosCollection!
        .doc(idEvento)
        .collection('invitados');

    // Elimina todos los documentos existentes de invitados
    await invitadosCollection.get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    // Agrega los nuevos documentos de invitados
    for (Map<String, dynamic> invitado in invitados) {
      await invitadosCollection.add(invitado);
    }
  }



  Future<void> delEvento(String id) async{
    return _eventosCollection!.doc(id).delete();
  }

  

  Future<DocumentSnapshot<Object?>> getEventById(String eventId) {
    return _eventosCollection!.doc(eventId).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getEventByIdStream(String eventId) {
    return FirebaseFirestore.instance
      .collection('eventos')
      .doc(eventId)
      .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getEventsByEmail(String email) {
    return FirebaseFirestore.instance
      .collection('eventos')
      .where('emailColono', isEqualTo: email)
      .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getInvitadosByEventoIdStream(String eventoId) {
    return FirebaseFirestore.instance
      .collection('eventos')
      .doc(eventoId)
      .collection('invitados')
      .snapshots();
  }

  Future<List<String>> getInvitadosByEventoId(String eventoId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('eventos')
      .doc(eventoId)
      .collection('invitados')
      .get();

    List<String> invitadosList = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data();
      // Assuming the 'nombre' field contains the invitado names
      String nombre = data['nombre'];
      invitadosList.add(nombre);
    }

    return invitadosList;
  }



  Future<void> updInvitado(Map<String, dynamic> map, String idEvento, String idInvitado) async{
    return _eventosCollection!.doc(idEvento).collection('invitados').doc(idInvitado).update(map);
  }

}














