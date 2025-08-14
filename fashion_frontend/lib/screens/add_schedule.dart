// add_schedule.dart (DB: Django + PostgreSQL)
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// /// ★ 서버 설정 (프로젝트에 맞게 수정)
// class ApiConfig {
//   // 예: http://10.0.2.2:8000  (Android 에뮬레이터에서 로컬 Django)
//   //     http://127.0.0.1:8000  (iOS 시뮬레이터)
//   static const String baseUrl = 'http://10.0.2.2:8000';
//   static const String schedulesEndpoint = '/api/schedules/';

//   // 인증 토큰이 필요하다면 여기에 설정 (없으면 null/빈문자)
//   static const String? bearerToken = null; // 'YOUR_JWT_TOKEN';
// }

// class AddScheduleScreen extends StatefulWidget {
//   const AddScheduleScreen({super.key});

//   @override
//   State<AddScheduleScreen> createState() => _AddScheduleScreenState();
// }

// class _AddScheduleScreenState extends State<AddScheduleScreen> {
//   // ----------------- 상태 -----------------
//   DateTime? _selectedDate; // 날짜 (필수)
//   bool _allDay = false; // 하루종일 여부 (체크박스)
//   TimeOfDay? _startTime; // 시작시간
//   TimeOfDay? _endTime; // 종료시간
//   final TextEditingController _planCtrl = TextEditingController(); // 계획 상세 (필수)
//   final TextEditingController _descCtrl = TextEditingController(); // 설명 (선택)
//   bool _showErrors = false; // 에러 표시 플래그
//   bool _saving = false; // 저장 중 로딩 상태

//   // 계획 상세 옵션(필수)
//   static const List<String> _planOptions = [
//     'Art Gallery Visit',
//     'Attending a Play',
//     'Baby Shower',
//     'Baking Session',
//     'Beach Trip',
//     'Beach Volleyball',
//     'Board Game Night',
//     'Book Club Meeting',
//     'Business Presentation',
//     'Camping Trip',
//     'Car Repair',
//     'Casual Day Out',
//     'Charity Marathon',
//     'Cocktail Party',
//     'Conference Attendance',
//     'Cultural Festival',
//     'Cruise Vacation',
//     'Cycling Tour',
//     'Date Night',
//     'Dog Walking',
//     'Evening Party',
//     'Fine Dining',
//     'Fishing Trip',
//     'Formal Gala',
//     'Game Day at Stadium',
//     'Gardening',
//     'Gym Workout',
//     'Hiking',
//     'Home Office Work',
//     'Job Interview',
//     'Library Study',
//     'Meditation Retreat',
//     'Movie Night In',
//     'Morning Coffee Run',
//     'Museum Visit',
//     'Music Festival',
//     'Neighborhood Walk',
//     'Night Out with Friends',
//     'Office Meeting',
//     'Online Class',
//     'Opera Night',
//     'Outdoor Concert',
//     'Picnic in Park',
//     'Pottery Class',
//     'Public Speaking Event',
//     'Quick Grocery Run',
//     'Relaxing at Home',
//     'Religious Gathering',
//     'Road Trip',
//     'Running Errands',
//     'Shopping Spree',
//     'Ski Trip',
//     'Street Photography',
//     'Summer BBQ',
//     'Traditional Ceremony',
//     'Travel Day',
//     'University Lecture',
//     'Volunteering Event',
//     'Weekend Brunch',
//     'Wedding Ceremony',
//     'Yoga Class',
//   ];

//   @override
//   void dispose() {
//     _planCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }

//   // ----------------- 포맷터 -----------------
//   String _formatDate(DateTime d) =>
//       '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

//   String _formatTime(TimeOfDay t) =>
//       '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

//   // ----------------- 유효성 -----------------
//   bool get _isDateValid => _selectedDate != null;

//   // 계획 상세는 옵션 목록 중 하나를 선택해야 함
//   bool get _isPlanValid => _planOptions.contains(_planCtrl.text.trim());

