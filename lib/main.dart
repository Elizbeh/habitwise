import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/rendering.dart';
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
import 'package:habitwise/screens/goals_screen.dart';
import 'package:habitwise/screens/group/create_group_screen.dart';
import 'package:habitwise/screens/group/group_details_screen.dart';
import 'package:habitwise/screens/habit_screen.dart';
import 'package:habitwise/screens/landing_page.dart';
import 'package:habitwise/screens/profile_screen.dart';
import 'package:habitwise/screens/setting_screen.dart';
import 'package:habitwise/screens/launch_background.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'themes/theme.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// Centralized ValueNotifier for theme management
final ValueNotifier<ThemeMode> appThemeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  //debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      
    ),
  );

  runApp(
    
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
      ],
      child: MyApp(),
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
          theme: lightTheme(context),
          darkTheme: darkTheme(context),
          themeMode: themeMode,
          initialRoute: '/',
          routes: {
            // Splash screen as the initial route
            '/': (context) => SplashScreen(),
            
            // Landing Page after splash screen
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
            
            // Verify email screen
            '/verifyEmail': (context) => VerifyEmailScreen(),
            
            // Login screen with additional logic for successful login
            '/login': (context) => LoginScreen(
              emailController: TextEditingController(),
              passwordController: TextEditingController(),
              onLoginSuccess: (String username) async {
                UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

                try {
                  HabitWiseUser? user = await userProvider.getUserDetails();

                  if (user != null) {
                    if (user.emailVerified) {
                      // Navigate to dashboard if email is verified
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => DashboardScreen(
                            user: user,
                            groupId: user.groupIds.isNotEmpty ? user.groupIds[0] : '',
                          ),
                        ),
                      );
                    } else {
                      // Show snackbar to verify email
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please verify your email address.',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      });
                    }
                  } else {
                    // Show snackbar if user data not found
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      scaffoldMessengerKey.currentState?.showSnackBar(
                        SnackBar(
                          content: Text(
                            'User data not found. Please try again.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    });
                  }
                } catch (error) {
                  // Show snackbar for error during user details retrieval
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error retrieving user details: $error',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  });
                }
              },
            ),
            
            // Signup screen with logic to navigate to login after successful signup
            '/signup': (context) => SignUpScreen(
              emailController: TextEditingController(),
              usernameController: TextEditingController(),
              passwordController: TextEditingController(),
              passwordConfirmController: TextEditingController(),
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
                                Text('Please verify your email to access the app.', style: TextStyle(color: Colors.green)),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacementNamed('/login');
                                  },
                                  child: Text('Go to Login'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Show snackbar if user data not found after signup
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      scaffoldMessengerKey.currentState?.showSnackBar(
                        SnackBar(
                          content: Text(
                            'User data not found after signup. Please try again.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    });
                  }
                } catch (error) {
                  // Show snackbar for error during user details retrieval after signup
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error retrieving user details after signup: $error',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  });
                }
              },
            ),
            
            // Dashboard screen
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
                        return DashboardScreen(
                          user: snapshot.data!,
                          groupId: '',
                        );
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
                  return DashboardScreen(
                    user: userProvider.user!,
                    groupId: '',
                  );
                }
              },
            ),
            
            // Create group screen
            '/createGroup': (context) => CreateGroupScreen(),
            
            // Group details screen
            '/groupDetails': (context) {
              final HabitWiseGroup group = ModalRoute.of(context)!.settings.arguments as HabitWiseGroup;
              final HabitWiseUser user = Provider.of<UserProvider>(context, listen: false).user!;
              
              return GroupDetailsScreen(group: group, user: user);
            },
            
            // Habit screen
            '/habit': (context) => Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                if (userProvider.user == null) {
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
                    return ProfilePage(user: userProvider.user!);
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
