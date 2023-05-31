import 'package:flutter/material.dart';
import 'package:shysob/widgets/menu_widget_colono.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shysob/widgets/mis_eventos_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class MisEventosScreen extends StatefulWidget {
  const MisEventosScreen({super.key, required this.user});
  final GoogleSignInAccount user;

  @override
  State<MisEventosScreen> createState() => _MisEventosScreenState();
}

class _MisEventosScreenState extends State<MisEventosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis eventos', style: TextStyle(color: Theme.of(context).colorScheme.primary),)),
      body: MisEventosWidget(user: widget.user,),
      drawer: MenuWidgetColonos(user: widget.user),
    );
  }
}