import 'package:fashion_frontend/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false; // 실제는 FirebaseAuth 등에서 판별

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // 1. 로그인 상태 확인 시작
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // 로딩시간 (2~5초)

    // TODO: 실제 로그인 여부 확인 로직으로 변경 필요
    setState(() {
      isLoggedIn = true; // 가정: 로그인 되어 있음
    });

    // 2. 로그인 상태에 따라 화면 이동
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/root');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          SizedBox.expand(
            child: Image.asset(
              'assets/images/splash_bg.png', // 배경 이미지
              fit: BoxFit.cover,
            ),
          ),

          // 로고 + 로딩바
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Image.asset(
                  'assets/images/outfitter_logo.png',
                ), // 로고 이미지
              ),
              Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: LinearProgressIndicator(
                  // 로딩 바
                  minHeight: 4,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.secondary,
                  ),
                ),
              ),
              Spacer(flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
