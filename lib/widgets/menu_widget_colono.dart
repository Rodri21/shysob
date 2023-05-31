// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shysob/services/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final avatarProvider = StateProvider<String>((ref) => '');

class MenuWidgetColonos extends ConsumerStatefulWidget {
  const MenuWidgetColonos({super.key, required this.user});
  final GoogleSignInAccount user;

  @override
  _MenuWidgetColonosState createState() => _MenuWidgetColonosState();
}

class _MenuWidgetColonosState extends ConsumerState<MenuWidgetColonos> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _signOut() async {
    await _googleSignIn.signOut();
  }

  void loadAvatar() async{
    String img =  await downloadURLExample('avatar/${widget.user.email}');
    ref.read(avatarProvider.notifier).state = img;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadAvatar();
  }

  
  @override
  Widget build(BuildContext context) {
    String avatar = ref.watch(avatarProvider);

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
              currentAccountPicture: InkWell(
                onTap: () {
                  //await uploadImage(context, widget.user.email);
                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                      title: const Text('Cambiar foto'),
                      content: const Text('Desea cambiar su foto de perfil?'),
                      actions: [
                        TextButton(onPressed: () async{
                          await uploadImage(context, widget.user.email);
                          Navigator.pop(context);
                          loadAvatar();
                        }, child: const Text('Si')),
                        TextButton(onPressed: () {
                          Navigator.pop(context);
                        }, child: const Text('No'))
                      ],
                    );
                  },);
                },
                child: CircleAvatar(
                  radius: 30, // Ajusta el tamaño del avatar según tus necesidades
                  backgroundImage: NetworkImage(avatar != '' ? avatar : widget.user.photoUrl!)
                ),
              ),
              accountName: Text(widget.user.displayName.toString(), style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
              accountEmail: Text(widget.user.email.toString(), style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),)),

          ListTile(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/agregarEvento', arguments: widget.user);
            },
            title: Text('Agregar evento', style: TextStyle(color: Theme.of(context).colorScheme.primary),),
            leading: const Icon(Icons.add),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/misEventos', arguments: widget.user);
            },
            title: Text('Mis eventos', style: TextStyle(color: Theme.of(context).colorScheme.primary),),
            leading: const Icon(Icons.edit_calendar),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, '/theme', arguments: widget.user);
            },
            title: Text('Temas', style: TextStyle(color: Theme.of(context).colorScheme.primary),),
            leading: const Icon(Icons.draw),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            onTap: () {
              _signOut();
              Navigator.pushReplacementNamed(context, '/login', arguments: widget.user);
            },
            title: Text('Cerrar sesión', style: TextStyle(color: Theme.of(context).colorScheme.primary),),
            leading: const Icon(Icons.logout),
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}