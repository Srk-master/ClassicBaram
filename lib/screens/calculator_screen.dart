import 'package:flutter/material.dart';
import '../services/exprience_calculator.dart';
import '../widgets/input_field.dart';
import '../widgets/db_helper.dart';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _currentHpController = TextEditingController();
  final _goalHpController = TextEditingController();
  final _currentMpController = TextEditingController();
  final _goalMpController = TextEditingController();

  double _result = 0;
  bool isWR = false; //격수 비격수 구분
  String job = '전사'; //기본 값
  int currentHp = 0;
  int currentMp = 0;
  //각 직업의 최대값 설정
  final maxWRHp = 2700000;
  final maxWRMp = 750000;
  final maxJDHp = 1400000;
  final maxJDMp = 2000000;
  @override
  void initState()
  {
    super.initState();
    _loadPlayerData();
  }
  Future <void> _loadPlayerData() async {
    final playerData = await DBHelper().getPlayerInfo();
    if (playerData != null) {
      setState(() {
        job = playerData['JOB'];
        currentHp = playerData['CURRENT_HP'];
        currentMp = playerData['CURRENT_MP'];

        isWR = (job == '전사' || job == '도적');

        //초기값 설정
        _currentHpController.text = currentHp.toString();
        _currentMpController.text = currentMp.toString();
      });
    }
  }
  //에러 알림
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
  //유효성 검사
  bool validateInput(double currentHp, double targetHp, double currentMp, double targetMp) {
    final maxHp = isWR ? maxWRHp : maxJDHp;
    final maxMp = isWR ? maxWRMp : maxJDMp;
    if (targetHp < currentHp || targetMp < currentMp) {
      _showErrorDialog('입력 오류', '목표 체력/마력은 현재 체력/마력보다 낮을 수 없습니다.');
      return false; // 유효 x
    }
    // 음수 검사
    if (currentHp <= 0 || targetHp <= 0 || currentMp <= 0 || targetMp <= 0) {
      _showErrorDialog('입력 오류', '체력 마력 값은 0보다 커야합니다.');
      return false; //유효 x
    }
    if (targetHp > maxHp || targetMp > maxMp) {
      _showErrorDialog('입력 오류', '${isWR ? '격수' : '비격수'}의 체력 또는 마력 범위를 초과했습니다.\n'
          '최대 체력: ${maxHp.toStringAsFixed(0)}\n최대 마력: ${maxMp.toStringAsFixed(0)}');
      return false; //유효 x
    }
    return true; //유효
  }

  void _calculate() {
    final currentHp = double.tryParse(_currentHpController.text) ?? 0;
    final targetHp = double.tryParse(_goalHpController.text) ?? 0;
    final currentMp = double.tryParse(_currentMpController.text) ?? 0;
    final targetMp = double.tryParse(_goalMpController.text) ?? 0;

    //유효성 검사 실행
    if (!validateInput(currentHp, targetHp, currentMp, targetMp)) return;

    setState(() {
      _result = ExprienceCalculator.calculateTotalExp(
          currentHp: currentHp,
          targetHp: targetHp,
          currentMp: currentMp,
          targetMp: targetMp,
          isWR: isWR
      );
    });

    print('총 필요 경험치 : ${_result.toStringAsFixed(0)}');
  }

  //높은 숫자 포맷팅 함수
  String formatToKorenLargeUnits(double value) {
    if (value >= 1e12) {
      // 조 단위
      double trillion = (value / 1e12).floorToDouble(); //1조
      double billion = ((value % 1e12) / 1e8).floorToDouble(); //1억
      double milloin = ((value % 1e8) / 1e4).floorToDouble(); //1만

      return '${trillion.toStringAsFixed(0)}조 '
            '${billion > 0 ? ' ${billion.toStringAsFixed(0)}억' : ''}'
            '${milloin > 0 ? ' ${milloin.toStringAsFixed(0)}만' : ''}';
    }
    else if (value >= 1e8) {
      //억 단위
      double billion = ((value % 1e12) / 1e8).floorToDouble(); //1억
      double milloin = ((value % 1e8) / 1e4).floorToDouble(); //1만

      return '${billion.toStringAsFixed(0)}억 '
            '${milloin > 0 ? ' ${milloin.toStringAsFixed(0)}만' : ''}';
    }
    else if (value >= 1e4) {
      //만 단위
      return '${(value / 1e4).toStringAsFixed(0)}만';
    }
    else {
      //1만 미만
      return value.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('목표 체력/마력 계산기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //직업 선택 드롭다운리스트
            Text(
              '직업 선택:',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 8,),
            DropdownButton<bool>(
              value: isWR,
              onChanged: (value) {
                setState(() {
                    isWR = value!;
                  });
                },
              items: [
                DropdownMenuItem(
                  value: true,
                  child: Text('전사 / 도적'),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text('주술사 / 도사'),
                ),
              ],
            ),
            InputField(label: '현재 체력', controller: _currentHpController),
            SizedBox(height: 16,),
            InputField(label: '목표 체력', controller: _goalHpController),
            SizedBox(height: 16,),
            InputField(label: '현재 마력', controller: _currentMpController),
            SizedBox(height: 16,),
            InputField(label: '목표 마력', controller: _goalMpController),
            SizedBox(height: 16,),
            ElevatedButton(
                onPressed: _calculate,
                child: Text('계산하기'),
            ),
            SizedBox(height: 24,),
            if(_result != null)
              Text(
                '총 필요 경험치 : ${formatToKorenLargeUnits(_result)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}