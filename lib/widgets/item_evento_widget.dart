// ignore_for_file: depend_on_referenced_packages, avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shysob/firebase/eventos.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selDateProvider = StateProvider<DateTime>((ref) => DateTime.now().toLocal());
final invitadosListProvider = StateProvider<List<String>>((ref) => ['']);
final invitadoControllersProvider = StateProvider<List<TextEditingController>>((ref) => [TextEditingController()]);
final idEventoProvider = StateProvider<String>((ref) => '');
final loadedProvider = StateProvider((ref) => false);
final nombreEventoControllerProvider = StateProvider<TextEditingController>((ref) {
  return TextEditingController();
});

class ItemEventoWidget extends ConsumerStatefulWidget  {
  const ItemEventoWidget({super.key, required this.user, required this.idEvento});
  final GoogleSignInAccount user;
  final String idEvento;
  
  @override
  _ItemEventoWidgetState createState() => _ItemEventoWidgetState();
}

class _ItemEventoWidgetState extends ConsumerState<ItemEventoWidget> {
  final _formKey = GlobalKey<FormState>();
  final Eventos eventos = Eventos();

  @override
  void initState() {
    eventos.getEventById(widget.idEvento).then((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> evento = snapshot.data()! as Map<String, dynamic>;
        // Asignar valores iniciales a los controladores de texto y lista de invitados
        ref.read(nombreEventoControllerProvider.notifier).state.text = evento['nombre'];
        ref.read(selDateProvider.notifier).state = DateFormat('dd/MM/yyyy').parse(evento['fecha']);
        ref.read(loadedProvider.notifier).state = true;
      } 
    });
    eventos.getInvitadosByEventoId(widget.idEvento).then((invitados) {
      ref.read(invitadosListProvider.notifier).state = List<String>.from(invitados);
      List<String> invitadosList = ref.watch(invitadosListProvider);
      ref.read(invitadoControllersProvider.notifier).state = invitadosList.map((invitado) => TextEditingController(text: invitado)).toList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime selectedDay = ref.watch(selDateProvider);
    List<String> invitadosList = ref.watch(invitadosListProvider);
    List<TextEditingController> invitadoControllers = ref.watch(invitadoControllersProvider);
    bool loaded = ref.watch(loadedProvider);
    final nombreEventoController = ref.watch(nombreEventoControllerProvider);
    
    void onDaySelected(DateTime day, DateTime focusedDay) {
      ref.read(selDateProvider.notifier).state = day;
    }

    void updateEvent(String nombre, DateTime fecha, List<Map<String, dynamic>> invitados, String id) {
      String fechaFormateada = DateFormat('dd/MM/yyyy').format(fecha);
      // Actualiza los detalles del evento
      eventos.updEvento({
        'nombre': nombreEventoController.text,
        'fecha': fechaFormateada.toString(),
        'emailColono': widget.user.email,
      }, id);

      // Actualiza la lista de invitados del evento
      eventos.updInvitados(id, invitados);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          content: Text(
            'Evento actualizado',
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    Widget buildAddRemoveButton(bool isAddButton, int index) {
      return InkWell(
        onTap: () {
          if (isAddButton) {
            // Agregar un nuevo campo de invitado al final de la lista
            ref.read(invitadosListProvider.notifier).state = [...invitadosList, ''];
            ref.read(invitadoControllersProvider.notifier).state= [
              ...invitadoControllers,
              TextEditingController(),
            ];
          } else {
            // Eliminar el campo de invitado en la posición 'index'
            invitadoControllers[index].dispose(); // Dispose del controlador en la posición 'index'
            ref.read(invitadosListProvider.notifier).state = [
              ...invitadosList..removeAt(index),
            ];
            ref.read(invitadoControllersProvider.notifier).state = [
              ...invitadoControllers..removeAt(index),
            ];
          }
        },
        child: Container(
          width: 30.0,
          height: 30.0,
          decoration: BoxDecoration(
            color: isAddButton ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Icon(
            isAddButton ? Icons.add : Icons.remove,
            color: Colors.white,
          ),
        ),
      );
    }

    Widget buildInvitadoRow(int index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: invitadoControllers[index],
                decoration: InputDecoration(
                  labelText: 'Invitado ${index + 1}',
                ),
                onChanged: (value) {
                  final updatedInvitadosList = List<String>.from(invitadosList);
                  updatedInvitadosList[index] = value;
                  ref.read(invitadosListProvider.notifier).state = updatedInvitadosList;
                },
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return 'Por favor, ingresa el nombre del invitado';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8.0),
            buildAddRemoveButton(index == invitadosList.length - 1, index),
          ],
        ),
      );
    }

    if (!loaded) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Detalles del Evento',
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nombreEventoController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del evento',
                  ),
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Por favor, ingresa un nombre para el evento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Fecha:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 300,
                  child: TableCalendar(
                    rowHeight: 40,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                    availableGestures: AvailableGestures.all,
                    selectedDayPredicate: (date) => isSameDay(date, selectedDay),
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    onDaySelected: onDaySelected,
                    focusedDay: selectedDay,
                    calendarStyle: CalendarStyle(
                        defaultTextStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                        weekNumberTextStyle: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                        selectedTextStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary),
                        selectedDecoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary),
                        todayTextStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Invitados',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8.0),
                Column(
                  children: invitadosList.map((invitado) {
                    final index = invitadosList.indexOf(invitado);
                    //print(invitadosList);
                    return buildInvitadoRow(index);
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      nombreEventoController.text;
                      selectedDay;
                      List<Map<String, dynamic>> invitadoJsonList =
                          invitadoControllers.map((controller) {
                        return {'nombre': controller.text};
                      }).toList();
                      updateEvent(nombreEventoController.text, selectedDay,
                          invitadoJsonList, widget.idEvento);
                    }
                  },
                  child: Text('Actualizar Evento',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
