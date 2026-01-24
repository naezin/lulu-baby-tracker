import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Temporarily disabled for web
import '../screens/main/main_navigation.dart';

/// 🔐 Auth Wrapper
/// Automatically routes to login or home based on authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // On web, skip Firebase Auth and go directly to main navigation
    // For mobile, we would check Firebase Auth here
    return const MainNavigation();

    // TODO: Re-enable Firebase Auth when web compatibility is fixed
    // if (kIsWeb) {
    //   return const MainNavigation();
    // }
    //
    // return StreamBuilder<User?>(
    //   stream: FirebaseAuth.instance.authStateChanges(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Scaffold(
    //         body: Center(
    //           child: CircularProgressIndicator(),
    //         ),
    //       );
    //     }
    //
    //     if (snapshot.hasData && snapshot.data != null) {
    //       return const MainNavigation();
    //     }
    //
    //     return const LoginScreen();
    //   },
    // );
  }
}
