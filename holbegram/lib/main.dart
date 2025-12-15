import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // Note: For web platform, you need to configure Firebase using flutterfire CLI
  // Run: dart pub global activate flutterfire_cli
  // Then: flutterfire configure
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Holbegram',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasData) {
              // User is logged in, load user data and show Home
              return FutureBuilder(
                future: Provider.of<UserProvider>(context, listen: false).refreshUser(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return const Home();
                },
              );
            }

            // User is not logged in, show LoginScreen
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
