class DamageCalculator {
  //데미지 계산
  static double calculateDamage({
    required String skill,
    required double currentHp,
    required double currentMp,
    double maxMp = 20300, //백호검무 최대 마력 상한선
    double armor = 0, //방어력
    bool isCursed = false, //저주 여부
    bool isConfused = false, //혼마술 여부
}) {
    //무장 계산 (디버프 적용)
    double adjustedArmor = armor;
    if (isCursed) {
      adjustedArmor += 30; //저주
    }
    if (isConfused) {
      adjustedArmor += 50; //혼마술
    }

    //방어력에 따른 데미지 감소율
    double damageReduction;
    if (adjustedArmor <= 0 ) {
      damageReduction = 1 - (-adjustedArmor / 100);
    } else {
      damageReduction = 1 + (adjustedArmor / 100);
    }

    //배율 제한
    if (damageReduction < 0.01) {
      damageReduction = 0.01;
    }

    //스킬별 데미지 계산
    double baseDamage = 0;
    switch (skill) {
      case '건곤대나이':
      case '백호참' :
        baseDamage = currentHp; //현재 체력의 100%
        break;
      case '동귀어진':
        baseDamage = (currentHp * 2);
        break;
      case '필살검무':
        baseDamage = (currentHp + currentMp); //현재 체력의 100% + 현재 마력의 100%
        break;
      case '백호검무':
        baseDamage = (currentHp + (maxMp > 20300 ? 20300 : maxMp));
        break;
      case '헬파이어':
        baseDamage = (currentMp * 1.5); //현재 마력의 150%
        break;
      default:
        throw Exception('알 수 없는 스킬 $skill');
    }

    //방어력 및 디버프 적용
    return baseDamage * damageReduction;
  }
}