import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'widgets/db_helper.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/remote_config_helper.dart';
import 'services/VersionChecker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  await DBHelper().database;
  //await DBHelper().checkPlayerTable();

  //firebase romote 초기화
  final remoteConfigHelper = RemoteConfigHelper();
  await remoteConfigHelper.initialize();
  print('server version ${remoteConfigHelper.getLastestVersion()}');
  runApp(MyApp(lastestVersion: remoteConfigHelper.getLastestVersion()));
}
class MyApp extends StatelessWidget {
  final String lastestVersion;

  MyApp({required this.lastestVersion});

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
      //home: HomeScreen(),
      home: HomeScreenWrapper(lastestVersion: lastestVersion,),
    );
  }
}

class HomeScreenWrapper extends StatelessWidget {
  final String lastestVersion;

  HomeScreenWrapper({required this. lastestVersion});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: VersionChecker(lastestVersion).isUpdateRequired(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('오류 발생: ${snapshot.error}')),
          );
        }

        final isUpdateRequired = snapshot.data ?? false;

        if (isUpdateRequired) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false, // 팝업 외부 클릭으로 닫히지 않음
              builder: (context) {
                return AlertDialog(
                  title: Text('업데이트 필요'),
                  content: Text('최신 버전이 출시되었습니다. 업데이트하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Play Store로 이동 (앱 패키지명 필요)
                        Navigator.pop(context);
                      },
                      child: Text('예'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // 업데이트 팝업 닫기
                      },
                      child: Text('아니오'),
                    ),
                  ],
                );
              },
            );
          });
        }

        return HomeScreen(); // 홈 화면 표시
      },
    );
  }
}