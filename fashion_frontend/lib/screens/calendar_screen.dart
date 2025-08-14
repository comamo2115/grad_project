// calendar_screen.dart

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:fashion_frontend/screens/add_schedule.dart';
// import 'package:fashion_frontend/screens/modify_schedule.dart';
// import 'package:fashion_frontend/widgets/bottom_nav.dart';

// class CalendarScreen extends StatefulWidget {
//   const CalendarScreen({Key? key}) : super(key: key);

//   @override
//   State<CalendarScreen> createState() => _CalendarScreenState();
// }

// class _CalendarScreenState extends State<CalendarScreen> {
//   // 백엔드 베이스 URL (환경에 맞게 변경)
//   // - iOS 시뮬레이터: http://127.0.0.1:8000
//   // - Android 에뮬레이터: http://10.0.2.2:8000
//   static const String _baseUrl = 'http://127.0.0.1:8000';

//   // 현재 표시 중인 달
//   DateTime _currentMonth = DateTime(
//     DateTime.now().year,
//     DateTime.now().month,
//     1,
//   );

//   // 월 단위 일정 데이터: day(1~31) -> 일정 리스트
//   final Map<int, List<Map<String, dynamic>>> _monthSchedules = {};

//   // 오늘 정보 (항상 오늘 기준으로 별도 보관)
//   DateTime _today = DateTime.now();
//   List<Map<String, dynamic>> _todaySchedules = [];

//   // 로딩/에러 상태
//   bool _isLoadingMonth = false;
//   bool _isLoadingToday = false;
//   String? _errorMonth;
//   String? _errorToday;

//   // 리스트 스크롤 제어 (오늘 날짜로 자동 스크롤)
//   final ScrollController _scrollController = ScrollController();
//   static const double _rowHeight = 56.0; // 각 행 높이 (자동 스크롤 계산에 사용)

