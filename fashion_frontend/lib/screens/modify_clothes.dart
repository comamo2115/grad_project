// modify_clothes.dart
// ★ 주석은 한국어로 작성했습니다.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // ★ 카메라/갤러리 픽커

class ModifyClothesScreen extends StatefulWidget {
  const ModifyClothesScreen({Key? key}) : super(key: key);

  @override
  State<ModifyClothesScreen> createState() => _ModifyClothesScreenState();
}

class _ModifyClothesScreenState extends State<ModifyClothesScreen> {
  // ---------------- 날짜/숫자 상태 ----------------
  DateTime? lastUsedDate;
  DateTime? purchaseDate;
  final TextEditingController timesUsedController = TextEditingController();

  // ---------------- 이미지 상태 ----------------
  File? _imageFile; // ★ 촬영/변경한 이미지 파일 (수정용)
  final ImagePicker _picker = ImagePicker();
  String? _initialImagePath; // ★ 초기 이미지 경로(assets 등). 전달 없으면 null

  // ---------------- 선택 항목(필수 포함) ----------------
  String? gender; // ★ 필수
  String? masterCategory; // ★ 필수
  String? subCategory; // ★ 필수 (검색 가능)
  String? articleType; // ★ 선택 자유 (검색 가능)
  String? baseColor; // ★ 필수
  final Set<String> seasons = {}; // ★ 필수(복수 선택 가능)
  String? usage; // ★ 필수

  // ---------------- 선택지 상수( add_clothes.dart 과 동일 ) ----------------
  static const List<String> genders = [
    'Men',
    'Women',
    'Boys',
    'Girls',
    'Unisex',
  ];

  static const List<String> masterCategories = [
    'Accessories',
    'Apparel',
    'Footwear',
    'Free Items',
    'Home',
    'Personal Care',
    'Sporting Goods',
  ];

  static const List<String> subCategories = [
    'Accessories',
    'Apparel Set',
    'Bags',
    'Bath and Body',
    'Beauty Accessories',
    'Belts',
    'Bottomwear',
    'Cufflinks',
    'Dress',
    'Eyes',
    'Eyewear',
    'Flip Flops',
    'Fragrance',
    'Free Gifts',
    'Gloves',
    'Hair',
    'Headwear',
    'Home Furnishing',
    'Innerwear',
    'Jewellery',
    'Lips',
    'Loungewear and Nightwear',
    'Makeup',
    'Mufflers',
    'Nails',
    'Perfumes',
    'Sandal',
    'Saree',
    'Scarves',
    'Shoe Accessories',
    'Shoes',
    'Skin',
    'Skin Care',
    'Socks',
    'Sports Accessories',
    'Sports Equipment',
    'Stoles',
    'Ties',
    'Topwear',
    'Umbrellas',
    'Vouchers',
    'Wallets',
    'Watches',
    'Water Bottle',
    'Wristbands',
  ];

