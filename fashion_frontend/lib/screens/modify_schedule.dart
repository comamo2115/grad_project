// modify_schedule.dart (DB: Django + PostgreSQL)

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// /// ★ 서버 설정 (add_schedule.dart 와 동일하게 유지)
// class ApiConfig {
//   // 예: http://10.0.2.2:8000 (Android 에뮬레이터에서 로컬 Django)
//   //     http://127.0.0.1:8000 (iOS 시뮬레이터)
//   static const String baseUrl = 'http://10.0.2.2:8000';
//   static const String schedulesEndpoint = '/api/schedules/';

//   // 인증 토큰이 필요하다면 설정 (없으면 null/빈문자)
//   static const String? bearerToken = null; // 'YOUR_JWT_TOKEN';
// }

// /// ★ 수정 화면: 기존 스케줄 편집/삭제
// /// - scheduleId 또는 initialDate 중 하나로 로딩
// class ModifyScheduleScreen extends StatefulWidget {
//   final int? scheduleId; // 우선순위 1: 명시 ID 기반 로딩
//   final DateTime? initialDate; // 우선순위 2: 날짜 기반 로딩 (YYYY-MM-DD 첫 1건)

//   const ModifyScheduleScreen({super.key, this.scheduleId, this.initialDate});

//   @override
//   State<ModifyScheduleScreen> createState() => _ModifyScheduleScreenState();
// }

// class _ModifyScheduleScreenState extends State<ModifyScheduleScreen> {
//   // ----------------- 상태 -----------------
//   bool _initialLoading = true; // 최초 로딩 스피너
//   bool _saving = false; // 저장 중 로딩
//   bool _deleting = false; // 삭제 중 로딩
//   bool _showErrors = false; // 검증 에러 표시

//   // 폼 필드
//   DateTime? _selectedDate; // 날짜 (필수)
//   bool _allDay = false; // 하루종일
//   TimeOfDay? _startTime; // 시작시간
//   TimeOfDay? _endTime; // 종료시간
//   final TextEditingController _planCtrl = TextEditingController(); // 계획 상세 (필수)
//   final TextEditingController _descCtrl = TextEditingController(); // 설명 (선택)

//   // 플랜 옵션 (add_schedule.dart 과 동일)
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

//   // 백엔드에서 로딩한 엔티티의 식별자
//   int? _entityId; // PUT/DELETE 시 사용

//   // 변경 감지를 위한 초기 스냅샷
//   Map<String, dynamic>? _initialSnapshot;

//   @override
//   void initState() {
//     super.initState();
//     _loadSchedule();
//   }

//   @override
//   void dispose() {
//     _planCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }

//   // ----------------- 공통 포맷터 -----------------
//   String _formatDate(DateTime d) =>
//       '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

//   String _formatTime(TimeOfDay t) =>
//       '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

//   String _toIsoDate(DateTime d) =>
//       '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

//   // ----------------- 검증 -----------------
//   bool get _isDateValid => _selectedDate != null;
//   bool get _isPlanValid => _planOptions.contains(_planCtrl.text.trim());

//   bool get _isTimeRangeValid {
//     if (_allDay) return true;
//     if (_startTime == null || _endTime == null) return true;
//     final s = _startTime!.hour * 60 + _startTime!.minute;
//     final e = _endTime!.hour * 60 + _endTime!.minute;
//     return s <= e;
//   }

//   bool get _formValid => _isDateValid && _isPlanValid && _isTimeRangeValid;

//   // ----------------- 변경 감지 -----------------
//   /// ★ 현재 폼 상태를 스냅샷으로 직렬화 (초기값과 비교용)
//   Map<String, dynamic> _currentSnapshot() {
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
//     return {
//       'date': _selectedDate != null ? _toIsoDate(_selectedDate!) : null,
//       'all_day': _allDay,
//       'start_time': startTimeStr,
//       'end_time': endTimeStr,
//       'plan_detail': _planCtrl.text.trim(),
//       'description': _descCtrl.text.trim(),
//     };
//   }

