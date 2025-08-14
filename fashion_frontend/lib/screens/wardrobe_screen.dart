// wardrobe_screen.dart
// ★ 주석은 한국어로 작성했습니다.
import 'package:flutter/material.dart';
import 'package:fashion_frontend/screens/add_clothes.dart';
import 'package:fashion_frontend/screens/modify_clothes.dart';

/// ★ 카테고리 상수 (탭 순서 고정)
const List<String> _categories = <String>[
  'ALL',
  'TOPS',
  'BOTTOMS',
  'OUTER',
  'SHOES',
  'ACCESSORIES',
  'BAGS',
  'OTHER',
];

/// ★ 색상(앱 전체 톤에 맞춤)
//  - AppBar 배경: primary
//  - 포커스/액션: secondary
//  - 텍스트/테두리: 중립 계열
const Color _primary = Color(0xFFBFB69B);
const Color _secondary = Color(0xFFBF634E);
const Color _border = Color(0xFFE3E3E3);
const Color _bg = Color(0xFFFBFBFB);

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({Key? key}) : super(key: key);

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  // ---------------- 데모용 아이템 ----------------
  // ★ 실제로는 서버/DB에서 받아온 리스트로 대체
  final List<Map<String, String>> _items = [
    {
      'image': 'assets/images/jacket.jpeg',
      'title': 'Black Jacket',
      'category': 'OUTER',
    },
    {
      'image': 'assets/images/tshirt.jpeg',
      'title': 'Black T-shirt',
      'category': 'TOPS',
    },
    {
      'image': 'assets/images/dress.jpeg',
      'title': 'Beige Dress',
      'category': 'OTHER',
    },
    {
      'image': 'assets/images/jacket.jpeg',
      'title': 'Brown Jacket',
      'category': 'OUTER',
    },
  ];

  // ---------------- 필터링 함수 ----------------
  List<Map<String, String>> _filterByCategory(String cat) {
    if (cat == 'ALL') return _items;
    return _items.where((e) => (e['category'] ?? '') == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ★ 상단 탭/컨텐츠 동기화를 위해 DefaultTabController 사용
    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _primary,
          title: const Text(
            'My Closet',
            style: TextStyle(
              fontFamily: 'Futura',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            // ★ 우상단 + 버튼: 옷 등록 화면으로 이동
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddClothesScreen()),
                );
              },
              tooltip: 'Add',
            ),
          ],
          // ★ 가로 스크롤 가능한 탭바
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.8),
            labelStyle: const TextStyle(fontFamily: 'Futura', fontSize: 13),
            indicatorColor: Colors.white,
            indicatorWeight: 2.4,
            tabs: _categories.map((c) => Tab(text: c)).toList(),
          ),
        ),
        // ★ 탭별 컨텐츠
        body: TabBarView(
          children: _categories.map((cat) {
            final data = _filterByCategory(cat);
            return _GridSection(
              items: data,
              onTapItem: (item) {
                // ★ 이미지 탭: 수정 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ModifyClothesScreen(),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// ---------------- 그리드 섹션 위젯 ----------------
/// - 3열 그리드
/// - 이미지 + 간단한 타이틀
class _GridSection extends StatelessWidget {
  final List<Map<String, String>> items;
  final void Function(Map<String, String> item) onTapItem;

  const _GridSection({required this.items, required this.onTapItem});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      // ★ 빈 상태 표시
      return const Center(
        child: Text(
          'No items yet',
          style: TextStyle(fontFamily: 'Futura', color: Color(0xFF707070)),
        ),
      );
    }

    // ★ 3열 그리드: 간격/비율 조정
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // ★ 3열
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8, // ★ 카드 비율(이미지+텍스트)
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _ClosetCard(
          imagePath: item['image'] ?? '',
          title: item['title'] ?? '',
          onTap: () => onTapItem(item),
        );
      },
    );
  }
}

/// ---------------- 단일 카드 ----------------
class _ClosetCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const _ClosetCard({
    required this.imagePath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // ★ 카드 탭 시 수정 화면으로 이동
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // ★ 상단 이미지(정사각에 가깝게)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: Color(0xFFEFEFEF),
                    child: Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
              ),
            ),
            // ★ 하단 타이틀
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 12,
                  color: Color(0xFF0D0D0D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:fashion_frontend/screens/add_clothes.dart';
// import 'package:fashion_frontend/screens/modify_clothes.dart';

// class WardrobeScreen extends StatelessWidget {
//   const WardrobeScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // ####### 데모용 옷 리스트 #######
//     final List<Map<String, dynamic>> clothes = [
//       {
//         'image': 'assets/images/jacket.jpeg',
//         'title': 'Black Jacket',
//         'category': 'Topwear',
//       },
//       {
//         'image': 'assets/images/tshirt.jpeg',
//         'title': 'White T-shirt',
//         'category': 'Topwear',
//       },
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'My Closet',
//           style: TextStyle(fontFamily: 'Futura', color: Colors.white),
//         ),
//         backgroundColor: const Color(0xFFBFB69B),
//         actions: [
//           // ####### 옷 추가 버튼 #######
//           IconButton(
//             icon: const Icon(Icons.add, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const AddClothesScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       backgroundColor: const Color(0xFFFBFBFB),
//       body: ListView.builder(
//         itemCount: clothes.length,
//         itemBuilder: (context, index) {
//           final item = clothes[index];
//           return GestureDetector(
//             onTap: () {
//               // ####### 옷 클릭 시 수정 화면으로 이동 #######
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const ModifyClothesScreen()),
//               );
//             },
//             child: Card(
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               elevation: 2,
//               child: ListTile(
//                 leading: Image.asset(item['image'], width: 50, height: 50),
//                 title: Text(
//                   item['title'],
//                   style: const TextStyle(fontFamily: 'Futura'),
//                 ),
//                 subtitle: Text(item['category']),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
