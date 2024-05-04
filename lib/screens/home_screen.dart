import 'package:flutter/material.dart';
import '/models/user.dart';
import 'dashboard_screen.dart';
import 'goals_screen.dart';

class HomeScreen extends StatefulWidget {
  final HabitWiseUser user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildContent(),
          ),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: 'Goals',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return DashboardScreen(user: widget.user);
      case 1:
        return GoalsScreen(user: widget.user);
      default:
        return Container();
    }
  }
}
