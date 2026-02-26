import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/splash/splash_screen.dart';
import 'providers/location_provider.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // On Android: Uses google-services.json automatically
  // On iOS: Uses GoogleService-Info.plist automatically
  // On Web: Would need DefaultFirebaseOptions
  try {
    await Firebase.initializeApp();
    print('✅ [Firebase] Initialized successfully');
  } catch (e) {
    print('❌ [Firebase] Initialization error: $e');
    print('ℹ️ [Firebase] Make sure google-services.json exists in android/app/');
    print('ℹ️ [Firebase] Make sure GoogleService-Info.plist exists in ios/Runner/');
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
      ],
      child: MaterialApp(
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
