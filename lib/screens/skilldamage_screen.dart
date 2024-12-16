import 'package:flutter/material.dart';
import '../widgets/db_helper.dart';
import '../services/damage_calculator.dart';

class SkillDamageScreen extends StatefulWidget {
  @override
  _SkillDamageScreenState createState() => _SkillDamageScreenState();
}

class _SkillDamageScreenState extends State<SkillDamageScreen> {
  String selectedJob = '';
  String selectedSkill = '';
  String? selectedMonster;

  final TextEditingController _currentHpController = TextEditingController();
  final TextEditingController _currentMpController = TextEditingController();
  final TextEditingController _armorController = TextEditingController();
  final TextEditingController _monsterSearchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode(); //팝업창 포커스용

  bool isCursed = false;
  bool isConfused = false;
  double resultDamage = 0;
  List<String> availableSkills = [];
  List<Map<String, dynamic>> monsters = [];
  List<Map<String, dynamic>> filteredMonsters = [];
  int monsterHP = 0;
  int monsterAC = 0;

  @override
  void initState() {
    super.initState();
    _loadPlayerData();
    _loadMonsters();
  }

  Future<void> _loadPlayerData() async {
    final playerData = await DBHelper().getPlayerInfo();
    if (playerData != null) {
      setState(() {
        selectedJob = playerData['JOB'];
        _currentHpController.text = playerData['CURRENT_HP'].toString();
        _currentMpController.text = playerData['CURRENT_MP'].toString();
        availableSkills = _getSkillsForJob(selectedJob);
        if (availableSkills.isNotEmpty) {
          selectedSkill = availableSkills.first;
        }
      });
    }
  }

  Future<void> _loadMonsters() async {
    final monsterData = await DBHelper().getMonsterInfo();
    setState(() {
      monsters = monsterData;
      filteredMonsters = monsterData;
    });
  }

  List<String> _getSkillsForJob(String job) {
    switch (job) {
      case '전사':
        return ['건곤대나이', '동귀어진', '백호참'];
      case '도적':
        return ['필살검무', '백호검무'];
      case '주술사':
        return ['헬파이어'];
      case '도사':
        return ['백호의희원'];
      default:
        return [];
    }
  }

