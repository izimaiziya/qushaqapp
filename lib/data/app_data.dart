import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../l10n/strings.dart';
import 'storage_service.dart';

class Episode {
  DateTime date;
  String place;
  String what;
  String? trigger;
  int durationMin;
  String childId;

  Episode({required this.date, required this.place, required this.what, this.trigger, this.durationMin = 10, this.childId = ''});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'place': place,
        'what': what,
        'trigger': trigger,
        'durationMin': durationMin,
        'childId': childId,
      };

  factory Episode.fromJson(Map<String, dynamic> j) => Episode(
        date: DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
        place: j['place']?.toString() ?? '',
        what: j['what']?.toString() ?? '',
        trigger: j['trigger']?.toString(),
        durationMin: int.tryParse(j['durationMin']?.toString() ?? '') ?? 10,
        childId: j['childId']?.toString() ?? '',
      );
}

class ChatMsg {
  final bool fromUser;
  final String text;
  final GeminiReply? reply;
  final bool offline;
  ChatMsg(this.fromUser, this.text, {this.reply, this.offline = false});

  Map<String, dynamic> toJson() => {
        'fromUser': fromUser,
        'text': text,
        'reply': reply?.toJson(),
        'offline': offline,
      };

  factory ChatMsg.fromJson(Map<String, dynamic> j) => ChatMsg(
        j['fromUser'] == true,
        j['text']?.toString() ?? '',
        reply: j['reply'] != null ? GeminiReply.fromJson(j['reply'] as Map<String, dynamic>) : null,
        offline: j['offline'] == true,
      );
}

class ChildProfile {
  String id;
  String name;
  String age;
  String gender;
  List<String> diagnosis;

