import 'package:flutter/material.dart';
import 'package:habitwise/screens/setting_screen.dart';
import 'package:habitwise/themes/theme.dart';  // Ensure this import matches your project structure

class BottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final ValueNotifier<ThemeMode> themeNotifier;

  const BottomNavigationBarWidget({
    required this.currentIndex,
    required this.onTap,
    required this.themeNotifier,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current brightness (light or dark mode)
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 4) {  // Assuming the last item is for settings
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SettingsPage(themeNotifier: themeNotifier),
            ),
          );
        } else {
          onTap(index);
        }
      },
      // Set the colors based on the theme mode
      selectedItemColor: isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary,
      unselectedItemColor: isDarkMode ? Colors.white.withOpacity(0.7) : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Goals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Habit',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
