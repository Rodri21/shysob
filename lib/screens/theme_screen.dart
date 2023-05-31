import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shysob/provider/providers.dart';
import 'package:shysob/settings/styles_settings.dart';


class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  Future<void> _saveThemeData(String theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Temas'),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Elige un tema',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Consumer(builder: (context, ref, _) {
              return ElevatedButton(
                onPressed: ()  {
                  ref.read(themeProvider.notifier).state = StylesSettings.lightTheme();  
                  ref.read(themeModeProvider.notifier).state = ThemeMode.light;  
                  _saveThemeData('light');
                },
                child: const Text('Claro'),
              );
            }),
            const SizedBox(height: 20),
            Consumer(builder: (context, ref, _) {
              return ElevatedButton(
                onPressed: ()  {
                  ref.read(themeProvider.notifier).state = StylesSettings.darkTheme(); 
                  ref.read(themeModeProvider.notifier).state = ThemeMode.dark;   
                  _saveThemeData('dark');
                },
                child: const Text('Oscuro'),
              );
            }),
            const SizedBox(height: 20),
            Text(
              'Componentes de muestra',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Card(
              color: Theme.of(context).cardColor,
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                title: Text('Elemento de lista', style: TextStyle(color: Theme.of(context).colorScheme.primary),),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 100,
              color: Theme.of(context).primaryColor,
              alignment: Alignment.center,
              child: Text(
                'Contenedor',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}