  static const List<String> articleTypes = [
    'Accessory Gift Set',
    'Baby Dolls',
    'Backpacks',
    'Bangle',
    'Basketballs',
    'Bath Robe',
    'Beauty Accessory',
    'Belts',
    'Blazers',
    'Body Lotion',
    'Body Wash and Scrub',
    'Booties',
    'Boxers',
    'Bra',
    'Bracelet',
    'Briefs',
    'Camisoles',
    'Capris',
    'Caps',
    'Casual Shoes',
    'Churidar',
    'Clothing Set',
    'Clutches',
    'Compact',
    'Concealer',
    'Cufflinks',
    'Cushion Covers',
    'Deodorant',
    'Dresses',
    'Duffel Bag',
    'Dupatta',
    'Earrings',
    'Eye Cream',
    'Eyeshadow',
    'Face Moisturisers',
    'Face Scrub and Exfoliator',
    'Face Serum and Gel',
    'Face Wash and Cleanser',
    'Flats',
    'Flip Flops',
    'Footballs',
    'Formal Shoes',
    'Foundation and Primer',
    'Fragrance Gift Set',
    'Free Gifts',
    'Gloves',
    'Hair Accessory',
    'Hair Colour',
    'Handbags',
    'Hat',
    'Headband',
    'Heels',
    'Highlighter and Blush',
    'Innerwear Vests',
    'Ipad',
    'Jackets',
    'Jeans',
    'Jeggings',
    'Jewellery Set',
    'Jumpsuit',
    'Kajal and Eyeliner',
    'Key chain',
    'Kurta Sets',
    'Kurtas',
    'Kurtis',
    'Laptop Bag',
    'Leggings',
    'Lehenga Choli',
    'Lip Care',
    'Lip Gloss',
    'Lip Liner',
    'Lip Plumper',
    'Lipstick',
    'Lounge Pants',
    'Lounge Shorts',
    'Lounge Tshirts',
    'Makeup Remover',
    'Mascara',
    'Mask and Peel',
    'Mens Grooming Kit',
    'Messenger Bag',
    'Mobile Pouch',
    'Mufflers',
    'Nail Essentials',
    'Nail Polish',
    'Necklace and Chains',
    'Nehru Jackets',
    'Night suits',
    'Nightdress',
    'Patiala',
    'Pendant',
    'Perfume and Body Mist',
    'Rain Jacket',
    'Rain Trousers',
    'Ring',
    'Robe',
    'Rompers',
    'Rucksacks',
    'Salwar',
    'Salwar and Dupatta',
    'Sandals',
    'Sarees',
    'Scarves',
    'Shapewear',
    'Shirts',
    'Shoe Accessories',
    'Shoe Laces',
    'Shorts',
    'Shrug',
    'Skirts',
    'Socks',
    'Sports Sandals',
    'Sports Shoes',
    'Stockings',
    'Stoles',
    'Suits',
    'Sunglasses',
    'Sunscreen',
    'Suspenders',
    'Sweaters',
    'Sweatshirts',
    'Swimwear',
    'Tablet Sleeve',
    'Ties',
    'Ties and Cufflinks',
    'Tights',
    'Toner',
    'Tops',
    'Track Pants',
    'Tracksuits',
    'Travel Accessory',
    'Trolley Bag',
    'Trousers',
    'Trunk',
    'Tshirts',
    'Tunics',
    'Umbrellas',
    'Waist Pouch',
    'Waistcoat',
    'Wallets',
    'Watches',
    'Water Bottle',
    'Wristbands',
  ];

  static const List<String> baseColors = [
    'Beige',
    'Black',
    'Blue',
    'Bronze',
    'Brown',
    'Burgundy',
    'Charcoal',
    'Coffee Brown',
    'Copper',
    'Cream',
    'Fluorescent Green',
    'Gold',
    'Green',
    'Grey',
    'Grey Melange',
    'Khaki',
    'Lavender',
    'Lime Green',
    'Magenta',
    'Maroon',
    'Mauve',
    'Metallic',
    'Multi',
    'Mushroom Brown',
    'Mustard',
    'Navy Blue',
    'Nude',
    'Off White',
    'Olive',
    'Orange',
    'Peach',
    'Pink',
    'Purple',
    'Red',
    'Rose',
    'Rust',
    'Sea Green',
    'Silver',
    'Skin',
    'Steel',
    'Tan',
    'Taupe',
    'Teal',
    'Turquoise Blue',
    'White',
    'Yellow',
  ];

  static const List<String> seasonOptions = [
    'Spring',
    'Summer',
    'Fall',
    'Winter',
  ];

  static const List<String> usages = [
    'Casual',
    'Ethnic',
    'Formal',
    'Home',
    'Party',
    'Smart Casual',
    'Sports',
    'Travel',
  ];

  // ---------------- 유효성 체크(저장 버튼 활성 제어) ----------------
  bool get _isValidRequired =>
      (gender != null && gender!.isNotEmpty) &&
      (masterCategory != null && masterCategory!.isNotEmpty) &&
      (subCategory != null && subCategory!.isNotEmpty) &&
      (baseColor != null && baseColor!.isNotEmpty) &&
      seasons.isNotEmpty &&
      (usage != null && usage!.isNotEmpty);

  // ---------------- 변경 여부(닫기 확인용) ----------------
  late Map<String, dynamic> _initialSnapshot;

  Map<String, dynamic> _currentSnapshot() => {
    'imageSet': _imageFile != null || (_initialImagePath != null),
    'lastUsed': lastUsedDate?.toIso8601String(),
    'purchase': purchaseDate?.toIso8601String(),
    'times': timesUsedController.text.trim(),
    'gender': gender,
    'master': masterCategory,
    'sub': subCategory,
    'article': articleType,
    'baseColor': baseColor,
    'seasons': seasons.toList()..sort(),
    'usage': usage,
  };

  bool get _isDirty {
    final now = _currentSnapshot();
    final old = _initialSnapshot;
    if (now.length != old.length) return true;
    for (final k in now.keys) {
      if ('$now[k]' != '${old[k]}') return true;
    }
    return false;
  }

