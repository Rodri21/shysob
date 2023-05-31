// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:shysob/screens/agregar_evento_screen.dart';
import 'package:shysob/screens/atender_eventos_screen.dart';
import 'package:shysob/screens/login_screen.dart';
import 'package:shysob/screens/mis_eventos_screen.dart';
import 'package:shysob/screens/register_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shysob/screens/theme_screen.dart';
import 'package:shysob/widgets/item_evento_widget.dart';

Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    '/register': (BuildContext context) => RegisterScreen(),
    //'/dash': (BuildContext context) => DashboardScreen(),
    '/login': (BuildContext context) => LoginScreen(),
    '/theme':(BuildContext context) => const ThemeScreen(),
    //'/events':(BuildContext context) => const Events(), 
    '/itemEvento': (BuildContext context) {
      final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final GoogleSignInAccount? user = arguments?['user'] as GoogleSignInAccount?;
      final String? idEvento = arguments?['idEvento'] as String?;
      
      if (user != null && idEvento != null) {
        return ItemEventoWidget(user: user, idEvento: idEvento);
      } else {
        return Container();
      }
    },
    '/atenderEvento': (BuildContext context) {
      final user = ModalRoute.of(context)?.settings.arguments as GoogleSignInAccount?;
      if (user != null) {
        return AtenderEventosScreen(user: user);
      } else {
        return Container();
      }
    },
    '/agregarEvento': (BuildContext context) {
      final user = ModalRoute.of(context)?.settings.arguments as GoogleSignInAccount?;
      if (user != null) {
        return AgregarEventoScreen(user: user);
      } else {
        return Container();
      }
    },
    '/misEventos': (BuildContext context) {
      final user = ModalRoute.of(context)?.settings.arguments as GoogleSignInAccount?;
      if (user != null) {
        return MisEventosScreen(user: user);
      } else {
        return Container();
      }
    },
  };
}