  ChildProfile({required this.name, required this.age, required this.gender, required this.diagnosis, String? id})
      : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'age': age, 'gender': gender, 'diagnosis': diagnosis};

  factory ChildProfile.fromJson(Map<String, dynamic> j, [String? fallbackId]) => ChildProfile(
        id: j['id']?.toString() ?? fallbackId,
        name: j['name']?.toString() ?? '',
        age: j['age']?.toString() ?? '',
        gender: j['gender']?.toString() ?? 'мальчик',
        diagnosis: (j['diagnosis'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
}

class ArticleItem {
  final String title;
  final String desc;
  final String category;
  final Color accent;
  final String time;
  final String url;

  ArticleItem(this.title, this.desc, this.category, this.accent, this.time, this.url);
}

const String kWelcomeMsg = 'Привет! Я помогу понять, что происходит с ребёнком, и подскажу, что делать прямо сейчас. Опишите ситуацию.';

String hashPass(String raw) {
  return sha256.convert(utf8.encode(raw)).toString();
}

class AppData {
  static final AppData instance = AppData._internal();
  AppData._internal();

  List<ChildProfile> children = [ChildProfile(name: '', age: '', gender: 'мальчик', diagnosis: [])];
  int activeChildIndex = 0;

  String get childName => children[activeChildIndex].name;
  set childName(String v) => children[activeChildIndex].name = v;

  String get childAge => children[activeChildIndex].age;
  set childAge(String v) => children[activeChildIndex].age = v;

  String get childGender => children[activeChildIndex].gender;
  set childGender(String v) => children[activeChildIndex].gender = v;

  List<String> get diagnosis => children[activeChildIndex].diagnosis;
  set diagnosis(List<String> v) => children[activeChildIndex].diagnosis = v;

  String get activeChildId => children[activeChildIndex].id;

  List<Episode> get activeChildEpisodes {
    final id = activeChildId;
    final isFirstChild = activeChildIndex == 0;
    return episodes.where((e) => e.childId == id || (e.childId.isEmpty && isFirstChild)).toList();
  }

  bool loggedIn = false;
  String userEmail = '';

  List<Map<String, String>> users = [];

  List<Episode> episodes = [
    Episode(date: DateTime(2026, 3, 9), place: 'Супермаркет', what: 'Удары, плач, лёг на пол · 12 мин', trigger: 'Громкое объявление'),
    Episode(date: DateTime(2026, 3, 12), place: 'День рождения', what: 'Закрывал уши, ушёл, качался · 7 мин', trigger: 'Голоса и музыка'),
    Episode(date: DateTime(2026, 3, 5), place: 'Утро, перед садиком', what: 'Плакал, отказался надевать обувь · 20 мин', trigger: 'Переход без предупреждения'),
  ];

  List<ChatMsg> chatMessages = [ChatMsg(false, kWelcomeMsg)];

  List<String> sensoryKit = ['🎧 Шумоподавляющие наушники'];

  bool notifRead = false;

  String lang = 'ru';

  bool _loaded = false;

  bool get hasChild => childName.isNotEmpty;

  String childLabel() {
    if (childName.isEmpty) return 'Ребёнок';
    return '$childName, $childAge';
  }

  String diagnosisLabel() {
    if (diagnosis.isEmpty) return tr('not_specified');
    return diagnosis.map((d) => diagLabel(d)).join(', ');
  }

  Future<void> load() async {
    if (_loaded) return;
    await StorageService.instance.init();

    final savedLang = StorageService.instance.getString(SKeys.lang);
    if (savedLang != null && savedLang.isNotEmpty) {
      lang = savedLang;
    }

    final usersRaw = StorageService.instance.getString(SKeys.users);
    if (usersRaw != null) {
      final list = jsonDecode(usersRaw) as List;
      users = list.map((e) => Map<String, String>.from(e as Map)).toList();
    }

    final session = StorageService.instance.getString(SKeys.session);
    if (session != null && session.isNotEmpty) {
      loggedIn = true;
      userEmail = session;
      await load2ForUser();
    }

    _loaded = true;
  }

  Future<void> saveChild() async {
    await StorageService.instance.setString(
      '${SKeys.child}_$userEmail',
      jsonEncode({'active': activeChildIndex, 'list': children.map((c) => c.toJson()).toList()}),
    );
  }

  Future<void> addChild(ChildProfile c) async {
    children.add(c);
    activeChildIndex = children.length - 1;
    await saveChild();
  }

  Future<void> removeChild(int index) async {
    if (children.length <= 1) return;
    children.removeAt(index);
    if (activeChildIndex >= children.length) activeChildIndex = children.length - 1;
    await saveChild();
  }

  Future<void> switchChild(int index) async {
    if (index < 0 || index >= children.length) return;
    activeChildIndex = index;
    await saveChild();
  }

  Future<void> saveEpisodes() async {
    await StorageService.instance.setString(
      '${SKeys.episodes}_$userEmail',
      jsonEncode(episodes.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> saveChat() async {
    await StorageService.instance.setString(
      '${SKeys.chat}_$userEmail',
      jsonEncode(chatMessages.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> saveSensoryKit() async {
    await StorageService.instance.setString(
      '${SKeys.sensoryKit}_$userEmail',
      jsonEncode(sensoryKit),
    );
  }

  Future<void> saveNotifRead() async {
    await StorageService.instance.setString('${SKeys.notifRead}_$userEmail', notifRead ? '1' : '0');
  }

  Future<void> saveUsers() async {
    await StorageService.instance.setString(SKeys.users, jsonEncode(users));
  }

  Future<void> setLang(String newLang) async {
    lang = newLang;
    await StorageService.instance.setString(SKeys.lang, newLang);
  }

  Future<bool> tryLogin(String email, String pass) async {
    final hashed = hashPass(pass);
    final match = users.where((u) => u['email'] == email && u['pass'] == hashed);
    if (match.isEmpty) return false;
    loggedIn = true;
    userEmail = email;
    await StorageService.instance.setString(SKeys.session, email);
    await load2ForUser();
    return true;
  }

  Future<String?> tryRegister(String email, String pass) async {
    if (users.any((u) => u['email'] == email)) {
      return 'Пользователь с таким email уже существует';
    }
    users.add({'email': email, 'pass': hashPass(pass)});
    await saveUsers();
    loggedIn = true;
    userEmail = email;
    await StorageService.instance.setString(SKeys.session, email);
    resetForNewUser();
    return null;
  }

  Future<void> load2ForUser() async {
    children = [ChildProfile(name: '', age: '', gender: 'мальчик', diagnosis: [])];
    activeChildIndex = 0;
    episodes = [];
    chatMessages = [ChatMsg(false, tr('chat_welcome'))];
    sensoryKit = [tr('sensory_default_item')];

    final childRaw = StorageService.instance.getString('${SKeys.child}_$userEmail');
    if (childRaw != null) {
      final j = jsonDecode(childRaw) as Map<String, dynamic>;
      final list = (j['list'] as List?) ?? [];
      if (list.isNotEmpty) {
        children = list.asMap().entries.map((e) => ChildProfile.fromJson(e.value as Map<String, dynamic>, 'child_${e.key}')).toList();
        activeChildIndex = (int.tryParse(j['active']?.toString() ?? '') ?? 0).clamp(0, children.length - 1);
      }
    }
    final epRaw = StorageService.instance.getString('${SKeys.episodes}_$userEmail');
    if (epRaw != null) {
      final list = jsonDecode(epRaw) as List;
      episodes = list.map((e) => Episode.fromJson(e as Map<String, dynamic>)).toList();
    }
    final chatRaw = StorageService.instance.getString('${SKeys.chat}_$userEmail');
    if (chatRaw != null) {
      final list = jsonDecode(chatRaw) as List;
      if (list.isNotEmpty) chatMessages = list.map((e) => ChatMsg.fromJson(e as Map<String, dynamic>)).toList();
    }
    final kitRaw = StorageService.instance.getString('${SKeys.sensoryKit}_$userEmail');
    if (kitRaw != null) {
      final list = jsonDecode(kitRaw) as List;
      sensoryKit = list.map((e) => e.toString()).toList();
    }
    notifRead = StorageService.instance.getString('${SKeys.notifRead}_$userEmail') == '1';
  }

  Future<void> logout() async {
    loggedIn = false;
    userEmail = '';
    await StorageService.instance.remove(SKeys.session);
  }

  void resetForNewUser() {
    episodes = [];
    chatMessages = [ChatMsg(false, tr('chat_welcome'))];
    children = [ChildProfile(name: '', age: '', gender: 'мальчик', diagnosis: [])];
    activeChildIndex = 0;
    sensoryKit = [tr('sensory_default_item')];
  }
}

const List<String> diagOptions = [
  'РАС / Аутизм',
  'СДВГ',
  'Задержка речи',
  'Сенсорные нарушения',
  'Задержка развития',
  'Синдром Дауна',
  'Нет диагноза',
  'Другое',
];

String diagLabel(String canonicalRu) {
  const map = {
    'РАС / Аутизм': 'diag_autism',
    'СДВГ': 'diag_adhd',
    'Задержка речи': 'diag_speech',
    'Сенсорные нарушения': 'diag_sensory',
    'Задержка развития': 'diag_devdelay',
    'Синдром Дауна': 'diag_down',
    'Нет диагноза': 'diag_none',
    'Другое': 'diag_other',
  };
  final key = map[canonicalRu];
  if (key == null) return canonicalRu;
  return tr(key);
}

String resolveCategory(String? trigger) {
  if (trigger == null || trigger.trim().isEmpty) return 'НЕ ОПРЕДЕЛЕНО';
  final t = trigger.toLowerCase();
  if (t.contains('звук') || t.contains('шум') || t.contains('громк') || t.contains('объявл') || t.contains('музык') || t.contains('свет') || t.contains('ярк')) {
    return 'СЕНСОРНОЕ';
  }
  if (t.contains('люд') || t.contains('толп') || t.contains('обстанов')) {
    return 'СРЕДА';
  }
  if (t.contains('переход') || t.contains('переключ')) {
    return 'ПЕРЕХОД';
  }
  if (t.contains('устал') || t.contains('сон')) {
    return 'СОСТОЯНИЕ';
  }
  return 'НЕ ОПРЕДЕЛЕНО';
}

Color categoryColor(String cat) {
  switch (cat) {
    case 'СЕНСОРНОЕ':
      return const Color(0xFF6D4FCF);
    case 'СРЕДА':
      return const Color(0xFFC2762A);
    case 'ПЕРЕХОД':
      return const Color(0xFF2B8CC4);
    case 'СОСТОЯНИЕ':
      return const Color(0xFF64748B);
    default:
      return const Color(0xFF94A3B8);
  }
}

String categoryLabel(String cat) {
  switch (cat) {
    case 'СЕНСОРНОЕ':
      return tr('cat_sensory');
    case 'СРЕДА':
      return tr('cat_environment');
    case 'ПЕРЕХОД':
      return tr('cat_transition');
    case 'СОСТОЯНИЕ':
      return tr('cat_state');
    default:
      return tr('cat_unknown');
  }
}

double categoryWeight(String cat) {
  switch (cat) {
    case 'СЕНСОРНОЕ':
      return 0.9;
    case 'СРЕДА':
      return 0.6;
    case 'ПЕРЕХОД':
      return 0.45;
    case 'СОСТОЯНИЕ':
      return 0.35;
    default:
      return 0.2;
  }
}

final List<ArticleItem> articles = [
  ArticleItem('Почему дети «перегружаются» от звуков и света', 'Что происходит с ребёнком во время сильной перегрузки и почему это не каприз.', 'Сенсорика', const Color(0xFF1F9070), '4 мин', 'https://pedsovet.org/article/cto-takoe-sensornaa-peregruzka-u-detej-i-kak-s-nej-rabotat'),
  ArticleItem('Как помочь ребёнку переключаться между делами', 'Конкретные приёмы для снижения истерик при смене занятий.', 'Переходы', const Color(0xFFD97706), '5 мин', 'https://moaplaneta.com/'),
  ArticleItem('Почему дети бьются головой в сложные моменты', 'Что это означает и как спокойно и безопасно реагировать.', 'Поведение', const Color(0xFFC0392B), '6 мин', 'https://letidor.ru/'),
  ArticleItem('Научите ребёнка просить перерыв', 'Простой жест или карточка, чтобы ребёнок мог попросить о помощи до кризиса.', 'Коммуникация', const Color(0xFF2563EB), '4 мин', 'https://autismjournal.help/'),
  ArticleItem('Сон и поведение, прямая связь', 'Как выстроить режим сна, который работает для детей с аутизмом.', 'Сон', const Color(0xFF5B21B6), '5 мин', 'https://aba-kurs.com/'),
  ArticleItem('Что такое сенсорная диета и как её попросить', 'Простое объяснение и вопросы для первого приёма у ОТ.', 'Терапия', const Color(0xFFEA580C), '7 мин', 'https://autism-frc.ru/'),
];
