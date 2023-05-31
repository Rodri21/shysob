// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:shysob/firebase/eventos.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shysob/widgets/item_evento_widget.dart';

class MisEventosWidget extends StatefulWidget {
  const MisEventosWidget({super.key, required this.user});
  final GoogleSignInAccount user;

  @override
  State<MisEventosWidget> createState() => _MisEventosWidgetState();
}

class _MisEventosWidgetState extends State<MisEventosWidget> {
  Eventos eventos = Eventos();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: eventos.getEventsByEmail(widget.user.email),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return Card( // Wrap ListTile with Card
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/itemEvento', arguments: {'user': widget.user, 'idEvento': snapshot.data!.docs[index].id});
                    /* showDialog(
                      context: context,
                      builder: (context) => ItemEventoWidget(user: widget.user, idEvento: snapshot.data!.docs[index].id),
                    ); */
                  },
                  leading: const Icon(Icons.calendar_today),
                  title: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        snapshot.data!.docs[index].get('nombre'),
                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Theme.of(context).colorScheme.secondary,
                                  title: Text('Confirmar Borrado', style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),),
                                  content: Text('Deseas borrar el evento?', style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        eventos.delEvento(snapshot.data!.docs[index].id);
                                        Navigator.pop(context);
                                      },
                                      child: Text('Si', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondary)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('No', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondary)),
                                    )
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      )
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error en la petición, intente de nuevo más tarde'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
