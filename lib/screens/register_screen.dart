// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:shysob/firebase/colonos.dart';
import 'package:shysob/firebase/colonosHabilitados.dart';
import 'package:shysob/firebase/vigilantes.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _userTypeProvider = StateProvider<String>((ref) => 'colono');
final showDireccionProvider = StateProvider<bool>((ref) => true);
final showZonaProvider = StateProvider<bool>((ref) => false);

class RegisterScreen extends ConsumerWidget {
  RegisterScreen({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final List<String> _opciones = ['colono', 'vigilante'];
  final ColonosHabilitados colonosHabilitados = ColonosHabilitados();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String email = '';
    String nombre = '';
    String apellidos = '';
    String userType = ref.watch(_userTypeProvider);
    String zone = '';
    String address = '';
    Colonos colonos = Colonos();
    Vigilantes vigilantes = Vigilantes();
    bool showDireccion = ref.watch(showDireccionProvider);
    bool showZona = ref.watch(showZonaProvider);

    registerWithGoogle() async {
      // Autenticar con Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      Map<String, dynamic> colonosHabilitadosData = await colonosHabilitados
          .getUserByEmail(authResult.user!.email!); //_userType

      if (await colonos.checkUserExists(authResult.user!.email!) ||
          await vigilantes.checkUserExists(authResult.user!.email!)) {
        //Usuario ya existe
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('El usuario ya existe'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      if (!await colonosHabilitados.checkUserEnabled(authResult.user!.email!) ||
          colonosHabilitadosData['tipo'] != userType) {
        //Usuario no habilitado
        FirebaseAuth.instance.currentUser!.delete(); //borrar usuario
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Solicita que se habilite tu correo'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      //Todo correcto, se agrega el usuario
      String? idDoc =
          await colonosHabilitados.getUserIdByEmail(authResult.user!.email!);
      if (colonosHabilitadosData['tipo'] == 'colono') {
        colonos.insUser({
          'nombre': '$nombre $apellidos',
          'correo': authResult.user!.email!,
          'direccion': address,
        }, authResult.user!.uid);
      }
      if (colonosHabilitadosData['tipo'] == 'vigilante') {
        vigilantes.insUser({
          'nombre': '$nombre $apellidos',
          'correo': authResult.user!.email!,
          'zona': zone,
        }, authResult.user!.uid);
      }
      colonosHabilitados.updateUser({'registrado': true}, idDoc!);

      // Ir a la pantalla de inicio
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.blue,
          content: Text('Registro completado'),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }

    void onDropdownChanged(String opcion) {
      ref.read(_userTypeProvider.notifier).state = opcion;
      ref.read(showDireccionProvider.notifier).state = opcion == 'colono';
      ref.read(showZonaProvider.notifier).state = opcion == 'vigilante';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrarse',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const FlutterLogo(size: 100.0),
                const SizedBox(height: 16.0),
                DropdownButtonFormField(
                  items: _opciones.map((opcion) {
                    return DropdownMenuItem(
                      value: opcion,
                      child: Text(opcion),
                    );
                  }).toList(),
                  value: userType,
                  onChanged: (nuevaOpcion) {
                    onDropdownChanged(nuevaOpcion!);
                  },
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona una opción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nombre(s)'),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor ingrese su nombre';
                    }
                    return null;
                  },
                  onSaved: (value) => nombre = value!,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Apellidos'),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor ingrese sus apellidos';
                    }
                    return null;
                  },
                  onSaved: (value) => apellidos = value!,
                ),
                const SizedBox(height: 16.0),
                if (showZona)
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Zona'),
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor ingrese su zona';
                      }
                      return null;
                    },
                    onSaved: (value) => zone = value!,
                  ),
                if (showDireccion)
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Dirección'),
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor ingrese su dirección';
                      }
                      return null;
                    },
                    onSaved: (value) => address = value!,
                  ),
                const SizedBox(height: 32.0),
                SocialLoginButton(
                    buttonType: SocialLoginButtonType.google,
                    text: 'Registrarse con Google',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        registerWithGoogle();
                      }
                    }),
                const SizedBox(height: 16.0),
                TextButton(
                  child: const Text('¿Ya tiene una cuenta? Inicie sesión'),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