//   @override
//   void initState() {
//     super.initState();
//     _fetchToday();
//     _fetchMonth(); // 현재 달 데이터 로드
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _goBackOrHome() {
//     final localNavigator = Navigator.of(context);
//     if (localNavigator.canPop()) {
//       // 스택에 이전 페이지가 있으면 일반 pop
//       localNavigator.pop();
//       return;
//     }
//     // ★ 탭 루트에 있다면, 이미 떠 있는 BottomNavRoot 를 찾아 Home(0) 탭으로 전환
//     final controller = BottomNavRoot.maybeOf(context);
//     if (controller != null) {
//       controller.switchTab(0); // 0 = Home
//       return;
//     }
//     // ★ (예외) BottomNavRoot 문맥이 없을 때만 최후의 수단으로 /home 교체
//     Navigator.of(context, rootNavigator: true).pushReplacementNamed('/home');
//   }

//   // 오늘 일정 로드
//   Future<void> _fetchToday() async {
//     setState(() {
//       _isLoadingToday = true;
//       _errorToday = null;
//     });
//     try {
//       final uri = Uri.parse('$_baseUrl/api/calendar/today');
//       final resp = await http.get(uri);
//       if (resp.statusCode == 200) {
//         final map = jsonDecode(resp.body) as Map<String, dynamic>;
//         // 날짜 문자열(YYYY-MM-DD) → DateTime
//         final dateStr = (map['date'] as String?) ?? '';
//         final parts = dateStr
//             .split('-')
//             .map((e) => int.tryParse(e) ?? 0)
//             .toList();
//         if (parts.length == 3) {
//           _today = DateTime(parts[0], parts[1], parts[2]);
//         } else {
//           _today = DateTime.now();
//         }
//         _todaySchedules = ((map['schedules'] as List?) ?? [])
//             .cast<Map>()
//             .map((e) => Map<String, dynamic>.from(e as Map))
//             .toList();
//       } else {
//         _errorToday = 'Failed to load today (${resp.statusCode})';
//       }
//     } catch (e) {
//       _errorToday = 'Network error: $e';
//     } finally {
//       if (mounted) setState(() => _isLoadingToday = false);
//     }
//   }

//   // 현재 월 일정 로드
//   Future<void> _fetchMonth() async {
//     setState(() {
//       _isLoadingMonth = true;
//       _errorMonth = null;
//       _monthSchedules.clear();
//     });
//     try {
//       final y = _currentMonth.year;
//       final m = _currentMonth.month;
//       final uri = Uri.parse('$_baseUrl/api/calendar?year=$y&month=$m');
//       final resp = await http.get(uri);
//       if (resp.statusCode == 200) {
//         final map = jsonDecode(resp.body) as Map<String, dynamic>;
//         final days = (map['days'] as List?) ?? [];
//         for (final d in days) {
//           final day = (d['day'] as num).toInt();
//           final schedules = ((d['schedules'] as List?) ?? [])
//               .cast<Map>()
//               .map((e) => Map<String, dynamic>.from(e as Map))
//               .toList();
//           _monthSchedules[day] = schedules;
//         }
//       } else {
//         _errorMonth = 'Failed to load calendar (${resp.statusCode})';
//       }
//     } catch (e) {
//       _errorMonth = 'Network error: $e';
//     } finally {
//       if (!mounted) return;
//       setState(() => _isLoadingMonth = false);

//       // 현재 표시 달이 "오늘이 속한 달"이면, 오늘 날짜 위치로 자동 스크롤
//       if (_currentMonth.year == _today.year &&
//           _currentMonth.month == _today.month) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           final idx = _today.day - 1;
//           final offset = (idx * _rowHeight) - 8; // 약간의 상단 여백 보정
//           if (offset > 0 && _scrollController.hasClients) {
//             _scrollController.jumpTo(offset);
//           }
//         });
//       } else {
//         // 다른 달일 때는 맨 위로
//         if (_scrollController.hasClients) {
//           _scrollController.jumpTo(0);
//         }
//       }
//     }
//   }

//   // 이전 달로 이동
//   void _goPrevMonth() {
//     setState(() {
//       _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
//     });
//     _fetchMonth();
//   }

//   // 다음 달로 이동
//   void _goNextMonth() {
//     setState(() {
//       _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
//     });
//     _fetchMonth();
//   }

//   // 요일 라벨 (영문 약어)
//   String _weekdayLabel(int y, int m, int d) {
//     final wd = DateTime(y, m, d).weekday; // 1=Mon ... 7=Sun
//     const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return labels[wd - 1];
//   }

//   // 오늘 헤더용 날짜 포맷 (YYYY/MM/DD (EEE))
//   String _formatTodayHeader(DateTime dt) {
//     final y = dt.year.toString().padLeft(4, '0');
//     final m = dt.month.toString().padLeft(2, '0');
//     final d = dt.day.toString().padLeft(2, '0');
//     final wd = _weekdayLabel(dt.year, dt.month, dt.day);
//     return '$y/$m/$d ($wd)';
//     // 필요 시 intl 패키지를 사용해 로컬라이즈 가능
//   }

//   // 한 달의 말일 계산
//   int _lastDayOfMonth(DateTime month) {
//     final firstNext = DateTime(month.year, month.month + 1, 1);
//     final last = firstNext.subtract(const Duration(days: 1));
//     return last.day;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final y = _currentMonth.year;
//     final m = _currentMonth.month;
//     final lastDay = _lastDayOfMonth(_currentMonth);

//     return Scaffold(
//       backgroundColor: const Color(0xFFFBFBFB),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 헤더 영역
//           Container(
//             padding: const EdgeInsets.only(
//               top: 50,
//               left: 16,
//               right: 16,
//               bottom: 16,
//             ),
//             color: const Color(0xFFBFB69B),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.arrow_back, color: Colors.white),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Calendar',
//                   style: TextStyle(
//                     fontFamily: 'Futura',
//                     fontSize: 16,
//                     color: Color(0xFFF9F2ED),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // 오늘의 날짜/일정 + Add Schedule
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // 오늘 날짜 & 오늘 일정 (DB 로드)
//                 Expanded(
//                   child: _isLoadingToday
//                       ? const Text(
//                           "Loading today's schedule...",
//                           style: TextStyle(fontSize: 14, color: Colors.black54),
//                         )
//                       : (_errorToday != null
//                             ? Text(
//                                 _errorToday!,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.red,
//                                 ),
//                               )
//                             : Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     _formatTodayHeader(_today),
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     _todaySchedules.isEmpty
//                                         ? "Today's plan : (No schedule)"
//                                         : "Today's plan : ${_todaySchedules.map((e) => e['title']).join(', ')}",
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.black54,
//                                     ),
//                                   ),
//                                 ],
//                               )),
//                 ),

//                 // Add Schedule 버튼
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const AddScheduleScreen(),
//                       ),
//                     );
//                   },
//                   child: const Row(
//                     children: [
//                       Icon(
//                         Icons.add_circle_outline,
//                         color: Colors.redAccent,
//                         size: 16,
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         'Add Schedule',
//                         style: TextStyle(
//                           color: Colors.redAccent,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // 월 이동 (좌/우) + 현재 월 표시
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                   onPressed: _goPrevMonth,
//                   icon: const Icon(
//                     Icons.chevron_left,
//                     color: Color(0xFFBFB69B),
//                   ),
//                 ),
//                 Text(
//                   '$y / ${m.toString().padLeft(2, '0')}',
//                   style: const TextStyle(
//                     fontFamily: 'Futura',
//                     fontSize: 18,
//                     color: Color(0xFFBFB69B),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: _goNextMonth,
//                   icon: const Icon(
//                     Icons.chevron_right,
//                     color: Color(0xFFBFB69B),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // 날짜 리스트 (세로 스크롤)
//           Expanded(
//             child: _isLoadingMonth
//                 ? const Center(child: CircularProgressIndicator())
//                 : (_errorMonth != null
//                       ? Center(
//                           child: Text(
//                             _errorMonth!,
//                             style: const TextStyle(color: Colors.red),
//                           ),
//                         )
//                       : ListView.builder(
//                           controller: _scrollController,
//                           itemCount: lastDay,
//                           itemBuilder: (context, index) {
//                             final day = index + 1;
//                             final weekdayLabel = _weekdayLabel(y, m, day);
//                             final schedules = _monthSchedules[day] ?? [];
//                             final isSat =
//                                 DateTime(y, m, day).weekday ==
//                                 DateTime.saturday;
//                             final isSun =
//                                 DateTime(y, m, day).weekday == DateTime.sunday;
//                             final color = isSun
//                                 ? Colors.red
//                                 : (isSat ? Colors.blue : Colors.black);

//                             // 첫 줄에 노출할 대표 일정 제목 (여러 개면 첫 번째)
//                             final previewTitle = schedules.isNotEmpty
//                                 ? (schedules.first['title'] ?? '')
//                                 : '';

//                             return InkWell(
//                               onTap: () {
//                                 // 날짜 탭 시 modify_schedule 화면으로 이동
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) =>
//                                         const ModifyScheduleScreen(),
//                                     settings: RouteSettings(
//                                       arguments: {
//                                         'year': y,
//                                         'month': m,
//                                         'day': day,
//                                         'schedules': schedules,
//                                       },
//                                     ),
//                                   ),
//                                 ).then((_) {
//                                   // 수정 후 돌아오면 현재 달 재로딩 (필요 시)
//                                   _fetchMonth();
//                                   if (_currentMonth.year == _today.year &&
//                                       _currentMonth.month == _today.month) {
//                                     _fetchToday();
//                                   }
//                                 });
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 24.0,
//                                 ),
//                                 child: Container(
//                                   height: _rowHeight,
//                                   alignment: Alignment.centerLeft,
//                                   decoration: const BoxDecoration(
//                                     border: Border(
//                                       bottom: BorderSide(color: Colors.black12),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       // 날짜 + 요일
//                                       RichText(
//                                         text: TextSpan(
//                                           text: '$day  ',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             fontFamily: 'Futura',
//                                             color: color,
//                                           ),
//                                           children: [
//                                             TextSpan(
//                                               text: weekdayLabel,
//                                               style: TextStyle(color: color),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       // 일정 프리뷰
//                                       Expanded(
//                                         child: Align(
//                                           alignment: Alignment.centerRight,
//                                           child: Text(
//                                             previewTitle,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: const TextStyle(
//                                               fontSize: 13,
//                                               color: Colors.black54,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         )),
//           ),
//         ],
//       ),
//     );
//   }
// }

