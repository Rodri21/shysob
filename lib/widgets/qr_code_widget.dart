// ignore_for_file: depend_on_referenced_packages

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:esys_flutter_share_plus/esys_flutter_share_plus.dart';
import 'package:image/image.dart' as img;


class QRCodeWidget extends StatefulWidget {
  const QRCodeWidget({super.key, required this.user, required this.idDoc});
  final GoogleSignInAccount user;
  final String idDoc;

  @override
  State<QRCodeWidget> createState() => _QRCodeWidgetState();
}

class _QRCodeWidgetState extends State<QRCodeWidget> {
  ScreenshotController screenshotController = ScreenshotController();

  void _shareQrCode(BuildContext context) async {
    const String shareText = '¡Echa un vistazo a mi código QR generado con Flutter!';
    final imageBytes = await screenshotController.capture().then((Uint8List? image) => image);

    if (imageBytes != null) {
      final image = img.decodeImage(imageBytes);
      final pngBytes = img.encodePng(image!);
      await Share.file('Código QR', 'qrcode.png', pngBytes, 'image/png', text: shareText);
    } else {
      // Handle error capturing the screenshot
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('QR')),
      content: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Screenshot(
                controller: screenshotController,
                child: Container(
                  color: Colors.white, // Establecer el color de fondo como blanco
                  child: QrImageView(
                    data: widget.idDoc,
                    size: 200,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => _shareQrCode(context),
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}