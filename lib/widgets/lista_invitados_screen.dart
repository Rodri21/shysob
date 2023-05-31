import 'package:flutter/material.dart';
import 'package:shysob/firebase/eventos.dart';
import 'package:google_fonts/google_fonts.dart';

class ListaInvitadosScreen extends StatefulWidget {
  const ListaInvitadosScreen({super.key, required this.id});
  final String id;

  @override
  State<ListaInvitadosScreen> createState() => _ListaInvitadosScreenState();
}

class _ListaInvitadosScreenState extends State<ListaInvitadosScreen> {
  Eventos eventos = Eventos();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: eventos.getInvitadosByEventoIdStream(widget.id),
      builder: (context, snapshot){
        if (snapshot.hasData) {
          final invitados = snapshot.data!.docs;
          return ListView.builder(
            itemCount: invitados.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  invitados[index]['nombre'],
                  style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary),
                ),
                trailing: IconButton(onPressed: () {
                  eventos.updInvitado({'asistencia':!invitados[index]['asistencia']}, widget.id, invitados[index].id);
                }, icon: invitados[index]['asistencia'] ? const Icon(Icons.check_box) : const Icon(Icons.check_box_outline_blank)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0),
              );
            },
          );
        } else if(snapshot.hasError){
          return const Center(child: Text('Error en la peticion, intente de nuevo mas tarde'),);
        } else{
          return const Center(child: CircularProgressIndicator(),);
        }
      },
    );
  }
}