// MOCK
// calendar_screen_mock.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fashion_frontend/screens/add_schedule.dart';
import 'package:fashion_frontend/screens/modify_schedule.dart';
import 'package:fashion_frontend/widgets/bottom_nav.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenMockState();
}

class _CalendarScreenMockState extends State<CalendarScreen> {
  // 현재 표시 중인 달 (항상 1일 기준으로 보관)
  DateTime _currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  // 오늘 날짜
  final DateTime _today = DateTime.now();

  // 월 단위 더미 일정: day(1..말일) -> [{'id':int, 'title':String}, ...]
  final Map<int, List<Map<String, dynamic>>> _monthSchedules = {};

  // 오늘 일정 캐시
  List<Map<String, dynamic>> _todaySchedules = [];

  // 리스트 자동 스크롤(오늘로 이동)
  final ScrollController _scrollController = ScrollController();
  static const double _rowHeight = 56.0;

  @override
  void initState() {
    super.initState();
    // 더미 데이터 초기화
    _generateMockMonthData();
    _generateMockToday();
    // 첫 렌더 후 오늘 위치로 점프
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToTodayIfNeeded(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ★ Home 으로 돌아가기/혹은 팝: BottomNav 탭 안일 때는 루트 네비게이터에서 Home으로 교체
  void _goBackOrHome() {
    final localNavigator = Navigator.of(context);
    if (localNavigator.canPop()) {
      // 스택에 이전 페이지가 있으면 일반 pop
      localNavigator.pop();
      return;
    }
    // ★ 탭 루트에 있다면, 이미 떠 있는 BottomNavRoot 를 찾아 Home(0) 탭으로 전환
    final controller = BottomNavRoot.maybeOf(context);
    if (controller != null) {
      controller.switchTab(0); // 0 = Home
      return;
    }
    // ★ (예외) BottomNavRoot 문맥이 없을 때만 최후의 수단으로 /home 교체
    Navigator.of(context, rootNavigator: true).pushReplacementNamed('/home');
  }

  // 말일 계산
  int _lastDayOfMonth(DateTime month) {
    final firstNext = DateTime(month.year, month.month + 1, 1);
    return firstNext.subtract(const Duration(days: 1)).day;
  }

  // 요일 라벨
  String _weekdayLabel(int y, int m, int d) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final wd = DateTime(y, m, d).weekday; // 1=Mon .. 7=Sun
    return labels[wd - 1];
  }

  // 상단 오늘 표시용
  String _formatTodayHeader(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final wd = _weekdayLabel(dt.year, dt.month, dt.day);
    return '$y/$m/$d ($wd)';
  }

  // 더미: 해당 월 일정 생성
  void _generateMockMonthData() {
    _monthSchedules.clear();
    final last = _lastDayOfMonth(_currentMonth);
    final rnd = Random(_currentMonth.month * 1000 + _currentMonth.year);

    for (int day = 1; day <= last; day++) {
      final weekday = DateTime(
        _currentMonth.year,
        _currentMonth.month,
        day,
      ).weekday;
      final maxItems =
          (weekday == DateTime.saturday || weekday == DateTime.sunday) ? 1 : 2;
      final count = rnd.nextInt(maxItems + 1);

      final List<Map<String, dynamic>> items = [];
      for (int i = 0; i < count; i++) {
        final pool = [
          'Team Meeting',
          'Gym',
          'Lunch with Friend',
          'Study Session',
          'Project Review',
          'Grocery',
          'Dentist',
          'Running',
        ];
        final title = pool[rnd.nextInt(pool.length)];
        items.add({'id': rnd.nextInt(100000), 'title': title});
      }
      _monthSchedules[day] = items;
    }
  }

  // 더미: 오늘 일정 갱신
  void _generateMockToday() {
    if (_currentMonth.year == _today.year &&
        _currentMonth.month == _today.month) {
      _todaySchedules = List<Map<String, dynamic>>.from(
        _monthSchedules[_today.day] ?? [],
      );
    } else {
      _todaySchedules = [];
    }
  }

  // 오늘 위치로 스크롤 (현재 월이 오늘을 포함할 때만)
  void _scrollToTodayIfNeeded() {
    if (_currentMonth.year == _today.year &&
        _currentMonth.month == _today.month) {
      final idx = _today.day - 1;
      final offset = (idx * _rowHeight) - 8;
      if (offset > 0 && _scrollController.hasClients) {
        _scrollController.jumpTo(offset);
      }
    } else {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    }
  }

  // 이전 달로 이동
  void _goPrevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _generateMockMonthData();
      _generateMockToday();
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToTodayIfNeeded(),
    );
  }

  // 다음 달로 이동
  void _goNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _generateMockMonthData();
      _generateMockToday();
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToTodayIfNeeded(),
    );
  }

  // 일정 추가(더미): AddSchedule에서 결과를 받아 오늘 날짜에 추가
  void _appendScheduleToday(String title) {
    final day = _today.day;
    final list = _monthSchedules[day] ?? [];
    list.add({'id': DateTime.now().millisecondsSinceEpoch, 'title': title});
    _monthSchedules[day] = list;
    _generateMockToday();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final y = _currentMonth.year;
    final m = _currentMonth.month;
    final lastDay = _lastDayOfMonth(_currentMonth);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            color: const Color(0xFFBFB69B),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ★ 뒤로가기 → 탭 루트라면 Home 탭으로 전환
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _goBackOrHome,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Calendar',
                  style: TextStyle(
                    fontFamily: 'Futura',
                    fontSize: 16,
                    color: Color(0xFFF9F2ED),
                  ),
                ),
              ],
            ),
          ),

          // 오늘 날짜/일정 + Add Schedule (상단 고정)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                // 오늘 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTodayHeader(_today),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _todaySchedules.isEmpty
                            ? "Today's plan : (No schedule)"
                            : "Today's plan : ${_todaySchedules.map((e) => e['title']).join(', ')}",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                // Add Schedule 버튼: 화면 위에 push (fullscreenDialog로 상단 스택)
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) => const AddScheduleScreen(),
                        fullscreenDialog: true,
                      ),
                    );
                    if (result != null && result.trim().isNotEmpty) {
                      _appendScheduleToday(result.trim());
                    }
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Add Schedule',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 월 전후 이동 + 현재 월
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _goPrevMonth,
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFFBFB69B),
                  ),
                ),
                Text(
                  '$y / ${m.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontFamily: 'Futura',
                    fontSize: 18,
                    color: Color(0xFFBFB69B),
                  ),
                ),
                IconButton(
                  onPressed: _goNextMonth,
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFBFB69B),
                  ),
                ),
              ],
            ),
          ),

          // 날짜 리스트(세로 스크롤)
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: lastDay,
              itemBuilder: (context, index) {
                final day = index + 1;
                final weekdayLabel = _weekdayLabel(y, m, day);
                final schedules = _monthSchedules[day] ?? [];

                final isSat = DateTime(y, m, day).weekday == DateTime.saturday;
                final isSun = DateTime(y, m, day).weekday == DateTime.sunday;
                final color = isSun
                    ? Colors.red
                    : (isSat ? Colors.blue : Colors.black);

                final previewTitle = schedules.isNotEmpty
                    ? (schedules.first['title'] ?? '')
                    : '';

                return InkWell(
                  // 날짜 탭 시 수정 화면을 캘린더 위에 push
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ModifyScheduleScreen(),
                        fullscreenDialog: true,
                        settings: RouteSettings(
                          arguments: {
                            'year': y,
                            'month': m,
                            'day': day,
                            'schedules': schedules,
                          },
                        ),
                      ),
                    );
                    _generateMockToday();
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      height: _rowHeight,
                      alignment: Alignment.centerLeft,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: '$day  ',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Futura',
                                color: color,
                              ),
                              children: [
                                TextSpan(
                                  text: weekdayLabel,
                                  style: TextStyle(color: color),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                previewTitle,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
