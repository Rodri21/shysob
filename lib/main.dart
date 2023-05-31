// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shysob/routes.dart';
import 'package:shysob/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shysob/provider/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shysob/settings/styles_settings.dart';
import 'package:introduction_screen/introduction_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('theme');
  //print(savedTheme);

  final theme = savedTheme == 'dark' ? StylesSettings.darkTheme() : StylesSettings.lightTheme();
  final themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  runApp(ProviderScope(
    overrides: [
      themeProvider.overrideWith((ref) => theme),
      themeModeProvider.overrideWith((ref) => themeMode),
    ],
    child: const MainApp(),
  ));
}


class MainApp extends ConsumerWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(themeProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    List<PageViewModel> getPages(){
      return [
        PageViewModel(
          image: const Image(image: NetworkImage('https://img.freepik.com/vector-gratis/seguridad-datos-global-seguridad-datos-personales-ilustracion-concepto-linea-seguridad-datos-ciberneticos-seguridad-internet-o-privacidad-proteccion-informacion_1150-37373.jpg?w=996&t=st=1685340393~exp=1685340993~hmac=04a33e0c8f3ad4dd6d7a9b85b29aac374dca2cf46b40100a4ba5994882605f28')),
          title: 'Controla el acceso',
          body: 'Con nuestra aplicación, podrás gestionar de manera eficiente las visitas en tu fraccionamiento o privada. Mantén un registro de quienes ingresan, mejorando la seguridad de tu comunidad.',
        ),

        PageViewModel(
          image: const Image(image: NetworkImage('https://img.freepik.com/vector-gratis/verificacion-usuario-prevencion-acceso-no-autorizado-autenticacion-cuenta-privada-ciberseguridad-personas-que-ingresan-nombre-usuario-contrasena-medidas-seguridad_335657-3530.jpg?w=740&t=st=1685340471~exp=1685341071~hmac=23dc315fa2db3a002d779abb53502e773172fa589fe7d18df87b1f8c520d026f')),
          title: 'Registro rápido de visitantes',
          body: 'Nuestra aplicación simplifica el proceso de registro de visitantes. Captura la información necesaria de forma rápida y sencilla, reduciendo los tiempos de espera y mejorando la experiencia de tus residentes y visitantes.',
        ),
        PageViewModel(
          image: const Image(image: NetworkImage('https://img.freepik.com/vector-gratis/familia-protegida-concepto-virus_23-2148584608.jpg?w=740&t=st=1685340620~exp=1685341220~hmac=ff65686679121aa6d11a73e33afc618687106dcce35d4f5b2ac9a7d2cd8082af')),
          title: 'Mantén tu comunidad segura',
          body: 'Nos preocupamos por la seguridad de tu hogar. Con nuestra aplicación, recibirás notificaciones instantáneas sobre las visitas registradas, y tomar medidas inmediatas en caso de detectar alguna actividad sospechosa.',
        ),
      ];
    }
    
    //print(theme.textTheme);
    return MaterialApp(
      //home: LoginScreen(),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return IntroductionScreen(
              done: const Text('Done'),
              onDone: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              pages: getPages(),
              showNextButton: true,
              next: const Icon(Icons.arrow_forward_ios),
            );
          }
        ),
      ),
      routes: getApplicationRoutes(),
      darkTheme: theme,
      themeMode: themeMode,
    );
  }
}