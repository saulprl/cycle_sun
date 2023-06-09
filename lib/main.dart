import 'package:cycle_sun/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/home_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/sell_product_screen.dart';
import './screens/splash_screen.dart';
import './screens/auth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> firebaseApp =
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    return FutureBuilder(
      future: firebaseApp,
      builder: (ctx, appSnapshot) {
        return MaterialApp(
          title: 'Cycle Sun',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: Colors.pink,
              secondary: Colors.deepPurple[500],
              background: Colors.pink,
            ),
          ),
          home: appSnapshot.connectionState != ConnectionState.done
              ? const SplashScreen()
              : StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (ctx, AsyncSnapshot<User?> userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SplashScreen();
                    }
                    if (userSnapshot.hasData) {
                      return const HomeScreen();
                    }
                    return const AuthScreen();
                  },
                ),
          routes: {
            EditProductScreen.routeName: (context) => const EditProductScreen(),
            ProductDetailScreen.routeName: (context) =>
                const ProductDetailScreen(),
            SellProductScreen.routeName: (context) => const SellProductScreen(),
          },
        );
      },
    );
  }
}
