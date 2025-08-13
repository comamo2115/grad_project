import 'package:flutter/material.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffbfb69b),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 뒤로가기 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  const Text(
                    'Weather',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Futura',
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24), // 아이콘 공간 확보
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 도시명 + 날씨 아이콘
            const Icon(Icons.cloud, size: 80, color: Colors.white),
            const SizedBox(height: 8),
            const Text(
              'Busan',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Futura',
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // 현재 온도
            const Text(
              '30°C',
              style: TextStyle(
                fontSize: 60,
                fontFamily: 'Futura',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            // 최고/최저 온도
            const Text(
              'H: 32°C  /  L: 22°C',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Futura',
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // 체감 온도, 습도 등
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Feels like\n31°C',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Futura',
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Humidity\n63%',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Futura',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 시간별 날씨 가로 리스트
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final hours = [
                    '09:00',
                    '12:00',
                    '15:00',
                    '18:00',
                    '21:00',
                    '00:00',
                  ];
                  final temps = [
                    '29°C',
                    '30°C',
                    '31°C',
                    '28°C',
                    '26°C',
                    '24°C',
                  ];
                  return Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xfff9f2ed),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          hours[index],
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Futura',
                            color: Color(0xff707070),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Icon(
                          Icons.cloud,
                          color: Color(0xffbf634e),
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          temps[index],
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Futura',
                            fontWeight: FontWeight.bold,
                            color: Color(0xff707070),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
