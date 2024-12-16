import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigHelper {
  static final RemoteConfigHelper _instance = RemoteConfigHelper._internal();
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  RemoteConfigHelper._internal();

  factory RemoteConfigHelper() {
    return _instance;
  }

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        //minimumFetchInterval: const Duration(hours: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Remote Config initialization failed: $e');
    }
  }
  String getLastestVersion() {
    return _remoteConfig.getString('lastest_version');
  }
}