import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isGenerated = false;

  final List<String> outfitImages = [
    'assets/images/jacket.jpeg',
    'assets/images/tshirt.jpeg',
    'assets/images/dress.jpeg',
  ];

  final String outfitReason = 'This is an outfit suitable for a meeting.';

  @override
  Widget build(BuildContext context) {
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
            top: 45,
            left: MediaQuery.of(context).size.width / 2 - 75,
            child: SizedBox(
              width: 150,
              child: Center(
                child: Text(
                  'OutfitterAI',
                  style: TextStyle(
                    fontFamily: 'Futura',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // 날씨 정보 영역 (탭 시 weather로 이동)
          Positioned(
            top: 80,
            left: 12,
            right: 12,
            height: 41,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/weather'),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xfff9f2ed),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),

          // 위치 + 날씨 텍스트
          Positioned(
            top: 94,
            left: 44,
            child: Row(
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

          // 오늘 일정 텍스트
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

          // 추천 이미지 표시 영역
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

          // 하단 내비게이션
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 94,
            child: Container(
              color: const Color(0xffbfb69b),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home, 'home'),
                  _buildNavItem(Icons.calendar_month, 'calendar'),
                  _buildNavItem(Icons.checkroom, 'wardrobe'),
                  _buildNavItem(Icons.person, 'profile'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xfff9f2ed)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Futura',
            color: Color(0xfff9f2ed),
          ),
        ),
      ],
    );
  }
}
