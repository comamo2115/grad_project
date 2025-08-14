// home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isGenerated = false;

  // ★ 코디 추천 이미지(예시)
  final List<String> outfitImages = [
    'assets/images/jacket.jpeg',
    'assets/images/tshirt.jpeg',
    'assets/images/dress.jpeg',
  ];

  // ★ 코디 추천 사유(예시)
  final String outfitReason = 'This is an outfit suitable for a meeting.';

  // ★ (옵션) /weather 에서 돌아온 뒤 갱신이 필요하면 여기서 setState 호출
  Future<void> _openWeather() async {
    // '/weather' 화면으로 이동 → 닫히면 여기로 복귀
    await Navigator.of(context, rootNavigator: true).pushNamed('/weather');
    // TODO: 날씨 재조회가 필요하면 아래 주석 해제
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // ★ 주의: 이 화면은 BottomNavRoot(탭 컨테이너) 안에 포함되어 사용됩니다.
    //   -> 이 파일에서는 하단 네비게이션을 직접 그리지 않습니다.
    return Scaffold(
      backgroundColor: const Color(0xfffbfbfb),
      body: Stack(
        children: [
          // 상단 배경
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 167,
            child: Container(color: const Color(0xffbfb69b)),
          ),

          // 로고
          Positioned(
            top: 25,
            left: MediaQuery.of(context).size.width / 2 - 75,
            child: SizedBox(
              width: 150,
              child: Center(
                child: Image.asset(
                  'assets/images/outfitter_logo2.png',
                  fit: BoxFit.contain,
                  height: 60,
                ),
              ),
            ),
          ),

          // ★ 위치/날씨 정보 블록(전체가 터치 영역) → /weather 로 이동
          Positioned(
            top: 80,
            left: 12,
            right: 12,
            height: 41,
            child: GestureDetector(
              onTap: _openWeather, // ★ 블록 전체 탭 시 이동
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xfff9f2ed),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                // ★ 내부에 아이콘+텍스트를 같은 블록 안에 배치
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(Icons.location_on, size: 16, color: Color(0xffbf634e)),
                    SizedBox(width: 4),
                    Text(
                      'busan',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Futura',
                        color: Color(0xff707070),
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.cloud, size: 16, color: Color(0xffbf634e)),
                    SizedBox(width: 4),
                    Text(
                      '30°C / 23°C',
                      style: TextStyle(fontSize: 12, fontFamily: 'Futura'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 오늘 일정 텍스트（탭 시 calendar 화면으로 이동 - 라우트 사용）
          Positioned(
            top: 135,
            left: MediaQuery.of(context).size.width / 2 - 133,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/calendar'),
              child: const Text(
                "Today’s plan : Team Meeting at 4pm",
                style: TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 16,
                  color: Color(0xfff9f2ed),
                ),
              ),
            ),
          ),

          // 추천 버튼
          Positioned(
            top: 180,
            left: MediaQuery.of(context).size.width / 2 - 100,
            child: GestureDetector(
              onTap: () {
                // ★ MOCK: 버튼 탭 시 결과 표시
                setState(() {
                  isGenerated = true;
                });
              },
              child: Container(
                width: 200,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xffbf634e),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: const Center(
                  child: Text(
                    "Generate Today's Outfit",
                    style: TextStyle(
                      fontFamily: 'Futura',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xfff9f2ed),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 추천 이미지/사유 표시 영역
          if (isGenerated) ...[
            Positioned(
              top: 240,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: outfitImages
                    .map(
                      (img) => Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffe3e3e3)),
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(img),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Positioned(
              top: 360,
              left: MediaQuery.of(context).size.width / 2 - 140,
              child: Text(
                outfitReason,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Futura',
                  color: Color(0xff707070),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
