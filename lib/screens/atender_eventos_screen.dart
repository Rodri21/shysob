// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:shysob/firebase/eventos.dart';
import 'package:shysob/widgets/lista_invitados_screen.dart';
import 'package:shysob/widgets/menu_widget_vigilante.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final qrDataProvider = StateProvider<String>((ref) => '');
class AtenderEventosScreen extends ConsumerWidget {
  AtenderEventosScreen({super.key, required this.user});
  final GoogleSignInAccount user;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  

  String qrData = '';

  Eventos eventos = Eventos();



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    QRViewController controller;
      void onQRViewCreated(QRViewController controller) {
        controller.scannedDataStream.listen((scanData) {
          ref.read(qrDataProvider.notifier).state = scanData.code!;
        });
      }
    String qrData = ref.watch(qrDataProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Visitas')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20,),
              Text('Escanear QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.primary),),
              const SizedBox(height: 20,),
              SizedBox(
                height: 200,
                width: 200,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: onQRViewCreated,
                ),
              ),
              const SizedBox(height: 20,),
               ElevatedButton(onPressed: (){
                ref.read(qrDataProvider.notifier).state = '';
              }, child: const Text('Reiniciar')),
              const SizedBox(height: 20,), 
              
               (qrData.isNotEmpty) ? 
                StreamBuilder(
                  stream: eventos.getEventByIdStream(qrData),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        children: [
                          Text(data['nombre'] + ': ' + data['fecha'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.primary),),
                          const SizedBox(height: 10,),
                          SizedBox(height: 300, child: ListaInvitadosScreen(id: qrData)),
                          const SizedBox(height: 20,),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Container();
                    }
                  },
                )
              : Text('Vacio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error),) 
            ],
          ),
        ),
      ),
      drawer: MenuWidgetVigilante(user: user),
    );
  }
}
