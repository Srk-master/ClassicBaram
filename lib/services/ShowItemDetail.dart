import 'package:flutter/material.dart';
import '../widgets/db_helper.dart';

//직업 제한 문자열 매핑 함수
String _getJobRestriction(int jobCode) {
  const jobRestrictions = {
    0: '직업제한무',
    1: '전사 전용',
    2: '도적 전용',
    3: '주술사 전용',
    4: '도사 전용',
  };
  return jobRestrictions[jobCode] ?? '알 수 없음'; // 기본값 처리
}

//무기 상세보기
void showWeaponDetails(BuildContext context, Map<String, dynamic> weapon) {
  final weaponJob = int.tryParse(weapon['WEAPON_JOB']?.toString() ?? '0') ?? 0;
  final level = int.tryParse(weapon['LEVEL']?.toString() ?? '0') ?? 0;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(weapon['WEAPON_NAME']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (weapon['WEAPON_JOB'] != null)
              Text(_getJobRestriction(weaponJob)),
            if (weapon['DURABILITY'] != 0) Text('내구도: ${weapon['DURABILITY']}'),
            if (weapon['WEAPON_STR'] != 0) Text('힘: ${weapon['WEAPON_STR']}'),
            if (weapon['WEAPON_DEX'] != 0) Text('민첩: ${weapon['WEAPON_DEX']}'),
            if (weapon['WEAPON_INT'] != 0) Text('지력: ${weapon['WEAPON_INT']}'),
            if (weapon['WEAPON_HP'] != 0) Text('체력: ${weapon['WEAPON_HP']}'),
            if (weapon['WEAPON_MP'] != 0) Text('마력: ${weapon['WEAPON_MP']}'),
            if (weapon['WEAPON_RES'] != 0) Text('재생력: ${weapon['WEAPON_RES']}'),
            if (weapon['WEAPON_HIT'] != 0) Text('HIT: ${weapon['WEAPON_HIT']}'),
            if (weapon['WEAPON_DAM'] != 0) Text('DAM: ${weapon['WEAPON_DAM']}'),
            if (weapon['DAMAGE_S'] != 0) Text('파괴력 (S): ${weapon['DAMAGE_S']}'),
            if (weapon['DAMAGE_L'] != 0) Text('파괴력 (L): ${weapon['DAMAGE_L']}'),
            if (weapon['WEAPON_STR_LIMIT'] != 0) Text('힘 제한: ${weapon['WEAPON_STR_LIMIT']}'),
            if (weapon['WEAPON_DEX_LIMIT'] != 0) Text('민첩 제한: ${weapon['WEAPON_DEX_LIMIT']}'),
            if (weapon['WEAPON_INT_LIMIT'] != 0) Text('지력 제한: ${weapon['WEAPON_INT_LIMIT']}'),
            if (weapon['LEVEL'] != 0) Text('착용 가능 레벨: $level'),
            Text('수리가능: ${weapon['WEAPON_REPAIR'] == 'Y' ? 'O' : 'X'}'),
            Text('교환가능: ${weapon['WEAPON_EXCHANGE'] == 'Y' ? 'O' : 'X'}'),
            if (weapon['DESCRIPTION'] != null && weapon['DESCRIPTION'].isNotEmpty)
              Text('설명: ${weapon['DESCRIPTION']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기'),
          ),
        ],
      );
    },
  );
}

//갑옷 상세보기
void showArmorDetails(BuildContext context, Map<String, dynamic> armor) {
  final armorJob = int.tryParse(armor['ARMOR_JOB']?.toString() ?? '0') ?? 0;
  final level = int.tryParse(armor['LEVEL']?.toString() ?? '0') ?? 0;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(armor['ARMOR_NAME']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (armor['ARMOR_JOB'] != null)
              Text(_getJobRestriction(armorJob)),
            if (armor['DURABILITY'] != 0) Text('내구도: ${armor['DURABILITY']}'),
            if (armor['ARMOR_SEX'] != 0) Text('성별: ${armor['ARMOR_SEX'] == 'F' ? '여자용' : '남자용'}'),
            if (armor['ARMOR_SEX'] == 0) const Text('성별: 공용'),
            if (armor['ARMOR_AC'] != 0) Text('무장: ${armor['ARMOR_AC']}'),
            if (armor['ARMOR_STR'] != 0) Text('힘: ${armor['ARMOR_STR']}'),
            if (armor['ARMOR_DEX'] != 0) Text('민첩: ${armor['ARMOR_DEX']}'),
            if (armor['ARMOR_INT'] != 0) Text('지력: ${armor['ARMOR_INT']}'),
            if (armor['ARMOR_HP'] != 0) Text('체력: ${armor['ARMOR_HP']}'),
            if (armor['ARMOR_MP'] != 0) Text('마력: ${armor['ARMOR_MP']}'),
            if (armor['ARMOR_RES'] != 0) Text('재생력: ${armor['ARMOR_RES']}'),
            if (armor['ARMOR_MD'] != 0) Text('마법 방어: ${armor['ARMOR_MD']}'),
            if (armor['ARMOR_STR_LIMIT'] != 0) Text('힘 제한: ${armor['ARMOR_STR_LIMIT']}'),
            if (armor['ARMOR_DEX_LIMIT'] != 0) Text('민첩 제한: ${armor['ARMOR_DEX_LIMIT']}'),
            if (armor['ARMOR_INT_LIMIT'] != 0) Text('지력 제한: ${armor['ARMOR_INT_LIMIT']}'),
            if (armor['LEVEL'] != 0) Text('착용 가능 레벨: $level'),
            Text('수리가능: ${armor['ARMOR_REPAIR'] == 'Y' ? 'O' : 'X'}'),
            Text('교환가능: ${armor['ARMOR_EXCHANGE'] == 'Y' ? 'O' : 'X'}'),
            if (armor['DESCRIPTION'] != null && armor['DESCRIPTION'].isNotEmpty)
              Text('설명: ${armor['DESCRIPTION']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기'),
          ),
        ],
      );
    },
  );
}