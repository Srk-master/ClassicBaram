import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import '../widgets/db_helper.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserInfoScreenState();
}
class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController _currentHpController = TextEditingController();
  final TextEditingController _currentMpController = TextEditingController();
  String _selectedJob = '전사';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _currentHpController.dispose();
    _currentMpController.dispose();
    super.dispose();
  }
  //사용자 데이터 불러오기
  Future<void> _loadUserData() async {
    final userData = await DBHelper().getPlayerInfo();
    if (userData != null) {
      setState(() {
        _selectedJob = userData['JOB'];
        _currentHpController.text = userData['CURRENT_HP'].toString();
        _currentMpController.text = userData['CURRENT_MP'].toString();
      });
    }
  }
  Future<void> _saveUserData() async {
    final job = _selectedJob;
    final currentHp = int.tryParse(_currentHpController.text) ?? 0;
    final currentMp = int.tryParse(_currentMpController.text) ?? 0;

    await DBHelper().savePlayerInfo(job, currentHp, currentMp);
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사용자 정보 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
                value: _selectedJob,
                decoration: InputDecoration(labelText: '직업 선택'),
                items: ['전사','도적','주술사','도사'].map((job) => DropdownMenuItem(
                  value: job,
                  child: Text(job),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedJob = value!;
                  });
                },
            ),
            TextField(
              controller: _currentHpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '현재 체력'),
            ),
            TextField(
              controller: _currentMpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '현재 마력'),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
                onPressed: _saveUserData,
                child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}