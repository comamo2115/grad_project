// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/wardrobe_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
// import 'screens/profile_screen.dart'; // ★ 프로필 화면 임포트 (탭 주입용)
import 'widgets/bottom_nav.dart'; // ★ BottomNavRoot 임포트

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OutfitterAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // ★ 초기 라우트는 스플래시로 유지
      initialRoute: '/',
      routes: {
        // ---------------- 공용/인증/단건 페이지 ----------------
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/weather': (context) => const WeatherScreen(),

        // ---------------- 기존 단독 화면 라우트 ----------------
        // ※ 필요시 유지. 다만 캘린더/홈/옷장/프로필은 이제 탭으로 사용 권장
        '/home': (context) => const HomeScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/wardrobe': (context) => const WardrobeScreen(),

        // ---------------- Bottom Navigation 루트 ----------------
        // ★ 스플래시 종료 후 진입해야 하는 실제 앱의 루트
        '/root': (context) => const BottomNavRoot(
          // ★ 각 탭에 들어갈 실제 화면을 주입
          home: HomeScreen(),
          calendar: CalendarScreen(),
          wardrobe: WardrobeScreen(),
          // profile: ProfileScreen(),
        ),
      },
    );
  }
}