//   // 시간 제약: 선택 자유. 단, 둘 다 있을 때는 시작 <= 종료
//   bool get _isTimeRangeValid {
//     if (_allDay) return true;
//     if (_startTime == null || _endTime == null) return true;
//     final s = _startTime!.hour * 60 + _startTime!.minute;
//     final e = _endTime!.hour * 60 + _endTime!.minute;
//     return s <= e;
//   }

//   bool get _formValid => _isDateValid && _isPlanValid && _isTimeRangeValid;

//   // ----------------- 피커 -----------------
//   Future<void> _pickDate() async {
//     final now = DateTime.now();
//     final result = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? now,
//       firstDate: DateTime(now.year - 3),
//       lastDate: DateTime(now.year + 3),
//       helpText: 'Select date',
//     );
//     if (result != null) setState(() => _selectedDate = result);
//   }

//   Future<void> _pickTime({required bool isStart}) async {
//     if (_allDay) return;
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: isStart
//           ? (_startTime ?? TimeOfDay.now())
//           : (_endTime ?? TimeOfDay.now()),
//       helpText: isStart ? 'Select start time' : 'Select end time',
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStart) {
//           _startTime = picked;
//         } else {
//           _endTime = picked;
//         }
//       });
//     }
//   }

//   // ----------------- 서버 저장 -----------------
//   /// ★ Django로 전송할 JSON을 생성
//   /// 백엔드가 `date/all_day/start_time/end_time/plan_detail/description` 를 받는다고 가정
//   Map<String, dynamic> _buildPayload() {
//     // 시간 문자열 포맷(선택). allDay면 null.
//     String? startTimeStr;
//     String? endTimeStr;

//     if (!_allDay) {
//       if (_startTime != null) {
//         startTimeStr =
//             '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
//       }
//       if (_endTime != null) {
//         endTimeStr =
//             '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';
//       }
//     }

//     // 날짜는 YYYY-MM-DD 로 전송
//     final dateStr =
//         '${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

//     return {
//       'date': dateStr,
//       'all_day': _allDay,
//       'start_time': startTimeStr, // null 허용
//       'end_time': endTimeStr, // null 허용
//       'plan_detail': _planCtrl.text.trim(),
//       'description': _descCtrl.text.trim(),
//     };
//   }

//   /// ★ Django API 호출
//   Future<void> _saveToServer() async {
//     // 저장 중 상태 처리
//     setState(() => _saving = true);

//     try {
//       final uri = Uri.parse(
//         '${ApiConfig.baseUrl}${ApiConfig.schedulesEndpoint}',
//       );
//       final headers = <String, String>{'Content-Type': 'application/json'};
//       // 토큰이 있으면 Authorization 추가
//       if (ApiConfig.bearerToken != null && ApiConfig.bearerToken!.isNotEmpty) {
//         headers['Authorization'] = 'Bearer ${ApiConfig.bearerToken}';
//       }

//       final resp = await http.post(
//         uri,
//         headers: headers,
//         body: jsonEncode(_buildPayload()),
//       );

//       if (resp.statusCode == 201 || resp.statusCode == 200) {
//         // ★ 성공: 캘린더 화면으로 복귀(갱신 트리거 용 true 반환)
//         if (mounted) {
//           Navigator.pop(context, true);
//         }
//       } else {
//         // ★ 실패: 서버 메시지 표시
//         String message = 'Failed to save (status: ${resp.statusCode}).';
//         try {
//           final parsed = jsonDecode(resp.body);
//           if (parsed is Map && parsed['detail'] != null) {
//             message = parsed['detail'].toString();
//           }
//         } catch (_) {}
//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text(message)));
//         }
//       }
//     } catch (e) {
//       // ★ 네트워크/기타 예외 처리
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Network error: $e')));
//       }
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }

//   void _save() {
//     setState(() => _showErrors = true);
//     if (!_formValid) return;
//     _saveToServer();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dateText = _selectedDate == null ? '' : _formatDate(_selectedDate!);
//     final startText = _startTime == null ? '' : _formatTime(_startTime!);
//     final endText = _endTime == null ? '' : _formatTime(_endTime!);

