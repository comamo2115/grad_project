// weather_screen.dart(mock)
import 'package:flutter/material.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // ----------------------------- 색/스타일 상수 -----------------------------
  static const Color primary = Color(0xFFBFB69B); // 상단 배경
  static const Color cardBg = Color(0xFFF9F2ED);
  static const Color cardBgAlt = Color(0xFFF3F0EC);
  static const Color textMain = Color(0xFF0D0D0D);
  static const Color textSub = Color(0xFF707070);
  static const Color accentRed = Color(0xFFBF634E);
  static const Color accentBlue = Color(0xFF2F67FF);

  // ----------------------------- MOCK 데이터 -----------------------------
  late final List<Map<String, dynamic>> _hourly = _buildMockHourly();

  List<Map<String, dynamic>> _buildMockHourly() {
    const icons = [
      Icons.wb_sunny_outlined,
      Icons.cloud_outlined,
      Icons.wb_cloudy_outlined,
      Icons.cloud_queue,
      Icons.grain, // 비
      Icons.thunderstorm, // 천둥/번개
    ];
    final List<Map<String, dynamic>> list = [];
    for (int h = 0; h < 24; h++) {
      list.add({
        'hour': '${h.toString().padLeft(2, '0')}:00',
        'icon': icons[(h ~/ 4) % icons.length],
        'temp': 23 + (h % 6), // 23~28
        'pop': (h * 7) % 90, // 강수확률 0~89
      });
    }
    return list;
  }

  final Map<String, dynamic> _summary = const {
    'city': 'Busan, Korea',
    'current': 30,
    'high': 30,
    'low': 23,
    'feelsLike': 31,
    'humidity': 56,
    'uv': 3,
    'wind': 4, // m/s
    'sunrise': '05:10',
    'sunset': '19:20',
  };

  // ★ 4개 행을 하나로 스크롤하기 위한 단일 컨트롤러
  final ScrollController _hScrollCtrl = ScrollController();

  @override
  void dispose() {
    _hScrollCtrl.dispose();
    super.dispose();
  }

  // ----------------------------- 위젯 빌더 -----------------------------
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: primary,
      padding: const EdgeInsets.only(top: 52, left: 12, right: 12, bottom: 10),
      child: Row(
        children: const [
          _BackButtonWhite(),
          Spacer(),
          Text(
            'Weather',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Futura',
              color: Colors.white,
            ),
          ),
          Spacer(),
          SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildLocationAndHL() {
    return Container(
      color: primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Current location ',
                style: TextStyle(
                  fontFamily: 'Futura',
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const Icon(Icons.location_on, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                _summary['city'],
                style: const TextStyle(
                  fontFamily: 'Futura',
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.thermostat, color: accentRed, size: 18),
              Text(
                ' ${_summary['high']}°C ',
                style: const TextStyle(
                  color: accentRed,
                  fontFamily: 'Futura',
                  fontSize: 16,
                ),
              ),
              const Text(
                ' / ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Futura',
                ),
              ),
              const Icon(Icons.ac_unit, color: accentBlue, size: 18),
              Text(
                ' ${_summary['low']}°C',
                style: const TextStyle(
                  color: accentBlue,
                  fontFamily: 'Futura',
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ----------------------------- ★ 동기 스크롤 테이블 (열 단위) -----------------------------
  // ★ 핵심: 가로 스크롤 뷰를 1개만 사용하고, 시간별 데이터를 '세로로 묶은 열(Column)'로 만들어 좌->우로 배치
  //   이렇게 하면 각 시간의 [시각/날씨/온도/강수확률]이 항상 한 덩어리로 함께 스크롤됨
  Widget _buildHourlyTable() {
    const double leftColW = 112; // 라벨 고정 폭
    const double colW = 72; // 각 시간 열의 폭
    const double gap = 12; // 열 간 간격
    const double rowGap = 10; // 행 간 간격

    // ★ 시간 열 위젯 빌더
    List<Widget> _buildHourColumns() {
      return List.generate(_hourly.length, (i) {
        final h = _hourly[i];
        return Padding(
          padding: EdgeInsets.only(right: i == _hourly.length - 1 ? 0 : gap),
          child: SizedBox(
            width: colW,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 시각
                Text(
                  h['hour'],
                  style: const TextStyle(
                    fontFamily: 'Futura',
                    color: textSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: rowGap),
                // 날씨 아이콘
                Icon(h['icon'] as IconData, color: accentRed, size: 26),
                SizedBox(height: rowGap),
                // 온도
                Text(
                  '${h['temp']}°C',
                  style: const TextStyle(
                    fontFamily: 'Futura',
                    fontWeight: FontWeight.w600,
                    color: textMain,
                  ),
                ),
                SizedBox(height: rowGap),
                // 강수확률
                Text(
                  '${h['pop']}%',
                  style: const TextStyle(fontFamily: 'Futura', color: textMain),
                ),
              ],
            ),
          ),
        );
      });
    }

    return Column(
      children: [
        // 상단 헤더 + 가로 스크롤 영역
        Container(
          decoration: BoxDecoration(
            color: cardBgAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ★ 좌측 라벨 열 (고정)
              SizedBox(
                width: leftColW,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    // 첫 줄은 "Time"으로 시각 라벨
                    Text(
                      'Time',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Futura',
                        color: textSub,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Weather',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Futura', color: textSub),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Temperature',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Futura', color: textSub),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Chance of\nprecipitation',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Futura', color: textSub),
                    ),
                  ],
                ),
              ),

              // ★ 우측: 시간별 열들이 하나의 가로 스크롤로 이동
              Expanded(
                child: SingleChildScrollView(
                  controller: _hScrollCtrl, // 하나의 컨트롤러만 사용
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildHourColumns(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripleCards() {
    return Row(
      children: const [
        Expanded(
          child: _MiniCard(
            icon: Icons.water_drop_outlined,
            title: 'humidity',
            valueKey: 'humidity',
            suffix: '%',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _MiniCard(
            icon: Icons.wb_sunny_outlined,
            title: 'UV index',
            valueKey: 'uv',
            suffix: '',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _MiniCard(
            icon: Icons.air,
            title: 'wind speed',
            valueKey: 'wind',
            suffix: ' m/s',
          ),
        ),
      ],
    );
  }

  Widget _buildSunBar() {
    return Container(
      decoration: BoxDecoration(
        color: cardBgAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.wb_twighlight, color: accentRed),
          const SizedBox(width: 8),
          Text(
            'sunrise ${_summary['sunrise']}',
            style: const TextStyle(fontFamily: 'Futura', color: textMain),
          ),
          const Spacer(),
          const Icon(Icons.nightlight_round, color: accentBlue),
          const SizedBox(width: 8),
          Text(
            'sunset ${_summary['sunset']}',
            style: const TextStyle(fontFamily: 'Futura', color: textMain),
          ),
        ],
      ),
    );
  }

  // ----------------------------- build -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildLocationAndHL(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    _buildHourlyTable(), // ★ 동기 스크롤 테이블로 교체
                    const SizedBox(height: 12),
                    _buildTripleCards(),
                    const SizedBox(height: 12),
                    _buildSunBar(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------- 보조 위젯 -----------------------------
class _BackButtonWhite extends StatelessWidget {
  const _BackButtonWhite();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.maybePop(context),
      child: const Icon(Icons.arrow_back, color: Colors.white),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String valueKey;
  final String suffix;

  const _MiniCard({
    required this.icon,
    required this.title,
    required this.valueKey,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_WeatherScreenState>();
    final summary = state?._summary ?? const {};
    final value = summary[valueKey]?.toString() ?? '-';

    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: _WeatherScreenState.cardBgAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: _WeatherScreenState.textSub),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Futura',
                    fontSize: 13,
                    color: _WeatherScreenState.textSub,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$value$suffix',
                  style: const TextStyle(
                    fontFamily: 'Futura',
                    fontWeight: FontWeight.w600,
                    color: _WeatherScreenState.textMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
