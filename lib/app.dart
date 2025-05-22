import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawdoct/screens/forgot_screen.dart';
import 'package:pawdoct/screens/home_screen.dart';
import 'package:pawdoct/screens/login_screen.dart';
import 'package:pawdoct/screens/register_screen.dart';
import 'package:pawdoct/screens/reset_screen.dart';
import 'package:pawdoct/screens/splash_screen.dart';
import 'package:app_links/app_links.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class PawdoctApp extends StatefulWidget {
  const PawdoctApp({super.key});

  @override
  State<PawdoctApp> createState() => _PawdoctAppState();
}

class _PawdoctAppState extends State<PawdoctApp> {
  late final AppLinks _appLinks;
  late final StreamSubscription<Uri>? _linkSubscription;
  Uri? _initialUri;

  @override
  void initState() {
    super.initState();

    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _initialUri = uri;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleIncomingLink();
      });
    });
  }

  void _handleIncomingLink() {
    if (_initialUri != null) {
      print('Received deep link: $_initialUri');
      final token =
          _initialUri!.pathSegments.isNotEmpty
              ? _initialUri!.pathSegments.last
              : null;
      final email = _initialUri!.queryParameters['email'];

      if (token != null && email != null) {
        navigatorKey.currentState?.pushReplacementNamed(
          '/reset',
          arguments: {'email': email, 'token': token},
        );
      }

      _initialUri = null;
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pawdoct',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgot': (context) => ForgotScreen(),
        '/reset': (context) => ResetScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