//     return Scaffold(
//       backgroundColor: const Color(0xFFFBFBFB),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: const Color(0xFFBFB69B),
//         title: const Text(
//           'Add New Schedule',
//           style: TextStyle(
//             fontFamily: 'Futura',
//             fontWeight: FontWeight.w500,
//             fontSize: 16,
//             color: Color(0xFFF9F2ED),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.close, color: Colors.white),
//             onPressed: _saving ? null : () => Navigator.pop(context),
//           ),
//         ],
//       ),
//       body: AbsorbPointer(
//         // ★ 저장 중이면 입력 막기
//         absorbing: _saving,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 35.0),
//           child: ListView(
//             children: [
//               const SizedBox(height: 30),

//               // --------- Date (필수) ---------
//               const _LabelText('Date'),
//               _StyledInput(
//                 child: InkWell(
//                   onTap: _pickDate,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 14,
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.event_note),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             dateText.isEmpty ? 'Select a date' : dateText,
//                             style: TextStyle(
//                               color: dateText.isEmpty
//                                   ? Colors.black45
//                                   : Colors.black87,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                         const Icon(Icons.calendar_today, size: 18),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               if (_showErrors && !_isDateValid)
//                 const _ErrorText('Please select a date.'),

//               const SizedBox(height: 25),

//               // --------- Time + All-day 체크박스 ---------
//               Row(
//                 children: [
//                   const _LabelText('Time'),
//                   const Spacer(),
//                   const Text('All-day'),
//                   Checkbox(
//                     value: _allDay,
//                     onChanged: (v) => setState(() => _allDay = v ?? false),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _StyledInput(
//                       child: InkWell(
//                         onTap: _allDay ? null : () => _pickTime(isStart: true),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 14,
//                           ),
//                           child: Text(
//                             startText.isEmpty ? 'Start (optional)' : startText,
//                             style: TextStyle(
//                               color: _allDay
//                                   ? Colors.black26
//                                   : (startText.isEmpty
//                                         ? Colors.black45
//                                         : Colors.black87),
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 8),
//                     child: Text('ー'),
//                   ),
//                   Expanded(
//                     child: _StyledInput(
//                       child: InkWell(
//                         onTap: _allDay ? null : () => _pickTime(isStart: false),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 14,
//                           ),
//                           child: Text(
//                             endText.isEmpty ? 'End (optional)' : endText,
//                             style: TextStyle(
//                               color: _allDay
//                                   ? Colors.black26
//                                   : (endText.isEmpty
//                                         ? Colors.black45
//                                         : Colors.black87),
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               if (_showErrors && !_isTimeRangeValid)
//                 const _ErrorText(
//                   'Start time must be before or equal to end time.',
//                 ),

//               const SizedBox(height: 25),

//               // --------- Plan detail (필수, 자동완성) ---------
//               const _LabelText('Plan detail'),
//               _StyledInput(
//                 height: 56,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 6),
//                   child: Autocomplete<String>(
//                     optionsBuilder: (TextEditingValue value) {
//                       final q = value.text.trim().toLowerCase();
//                       if (q.isEmpty) return _planOptions;
//                       return _planOptions.where(
//                         (o) => o.toLowerCase().contains(q),
//                       );
//                     },
//                     onSelected: (selection) {
//                       _planCtrl.text = selection;
//                       setState(() {});
//                     },
//                     fieldViewBuilder:
//                         (context, controller, focusNode, onSubmit) {
//                           controller.addListener(() {
//                             _planCtrl.value = controller.value;
//                             setState(() {});
//                           });
//                           return TextField(
//                             controller: controller,
//                             focusNode: focusNode,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                               hintText: 'Search & select…',
//                               contentPadding: EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 14,
//                               ),
//                             ),
//                           );
//                         },
//                     optionsViewBuilder: (context, onSelected, options) {
//                       return Align(
//                         alignment: Alignment.topLeft,
//                         child: Material(
//                           elevation: 4,
//                           borderRadius: BorderRadius.circular(8),
//                           child: ConstrainedBox(
//                             constraints: const BoxConstraints(
//                               maxHeight: 240,
//                               minWidth: 280,
//                             ),
//                             child: ListView.builder(
//                               padding: EdgeInsets.zero,
//                               itemCount: options.length,
//                               itemBuilder: (context, index) {
//                                 final opt = options.elementAt(index);
//                                 return ListTile(
//                                   title: Text(opt),
//                                   onTap: () => onSelected(opt),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               if (_showErrors && !_isPlanValid)
//                 const _ErrorText('Please choose from the list.'),

