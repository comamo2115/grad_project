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
    // ★ 전체 요소를 아래로 내릴 오프셋(픽셀). 요청: 약 30
    final double yOffset = 30.0;

    return Scaffold(
      backgroundColor: const Color(0xfffbfbfb),
      body: Stack(
        children: [
          // 상단 배경
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            // ★ 내용이 30 내려가므로 높이를 167→167 + yOffset 로 확장
            height: 167 + yOffset,
            child: Container(color: const Color(0xffbfb69b)),
          ),

          // 로고
          Positioned(
            // ★ 25 → 25 + yOffset
            top: 25 + yOffset,
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
            // ★ 80 → 80 + yOffset
            top: 80 + yOffset,
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

          // 오늘 일정 텍스트（탭無効）
          Positioned(
            // ★ 135 → 135 + yOffset
            top: 135 + yOffset,
            left: MediaQuery.of(context).size.width / 2 - 133,
            child: IgnorePointer(
              ignoring: true, // ★ 터치 무시
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

          // 추천 버튼: 중앙 정렬 + 줄바꿈(Generate\nToday's Outfit) + 버튼 사이즈 확대
          Positioned(
            // ★ 180 → 180 + yOffset
            top: 180 + yOffset,
            left: 0, // ★ 좌우 0으로 두고
            right: 0, // ★ Center로 자식(Container)을 중앙 배치
            child: GestureDetector(
              onTap: () {
                // ★ MOCK: 버튼 탭 시 결과 표시
                setState(() {
                  isGenerated = true;
                });
              },
              child: Center(
                child: Container(
                  width: 260, // ★ 폭 약간 확대 (기존 200 → 260)
                  height: 60, // ★ 높이 확대 (기존 45 → 60)
                  decoration: BoxDecoration(
                    color: const Color(0xffbf634e),
                    borderRadius: BorderRadius.circular(18.0), // ★ 라운드 조금 키움
                  ),
                  child: const Center(
                    child: Text(
                      "Generate\nToday’s Outfit", // ★ 줄바꿈 적용
                      textAlign: TextAlign.center, // ★ 가운데 정렬
                      softWrap: true, // ★ 줄바꿈 허용
                      maxLines: 2, // ★ 최대 2줄
                      style: TextStyle(
                        fontFamily: 'Futura',
                        fontSize: 18, // ★ 글자 크기 약간 키움
                        fontWeight: FontWeight.bold,
                        color: Color(0xfff9f2ed),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 추천 이미지/사유 표시 영역
          if (isGenerated) ...[
            Positioned(
              // ★ 240 → 240 + yOffset
              top: 260 + yOffset,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: outfitImages
                    .map(
                      (img) => Container(
                        width: 120,
                        height: 120,
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
              // ★ 360 → 360 + yOffset
              top: 780 + yOffset,
              left: MediaQuery.of(context).size.width / 2 - 140,
              child: Center(
                child: Text(
                  outfitReason,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Futura',
                    color: Color(0xff707070),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
