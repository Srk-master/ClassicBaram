

String getItemImagePath(String name, String category) {
  // 카테고리 이름을 폴더 이름으로 매핑
  final folderMapping = {
    '무기': 'weapons',
    '갑옷': 'armors',
    '방패': 'shields',
    '투구': 'helmets',
    '반지': 'rings',
    '장신구': 'accessories',
    '기타': 'etc',
  };

  final folder = folderMapping[category ?? '기타'] ??'unknown';

  //이미지 경로 리턴
  return 'assets/Image/$folder/${name.toLowerCase().replaceAll(" ", "")}.png';
}