//               const SizedBox(height: 25),

//               // --------- Description (선택) ---------
//               const _LabelText('Description'),
//               _StyledInput(
//                 height: 120,
//                 child: TextFormField(
//                   controller: _descCtrl,
//                   maxLines: 5,
//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.all(10),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 50),

//               // --------- Save 버튼 ---------
//               ElevatedButton(
//                 onPressed: (_formValid && !_saving)
//                     ? _save
//                     : () => setState(() => _showErrors = true),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFBF634E),
//                   disabledBackgroundColor: const Color(
//                     0xFFBF634E,
//                   ).withOpacity(0.5),
//                   minimumSize: const Size(double.infinity, 60),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: _saving
//                     ? const SizedBox(
//                         height: 22,
//                         width: 22,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       )
//                     : const Text(
//                         'Save',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//               ),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// //------------------- 커스텀 라벨 -------------------
// class _LabelText extends StatelessWidget {
//   final String label;
//   const _LabelText(this.label);
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       label,
//       style: const TextStyle(
//         fontFamily: 'Futura',
//         fontWeight: FontWeight.w500,
//         fontSize: 20,
//         color: Color(0xFF0D0D0D),
//       ),
//     );
//   }
// }

// //------------------- 에러 텍스트 -------------------
// class _ErrorText extends StatelessWidget {
//   final String text;
//   const _ErrorText(this.text);
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 8),
//       child: Text(text, style: const TextStyle(color: Colors.red)),
//     );
//   }
// }

// //------------------- 스타일 박스 -------------------
// class _StyledInput extends StatelessWidget {
//   final Widget? child;
//   final double height;
//   const _StyledInput({this.child, this.height = 50});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: height,
//       margin: const EdgeInsets.only(top: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFFFFF),
//         border: Border.all(color: const Color(0xFF707070)),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: child,
//     );
//   }
// }