//   bool get _isDirty {
//     if (_initialSnapshot == null) return false;
//     final now = _currentSnapshot();
//     // 단순 맵 비교 (키 동일 가정)
//     for (final k in _initialSnapshot!.keys) {
//       if (_initialSnapshot![k] != now[k]) return true;
//     }
//     return false;
//   }

//   // ----------------- 데이터 로딩 -----------------
//   Future<void> _loadSchedule() async {
//     setState(() {
//       _initialLoading = true;
//     });

//     final headers = <String, String>{'Content-Type': 'application/json'};
//     if (ApiConfig.bearerToken != null && ApiConfig.bearerToken!.isNotEmpty) {
//       headers['Authorization'] = 'Bearer ${ApiConfig.bearerToken}';
//     }

//     try {
//       Map<String, dynamic>? entity;

//       // ① ID 기반 로딩
//       if (widget.scheduleId != null) {
//         final uri = Uri.parse(
//           '${ApiConfig.baseUrl}${ApiConfig.schedulesEndpoint}${widget.scheduleId}/',
//         );
//         final resp = await http.get(uri, headers: headers);
//         if (resp.statusCode == 200) {
//           entity = jsonDecode(resp.body) as Map<String, dynamic>;
//         } else {
//           throw Exception('Failed to load (status: ${resp.statusCode})');
//         }
//       }
//       // ② 날짜 기반 로딩 (YYYY-MM-DD의 첫 1건)
//       else if (widget.initialDate != null) {
//         final dateStr = _toIsoDate(widget.initialDate!);
//         final uri = Uri.parse(
//           '${ApiConfig.baseUrl}${ApiConfig.schedulesEndpoint}?date=$dateStr',
//         );
//         final resp = await http.get(uri, headers: headers);
//         if (resp.statusCode == 200) {
//           final parsed = jsonDecode(resp.body);
//           if (parsed is List && parsed.isNotEmpty) {
//             // ★ 여러 건일 수 있으므로 현재는 첫 1건 선택
//             entity = parsed.first as Map<String, dynamic>;
//           } else {
//             throw Exception('No schedule found for $dateStr');
//           }
//         } else {
//           throw Exception(
//             'Failed to load by date (status: ${resp.statusCode})',
//           );
//         }
//       } else {
//         throw Exception('No scheduleId or initialDate provided');
//       }

//       // ★ 엔티티 -> 폼 상태 반영
//       _applyEntityToForm(entity!);

//       // ★ 초기 스냅샷 저장
//       _initialSnapshot = _currentSnapshot();
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Load error: $e')));
//       // 로딩 실패 시에도 화면은 유지 (사용자 재시도 가능)
//     } finally {
//       if (mounted) {
//         setState(() {
//           _initialLoading = false;
//         });
//       }
//     }
//   }

//   void _applyEntityToForm(Map<String, dynamic> entity) {
//     // ★ 서버 필드명 가정: id, date(YYYY-MM-DD), all_day(bool),
//     //   start_time("HH:mm" or null), end_time("HH:mm" or null),
//     //   plan_detail(string), description(string)
//     _entityId = entity['id'] as int?;

//     final dateStr = (entity['date'] ?? '') as String;
//     if (dateStr.isNotEmpty) {
//       final parts = dateStr
//           .split('-')
//           .map((e) => int.tryParse(e) ?? 0)
//           .toList();
//       if (parts.length == 3) {
//         _selectedDate = DateTime(parts[0], parts[1], parts[2]);
//       }
//     }

//     _allDay = (entity['all_day'] ?? false) as bool;

//     String? st = entity['start_time'] as String?;
//     String? et = entity['end_time'] as String?;
//     _startTime = (st == null || st.isEmpty)
//         ? null
//         : _parseTimeOfDay(st); // "HH:mm"
//     _endTime = (et == null || et.isEmpty) ? null : _parseTimeOfDay(et);

//     _planCtrl.text = (entity['plan_detail'] ?? '').toString();
//     _descCtrl.text = (entity['description'] ?? '').toString();

//     setState(() {});
//   }

