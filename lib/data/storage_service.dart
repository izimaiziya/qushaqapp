import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _p;

  Future<void> init() async {
    _p ??= await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String val) async {
    await init();
    await _p!.setString(key, val);
  }

  String? getString(String key) {
    return _p?.getString(key);
  }

  Future<void> remove(String key) async {
    await init();
    await _p!.remove(key);
  }

  bool has(String key) {
    return _p?.containsKey(key) ?? false;
  }

  Future<void> wipeEverything() async {
    await init();
    final keys = _p!.getKeys().where((k) => k.startsWith('qushaq_'));
    for (final k in keys.toList()) {
      await _p!.remove(k);
    }
  }
}

class SKeys {
  static const child = 'qushaq_child';
  static const episodes = 'qushaq_episodes';
  static const chat = 'qushaq_chat';
  static const users = 'qushaq_users';
  static const session = 'qushaq_session';
  static const sensoryKit = 'qushaq_sensory_kit';
  static const notifRead = 'qushaq_notif_read';
  static const lang = 'qushaq_lang';
}
