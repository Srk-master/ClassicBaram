import 'package:flutter/material.dart';
import '../widgets/db_helper.dart';
import '../services/ShowItemDetail.dart';

class ItemListScreen extends StatefulWidget {
  final String category; //아이템 종류 구분
  ItemListScreen({required this.category});

  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  List<Map<String, dynamic>> _items = [];
  final Map<String, String> categoryTitles = {
    '무기': '무기 아이템 보기',
    '갑옷': '갑옷 아이템 보기',
  };

  @override
  void initState() {
    super.initState();
    print('initState 호출됨'); // 확인용
    _loadItems();
  }

  Future<void> _loadItems() async {
    final dbHelper = DBHelper();
    List<Map<String,dynamic>> items;

    //카테고리에 따라 다른 테이블 호출
    if (widget.category == '무기') {
      items = await dbHelper.getWeaponInfo();
    } else if (widget.category == '갑옷') {
      items = await dbHelper.getArmorInfo();
    } else {
      items = [];
    }
    print('Fetched items for ${widget.category}: $items');
    setState(() {
      _items = items;
    });
  }

  String _getItemNameKey(String category) {
    // 카테고리에 따라 아이템 이름의 키를 반환
    const nameKeys = {
      '무기': 'WEAPON_NAME',
      '갑옷': 'ARMOR_NAME',
      '방패': 'SHIELD_NAME',
      '투구': 'HELMET_NAME',
      '반지': 'RING_NAME',
      '장신구': 'ACCESSORY_NAME',
      '기타': 'ITEM_NAME',
    };
    return nameKeys[category] ?? 'NAME'; //해당사항 없을 경우 NAME으로 처리함
  }

  String _getWeaponImagePath(String name, String category) {
    // 카테고리 이름을 폴더 이름으로 매핑
    final folderMapping = {
      '무기': 'weapons',
      '갑옷': 'armors',
      '방패': 'shields',
      '투구': 'helmets',
      '반지': 'rings',
      '장신구': 'accessories',
      '기타': 'etc',
    };

    final folder = folderMapping[category] ??'unknown';

    //이미지 경로 리턴
    return 'assets/Image/$folder/${name.toLowerCase().replaceAll(" ", "")}.png';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitles[widget.category] ?? '아이템 목록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _items.isNotEmpty
            ? ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            final nameKey = _getItemNameKey(widget.category);
            final itemName = item[nameKey] ?? 'unknown';
            final imagePath = _getWeaponImagePath(itemName, widget.category);
            return ListTile(
              leading: Image.asset(
                imagePath,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  //이미지가 없을 경우
                  return Icon(Icons.image_not_supported);
                },
              ),
              title: Text(itemName),
              //subtitle: Text('STR: ${weapon['WEAPON_STR']} | DEX: ${weapon['WEAPON_DEX']}'),
              //trailing: Text('HP: ${weapon['WEAPON_HP']}'),
              onTap: () {
                if (widget.category == '무기') {
                  showWeaponDetails(context, item);
                } else if (widget.category == '갑옷') {
                  showArmorDetails(context, item);
                }
              }
            );
          },
        )
            : Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