//   TimeOfDay _parseTimeOfDay(String hhmm) {
//     final sp = hhmm.split(':');
//     final h = int.tryParse(sp[0]) ?? 0;
//     final m = int.tryParse(sp.length > 1 ? sp[1] : '0') ?? 0;
//     return TimeOfDay(hour: h, minute: m);
//   }

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

//   // ----------------- 서버 저장/삭제 -----------------
//   Map<String, dynamic> _buildPayload() {
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
//     final dateStr = _selectedDate != null ? _toIsoDate(_selectedDate!) : null;

//     return {
//       'date': dateStr,
//       'all_day': _allDay,
//       'start_time': startTimeStr,
//       'end_time': endTimeStr,
//       'plan_detail': _planCtrl.text.trim(),
//       'description': _descCtrl.text.trim(),
//     };
//   }

//   Future<void> _save() async {
//     setState(() => _showErrors = true);
//     if (!_formValid) return;
//     if (_entityId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No schedule ID to update.')),
//       );
//       return;
//     }

//     setState(() => _saving = true);
//     try {
//       final uri = Uri.parse(
//         '${ApiConfig.baseUrl}${ApiConfig.schedulesEndpoint}$_entityId/',
//       );
//       final headers = <String, String>{'Content-Type': 'application/json'};
//       if (ApiConfig.bearerToken != null && ApiConfig.bearerToken!.isNotEmpty) {
//         headers['Authorization'] = 'Bearer ${ApiConfig.bearerToken}';
//       }

//       // ★ PUT 또는 PATCH 중 택1 (여기서는 PUT 전체 업데이트 예시)
//       final resp = await http.put(
//         uri,
//         headers: headers,
//         body: jsonEncode(_buildPayload()),
//       );

//       if (resp.statusCode == 200) {
//         // 초기 스냅샷 갱신 (dirty 해제)
//         _initialSnapshot = _currentSnapshot();
//         if (!mounted) return;
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Saved successfully.')));
//         // 캘린더 갱신 트리거를 위해 true 반환
//         Navigator.pop(context, true);
//       } else {
//         String message = 'Failed to update (status: ${resp.statusCode}).';
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
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Network error: $e')));
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }

//   Future<void> _delete() async {
//     if (_entityId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No schedule ID to delete.')),
//       );
//       return;
//     }
//     setState(() => _deleting = true);

//     try {
//       final uri = Uri.parse(
//         '${ApiConfig.baseUrl}${ApiConfig.schedulesEndpoint}$_entityId/',
//       );
//       final headers = <String, String>{'Content-Type': 'application/json'};
//       if (ApiConfig.bearerToken != null && ApiConfig.bearerToken!.isNotEmpty) {
//         headers['Authorization'] = 'Bearer ${ApiConfig.bearerToken}';
//       }

//       final resp = await http.delete(uri, headers: headers);

//       if (resp.statusCode == 200 || resp.statusCode == 204) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Deleted successfully.')));
//         // 삭제 후: true 반환 (리스트/캘린더 갱신)
//         Navigator.pop(context, true);
//       } else {
//         String message = 'Failed to delete (status: ${resp.statusCode}).';
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
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Network error: $e')));
//     } finally {
//       if (mounted) setState(() => _deleting = false);
//     }
//   }

