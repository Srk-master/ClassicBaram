import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'widgets/db_helper.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  await DBHelper().database;
  //await DBHelper().checkPlayerTable();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '클바 도우미',
      theme: ThemeData(
        primaryColor: Color(0xFF37474F), //메인 색상 (딥 그레이 블루)
        scaffoldBackgroundColor: Color(0xFFECEFF1), //배경색 (밝은 그레이)
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF37474F),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF546E7A), //버튼 색상
            foregroundColor: Colors.white, //버튼 텍스트 색상
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF37474F), fontSize: 16), //메인
          bodyMedium: TextStyle(color: Color(0xFF546E7A), fontSize: 14),
          bodySmall: TextStyle(color: Color(0xFF90A4AE), fontSize: 12),
          titleLarge: TextStyle(color: Color(0xFF37474F), fontSize: 20,
          fontWeight: FontWeight.bold),
        ),
        fontFamily: 'Maple',  //폰트 설정
      ),
      home: HomeScreen(),
    );
  }
}