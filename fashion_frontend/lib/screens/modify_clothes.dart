import 'package:flutter/material.dart';

class ModifyClothesScreen extends StatefulWidget {
  const ModifyClothesScreen({Key? key}) : super(key: key);

  @override
  State<ModifyClothesScreen> createState() => _ModifyClothesScreenState();
}

class _ModifyClothesScreenState extends State<ModifyClothesScreen> {
  // ####### 날짜 및 입력 필드 #######
  String lastUsed = '--/--/--';
  String purchaseDate = '--/--/--';
  int timesUsed = 0;

  // ####### 기본 옷 정보 (수정용) #######
  String gender = 'Men';
  String masterCategory = 'Apparel';
  String subCategory = 'Topwear';
  String articleType = 'Jackets';
  String baseColor = 'Black';
  String season = 'Spring, Fall';
  String usage = 'Formal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFB69B),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            // ####### 저장 없이 닫기 확인 #######
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Close without saving?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context), // Stay
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Back
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ),
            );
          },
        ),
        title: const Text(
          'Item Detail',
          style: TextStyle(fontFamily: 'Futura', color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              // ####### 삭제 확인 #######
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Are you sure you want to delete?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Stay
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Back
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ####### 옷 이미지 #######
            Center(
              child: Image.asset(
                'assets/images/jacket.jpeg',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 16),

            // ####### 날짜 및 사용횟수 #######
            _infoRow('LAST USED', lastUsed),
            _infoRow('TIMES USED', '$timesUsed'),
            _infoRow('PURCHASE DATE', purchaseDate),
            const SizedBox(height: 16),

            const Divider(),
            const Text(
              'Basic Information (required)',
              style: TextStyle(
                fontFamily: 'Futura',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // ####### 카테고리 정보 #######
            _infoRow('Gender', gender),
            _infoRow('Master Category', masterCategory),
            _infoRow('Sub Category', subCategory),
            _infoRow('Article Type', articleType),
            _infoRow('Base Color', baseColor),
            _infoRow('Season', season),
            _infoRow('Usage', usage),
            const SizedBox(height: 32),

            // ####### 저장 버튼 #######
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 실제 저장은 아직 없음
                  Navigator.pop(context); // 저장 후 Wardrobe로 이동
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBF634E),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontFamily: 'Futura',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ####### 정보 출력용 위젯 #######
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(title)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
