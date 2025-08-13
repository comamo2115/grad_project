import 'package:flutter/material.dart';
import 'package:fashion_frontend/screens/add_clothes.dart';
import 'package:fashion_frontend/screens/modify_clothes.dart';

class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ####### 데모용 옷 리스트 #######
    final List<Map<String, dynamic>> clothes = [
      {
        'image': 'assets/images/jacket.jpeg',
        'title': 'Black Jacket',
        'category': 'Topwear',
      },
      {
        'image': 'assets/images/tshirt.jpeg',
        'title': 'White T-shirt',
        'category': 'Topwear',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Closet',
          style: TextStyle(fontFamily: 'Futura', color: Colors.white),
        ),
        backgroundColor: const Color(0xFFBFB69B),
        actions: [
          // ####### 옷 추가 버튼 #######
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddClothesScreen()),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFBFBFB),
      body: ListView.builder(
        itemCount: clothes.length,
        itemBuilder: (context, index) {
          final item = clothes[index];
          return GestureDetector(
            onTap: () {
              // ####### 옷 클릭 시 수정 화면으로 이동 #######
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ModifyClothesScreen()),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              child: ListTile(
                leading: Image.asset(item['image'], width: 50, height: 50),
                title: Text(
                  item['title'],
                  style: const TextStyle(fontFamily: 'Futura'),
                ),
                subtitle: Text(item['category']),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
