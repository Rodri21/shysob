// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages, use_build_context_synchronously
import 'package:shysob/firebase/eventos.dart';
import 'package:shysob/widgets/menu_widget_colono.dart';
import 'package:shysob/widgets/qr_code_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selDateProvider = StateProvider<DateTime>((ref) => DateTime.now().toLocal());
final invitadosListProvider = StateProvider<List<String>>((ref) => ['']);
final invitadoControllersProvider = StateProvider<List<TextEditingController>>((ref) => [TextEditingController()]);

class AgregarEventoScreen extends ConsumerWidget {
  AgregarEventoScreen({super.key, required this.user});
  final GoogleSignInAccount user;
  final Eventos eventos = Eventos();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    DateTime selectedDay = ref.watch(selDateProvider);
    List<String> invitadosList = ref.watch(invitadosListProvider);
    List<TextEditingController> invitadoControllers = ref.watch(invitadoControllersProvider);

    TextEditingController nombreEventoController = TextEditingController();
    

    void onDaySelected(DateTime day, DateTime focusedDay){
      ref.read(selDateProvider.notifier).state = day;
    }

    Future<void> saveEvent(String nombre, DateTime fecha, List<Map<String, dynamic>> invitados) async {
      String fechaFormateada = DateFormat('dd/MM/yyyy').format(fecha);
      String docId = await eventos.insEvento({
        'nombre': nombre,
        'fecha': fechaFormateada.toString(),
        'emailColono': user.email,
        'visitaIndividual':false
      }, invitados);
      showDialog(
        context: context,
        builder: (context) => QRCodeWidget(user: user, idDoc: docId),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.blue,
          content: Text('Evento agregado'),
          duration: Duration(seconds: 3),
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
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: invitadoControllers[index],
                decoration: InputDecoration(
                  labelText: 'Invitado ${index + 1}',
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                onChanged: (value) {
                  ref.read(invitadosListProvider.notifier).state = [
                    ...invitadosList..replaceRange(index, index + 1, [value]),
                  ];
                },
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Evento', style: TextStyle(color: Theme.of(context).colorScheme.primary),),
      ),
      drawer: MenuWidgetColonos(user: user),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
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
                color: Theme.of(context).colorScheme.primary
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
                  titleTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),                
                ), 
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (date)=>isSameDay(date, selectedDay),
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                onDaySelected: onDaySelected,
                focusedDay: selectedDay,
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  weekNumberTextStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  selectedTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                  selectedDecoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
                  todayTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Invitados',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.primary
              ),
            ),
            const SizedBox(height: 8.0),
            Column(
              children: invitadosList.map((invitado) {
                final index = invitadosList.indexOf(invitado);
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
                  List<Map<String, dynamic>> invitadoJsonList = invitadoControllers.map((controller) {
                    return {
                      'nombre': controller.text,
                      'asistencia': false
                    };
                  }).toList();
                  saveEvent(nombreEventoController.text, selectedDay, invitadoJsonList);
                }
              },
              child: const Text('Guardar Evento'),
            ),
          ],
        ),
      ),
    );
  }
}
