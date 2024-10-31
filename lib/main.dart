import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:habitwise/methods/FirebaseOptions.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/providers/habit_provider.dart';
import 'package:habitwise/providers/quote_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/providers/group_provider.dart';
import 'package:habitwise/screens/auth/login_screen.dart';
import 'package:habitwise/screens/auth/signup_screen.dart';
import 'package:habitwise/screens/auth/verify_email_screen.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:habitwise/screens/group/create_group_screen.dart';
import 'package:habitwise/screens/group/group_details_screen.dart';
import 'package:habitwise/screens/landing_page.dart';
import 'package:habitwise/screens/profile_screen.dart';
import 'package:habitwise/screens/setting_screen.dart';
import 'package:habitwise/services/goals_db_service.dart';
import 'package:habitwise/services/group_db_service.dart';
import 'package:habitwise/services/habit_db_service.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'themes/theme.dart';




final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// Centralized ValueNotifier for theme management
final ValueNotifier<ThemeMode> appThemeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: firebaseOptions
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              throw Exception('User is not logged in'); // Handle user not logged in
            }
            return GoalProvider(userId: user.uid);
          },
        ),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
        Provider(create: (_) => GroupDBService()),
        Provider(create: (_) => GoalDBService()),
        Provider(create: (_) => HabitDBService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  const MyApp({super.key});

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
          themeMode: themeMode,
          theme: lightTheme(context),
          darkTheme: darkTheme(context),
          initialRoute: '/',
         
          routes: {
            '/': (context) => FutureBuilder<HabitWiseUser?>(
                  future: Provider.of<UserProvider>(context, listen: false).getUserDetails(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(body: Center(child: CircularProgressIndicator()));
                    } else if (snapshot.hasData && snapshot.data != null) {
                      final user = snapshot.data!;
                      if (user.emailVerified) {
                        return DashboardScreen(
                          user: user,
                          groupId: user.groupIds.isNotEmpty ? user.groupIds[0] : '',
                        );
                      } else {
                        return LandingPage(
                          onThemeChanged: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SettingsPage(themeNotifier: appThemeNotifier),
                              ),
                            );
                          },
                          themeNotifier: appThemeNotifier,
                        );
                      }
                    } else {
                      return LandingPage(
                        onThemeChanged: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(themeNotifier: appThemeNotifier),
                            ),
                          );
                        },
                        themeNotifier: appThemeNotifier,
                      );
                    }
                  },
                ),
            
            '/landing': (context) => LandingPage(
              onThemeChanged: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(themeNotifier: appThemeNotifier),
                  ),
                );
              },
              themeNotifier: appThemeNotifier,
            ),
            '/verifyEmail': (context) => VerifyEmailScreen(),
            '/login': (context) => LoginScreen(
              onLoginSuccess: (String username) async {
                UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

                try {
                  HabitWiseUser? user = await userProvider.getUserDetails();

                  if (user != null) {
                    if (user.emailVerified) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => DashboardScreen(
                            user: user,
                            groupId: user.groupIds.isNotEmpty ? user.groupIds[0] : '',
                          ),
                        ),
                      );
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please verify your email address.',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      });
                    }
                  } else {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      scaffoldMessengerKey.currentState?.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'User data not found. Please try again.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    });
                  }
                } catch (error) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error retrieving user details: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  });
                }
              },
            ),
            '/signup': (context) => SignUpScreen(
              onSignupSuccess: (String username) async {
                UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

                try {
                  HabitWiseUser? user = await userProvider.getUserDetails();

                  if (user != null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Please verify your email to access the app.', style: TextStyle(color: Colors.green)),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacementNamed('/login');
                                  },
                                  child: const Text('Go to Login'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      scaffoldMessengerKey.currentState?.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'User data not found after signup. Please try again.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    });
                  }
                } catch (error) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error retrieving user details after signup: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  });
                }
              },
            ),

            '/dashboard': (context) => Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                // Check if user data is already available
                if (userProvider.currentUser != null) {
                  return DashboardScreen(
                    user: userProvider.currentUser!,
                    groupId: userProvider.currentUser!.groupIds.isNotEmpty ? userProvider.currentUser!.groupIds[0] : '',
                  );
                }

                // If user data is not available, fetch it
                return FutureBuilder<HabitWiseUser?>(
                  future: userProvider.getUserDetails(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return Scaffold(
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Error fetching user data: ${snapshot.error}'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Retry fetching user data
                                  userProvider.getUserDetails();
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return DashboardScreen(
                        user: snapshot.data!,
                        groupId: snapshot.data!.groupIds.isNotEmpty ? snapshot.data!.groupIds[0] : '',
                      );
                    }

                    // If no data is found
                    return const Scaffold(
                      body: Center(child: Text('User data not found')),
                    );
                  },
                );
              },
            ),

            '/createGroup': (context) {
               final HabitWiseUser user = Provider.of<UserProvider>(context, listen: false).currentUser!;
               return CreateGroupScreen(user: user);
           
            },
            '/groupDetails': (context) {
              final HabitWiseGroup group = ModalRoute.of(context)!.settings.arguments as HabitWiseGroup;
              final HabitWiseUser user = Provider.of<UserProvider>(context, listen: false).currentUser!;
              
              return GroupDetailsScreen(group: group, user: user);
            },
            '/habit': (context) => Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                if (userProvider.currentUser == null) {
                  return FutureBuilder<HabitWiseUser?>(
                    future: userProvider.getUserDetails(),
                      builder: (context, AsyncSnapshot<HabitWiseUser?> snapshot) {
                        // Show a loading indicator while waiting for user data
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Scaffold(
                            body: Center(child: CircularProgressIndicator()),
                          );
                        } 
                        // Check if user data is available and return the appropriate screen
                        else if (snapshot.hasData && snapshot.data != null) {
                          return ProfilePage(user: snapshot.data!);
                        } 
                        // Handle errors during data fetching
                        else if (snapshot.hasError) {
                          return Scaffold(
                            body: Center(child: Text('Error fetching user data: ${snapshot.error}')),
                          );
                        } 
                        // Show a message if no user data is found
                        else {
                          return Scaffold(
                            body: Center(child: Text('User data not found')),
                          );
                        }
                      },
                    );
                  } 
                  // If user is available in provider, return ProfilePage directly
                  else {
                    return ProfilePage(user: userProvider.currentUser!);
                  }
                },
              ),
              '/settings': (context) => SettingsPage(
                themeNotifier: appThemeNotifier,
              ),
            },
          );
        },
      );
    }
}