//   // ----------------- 닫기/삭제 확인 다이얼로그 -----------------
//   Future<bool> _confirmDiscardIfDirty() async {
//     if (!_isDirty) return true; // 변경 없음 → 바로 닫기 허용
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         content: const Text('Do you want to close without saving?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false), // No
//             child: const Text('No'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true), // Yes
//             child: const Text('Yes'),
//           ),
//         ],
//       ),
//     );
//     return result == true;
//   }

//   Future<void> _confirmDelete() async {
//     if (_entityId == null) return;
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         content: const Text('Are you sure you want to delete this content?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false), // No
//             child: const Text('No'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true), // Yes
//             child: const Text('Yes'),
//           ),
//         ],
//       ),
//     );
//     if (result == true) {
//       await _delete();
//     }
//   }

//   // ----------------- UI -----------------
//   @override
//   Widget build(BuildContext context) {
//     // 뒤로가기(제스처/시스템 back) 가로채기 → 변경 시 확인
//     return WillPopScope(
//       onWillPop: () async {
//         final ok = await _confirmDiscardIfDirty();
//         return ok;
//       },
//       child: Scaffold(
//         backgroundColor: const Color(0xFFFBFBFB),
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           backgroundColor: const Color(0xFFBFB69B),
//           title: const Text(
//             'Modify Schedule',
//             style: TextStyle(
//               fontFamily: 'Futura',
//               fontWeight: FontWeight.w500,
//               fontSize: 16,
//               color: Color(0xFFF9F2ED),
//             ),
//           ),
//           actions: [
//             // ★ 삭제 아이콘 (오른쪽 상단)
//             IconButton(
//               icon: _deleting
//                   ? const SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                   : const Icon(Icons.delete, color: Colors.white),
//               onPressed: _deleting ? null : _confirmDelete,
//               tooltip: 'Delete',
//             ),
//             // ★ 닫기(×) 아이콘
//             IconButton(
//               icon: const Icon(Icons.close, color: Colors.white),
//               onPressed: _saving || _deleting
//                   ? null
//                   : () async {
//                       final ok = await _confirmDiscardIfDirty();
//                       if (ok && mounted) Navigator.pop(context, false);
//                     },
//               tooltip: 'Close',
//             ),
//           ],
//         ),
//         body: _initialLoading
//             ? const Center(child: CircularProgressIndicator())
//             : AbsorbPointer(
//                 absorbing: _saving || _deleting, // 저장/삭제 중 입력 잠금
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 35.0),
//                   child: ListView(
//                     children: [
//                       const SizedBox(height: 30),

//                       // --------- Date (필수) ---------
//                       const _LabelText('Date'),
//                       _StyledInput(
//                         child: InkWell(
//                           onTap: _pickDate,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 14,
//                             ),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.event_note),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     _selectedDate == null
//                                         ? 'Select a date'
//                                         : _formatDate(_selectedDate!),
//                                     style: TextStyle(
//                                       color: _selectedDate == null
//                                           ? Colors.black45
//                                           : Colors.black87,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ),
//                                 const Icon(Icons.calendar_today, size: 18),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       if (_showErrors && !_isDateValid)
//                         const _ErrorText('Please select a date.'),

//                       const SizedBox(height: 25),

//                       // --------- Time + All-day 체크박스 ---------
//                       Row(
//                         children: [
//                           const _LabelText('Time'),
//                           const Spacer(),
//                           const Text('All-day'),
//                           Checkbox(
//                             value: _allDay,
//                             onChanged: (v) =>
//                                 setState(() => _allDay = v ?? false),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _StyledInput(
//                               child: InkWell(
//                                 onTap: _allDay
//                                     ? null
//                                     : () => _pickTime(isStart: true),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 14,
//                                   ),
//                                   child: Text(
//                                     _startTime == null
//                                         ? 'Start (optional)'
//                                         : _formatTime(_startTime!),
//                                     style: TextStyle(
//                                       color: _allDay
//                                           ? Colors.black26
//                                           : (_startTime == null
//                                                 ? Colors.black45
//                                                 : Colors.black87),
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 8),
//                             child: Text('ー'),
//                           ),
//                           Expanded(
//                             child: _StyledInput(
//                               child: InkWell(
//                                 onTap: _allDay
//                                     ? null
//                                     : () => _pickTime(isStart: false),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 14,
//                                   ),
//                                   child: Text(
//                                     _endTime == null
//                                         ? 'End (optional)'
//                                         : _formatTime(_endTime!),
//                                     style: TextStyle(
//                                       color: _allDay
//                                           ? Colors.black26
//                                           : (_endTime == null
//                                                 ? Colors.black45
//                                                 : Colors.black87),
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       if (_showErrors && !_isTimeRangeValid)
//                         const _ErrorText(
//                           'Start time must be before or equal to end time.',
//                         ),

//                       const SizedBox(height: 25),

