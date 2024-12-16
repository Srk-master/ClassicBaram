import 'package:classicbaramhelper/screens/ItemSearchScreen.dart';
import 'package:classicbaramhelper/screens/userinfo_screen.dart';
import 'package:classicbaramhelper/widgets/AnimatedButton.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'calculator_screen.dart';
import 'skilldamage_screen.dart';
import '../widgets/custom_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkMode = false; //다크모드 상태
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; //화면 너비
    final isSmallScreen = screenWidth < 600; //반응형 기준
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.20),
        child: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Container(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/logos/logo_white.png',
              height: MediaQuery.of(context).size.height * 0.15,
              fit: BoxFit.contain,
            ),
          ),
          centerTitle: true,
          toolbarHeight: MediaQuery.of(context).size.height * 0.2,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.person),
              color: Colors.white,
              tooltip: '사용자 정보',
              onPressed: (){
                print('context: $context');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserInfoScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: AnimatedButton(
                        icon: RpgAwesome.axe,
                        title: '데미지 계산기',
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SkillDamageScreen()),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16,),
                    Expanded(
                      child: AnimatedButton(
                        icon: Icons.calculate,
                        title: '목표 체력/마력 계산기',
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CalculatorScreen()),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16,),
                    Expanded(
                      child: AnimatedButton(
                        icon: RpgAwesome.spinning_sword,
                        title: '아이템 검색',
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ItemSearchScreen()),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16,),
                    Expanded(
                      child: AnimatedButton(
                        icon: RpgAwesome.skull,
                        title: '몬스터 검색(준비중)',
                        onPressed: (){
                          //아이템 검색 이동 나중에 구현
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ),
          SizedBox(height: 16,),
          //나중에 광고 들어갈 자리
          Container(
            height: 60,
            color: Colors.grey[300], //임시 색상
            child: Center(
              child: Text(
                'Ad Placeholder',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
          ),
        ],
      )
    );
  }
}