  void _filterMonsters(String query) {
    setState(() {
      filteredMonsters = monsters
          .where((monster) =>
          monster['NAME'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _onMonsterSelected(String monsterName) {
    final selected = monsters.firstWhere((monster) => monster['NAME'] == monsterName);
    setState(() {
      selectedMonster = monsterName;
      monsterHP = selected['HP'];
      monsterAC = selected['AC'];
      _armorController.text = monsterAC.toString();
    });
  }

  void _openMonsterSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // 로컬 필터링된 몬스터 목록을 다이얼로그 내에서 관리
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus(); //검색 필드에 자동 포커스 넣기
        });
        List<Map<String, dynamic>> localFilteredMonsters = List.from(monsters);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            void _filterMonsters(String query) {
              setDialogState(() {
                localFilteredMonsters = monsters
                    .where((monster) =>
                    monster['NAME'].toString().toLowerCase().contains(query.toLowerCase()))
                    .toList();
              });
            }

            return AlertDialog(
              title: Text('몬스터 검색'),
              content: SizedBox(
                width: double.maxFinite, // 너비를 부모에 맞춤
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Column 크기를 내부 자식에 맞춤
                  children: [
                    TextField(
                      controller: _monsterSearchController,
                      decoration: InputDecoration(
                        labelText: '검색',
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: _filterMonsters,
                    ),
                    SizedBox(height: 16),
                    // ConstrainedBox로 ListView의 크기 제한
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 300, // ListView의 최대 높이를 제한
                      ),
                      child: ListView.builder(
                        shrinkWrap: true, // ListView가 Column의 크기에 맞게 축소
                        itemCount: localFilteredMonsters.length,
                        itemBuilder: (context, index) {
                          final monster = localFilteredMonsters[index];
                          return ListTile(
                            title: Text(monster['NAME']),
                            onTap: () {
                              setState(() {
                                selectedMonster = monster['NAME'];
                                _monsterSearchController.text = monster['NAME'];
                                monsterHP = monster['HP'];
                                monsterAC = monster['AC'];
                                _armorController.text = monster['AC'].toString();
                              });
                              Navigator.pop(context);
                              _onMonsterSelected(monster['NAME']);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



  void _calculateDamage() {
    if (selectedSkill.isEmpty) return;
    final currentHp = double.tryParse(_currentHpController.text) ?? 0;
    final currentMp = double.tryParse(_currentMpController.text) ?? 0;
    final armor = double.tryParse(_armorController.text) ?? 0;
    setState(() {
      resultDamage = DamageCalculator.calculateDamage(
        skill: selectedSkill,
        currentHp: currentHp,
        currentMp: currentMp,
        armor: armor,
        isCursed: isCursed,
        isConfused: isConfused,
      );
    });
  }

  int _calculateHitsToKill() {
    if (resultDamage <= 0 || monsterHP <= 0) {
      return 0;
    }
    return (monsterHP / resultDamage).ceil();
  }

  int _calculateMobHP() {
    if (resultDamage <= 0 || monsterHP <= 0) {
      return 0;
    }
    if ((monsterHP - resultDamage) < 0 )
      return 0;
    return (monsterHP - resultDamage).ceil();
  }

  void _handleDebuffSelection(bool value, String type) {
    setState(() {
      if (type == 'curse') {
        isCursed = value;
        if (value) isConfused = false;
      } else if (type == 'confuse') {
        isConfused = value;
        if (value) isCursed = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('스킬 데미지 계산기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: selectedJob.isNotEmpty ? selectedJob : null,
                items: ['전사', '도적', '주술사', '도사']
                    .map((job) => DropdownMenuItem(
                  value: job,
                  child: Text(job),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedJob = value!;
                    availableSkills = _getSkillsForJob(selectedJob);
                    if (availableSkills.isNotEmpty) {
                      selectedSkill = availableSkills.first;
                    } else {
                      selectedSkill = '';
                    }

                    // 데이터 초기화
                    selectedSkill = availableSkills.isNotEmpty ? availableSkills.first : '';
                    resultDamage = 0;
                    selectedMonster = null;
                    monsterHP = 0;
                    monsterAC = 0;
                    _armorController.clear();
                    _monsterSearchController.clear();


                  });
                },
                decoration: InputDecoration(labelText: '직업 선택'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSkill.isNotEmpty ? selectedSkill : null,
                items: availableSkills
                    .map((skill) => DropdownMenuItem(
                  value: skill,
                  child: Text(skill),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSkill = value!;
                  });
                },
                decoration: InputDecoration(labelText: '스킬 선택'),
              ),
              SizedBox(height: 16),
              // 도사일 경우 몬스터 검색 및 방어력 입력 숨김
              if (selectedJob != '도사') ...[
                TextField(
                  controller: _monsterSearchController,
                  focusNode: _searchFocusNode,
                  readOnly: true, // TextField 내 키보드 입력 막기
                  onTap: _openMonsterSearchDialog, // 텍스트 필드 클릭 시 팝업 열기
                  decoration: InputDecoration(
                    labelText: '몬스터 검색',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _openMonsterSearchDialog,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                if (selectedMonster != null) ...[
                  Text('몬스터 체력: $monsterHP', style: TextStyle(fontSize: 16)),
                ],
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: '대상 방어력'),
                  controller: _armorController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                CheckboxListTile(
                  title: Text('저주 적용'),
                  value: isCursed,
                  onChanged: (value) {
                    _handleDebuffSelection(value!, 'curse');
                  },
                ),
                CheckboxListTile(
                  title: Text('혼마술 적용'),
                  value: isConfused,
                  onChanged: (value) {
                    _handleDebuffSelection(value!, 'confuse');
                  },
                ),
              ],
              SizedBox(height: 16),
              //공용 입력 필드
              TextField(
                decoration: InputDecoration(labelText: '현재 체력'),
                controller: _currentHpController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: '현재 마력'),
                controller: _currentMpController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),


              //계산 버튼
              ElevatedButton(
                onPressed:
                _calculateDamage,
                child: Text(selectedJob == '도사' ? '회복량 계산하기' : '데미지 계산하기'),
              ),
              SizedBox(height: 24),
              // 결과 출력
              if (selectedJob == '도사' && resultDamage > 0)
                Text(
                  '계산된 회복량: ${resultDamage.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              if (selectedJob != '도사' && resultDamage > 0) ...[
                Text(
                  '계산된 데미지: ${resultDamage.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 8,),
              if (monsterHP > 0)
                Text(
                  '남은 몬스터 체력: ${_calculateMobHP()}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              if (monsterHP > 0)
                Text(
                  '필요한 타격 횟수: ${_calculateHitsToKill()}회',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