//                       // --------- Plan detail (필수) ---------
//                       const _LabelText('Plan detail'),
//                       _StyledInput(
//                         height: 56,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 6),
//                           child: Autocomplete<String>(
//                             optionsBuilder: (TextEditingValue value) {
//                               final q = value.text.trim().toLowerCase();
//                               if (q.isEmpty) return _planOptions;
//                               return _planOptions.where(
//                                 (o) => o.toLowerCase().contains(q),
//                               );
//                             },
//                             onSelected: (selection) {
//                               _planCtrl.text = selection;
//                               setState(() {});
//                             },
//                             fieldViewBuilder:
//                                 (context, controller, focusNode, onSubmit) {
//                                   // ★ 내부 TextEditingController 와 동기화
//                                   controller.text = _planCtrl.text;
//                                   controller.addListener(() {
//                                     _planCtrl.value = controller.value;
//                                     setState(() {});
//                                   });
//                                   return TextField(
//                                     controller: controller,
//                                     focusNode: focusNode,
//                                     decoration: const InputDecoration(
//                                       border: InputBorder.none,
//                                       hintText: 'Search & select…',
//                                       contentPadding: EdgeInsets.symmetric(
//                                         horizontal: 8,
//                                         vertical: 14,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                             optionsViewBuilder: (context, onSelected, options) {
//                               return Align(
//                                 alignment: Alignment.topLeft,
//                                 child: Material(
//                                   elevation: 4,
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: ConstrainedBox(
//                                     constraints: const BoxConstraints(
//                                       maxHeight: 240,
//                                       minWidth: 280,
//                                     ),
//                                     child: ListView.builder(
//                                       padding: EdgeInsets.zero,
//                                       itemCount: options.length,
//                                       itemBuilder: (context, index) {
//                                         final opt = options.elementAt(index);
//                                         return ListTile(
//                                           title: Text(opt),
//                                           onTap: () => onSelected(opt),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                       if (_showErrors && !_isPlanValid)
//                         const _ErrorText('Please choose from the list.'),

//                       const SizedBox(height: 25),

//                       // --------- Description (선택) ---------
//                       const _LabelText('Description'),
//                       _StyledInput(
//                         height: 120,
//                         child: TextFormField(
//                           controller: _descCtrl,
//                           maxLines: 5,
//                           decoration: const InputDecoration(
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.all(10),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 50),

//                       // --------- Save 버튼 ---------
//                       ElevatedButton(
//                         onPressed: (_formValid && !_saving && !_deleting)
//                             ? _save
//                             : () => setState(() => _showErrors = true),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFBF634E),
//                           disabledBackgroundColor: const Color(
//                             0xFFBF634E,
//                           ).withOpacity(0.5),
//                           minimumSize: const Size(double.infinity, 60),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         child: _saving
//                             ? const SizedBox(
//                                 height: 22,
//                                 width: 22,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : const Text(
//                                 'Save',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                       ),
//                       const SizedBox(height: 30),
//                     ],
//                   ),
//                 ),
//               ),
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

// // modify_schedule.dart
import 'dart:convert'; // 사용하지 않더라도 원본과 동일한 import 유지 가능
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http; // ★ MOCK에서는 사용 안 함 (원본 유지해도 무방)

/// ★ 서버 설정 (add_schedule.dart 와 동일하게 유지) - MOCK에서도 그대로 둡니다.
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const String schedulesEndpoint = '/api/schedules/';
  static const String? bearerToken = null; // 'YOUR_JWT_TOKEN';
}

/// ★ 수정 화면: 기존 스케줄 편집/삭제 (MOCK 동작)
/// - scheduleId 또는 initialDate 중 하나로 로딩
class ModifyScheduleScreen extends StatefulWidget {
  final int? scheduleId; // 우선순위 1: 명시 ID 기반 로딩
  final DateTime? initialDate; // 우선순위 2: 날짜 기반 로딩 (YYYY-MM-DD 첫 1건)

  const ModifyScheduleScreen({super.key, this.scheduleId, this.initialDate});

  @override
  State<ModifyScheduleScreen> createState() => _ModifyScheduleScreenState();
}

