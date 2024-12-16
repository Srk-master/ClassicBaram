import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'ItemList_screen.dart';
import '../services/Functions.dart';
import '../widgets/db_helper.dart';
import '../services/ShowItemDetail.dart';
import 'dart:async';    //타이머 사용

class ItemSearchScreen extends StatefulWidget {
  @override
  _ItemSearchScreenState createState() => _ItemSearchScreenState();
}

class _ItemSearchScreenState extends State<ItemSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _searchResults = []; //검색 결과 저장
  Timer? _debounce; //디바운싱 타이머

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
  void _onSearchChanged(String query) {
    //디바운싱 적용
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isNotEmpty) {
        //검색 쿼리 db로 전달
        final results = await _dbHelper.searchItems(query);
        setState(() {
          _searchResults = results;
        });
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }
  void _onCategoryButtonPressed(String category) {
    // 선택된 카테고리에 따라 아이템 리스트 화면으로 이동
      //무기 버튼 클릭시
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ItemListScreen(category: category)),
      );
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = _searchController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text('아이템 검색'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 검색창
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '아이템 이름을 검색하세요',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          if (isSearching) ...[
            SizedBox(height: 16.0),
            //검색 결과 리스트
            Expanded(
              child: _searchResults.isNotEmpty ? ListView.builder(
                itemCount:  _searchResults.length,
                itemBuilder: (context, index) {
                  final item = _searchResults[index];
                  print('Rendering Item: $item');
                  return ListTile(
                    leading: Image.asset(
                        getItemImagePath(item['NAME'], item['CATEGORY']),
                        width: 40,
                        height: 40,
                      errorBuilder: (context,error,stackTrace) {
                          return Icon(Icons.image_not_supported);
                      },
                    ),
                    title: Text(item['NAME']),
                    //subtitle: Text(item['description'] ?? '설명 없음'),
                    onTap: () async {
                      //클릭시 상세 정보 이동
                      final details = await _dbHelper.getItemDetails(
                        item['NAME'],
                        item['CATEGORY'],
                      );

                      if (item['CATEGORY'] == '무기') {
                        showWeaponDetails(context, details);
                      } else if (item['CATEGORY'] == '갑옷') {
                        showArmorDetails(context, details);
                      }
                    },
                  );
                },
              )
              :Center(
                child: Text(
                  '검색 결과가 없습니다.',
                  style:  TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
// 버튼은 검색 중일 때 숨김
            if (!isSearching) ...[
              SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: () => _onCategoryButtonPressed('무기'),
                icon: Icon(RpgAwesome.broadsword),
                label: Text('무기 아이템 보기'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton.icon(
                onPressed: () => _onCategoryButtonPressed('갑옷'),
                icon: Icon(RpgAwesome.vest),
                label: Text('갑옷 아이템 보기'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton.icon(
                onPressed: () => _onCategoryButtonPressed('방패'),
                icon: Icon(RpgAwesome.shield),
                label: Text('방패 아이템 보기'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton.icon(
                onPressed: () => _onCategoryButtonPressed('투구'),
                icon: Icon(RpgAwesome.helmet),
                label: Text('투구 아이템 보기'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton.icon(
                onPressed: () => _onCategoryButtonPressed('반지'),
                icon: Icon(RpgAwesome.fire_ring),
                label: Text('반지 아이템 보기'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton.icon(
                onPressed: () => _onCategoryButtonPressed('장신구'),
                icon: Icon(RpgAwesome.trefoil_lily),
                label: Text('장신구 아이템 보기'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton.icon(
                onPressed: () => _onCategoryButtonPressed('기타'),
                icon: Icon(RpgAwesome.potion),
                label: Text('기타 아이템 보기'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}