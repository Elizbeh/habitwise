import 'package:flutter/material.dart';

// Update SettingsPage to use appThemeNotifier
class SettingsPage extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  SettingsPage({required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Theme'),
            trailing: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, themeMode, child) {
                return Switch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (isDarkMode) {
                    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