class _ModifyScheduleScreenState extends State<ModifyScheduleScreen> {
  // ----------------- 상태 -----------------
  bool _initialLoading = true; // 최초 로딩 스피너
  bool _saving = false; // 저장 중 로딩
  bool _deleting = false; // 삭제 중 로딩
  bool _showErrors = false; // 검증 에러 표시

  // 폼 필드
  DateTime? _selectedDate; // 날짜 (필수)
  bool _allDay = false; // 하루종일
  TimeOfDay? _startTime; // 시작시간
  TimeOfDay? _endTime; // 종료시간
  final TextEditingController _planCtrl = TextEditingController(); // 계획 상세 (필수)
  final TextEditingController _descCtrl = TextEditingController(); // 설명 (선택)

  // 플랜 옵션 (add_schedule.dart 과 동일)
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

  // 백엔드에서 로딩한 엔티티의 식별자 (MOCK에서도 유지)
  int? _entityId; // PUT/DELETE 시 사용

  // 변경 감지를 위한 초기 스냅샷
  Map<String, dynamic>? _initialSnapshot;

  @override
  void initState() {
    super.initState();
    _loadSchedule(); // ★ MOCK: 네트워크 대신 가짜 데이터 로딩
  }

  @override
  void dispose() {
    _planCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ----------------- 공통 포맷터 -----------------
  String _formatDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _toIsoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ----------------- 검증 -----------------
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

  // ----------------- 변경 감지 -----------------
  Map<String, dynamic> _currentSnapshot() {
    String? startTimeStr;
    String? endTimeStr;
    if (!_allDay) {
      if (_startTime != null) {
        startTimeStr =
            '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
      }
      if (_endTime != null) {
        endTimeStr =
            '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';
      }
    }
    return {
      'date': _selectedDate != null ? _toIsoDate(_selectedDate!) : null,
      'all_day': _allDay,
      'start_time': startTimeStr,
      'end_time': endTimeStr,
      'plan_detail': _planCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
    };
  }

  bool get _isDirty {
    if (_initialSnapshot == null) return false;
    final now = _currentSnapshot();
    for (final k in _initialSnapshot!.keys) {
      if (_initialSnapshot![k] != now[k]) return true;
    }
    return false;
  }

  // ----------------- 데이터 로딩 (MOCK) -----------------
  Future<void> _loadSchedule() async {
    setState(() => _initialLoading = true);

    try {
      // ★ MOCK: 네트워크 지연 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 450));

      // ★ MOCK: 입력 조건에 따라 가짜 엔티티 생성
      final entity = _makeMockEntity(
        id: widget.scheduleId ?? 101,
        date: widget.initialDate ?? DateTime.now(),
      );

      // ★ 엔티티 -> 폼 상태 반영
      _applyEntityToForm(entity);

      // ★ 초기 스냅샷 저장
      _initialSnapshot = _currentSnapshot();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Load error (mock): $e')));
    } finally {
      if (mounted) setState(() => _initialLoading = false);
    }
  }

  Map<String, dynamic> _makeMockEntity({
    required int id,
    required DateTime date,
  }) {
    // ★ MOCK: 일정 ID/날짜에 따라 내용만 살짝 다르게
    final day = date.day;
    final samplePlans = [
      'Office Meeting',
      'Gym Workout',
      'Museum Visit',
      'Date Night',
      'Library Study',
      'Weekend Brunch',
      'Business Presentation',
    ];
    final pickedPlan = samplePlans[day % samplePlans.length];

    return {
      'id': id,
      'date': _toIsoDate(date),
      'all_day': day % 3 == 0, // 3일마다 하루종일
      'start_time': day % 3 == 0 ? null : '09:30',
      'end_time': day % 3 == 0 ? null : '11:00',
      'plan_detail': pickedPlan,
      'description': 'This is a mock schedule loaded for testing.',
    };
  }

  void _applyEntityToForm(Map<String, dynamic> entity) {
    _entityId = entity['id'] as int?;

    final dateStr = (entity['date'] ?? '') as String;
    if (dateStr.isNotEmpty) {
      final parts = dateStr
          .split('-')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      if (parts.length == 3) {
        _selectedDate = DateTime(parts[0], parts[1], parts[2]);
      }
    }

    _allDay = (entity['all_day'] ?? false) as bool;

    String? st = entity['start_time'] as String?;
    String? et = entity['end_time'] as String?;
    _startTime = (st == null || st.isEmpty) ? null : _parseTimeOfDay(st);
    _endTime = (et == null || et.isEmpty) ? null : _parseTimeOfDay(et);

    _planCtrl.text = (entity['plan_detail'] ?? '').toString();
    _descCtrl.text = (entity['description'] ?? '').toString();

    setState(() {});
  }

  TimeOfDay _parseTimeOfDay(String hhmm) {
    final sp = hhmm.split(':');
    final h = int.tryParse(sp[0]) ?? 0;
    final m = int.tryParse(sp.length > 1 ? sp[1] : '0') ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  // ----------------- 피커 -----------------
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
      helpText: 'Select date',
    );
    if (result != null) setState(() => _selectedDate = result);
  }