// add_schedule.dart (MOCK)
import 'package:flutter/material.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  // ----------------- 상태 -----------------
  DateTime? _selectedDate; // 날짜 (필수)
  bool _allDay = false; // 하루종일 여부 (체크박스)
  TimeOfDay? _startTime; // 시작시간
  TimeOfDay? _endTime; // 종료시간
  final TextEditingController _planCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  bool _showErrors = false;

  static const List<String> _planOptions = [
    'Art Gallery Visit',
    'Attending a Play',
    'Baby Shower',
    'Baking Session',
    'Beach Trip',
    'Beach Volleyball',
    'Board Game Night',
    'Book Club Meeting',
    'Business Presentation',
    'Camping Trip',
    'Car Repair',
    'Casual Day Out',
    'Charity Marathon',
    'Cocktail Party',
    'Conference Attendance',
    'Cultural Festival',
    'Cruise Vacation',
    'Cycling Tour',
    'Date Night',
    'Dog Walking',
    'Evening Party',
    'Fine Dining',
    'Fishing Trip',
    'Formal Gala',
    'Game Day at Stadium',
    'Gardening',
    'Gym Workout',
    'Hiking',
    'Home Office Work',
    'Job Interview',
    'Library Study',
    'Meditation Retreat',
    'Movie Night In',
    'Morning Coffee Run',
    'Museum Visit',
    'Music Festival',
    'Neighborhood Walk',
    'Night Out with Friends',
    'Office Meeting',
    'Online Class',
    'Opera Night',
    'Outdoor Concert',
    'Picnic in Park',
    'Pottery Class',
    'Public Speaking Event',
    'Quick Grocery Run',
    'Relaxing at Home',
    'Religious Gathering',
    'Road Trip',
    'Running Errands',
    'Shopping Spree',
    'Ski Trip',
    'Street Photography',
    'Summer BBQ',
    'Traditional Ceremony',
    'Travel Day',
    'University Lecture',
    'Volunteering Event',
    'Weekend Brunch',
    'Wedding Ceremony',
    'Yoga Class',
  ];

  @override
  void dispose() {
    _planCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  bool get _isDateValid => _selectedDate != null;
  bool get _isPlanValid => _planOptions.contains(_planCtrl.text.trim());
  bool get _isTimeRangeValid {
    if (_allDay) return true;
    if (_startTime == null || _endTime == null) return true;
    final s = _startTime!.hour * 60 + _startTime!.minute;
    final e = _endTime!.hour * 60 + _endTime!.minute;
    return s <= e;
  }

  bool get _formValid => _isDateValid && _isPlanValid && _isTimeRangeValid;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
    );
    if (result != null) setState(() => _selectedDate = result);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _save() {
    setState(() => _showErrors = true);
    if (!_formValid) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null ? '' : _formatDate(_selectedDate!);
    final startText = _startTime == null ? '' : _formatTime(_startTime!);
    final endText = _endTime == null ? '' : _formatTime(_endTime!);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFBFB69B),
        title: const Text(
          'Add New Schedule',
          style: TextStyle(
            fontFamily: 'Futura',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xFFF9F2ED),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0),
        child: ListView(
          children: [
            const SizedBox(height: 30),
            const _LabelText('Date'),
            _StyledInput(
              child: InkWell(
                onTap: _pickDate,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_note),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dateText.isEmpty ? 'Select a date' : dateText,
                          style: TextStyle(
                            color: dateText.isEmpty
                                ? Colors.black45
                                : Colors.black87,
                          ),
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            if (_showErrors && !_isDateValid)
              const _ErrorText('Please select a date.'),

            const SizedBox(height: 25),
            // Time + All-day checkbox
            Row(
              children: [
                const _LabelText('Time'),
                const Spacer(),
                const Text('All-day'),
                Checkbox(
                  value: _allDay,
                  onChanged: (v) => setState(() => _allDay = v ?? false),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _StyledInput(
                    child: InkWell(
                      onTap: _allDay ? null : () => _pickTime(isStart: true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        child: Text(
                          startText.isEmpty ? 'Start (optional)' : startText,
                          style: TextStyle(
                            color: _allDay
                                ? Colors.black26
                                : (startText.isEmpty
                                      ? Colors.black45
                                      : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('ー'),
                ),
                Expanded(
                  child: _StyledInput(
                    child: InkWell(
                      onTap: _allDay ? null : () => _pickTime(isStart: false),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        child: Text(
                          endText.isEmpty ? 'End (optional)' : endText,
                          style: TextStyle(
                            color: _allDay
                                ? Colors.black26
                                : (endText.isEmpty
                                      ? Colors.black45
                                      : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_showErrors && !_isTimeRangeValid)
              const _ErrorText(
                'Start time must be before or equal to end time.',
              ),

            const SizedBox(height: 25),
            const _LabelText('Plan detail'),
            _StyledInput(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue value) {
                    final q = value.text.trim().toLowerCase();
                    if (q.isEmpty) return _planOptions;
                    return _planOptions.where(
                      (o) => o.toLowerCase().contains(q),
                    );
                  },
                  onSelected: (selection) {
                    _planCtrl.text = selection;
                    setState(() {});
                  },
                  fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                    controller.addListener(() {
                      _planCtrl.value = controller.value;
                      setState(() {});
                    });
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search & select…',
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_showErrors && !_isPlanValid)
              const _ErrorText('Please choose from the list.'),

            const SizedBox(height: 25),
            const _LabelText('Description'),
            _StyledInput(
              height: 120,
              child: TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _formValid
                  ? _save
                  : () => setState(() => _showErrors = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBF634E),
                minimumSize: const Size(double.infinity, 60),
                disabledBackgroundColor: const Color(
                  0xFFBF634E,
                ).withOpacity(0.5),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelText extends StatelessWidget {
  final String label;
  const _LabelText(this.label);
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String text;
  const _ErrorText(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: const TextStyle(color: Colors.red)),
    );
  }
}

class _StyledInput extends StatelessWidget {
  final Widget? child;
  final double height;
  const _StyledInput({this.child, this.height = 50});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF707070)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
