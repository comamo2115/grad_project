import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddClothesScreen extends StatefulWidget {
  const AddClothesScreen({Key? key}) : super(key: key);

  @override
  State<AddClothesScreen> createState() => _AddClothesScreenState();
}

class _AddClothesScreenState extends State<AddClothesScreen> {
  // ####### 상태 관리 변수들 #######
  DateTime? lastUsedDate;
  DateTime? purchaseDate;
  final TextEditingController timesUsedController = TextEditingController();

  // ####### 날짜 선택 함수 #######
  Future<void> _selectDate(BuildContext context, bool isLastUsed) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isLastUsed) {
          lastUsedDate = picked;
        } else {
          purchaseDate = picked;
        }
      });
    }
  }

  // ####### 저장 버튼 동작 (임시 출력) #######
  void _saveClothing() {
    // TODO: 저장 API 호출 예정
    print('Saved!');
    Navigator.pop(context); // 저장 후 이전 페이지로 이동
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: Column(
        children: [
          // ####### 상단 바 영역 #######
          Container(
            color: const Color(0xFFBFB69B),
            padding: const EdgeInsets.only(
              top: 50,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 닫기 버튼
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text(
                          'Do you want to close without saving?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.popUntil(
                              context,
                              ModalRoute.withName('/wardrobe'),
                            ), // Yes
                            child: const Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context), // No
                            child: const Text('No'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                const Text(
                  'Add Item',
                  style: TextStyle(
                    color: Color(0xFFF9F2ED),
                    fontFamily: 'Futura',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 24), // 공간 확보용
              ],
            ),
          ),

          // ####### 이미지 + 날짜/횟수 영역 #######
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE3E3E3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // 카메라 아이콘
                const Icon(Icons.camera_alt, color: Colors.grey),

                const SizedBox(height: 16),
                _buildDateRow(
                  'LAST USED',
                  lastUsedDate,
                  () => _selectDate(context, true),
                ),
                _buildTextFieldRow('TIMES USED', timesUsedController),
                _buildDateRow(
                  'PURCHASE DATE',
                  purchaseDate,
                  () => _selectDate(context, false),
                ),
              ],
            ),
          ),

          // ####### 기본 정보 영역 타이틀 #######
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: const Color(0xFFBF9B9B),
            child: const Text(
              'Basic Information (required)',
              style: TextStyle(
                color: Color(0xFFF9F2ED),
                fontFamily: 'Futura',
                fontSize: 16,
              ),
            ),
          ),

          // ####### 입력 필드 (아직 선택 기능 없음) #######
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                _InfoRow(label: 'Gender'),
                _InfoRow(label: 'Master Category'),
                _InfoRow(label: 'Sub Category'),
                _InfoRow(label: 'Article Type'),
                _InfoRow(label: 'Base Color'),
                _InfoRow(label: 'Season'),
                _InfoRow(label: 'Usage'),
              ],
            ),
          ),

          // ####### 저장 버튼 #######
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBF634E),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _saveClothing,
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ####### 날짜 입력 행 빌더 #######
  Widget _buildDateRow(String label, DateTime? date, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontFamily: 'Futura')),
        TextButton(
          onPressed: onTap,
          child: Text(
            date != null ? DateFormat('yyyy/MM/dd').format(date) : '—/—/—',
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  // ####### 숫자 입력 행 빌더 #######
  Widget _buildTextFieldRow(String label, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontFamily: 'Futura')),
        SizedBox(
          width: 60,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            ),
          ),
        ),
      ],
    );
  }
}

// ####### 선택 항목 표시용 위젯 (기능은 미구현) #######
class _InfoRow extends StatelessWidget {
  final String label;
  const _InfoRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, color: Colors.black12),
        Container(
          height: 48,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontFamily: 'Futura'),
          ),
        ),
      ],
    );
  }
}