  Future<void> _pickTime({required bool isStart}) async {
    if (_allDay) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
      helpText: isStart ? 'Select start time' : 'Select end time',
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

  // ----------------- 서버 저장/삭제 (MOCK) -----------------
  Map<String, dynamic> _buildPayload() {
    String? startTimeStr;
    String? endTimeStr;
    if (!_allDay) {
      if (_startTime != null) {
        startTimeStr =
            '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
      }
      if (_endTime != null) {
        endTimeStr =
            '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';
      }
    }
    final dateStr = _selectedDate != null ? _toIsoDate(_selectedDate!) : null;

    return {
      'date': dateStr,
      'all_day': _allDay,
      'start_time': startTimeStr,
      'end_time': endTimeStr,
      'plan_detail': _planCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
    };
  }

  Future<void> _save() async {
    setState(() => _showErrors = true);
    if (!_formValid) return;
    if (_entityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No schedule ID to update.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      // ★ MOCK: 네트워크 지연 시뮬레이션 후 성공 처리
      await Future.delayed(const Duration(milliseconds: 600));

      // TODO: 본운영에서는 http.put(...) 으로 변경
      // final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.schedulesEndpoint}$_entityId/');
      // final headers = <String, String>{'Content-Type': 'application/json'};
      // if (ApiConfig.bearerToken != null && ApiConfig.bearerToken!.isNotEmpty) {
      //   headers['Authorization'] = 'Bearer ${ApiConfig.bearerToken}';
      // }
      // final resp = await http.put(uri, headers: headers, body: jsonEncode(_buildPayload()));

      _initialSnapshot = _currentSnapshot(); // 변경내용 커밋
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved successfully. (mock)')),
      );

      // ★ 캘린더 갱신 트리거
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save error (mock): $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (_entityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No schedule ID to delete.')),
      );
      return;
    }
    setState(() => _deleting = true);

    try {
      // ★ MOCK: 네트워크 지연 시뮬레이션 후 성공 처리
      await Future.delayed(const Duration(milliseconds: 600));

      // TODO: 본운영에서는 http.delete(...) 으로 변경
      // final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.schedulesEndpoint}$_entityId/');
      // final headers = <String, String>{'Content-Type': 'application/json'};
      // if (ApiConfig.bearerToken != null && ApiConfig.bearerToken!.isNotEmpty) {
      //   headers['Authorization'] = 'Bearer ${ApiConfig.bearerToken}';
      // }
      // final resp = await http.delete(uri, headers: headers);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted successfully. (mock)')),
      );

      // ★ 삭제 후: true 반환 (리스트/캘린더 갱신)
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete error (mock): $e')));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  // ----------------- 닫기/삭제 확인 다이얼로그 -----------------
  Future<bool> _confirmDiscardIfDirty() async {
    if (!_isDirty) return true; // 변경 없음 → 바로 닫기 허용
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('Do you want to close without saving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // No
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), // Yes
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _confirmDelete() async {
    if (_entityId == null) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('Are you sure you want to delete this content?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // No
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), // Yes
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (result == true) {
      await _delete();
    }
  }

  // ----------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    // 뒤로가기(제스처/시스템 back) 가로채기 → 변경 시 확인
    return WillPopScope(
      onWillPop: () async {
        final ok = await _confirmDiscardIfDirty();
        return ok;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFB),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFBFB69B),
          title: const Text(
            'Modify Schedule',
            style: TextStyle(
              fontFamily: 'Futura',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xFFF9F2ED),
            ),
          ),
          actions: [
            // ★ 삭제 아이콘 (오른쪽 상단)
            IconButton(
              icon: _deleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleting ? null : _confirmDelete,
              tooltip: 'Delete',
            ),
            // ★ 닫기(×) 아이콘
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _saving || _deleting
                  ? null
                  : () async {
                      final ok = await _confirmDiscardIfDirty();
                      if (ok && mounted) Navigator.pop(context, false);
                    },
              tooltip: 'Close',
            ),
          ],
        ),
        body: _initialLoading
            ? const Center(child: CircularProgressIndicator())
            : AbsorbPointer(
                absorbing: _saving || _deleting, // 저장/삭제 중 입력 잠금
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35.0),
                  child: ListView(
                    children: [
                      const SizedBox(height: 30),

                      // --------- Date (필수) ---------
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
                                    _selectedDate == null
                                        ? 'Select a date'
                                        : _formatDate(_selectedDate!),
                                    style: TextStyle(
                                      color: _selectedDate == null
                                          ? Colors.black45
                                          : Colors.black87,
                                      fontSize: 16,
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

                      // --------- Time + All-day 체크박스 ---------
                      Row(
                        children: [
                          const _LabelText('Time'),
                          const Spacer(),
                          const Text('All-day'),
                          Checkbox(
                            value: _allDay,
                            onChanged: (v) =>
                                setState(() => _allDay = v ?? false),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _StyledInput(
                              child: InkWell(
                                onTap: _allDay
                                    ? null
                                    : () => _pickTime(isStart: true),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  child: Text(
                                    _startTime == null
                                        ? 'Start (optional)'
                                        : _formatTime(_startTime!),
                                    style: TextStyle(
                                      color: _allDay
                                          ? Colors.black26
                                          : (_startTime == null
                                                ? Colors.black45
                                                : Colors.black87),
                                      fontSize: 16,
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
                                onTap: _allDay
                                    ? null
                                    : () => _pickTime(isStart: false),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  child: Text(
                                    _endTime == null
                                        ? 'End (optional)'
                                        : _formatTime(_endTime!),
                                    style: TextStyle(
                                      color: _allDay
                                          ? Colors.black26
                                          : (_endTime == null
                                                ? Colors.black45
                                                : Colors.black87),
                                      fontSize: 16,
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

                      // --------- Plan detail (필수) ---------
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
                            fieldViewBuilder:
                                (context, controller, focusNode, onSubmit) {
                                  // ★ 내부 TextEditingController 와 동기화
                                  controller.text = _planCtrl.text;
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
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 14,
                                      ),
                                    ),
                                  );
                                },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(8),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 240,
                                      minWidth: 280,
                                    ),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final opt = options.elementAt(index);
                                        return ListTile(
                                          title: Text(opt),
                                          onTap: () => onSelected(opt),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (_showErrors && !_isPlanValid)
                        const _ErrorText('Please choose from the list.'),

                      const SizedBox(height: 25),

                      // --------- Description (선택) ---------
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

                      // --------- Save 버튼 ---------
                      ElevatedButton(
                        onPressed: (_formValid && !_saving && !_deleting)
                            ? _save
                            : () => setState(() => _showErrors = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBF634E),
                          disabledBackgroundColor: const Color(
                            0xFFBF634E,
                          ).withOpacity(0.5),
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

//------------------- 커스텀 라벨 -------------------
class _LabelText extends StatelessWidget {
  final String label;
  const _LabelText(this.label);
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Futura',
        fontWeight: FontWeight.w500,
        fontSize: 20,
        color: Color(0xFF0D0D0D),
      ),
    );
  }
}

//------------------- 에러 텍스트 -------------------
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

//------------------- 스타일 박스 -------------------
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
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFF707070)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
