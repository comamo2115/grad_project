// home_screen.dart
// ★ 주석은 한국어로 작성했습니다.
import 'package:flutter/material.dart';
import 'dart:convert'; // ★ JSON 인/코딩
import 'dart:async'; // ★ TimeoutException
import 'dart:io'; // ★ Socket/Handshake 예외
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // ★ 현재 위치 가져오기 (추가)
import 'package:geocoding/geocoding.dart'; // ★ Open-Meteo 실패 시 대체 역지오코딩

// ★ OpenWeather 키는 추천 API 페이로드용 현재 날씨 취득에 사용 (상단 표시엔 Open-Meteo 사용)
const String kOpenWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY';

// ★ (가정) 서버가 추천해준 옷 ID를 실제 이미지 경로로 변환하는 함수
// 실제 앱에서는 사용자 옷장 DB의 매핑 규칙에 맞게 구현하세요.
String getImagePathFromId(int id) => 'assets/images/$id.jpg';

// ★ 공백/Null 제외하고 ", "로 합치는 유틸
String _joinPartsEn(Iterable<String?> parts) {
  final seen = <String>{};
  final out = <String>[];
  for (final raw in parts) {
    final s = (raw ?? '').trim();
    if (s.isEmpty) continue;
    if (seen.add(s)) out.add(s);
  }
  return out.join(', ');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ★ 색상 상수 (홈 상단 날씨용)
  static const Color accentRed = Color(0xFFBF634E); // ★ 최소(LOW) = 빨강
  static const Color accentBlue = Color(0xFF2F67FF); // ★ 최고(HIGH) = 파랑

  // ----------------------------- 상태 -----------------------------
  bool isGenerated = false; // 추천 결과 표시 여부
  bool _isLoading = false; // 로딩 스피너
  String _errorMessage = ''; // 에러 메시지

  // ★ 추천 결과
  List<String> outfitImages = [];
  String outfitReason = 'This is an outfit suitable for a meeting.';

  // ----------------------------- 설정 -----------------------------
  // ★ ngrok URL (https 중복 제거!)
  static const String _apiUrl =
      'https://11119ada0da0.ngrok-free.app/recommend_outfit';

  // ----------------------------- 상단(현재 위치/날씨) 표시용 상태 -----------------------------
  // ★ 도시명/현재/최고/최저/날씨코드
  String _topCity = 'Locating...';
  int? _topCurrent; // 현재 기온(°C)
  int? _topHigh; // 오늘 최고(°C)
  int? _topLow; // 오늘 최저(°C)
  int? _topCode; // weathercode (Open-Meteo)

  // ★ 화면 최초 진입 시 상단 날씨 로딩
  @override
  void initState() {
    super.initState();
    _loadHomeTopWeather();
  }

  // ----------------------------- 공통: 위치 권한/서비스 확인 -----------------------------
  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('位置情報サービスが無効です（端末の設定で有効にしてください）');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('位置情報の権限が拒否されました');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('位置情報の権限が永久に拒否されています（設定から許可が必要）');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  // ----------------------------- Open-Meteo: 역지오코딩(영문 도시명) -----------------------------
  // ★ 실패 시 'Current Location(failed)'
  Future<String> _resolveCityNameEn(double lat, double lon) async {
    // ---- ① Open-Meteo (language=en)
    try {
      final uri = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/reverse'
        '?latitude=$lat&longitude=$lon&language=en',
      );
      final res = await http
          .get(uri, headers: {HttpHeaders.acceptHeader: 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final j = json.decode(res.body) as Map<String, dynamic>;
        final results = (j['results'] as List?) ?? const [];
        if (results.isNotEmpty) {
          final r = results.first as Map<String, dynamic>;
          final name = _joinPartsEn([
            r['name'] as String?, // city
            r['admin1'] as String?, // state/province
            r['country'] as String?, // country
          ]);
          if (name.isNotEmpty) return name;
        }
      }
    } catch (e) {
      debugPrint('[reverse] Open-Meteo error: $e');
    }

    // ---- ② geocoding 패키지로 대체 (단말 로케일에 따를 수 있음)
    try {
      final placemarks = await placemarkFromCoordinates(
        lat,
        lon,
      ).timeout(const Duration(seconds: 6));
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final name = _joinPartsEn([
          p.locality, // city
          p.administrativeArea, // state/province
          p.country, // country
        ]);
        if (name.isNotEmpty) return name;
      }
    } catch (e) {
      debugPrint('[reverse] geocoding error: $e');
    }

    // ---- ③ 최종 실패
    return 'Current Location(failed)';
  }

  // ----------------------------- Open-Meteo: 현재/일일 데이터 -----------------------------
  Future<Map<String, dynamic>> _fetchOpenMeteo(double lat, double lon) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat'
      '&longitude=$lon'
      '&current=temperature_2m,weathercode'
      '&daily=temperature_2m_max,temperature_2m_min'
      '&timezone=auto',
    );

    final res = await http
        .get(uri, headers: {HttpHeaders.acceptHeader: 'application/json'})
        .timeout(const Duration(seconds: 8));

    if (res.statusCode != 200) {
      throw Exception('天気APIの呼び出しに失敗しました（${res.statusCode}）');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  // ----------------------------- 상단 날씨 로딩 -----------------------------
  Future<void> _loadHomeTopWeather() async {
    try {
      final pos = await _determinePosition();
      final city = await _resolveCityNameEn(pos.latitude, pos.longitude);
      final data = await _fetchOpenMeteo(pos.latitude, pos.longitude);

      // ★ 안전 추출
      Map<String, dynamic> current = (data['current'] is Map)
          ? (data['current'] as Map).cast<String, dynamic>()
          : {};
      Map<String, dynamic> daily = (data['daily'] is Map)
          ? (data['daily'] as Map).cast<String, dynamic>()
          : {};

      final currTemp = (current['temperature_2m'] as num?)?.toDouble();
      final currCode = (current['weathercode'] as num?)?.toInt();

      final tmax =
          (daily['temperature_2m_max'] as List?)?.cast<num>() ?? const [];
      final tmin =
          (daily['temperature_2m_min'] as List?)?.cast<num>() ?? const [];

      setState(() {
        _topCity = city;
        _topCurrent = currTemp?.round();
        _topHigh = tmax.isNotEmpty ? tmax.first.round() : null;
        _topLow = tmin.isNotEmpty ? tmin.first.round() : null;
        _topCode = currCode;
      });
    } catch (e) {
      // 실패해도 화면이 죽지 않도록 도시만 실패 메시지 표기
      setState(() {
        _topCity = 'Current Location(failed)';
        _topCurrent = null;
        _topHigh = null;
        _topLow = null;
        _topCode = null;
      });
      debugPrint('Top weather load failed: $e');
    }
  }

  // ----------------------------- (기존) OpenWeather: 추천 페이로드용 현재 날씨 -----------------------------
  Future<Map<String, dynamic>> _getCurrentWeather() async {
    // ★ 위치 서비스/권한 확인
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission denied.';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission permanently denied.';
    }

    // ★ 현재 좌표
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    // ★ OpenWeatherMap 호출 (units=metric → 섭씨)
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
      '?lat=${pos.latitude}&lon=${pos.longitude}'
      '&appid=$kOpenWeatherApiKey&units=metric',
    );

    final res = await http.get(url).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw 'Weather API error: HTTP ${res.statusCode}';
    }

    final data = json.decode(res.body);
    final double? tempC = (data['main']?['temp'] as num?)?.toDouble();
    final String? condition =
        (data['weather'] is List && data['weather'].isNotEmpty)
        ? (data['weather'][0]['main'] as String?)
        : null;

    if (tempC == null || condition == null) {
      throw 'Invalid weather response.';
    }

    return {'temperature': tempC, 'condition': condition};
  }

  // ----------------------------- 네비게이션 -----------------------------
  Future<void> _openWeather() async {
    await Navigator.of(context, rootNavigator: true).pushNamed('/weather');
  }

  // ----------------------------- 추천 API 호출 -----------------------------
  Future<void> _getOutfitRecommendation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      isGenerated = false;
    });

    double sendTemp = 22.0; // ★ 실패 시 폴백
    String sendCond = 'Clear'; // ★ 실패 시 폴백

    try {
      // ★ 1) 현재 날씨 취득(OpenWeather) → 추천 엔진에 전달
      final w = await _getCurrentWeather();
      sendTemp = (w['temperature'] as double?) ?? sendTemp;
      sendCond = (w['condition'] as String?) ?? sendCond;
    } catch (e) {
      debugPrint('Weather fetch failed: $e');
    }

    try {
      // ★ 예시 요청 페이로드(서버 스펙에 맞춰 수정 가능)
      final requestData = {
        "closet": [
          15970,
          39385,
          10579,
          13090,
          4959,
          28540,
          14392,
          19859,
          59435,
          6394,
        ],
        "event": "Casual Day Out",
        "temperature": sendTemp, // ★ 실제 현재 기온(섭씨)
        "condition": sendCond, // ★ 실제 현재 날씨(main)
        "gender": "Men",
      };

      final res = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestData),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = json.decode(utf8.decode(res.bodyBytes));
        final combo = body['best_combination'];
        List<dynamic>? idsDyn;
        List<dynamic>? urlsDyn;
        String? desc;

        if (combo is Map) {
          idsDyn = combo['ids'];
          desc = (combo['description'] is String) ? combo['description'] : null;
        } else {
          idsDyn = body['ids'];
          urlsDyn = body['image_urls'];
          if (body['description'] is String) desc = body['description'];
        }

        final List<String> imagePaths = [];
        if (idsDyn is List && idsDyn.isNotEmpty) {
          for (final v in idsDyn) {
            if (v is int) imagePaths.add(getImagePathFromId(v));
            if (v is String && int.tryParse(v) != null) {
              imagePaths.add(getImagePathFromId(int.parse(v)));
            }
          }
        } else if (urlsDyn is List && urlsDyn.isNotEmpty) {
          for (final v in urlsDyn) {
            if (v is String) imagePaths.add(v);
          }
        }

        if (imagePaths.isEmpty) {
          setState(() {
            _errorMessage = '추천 이미지 목록이 비어 있습니다. (ids/image_urls 확인 필요)';
            _isLoading = false;
          });
          return;
        }

        setState(() {
          outfitImages = imagePaths;
          if (desc != null && desc.trim().isNotEmpty) {
            outfitReason = desc;
          }
          isGenerated = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              '서버 응답 오류: HTTP ${res.statusCode} / ${res.reasonPhrase ?? ''}';
          _isLoading = false;
        });
      }
    } on TimeoutException {
      setState(() {
        _errorMessage = '요청 시간이 초과되었습니다. (Timeout)';
        _isLoading = false;
      });
    } on HandshakeException catch (e) {
      setState(() {
        _errorMessage = 'SSL/TLS 핸드셰이크 오류: $e';
        _isLoading = false;
      });
    } on SocketException catch (e) {
      setState(() {
        _errorMessage = '네트워크 연결 실패(DNS/접속 불가): $e';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '예기치 못한 오류: $e';
        _isLoading = false;
      });
    }
  }

  // ----------------------------- weathercode → 아이콘 -----------------------------
  IconData _iconFromWeatherCode(int? code) {
    if (code == null) return Icons.cloud_outlined;
    if (code == 0) return Icons.wb_sunny_outlined;
    if (code == 1 || code == 2 || code == 3) return Icons.cloud_outlined;
    if (code == 45 || code == 48) return Icons.blur_on; // 안개 대체
    if (code >= 51 && code <= 67) return Icons.grain; // 이슬비/비
    if (code >= 71 && code <= 77) return Icons.ac_unit; // 눈
    if (code >= 80 && code <= 82) return Icons.cloud_queue; // 소나기
    if (code == 95 || code == 96 || code == 99) return Icons.thunderstorm; // 뇌우
    return Icons.wb_cloudy_outlined;
  }

  // ----------------------------- UI -----------------------------
  @override
  Widget build(BuildContext context) {
    final double yOffset = 30.0; // ★ 상단 전체를 내리는 오프셋

    return Scaffold(
      backgroundColor: const Color(0xfffbfbfb),
      body: Stack(
        children: [
          // 상단 배경
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 167 + yOffset,
            child: Container(color: const Color(0xffbfb69b)),
          ),

          // 로고
          Positioned(
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

          // 위치/날씨 블록 → 탭 시 /weather 이동
          Positioned(
            top: 80 + yOffset,
            left: 12,
            right: 12,
            height: 41,
            child: GestureDetector(
              onTap: _openWeather,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xfff9f2ed),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // -------------------- 위치명 (왼쪽) --------------------
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xffbf634e),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _topCity,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Futura',
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),

                    // -------------------- 현재기온 + 아이콘（アイコンは現在気温の右） --------------------
                    const SizedBox(width: 12),
                    Text(
                      _topCurrent != null ? '${_topCurrent}°C' : '—',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Futura',
                        color: Color(0xff0d0d0d),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _iconFromWeatherCode(_topCode),
                      size: 16,
                      color: const Color(0xffbf634e),
                    ),

                    // -------------------- 최고/최저（最低=赤 / 最高=青） --------------------
                    const SizedBox(width: 12),
                    if (_topHigh != null || _topLow != null)
                      Row(
                        children: [
                          if (_topLow != null) ...[
                            const SizedBox(width: 2),
                            Text(
                              '${_topLow}°C',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Futura',
                                color: accentRed, // ★ 최저=빨강
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (_topHigh != null && _topLow != null)
                            const Text(
                              '  /  ',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Futura',
                                color: Color(0xff707070),
                              ),
                            ),
                          if (_topHigh != null) ...[
                            const SizedBox(width: 2),
                            Text(
                              '${_topHigh}°C',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Futura',
                                color: accentBlue, // ★ 최고=파랑
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),

          // 오늘 일정 텍스트（탭 무시）
          Positioned(
            top: 135 + yOffset,
            left: MediaQuery.of(context).size.width / 2 - 133,
            child: const IgnorePointer(
              ignoring: true,
              child: Text(
                "Today’s plan : Team Meeting at 4pm",
                style: TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 16,
                  color: Color(0xfff9f2ed),
                ),
              ),
            ),
          ),

          // 추천 버튼 (탭 시 API 호출)
          Positioned(
            top: 180 + yOffset,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _getOutfitRecommendation, // ★ 변경: isGenerated 토글 → API 호출
              child: Center(
                child: Container(
                  width: 260,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xffbf634e),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: const Center(
                    child: Text(
                      "Generate\nToday’s Outfit",
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: 'Futura',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xfff9f2ed),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 로딩 인디케이터
          if (_isLoading) const Center(child: CircularProgressIndicator()),

          // 에러 메시지
          if (_errorMessage.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // 추천 이미지/사유
          if (isGenerated) ...[
            Positioned(
              top: 260 + yOffset,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    spacing: 12,
                    runSpacing: 12,
                    children: outfitImages.map((img) {
                      final ImageProvider provider = img.startsWith('http')
                          ? NetworkImage(img)
                          : AssetImage(img) as ImageProvider;

                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffe3e3e3)),
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: provider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 280,
                    child: Text(
                      outfitReason,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Futura',
                        color: Color(0xff707070),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
