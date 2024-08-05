import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/providers/group_provider.dart';
import 'package:habitwise/screens/auth/login_screen.dart';
import 'package:habitwise/screens/auth/signup_screen.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:habitwise/screens/goals_screen.dart';
import 'package:habitwise/screens/group/create_group_screen.dart';
import 'package:habitwise/screens/group/group_details_screen.dart';
import 'package:habitwise/screens/habit_screen.dart';
import 'package:habitwise/screens/landing_page.dart';
import 'package:habitwise/screens/profile_screen.dart';
import 'package:habitwise/screens/setting_screen.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'themes/theme.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// Centralized ValueNotifier for theme management
final ValueNotifier<ThemeMode> appThemeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          title: 'HabitWise',
          navigatorObservers: <NavigatorObserver>[observer],
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => LandingPage(
              onThemeChanged: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(themeNotifier: appThemeNotifier),
                  ),
                );
              },
              themeNotifier: appThemeNotifier,
            ),
            '/login': (context) => LoginScreen(
              emailController: TextEditingController(),
              passwordController: TextEditingController(),
              onLoginSuccess: (username) async {
                UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
                HabitWiseUser? user = await userProvider.getUserDetails();
                if (user != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(user: user, groupId: '',),
                    ),
                  );
                } else {
                  // Handle error if user data isn't available
                }
              },
            ),
            '/signup': (context) => SignUpScreen(
              emailController: TextEditingController(),
              usernameController: TextEditingController(),
              passwordController: TextEditingController(),
              passwordConfirmController: TextEditingController(),
              onSignupSuccess: (username) async {
                UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
                HabitWiseUser? user = await userProvider.getUserDetails();
                if (user != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(user: user, groupId: '',),
                    ),
                  );
                } else {
                  // Handle error if user data isn't available
                }
              },
            ),
            '/dashboard': (context) => Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                if (userProvider.user == null) {
                  return FutureBuilder<HabitWiseUser?>(
                    future: userProvider.getUserDetails(),
                    builder: (context, AsyncSnapshot<HabitWiseUser?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return DashboardScreen(user: snapshot.data!, groupId: '',);
                      } else if (snapshot.hasError) {
                        return Scaffold(
                          body: Center(child: Text('Error fetching user data: ${snapshot.error}')),
                        );
                      } else {
                        return Scaffold(
                          body: Center(child: Text('User data not found')),
                        );
                      }
                    },
                  );
                } else {
                  return DashboardScreen(user: userProvider.user!, groupId: '',);
                }
              },
            ),
            '/createGroup': (context) => CreateGroupScreen(),
            '/groupDetails': (context) {
              final HabitWiseGroup group = ModalRoute.of(context)!.settings.arguments as HabitWiseGroup;
              final HabitWiseUser user = Provider.of<UserProvider>(context, listen: false).user!;
              
              return GroupDetailsScreen(group: group, user: user);
            },
            '/habit': (context) => Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                if (userProvider.user == null) {
                  return FutureBuilder<HabitWiseUser?>(
                    future: userProvider.getUserDetails(),
                    builder: (context, AsyncSnapshot<HabitWiseUser?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return HabitScreen(user: snapshot.data!, groupId: '',);
                      } else if (snapshot.hasError) {
                        return Scaffold(
                          body: Center(child: Text('Error fetching user data: ${snapshot.error}')),
                        );
                      } else {
                        return Scaffold(
                          body: Center(child: Text('User data not found')),
                        );
                      }
                    },
                  );
                } else {
                  return HabitScreen(user: userProvider.user!, groupId: '',);
                }
              },
            ),
            '/goals': (context) => Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                if (userProvider.user == null) {
                  return FutureBuilder<HabitWiseUser?>(
                    future: userProvider.getUserDetails(),
                    builder: (context, AsyncSnapshot<HabitWiseUser?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return GoalScreen(user: snapshot.data!);
                      } else if (snapshot.hasError) {
                        return Scaffold(
                          body: Center(child: Text('Error fetching user data: ${snapshot.error}')),
                        );
                      } else {
                        return Scaffold(
                          body: Center(child: Text('User data not found')),
                        );
                      }
                    },
                  );
                } else {
                  return GoalScreen(user: userProvider.user!);
                }
              },
            ),
            '/profile': (context) => Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                if (userProvider.user == null) {
                  return FutureBuilder<HabitWiseUser?>(
                    future: userProvider.getUserDetails(),
                    builder: (context, AsyncSnapshot<HabitWiseUser?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return ProfilePage(user: snapshot.data!);
                      } else if (snapshot.hasError) {
                        return Scaffold(
                          body: Center(child: Text('Error fetching user data: ${snapshot.error}')),
                        );
                      } else {
                        return Scaffold(
                          body: Center(child: Text('User data not found')),
                        );
                      }
                    },
                  );
                } else {
                  return ProfilePage(user: userProvider.user!);
                }
              },
            ),
          },
        );
      },
    );
  }
}
