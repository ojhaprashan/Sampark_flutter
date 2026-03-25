import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_notification_service.dart';
import 'pages/splash/splash_screen.dart';
import 'providers/location_provider.dart';
import 'providers/wallet_provider.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print('✅ [Firebase] Initialized successfully');
    
    // Initialize FCM Service
    await FirebaseNotificationService.initialize();
    print('✅ [FCM] Service initialized at startup');
  } catch (e) {
    print('❌ [Firebase] Initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: MaterialApp(
        navigatorKey: FirebaseNotificationService.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'SHAMPRAK',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryYellow),
          textTheme: GoogleFonts.interTextTheme(),
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