  // ---------------- 초기값 로딩 ----------------
  @override
  void initState() {
    super.initState();

    // ★ 라우트 arguments 로 초기값을 받는 경우 지원
    //   예) Navigator.pushNamed(context, '/modify', arguments: {...})
    //   이 화면의 build 시점에서 ModalRoute 접근해야 하므로
    //   addPostFrameCallback 으로 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;

      // ---- 데모 기본값 (args 없을 때) ----
      _initialImagePath = args?['imagePath'] as String?; // assets 경로 가능
      final initialGender = args?['gender'] as String? ?? 'Men';
      final initialMaster = args?['masterCategory'] as String? ?? 'Apparel';
      final initialSub = args?['subCategory'] as String? ?? 'Topwear';
      final initialArticle = args?['articleType'] as String? ?? 'Jackets';
      final initialBaseColor = args?['baseColor'] as String? ?? 'Black';
      final initialUsage = args?['usage'] as String? ?? 'Formal';
      final initialSeasons =
          (args?['seasons'] as List?)?.cast<String>() ??
          <String>['Spring', 'Fall'];
      final initialTimes = (args?['timesUsed']?.toString()) ?? '0';

      final lastUsedStr = args?['lastUsed'] as String?;
      final purchaseStr = args?['purchaseDate'] as String?;
      lastUsedDate = lastUsedStr != null
          ? DateTime.tryParse(lastUsedStr)
          : null;
      purchaseDate = purchaseStr != null
          ? DateTime.tryParse(purchaseStr)
          : null;

      timesUsedController.text = initialTimes;
      gender = initialGender;
      masterCategory = initialMaster;
      subCategory = initialSub;
      articleType = initialArticle;
      baseColor = initialBaseColor;
      usage = initialUsage;
      seasons
        ..clear()
        ..addAll(initialSeasons);

      // ★ 초기 스냅샷 저장
      _initialSnapshot = _currentSnapshot();

      setState(() {});
    });
  }

  @override
  void dispose() {
    timesUsedController.dispose();
    super.dispose();
  }

  // ---------------- 날짜 선택 ----------------
  Future<void> _selectDate(BuildContext context, bool isLastUsed) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isLastUsed ? lastUsedDate : purchaseDate) ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2035),
      helpText: isLastUsed ? 'Select last used date' : 'Select purchase date',
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

  // ---------------- 카메라 촬영/이미지 변경 ----------------
  Future<void> _pickFromCamera() async {
    try {
      final XFile? shot = await _picker.pickImage(source: ImageSource.camera);
      if (shot != null) {
        setState(() {
          _imageFile = File(shot.path);
          _initialImagePath = null; // 새로 찍으면 초기(assets) 이미지는 무시
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera error: $e')));
    }
  }

  // ---------------- 저장(모크) ----------------
  void _saveClothing() {
    if (!_isValidRequired) return;
    // TODO: API 연동 시 서버로 PUT/PATCH 호출
    // 성공 후 pop(true)로 상위 목록 갱신 트리거 가능
    Navigator.pop(context, true);
  }

  // ---------------- 삭제 확인(모크) ----------------
  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
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
    if (ok == true && mounted) {
      // TODO: API 연동 시 DELETE 호출
      Navigator.pop(context, true); // 목록으로 복귀
    }
  }

  // ---------------- 닫기 확인 ----------------
  Future<void> _tryClose() async {
    if (!_isDirty) {
      if (mounted) Navigator.pop(context, false);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('Do you want to close without saving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // No → 닫지 않음
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), // Yes → 닫기
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ★ 하드웨어 뒤로가기 시에도 닫기 확인
      onWillPop: () async {
        await _tryClose();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFBFB69B),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _tryClose,
            tooltip: 'Close',
          ),
          title: const Text(
            'Item Detail',
            style: TextStyle(fontFamily: 'Futura', color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _confirmDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---------- 이미지 프리뷰 ----------
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE3E3E3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.6,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE3E3E3)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Builder(
                            builder: (_) {
                              if (_imageFile != null) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              } else if (_initialImagePath != null) {
                                // ★ 초기 assets 이미지가 있는 경우 표시
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    _initialImagePath!,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                              return const Center(
                                child: Icon(
                                  Icons.checkroom,
                                  size: 36,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: SizedBox(
                          width: 200,
                          height: 42,
                          child: ElevatedButton.icon(
                            onPressed: _pickFromCamera,
                            icon: const Icon(Icons.camera_alt),
                            label: Text(
                              (_imageFile == null && _initialImagePath == null)
                                  ? 'Add Photo'
                                  : 'Change Photo',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBF634E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDateRow(
                        'LAST USED',
                        lastUsedDate,
                        () => _selectDate(context, true),
                      ),
                      _buildTimesRow(),
                      _buildDateRow(
                        'PURCHASE DATE',
                        purchaseDate,
                        () => _selectDate(context, false),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ---------- 기본 정보 타이틀 ----------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
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

                // ---------- 입력/선택 필드 ----------
                ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _DropdownRow(
                      label: 'Gender',
                      value: gender,
                      items: genders,
                      onChanged: (v) => setState(() => gender = v),
                    ),
                    _DropdownRow(
                      label: 'Master Category',
                      value: masterCategory,
                      items: masterCategories,
                      onChanged: (v) => setState(() => masterCategory = v),
                    ),
                    _SearchableRow(
                      label: 'Sub Category',
                      value: subCategory,
                      options: subCategories,
                      hintText: 'Search sub category…',
                      onChanged: (v) => setState(() => subCategory = v),
                    ),
                    _SearchableRow(
                      label: 'Article Type',
                      value: articleType,
                      options: articleTypes,
                      hintText: 'Search article type…',
                      onChanged: (v) => setState(() => articleType = v),
                    ),
                    _DropdownRow(
                      label: 'Base Color',
                      value: baseColor,
                      items: baseColors,
                      onChanged: (v) => setState(() => baseColor = v),
                    ),
                    const SizedBox(height: 8),
                    const _Label('Season'),
                    Wrap(
                      spacing: 8,
                      children: seasonOptions.map((s) {
                        final selected = seasons.contains(s);
                        return FilterChip(
                          label: Text(s),
                          selected: selected,
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                seasons.add(s);
                              } else {
                                seasons.remove(s);
                              }
                            });
                          },
                          selectedColor: const Color(
                            0xFFBF634E,
                          ).withOpacity(0.15),
                          checkmarkColor: const Color(0xFFBF634E),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    _DropdownRow(
                      label: 'Usage',
                      value: usage,
                      items: usages,
                      onChanged: (v) => setState(() => usage = v),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

                // ---------- 저장 버튼 ----------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: ElevatedButton(
                    onPressed: _isValidRequired ? _saveClothing : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBF634E),
                      disabledBackgroundColor: const Color(
                        0xFFBF634E,
                      ).withOpacity(0.4),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
          ),
        ),
      ),
    );
  }

  // ---------------- 공통: 날짜 행 ----------------
  Widget _buildDateRow(String label, DateTime? date, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Label(label),
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

  // ---------------- 공통: TIMES USED 행 ----------------
  Widget _buildTimesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _Label('TIMES USED'),
        SizedBox(
          width: 80,
          child: TextField(
            controller: timesUsedController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }
}

// ---------------- 라벨 공통 위젯 ----------------
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontFamily: 'Futura'),
    );
  }
}

// ---------------- 드롭다운 행(일반 선택) ----------------
class _DropdownRow extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, color: Colors.black12),
        SizedBox(
          height: 54,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Label(label),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  value: value,
                  items: items
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Futura'),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onChanged,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------- 검색 가능한 선택 행(Autocomplete) ----------------
class _SearchableRow extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchableRow({
    required this.label,
    required this.value,
    required this.options,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value ?? '');
    return Column(
      children: [
        const Divider(height: 1, color: Colors.black12),
        SizedBox(
          height: 58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Label(label),
              SizedBox(
                width: 220,
                child: Autocomplete<String>(
                  initialValue: TextEditingValue(text: value ?? ''),
                  optionsBuilder: (TextEditingValue textValue) {
                    final q = textValue.text.trim().toLowerCase();
                    if (q.isEmpty) return options;
                    return options.where((o) => o.toLowerCase().contains(q));
                  },
                  onSelected: (sel) => onChanged(sel),
                  fieldViewBuilder:
                      (context, textCtrl, focusNode, onFieldSubmitted) {
                        textCtrl.text = controller.text;
                        textCtrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: textCtrl.text.length),
                        );
                        return TextField(
                          controller: textCtrl,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: hintText,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 10,
                            ),
                          ),
                          onSubmitted: (v) {
                            if (options.contains(v)) onChanged(v);
                          },
                        );
                      },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
