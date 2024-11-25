import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  SettingsPage({required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(134, 41, 137, 1.0), // Purple
                Color.fromRGBO(181, 58, 185, 1),   // Light Purple
                Color.fromRGBO(46, 197, 187, 1.0), // Aqua
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        ),
      
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: Icon(Icons.light_mode, color: Colors.yellow),
              title: Text(
                'Theme',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              trailing: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, themeMode, child) {
                  return Switch(
                    activeColor: Colors.green,
                    value: themeMode == ThemeMode.dark,
                    onChanged: (isDarkMode) {
                      themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
                    },
                  );
                },
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: Icon(Icons.notifications, color: Colors.blue),
              title: Text(
                'Notifications',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              trailing: Switch(
                activeColor: Colors.green,
                value: true,
                onChanged: (bool value) {
                  // Handle notification toggle
                },
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: Icon(Icons.language, color: Colors.red),
              title: Text(
                'Language',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle language change
              },
            ),
          ),
        ],
      ),
    );
  }
}
 