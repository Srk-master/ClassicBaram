class ExprienceCalculator {
  static double calculateTotalExp(
  {
    required double currentHp,
    required double targetHp,
    required double currentMp,
    required double targetMp,
    required bool isWR, //격수 여부
  }) {
    double totalExp = 0;

    //체력 범위 (전사/도적 또는 주술사/도사)
    final hpRanges = isWR ? ranges_WR_HP : ranges_JD_HP;
    //마력 범위 (전사/도적 또는 주술사/도사)
    final mpRanges = isWR ? ranges_WR_MP : ranges_JD_MP;

    //체력 계산
    for (var range in hpRanges) {
      double rangeStart = range[0].toDouble();
      double rangeEnd = range[1].toDouble();
      double expPer50Hp = range[2].toDouble();

      if (currentHp > rangeEnd) continue; //현재 체력이 구간 밖일 경우 건너뜀
      if (targetHp < rangeStart) break; //목표 체력이 구간 이전일 경우 종료

      //유효 범위 내 체력 계산
      double effectiveStart = currentHp > rangeStart ? currentHp : rangeStart;
      double effectiveEnd = targetHp < rangeEnd ? targetHp : rangeEnd;

      double hpDiff = effectiveEnd - effectiveStart;
      totalExp += (hpDiff / 50).ceil() * expPer50Hp; //50단위로 나눠서 계산함
    }

    //마력 계산
    for (var range in mpRanges) {
      double rangeStart = range[0].toDouble();
      double rangeEnd = range[1].toDouble();
      double expPerUnit = range[2].toDouble(); //단위당 경험치
      double buyableUnits = range[3].toDouble(); //구간 내 살 수 있는 단위

      if (currentMp > rangeEnd) continue; //현재 MP가 구간 밖이면 건너뜀
      if (targetMp < rangeStart) break; //목표 MP가 구간 이전이면 종료

      //유효 범위 내 마력 계산
      double effectiveStart = currentMp > rangeStart ? currentMp : rangeStart;
      double effectiveEnd = targetMp < rangeEnd ? targetMp : rangeEnd;

      double mpDiff = effectiveEnd - effectiveStart;

      totalExp += (mpDiff/buyableUnits).ceil() * expPerUnit;
    }
    return totalExp;
  }
    static const ranges_WR_HP = [
      [0,800000,10000000],
      [800001,1000000,20000000],
      [1000001,1200000,50000000],
      [1200001,1500000,100000000],
      [1500001,1700000,200000000],
      [1700001,2000000,300000000],
      [2000001,2200000,400000000],
      [2200001,2300000,600000000],
      [2300001,2400000,900000000],
      [2400001,2500000,2000000000],
      [2500001,2600000,4000000000],
      [2600001,2700000,10000000000]
    ];
    static const ranges_WR_MP = [
      [0,100000,10000000,25],
      [100001,150000,20000000,25],
      [150001,200000,50000000,25],
      [200001,250000,100000000,25],
      [250001,300000,150000000,25],
      [300001,400000,200000000,25],
      [400001,450000,400000000,25],
      [450001,500000,600000000,25],
      [500001,550000,1000000000,25],
      [550001,600000,2000000000,25],
      [600000,650000,2000000000,15],
      [650001,700000,2000000000,10],
      [700001,750000,2000000000,5],
    ];
    static const ranges_JD_HP = [
      [0,400000,10000000],
      [400001,500000,20000000],
      [500001,600000,50000000],
      [600001,700000,100000000],
      [700001,800000,200000000],
      [800001,900000,300000000],
      [900001,1000000,400000000],
      [1000001,1100000,600000000],
      [1100001,1200000,900000000],
      [1200001,1250000,1200000000],
      [1250001,1300000,2000000000],
      [1300001,1400000,4000000000]
    ];
    static const ranges_JD_MP = [
      [0,600000,10000000,25],
      [600001,700000,20000000,25],
      [700001,800000,50000000,25],
      [800001,900000,100000000,25],
      [900001,1000000,20000000,25],
      [1000001,1100000,300000000,25],
      [1100001,1200000,400000000,25],
      [1200001,1400000,600000000,25],
      [1400001,1550000,900000000,25],
      [1550001,1600000,2000000000,25],
      [1600001,1650000,2000000000,15],
      [1650001,1700000,2000000000,10],
      [1700001,1750000,2000000000,5],
      [1750001,1800000,2000000000,3],
      [1800001,1900000,2000000000,1],
      [1900001,2000000,2500000000,1]
    ];

  }