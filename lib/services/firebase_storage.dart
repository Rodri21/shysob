// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

final ImagePicker _imagePicker = ImagePicker();
final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

Future<void> uploadImage(BuildContext context, String email) async {
  final pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
  final String fotoActual = await downloadURLExample(email);

  if (pickedImage != null) {

    if(fotoActual != ''){ //Ya tiene foto. Borrar primero esa foto
      final existingImageRef = FirebaseStorage.instance.refFromURL(fotoActual);
      await existingImageRef.delete();
    }

    final file = File(pickedImage.path);
    //final fileName = file.path.split('/').last;
    //final destination = 'avatar/$fileName';
    final destination = 'avatar/$email';

    try {
      await _firebaseStorage.ref(destination).putFile(file);
      // La imagen se ha subido correctamente.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen subida correctamente')),
      );
    } catch (e) {
      // Ocurrió un error al subir la imagen.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir la imagen')),
      );
    }
  }
}

Future<String> downloadURLExample(String imgName) async {
  try {
    final ref = FirebaseStorage.instance.ref().child(imgName);
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    if (e is FirebaseException && e.code == 'object-not-found') {
      return '';
    }
    print('Error al obtener la URL de descarga: $e');
    return '';
  }
}


Future<ImageProvider> _getImageProviderFromFirebase(String imageUrl) async {
  final firebaseImage = _firebaseStorage.ref(imageUrl);
  final url = await firebaseImage.getDownloadURL();
  return NetworkImage(url);
}