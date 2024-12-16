import 'package:package_info_plus/package_info_plus.dart';

class VersionChecker {
  final String lastestVersion;

  VersionChecker(this.lastestVersion);

  Future<bool> isUpdateRequired() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      return _compareVersions(currentVersion, lastestVersion);
    } catch (e) {
      print('Error checking app version: $e');
      return false;
    }
  }

  bool _compareVersions(String current, String lastest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final lastestParts = lastest.split('.').map(int.parse).toList();

    for (int i = 0; i < lastestParts.length; i++) {
      if (i >= currentParts.length || currentParts[i] < lastestParts[i]) {
        return true;
      } else if (currentParts[i] > lastestParts[i]) {
        return false;
      }
    }
    return false;
  }
}