// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages, use_build_context_synchronously, slash_for_doc_comments

import 'package:flutter/material.dart';
import 'package:shysob/firebase/colonosHabilitados.dart';
import 'package:shysob/screens/responsive.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tipoProvider = StateProvider<String>((ref) => '');
final userProvider = StateProvider<GoogleSignInAccount?>((ref) => null);

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final ColonosHabilitados colonosHabilitados = ColonosHabilitados();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String username = ''; 

    String password = '';

    String tipo = '';

    late GoogleSignInAccount user;

    Future<void> signInWithGoogle() async {
      // Obtener correo
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Verificar si esta registrado
      final ColonosHabilitados habilitados = ColonosHabilitados();
      final bool userRegistered = await habilitados.checkUserRegistered(googleUser!.email);

      if (userRegistered) {// Si esta registrado, sacar el tipo y actualizarlo
        Map<String, dynamic> colonosHabilitadosData = await colonosHabilitados.getUserByEmail(googleUser.email);
        ref.read(tipoProvider.notifier).state = colonosHabilitadosData['tipo'];
        ref.read(userProvider.notifier).state = googleUser;
      } else {// Si no esta registrado mostrar mensaje de que se registre y eliminar correo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('El usuario no existe. Registrate primero'),
            duration: Duration(seconds: 3),
          ),
        ); 
      }
    } 

    SocialLoginButton googleLoginButton() {
      return SocialLoginButton(
        buttonType: SocialLoginButtonType.google,
        onPressed: () async{
          await signInWithGoogle();
          tipo = ref.watch(tipoProvider);
          if (tipo == 'colono') Navigator.pushReplacementNamed(context, '/agregarEvento', arguments: ref.watch(userProvider));
          if (tipo == 'vigilante') Navigator.pushReplacementNamed(context, '/atenderEvento', arguments: ref.watch(userProvider));
        },
      );
    }

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Iniciar Sesión', style: TextStyle(color: Theme.of(context).colorScheme.primary),),
      ),
      //drawer: MenuWidget(user: '_user'),
      body: Responsive(
        mobile: mobileScreen(context, username, password, googleLoginButton),
        desktop: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                const FlutterLogo(size: 100.0),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Correo'),  
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),         
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor ingrese su correo';
                    }
                    return null;
                  },
                  onSaved: (value) => username = value!,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Contraseña'), 
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor ingrese su contraseña';
                    }
                    return null;
                  },
                  onSaved: (value) => password = value!,
                ),
                const SizedBox(height: 32.0),
                googleLoginButton(),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  child: const Text('Iniciar Sesión', ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      
                    }
                  },
                ),
                TextButton(
                  child: const Text('Registrarse', ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                ),
                TextButton(
                  child: const Text('¿Olvidaste tu contraseña?', ),
                  onPressed: () {
                    
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  SingleChildScrollView mobileScreen(BuildContext context, String username, String password, SocialLoginButton googleLoginButton()) {
    return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                const FlutterLogo(size: 100.0),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Correo'),  
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),         
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor ingrese su correo';
                    }
                    return null;
                  },
                  onSaved: (value) => username = value!,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Contraseña'), 
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor ingrese su contraseña';
                    }
                    return null;
                  },
                  onSaved: (value) => password = value!,
                ),
                const SizedBox(height: 32.0),
                googleLoginButton(),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  child: const Text('Iniciar Sesión', ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      
                    }
                  },
                ),
                TextButton(
                  child: const Text('Registrarse', ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                ),
                TextButton(
                  child: const Text('¿Olvidaste tu contraseña?', ),
                  onPressed: () {
                    
                  },
                ),
              ],
            ),
          ),
        ),
      );
  }
}
