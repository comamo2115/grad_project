// home_screen.dart
// ★ 주석은 한국어로 작성했습니다.
import 'package:flutter/material.dart';
import 'dart:convert'; // ★ JSON 인/코딩
import 'dart:async'; // ★ TimeoutException
import 'dart:io'; // ★ Socket/Handshake 예외
import 'package:http/http.dart' as http;

// ★ (가정) 서버가 추천해준 옷 ID를 실제 이미지 경로로 변환하는 함수
// 실제 앱에서는 사용자 옷장 DB의 매핑 규칙에 맞게 구현하세요.
String getImagePathFromId(int id) => 'assets/images/$id.jpg';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ----------------------------- 상태 -----------------------------
  bool isGenerated = false; // 추천 결과 표시 여부
  bool _isLoading = false; // 로딩 스피너
  String _errorMessage = ''; // 에러 메시지

  // ★ 서버 응답으로 대체될 이미지 목록
  // - 문자열 배열: "assets/...jpg" 또는 "https://..." 둘 다 허용
  List<String> outfitImages = [];

  // ★ 추천 사유(텍스트)
  String outfitReason = 'This is an outfit suitable for a meeting.';

  // ----------------------------- 설정 -----------------------------
  // ★ ngrok URL (https 중복 제거!)
  static const String _apiUrl =
      'https://11119ada0da0.ngrok-free.app/recommend_outfit';

  // ----------------------------- 네비게이션 -----------------------------
  Future<void> _openWeather() async {
    await Navigator.of(context, rootNavigator: true).pushNamed('/weather');
  }

  // ----------------------------- API 호출 -----------------------------
  Future<void> _getOutfitRecommendation() async {
    // ★ UI 상태 초기화
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      isGenerated = false;
    });

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
        "temperature": 22.0,
        "condition": "Clear",
        "gender": "Men",
      };

      // ★ POST + 타임아웃
      final res = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestData),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        // ★ 한글/UTF-8 안전 디코딩
        final body = json.decode(utf8.decode(res.bodyBytes));

        // ★ 예상되는 응답 케이스를 광범위하게 처리
        // 1) { best_combination: { ids: [int, ...], description: "..." } }
        // 2) { ids: [...], description: "..." }
        // 3) { image_urls: ["https://..."] }
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

        // ★ 이미지 경로 변환 로직
        final List<String> imagePaths = [];
        if (idsDyn is List && idsDyn.isNotEmpty) {
          // 정수 ID -> assets 경로로 매핑
          for (final v in idsDyn) {
            if (v is int) imagePaths.add(getImagePathFromId(v));
            if (v is String && int.tryParse(v) != null) {
              imagePaths.add(getImagePathFromId(int.parse(v)));
            }
          }
        } else if (urlsDyn is List && urlsDyn.isNotEmpty) {
          // 서버가 직접 URL을 내려주는 경우
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
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
          // ★ 추천 이미지/사유 (Wrap으로 줄바꿈/자동 배치)
          // 기존의 ① 이미지 Row Positioned, ② 사유 텍스트 Positioned 를 이 하나로 교체하세요.
          if (isGenerated) ...[
            Positioned(
              top: 260 + yOffset,
              left: 10,
              right: 10,
              // bottom 을 주지 않아 내용 높이에 맞춰 자동으로 확장됩니다.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ★ Wrap: 한 줄을 넘으면 자동으로 다음 줄에 배치
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly, // ★ 좌우 여백을 고르게
                    spacing: 12, // ★ 가로 간격
                    runSpacing: 12, // ★ 줄(세로) 간격
                    children: outfitImages.map((img) {
                      // ★ 네트워크/에셋 모두 지원
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
                  // ★ 추천 사유 텍스트: 이미지들 아래에 자연스럽게 배치
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

// // home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool isGenerated = false;

//   // ★ 코디 추천 이미지(예시)
//   final List<String> outfitImages = [
//     'assets/images/jacket.jpeg',
//     'assets/images/tshirt.jpeg',
//     'assets/images/dress.jpeg',
//   ];

//   // ★ 코디 추천 사유(예시)
//   final String outfitReason = 'This is an outfit suitable for a meeting.';

//   // ★ (옵션) /weather 에서 돌아온 뒤 갱신이 필요하면 여기서 setState 호출
//   Future<void> _openWeather() async {
//     // '/weather' 화면으로 이동 → 닫히면 여기로 복귀
//     await Navigator.of(context, rootNavigator: true).pushNamed('/weather');
//     // TODO: 날씨 재조회가 필요하면 아래 주석 해제
//     // setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ★ 전체 요소를 아래로 내릴 오프셋(픽셀). 요청: 약 30
//     final double yOffset = 30.0;

//     return Scaffold(
//       backgroundColor: const Color(0xfffbfbfb),
//       body: Stack(
//         children: [
//           // 상단 배경
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             // ★ 내용이 30 내려가므로 높이를 167→167 + yOffset 로 확장
//             height: 167 + yOffset,
//             child: Container(color: const Color(0xffbfb69b)),
//           ),

//           // 로고
//           Positioned(
//             // ★ 25 → 25 + yOffset
//             top: 25 + yOffset,
//             left: MediaQuery.of(context).size.width / 2 - 75,
//             child: SizedBox(
//               width: 150,
//               child: Center(
//                 child: Image.asset(
//                   'assets/images/outfitter_logo2.png',
//                   fit: BoxFit.contain,
//                   height: 60,
//                 ),
//               ),
//             ),
//           ),

//           // ★ 위치/날씨 정보 블록(전체가 터치 영역) → /weather 로 이동
//           Positioned(
//             // ★ 80 → 80 + yOffset
//             top: 80 + yOffset,
//             left: 12,
//             right: 12,
//             height: 41,
//             child: GestureDetector(
//               onTap: _openWeather, // ★ 블록 전체 탭 시 이동
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: const Color(0xfff9f2ed),
//                   borderRadius: BorderRadius.circular(20.0),
//                 ),
//                 // ★ 내부에 아이콘+텍스트를 같은 블록 안에 배치
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: const [
//                     Icon(Icons.location_on, size: 16, color: Color(0xffbf634e)),
//                     SizedBox(width: 4),
//                     Text(
//                       'busan',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontFamily: 'Futura',
//                         color: Color(0xff707070),
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     Icon(Icons.cloud, size: 16, color: Color(0xffbf634e)),
//                     SizedBox(width: 4),
//                     Text(
//                       '30°C / 23°C',
//                       style: TextStyle(fontSize: 12, fontFamily: 'Futura'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // 오늘 일정 텍스트（탭無効）
//           Positioned(
//             // ★ 135 → 135 + yOffset
//             top: 135 + yOffset,
//             left: MediaQuery.of(context).size.width / 2 - 133,
//             child: IgnorePointer(
//               ignoring: true, // ★ 터치 무시
//               child: const Text(
//                 "Today’s plan : Team Meeting at 4pm",
//                 style: TextStyle(
//                   fontFamily: 'Futura',
//                   fontSize: 16,
//                   color: Color(0xfff9f2ed),
//                 ),
//               ),
//             ),
//           ),

//           // 추천 버튼: 중앙 정렬 + 줄바꿈(Generate\nToday's Outfit) + 버튼 사이즈 확대
//           Positioned(
//             // ★ 180 → 180 + yOffset
//             top: 180 + yOffset,
//             left: 0, // ★ 좌우 0으로 두고
//             right: 0, // ★ Center로 자식(Container)을 중앙 배치
//             child: GestureDetector(
//               onTap: () {
//                 // ★ MOCK: 버튼 탭 시 결과 표시
//                 setState(() {
//                   isGenerated = true;
//                 });
//               },
//               child: Center(
//                 child: Container(
//                   width: 260, // ★ 폭 약간 확대 (기존 200 → 260)
//                   height: 60, // ★ 높이 확대 (기존 45 → 60)
//                   decoration: BoxDecoration(
//                     color: const Color(0xffbf634e),
//                     borderRadius: BorderRadius.circular(18.0), // ★ 라운드 조금 키움
//                   ),
//                   child: const Center(
//                     child: Text(
//                       "Generate\nToday’s Outfit", // ★ 줄바꿈 적용
//                       textAlign: TextAlign.center, // ★ 가운데 정렬
//                       softWrap: true, // ★ 줄바꿈 허용
//                       maxLines: 2, // ★ 최대 2줄
//                       style: TextStyle(
//                         fontFamily: 'Futura',
//                         fontSize: 18, // ★ 글자 크기 약간 키움
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xfff9f2ed),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // 추천 이미지/사유 표시 영역
//           if (isGenerated) ...[
//             Positioned(
//               // ★ 240 → 240 + yOffset
//               top: 260 + yOffset,
//               left: 10,
//               right: 10,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: outfitImages
//                     .map(
//                       (img) => Container(
//                         width: 120,
//                         height: 120,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: const Color(0xffe3e3e3)),
//                           borderRadius: BorderRadius.circular(10),
//                           image: DecorationImage(
//                             image: AssetImage(img),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     )
//                     .toList(),
//               ),
//             ),
//             Positioned(
//               // ★ 360 → 360 + yOffset
//               top: 780 + yOffset,
//               left: MediaQuery.of(context).size.width / 2 - 140,
//               child: Center(
//                 child: Text(
//                   outfitReason,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontFamily: 'Futura',
//                     color: Color(0xff707070),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
