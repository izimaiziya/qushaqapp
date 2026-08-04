import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_data.dart';
import '../data/storage_service.dart';
import '../l10n/strings.dart';
import 'dart:convert';

class RoutineItem {
  String title;
  String time;
  bool reminder;

  RoutineItem({required this.title, required this.time, this.reminder = true});

  Map<String, dynamic> toJson() => {'title': title, 'time': time, 'reminder': reminder};
  factory RoutineItem.fromJson(Map<String, dynamic> j) => RoutineItem(
        title: j['title']?.toString() ?? '',
        time: j['time']?.toString() ?? '08:00',
        reminder: j['reminder'] == true,
      );
}

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  List<RoutineItem> items = [];
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  String get storeKey => 'qushaq_routine_${AppData.instance.userEmail}';

  void load() async {
    await StorageService.instance.init();
    final raw = StorageService.instance.getString(storeKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      items = list.map((e) => RoutineItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    items.sort((a, b) => a.time.compareTo(b.time));
    setState(() => loaded = true);
  }

  void save() {
    StorageService.instance.setString(storeKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  void addItem() async {
    final titleCtrl = TextEditingController();
    TimeOfDay picked = const TimeOfDay(hour: 8, minute: 0);
    final result = await showDialog<RoutineItem>(
      context: context,
      builder: (c) => StatefulBuilder(builder: (c, setD) {
        return AlertDialog(
          title: Text(tr('routine_add_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: titleCtrl, autofocus: true, decoration: InputDecoration(hintText: tr('routine_name_hint'))),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(context: c, initialTime: picked);
                  if (t != null) setD(() => picked = t);
                },
                child: Row(children: [
                  const Icon(Icons.access_time, size: 16, color: kTeal),
                  const SizedBox(width: 8),
                  Text('${tr('routine_time')}: ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}'),
                ]),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: Text(tr('common_cancel'))),
            TextButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                Navigator.pop(c, RoutineItem(title: titleCtrl.text.trim(), time: '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}'));
              },
              child: Text(tr('common_add')),
            ),
          ],
        );
      }),
    );
    if (result == null) return;
    setState(() {
      items.add(result);
      items.sort((a, b) => a.time.compareTo(b.time));
    });
    save();
  }

  void toggleReminder(int i) {
    setState(() => items[i].reminder = !items[i].reminder);
    save();
  }

  void removeItem(int i) {
    setState(() => items.removeAt(i));
    save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: kInk),
        title: Text(tr('routine_title'), style: const TextStyle(color: kInk, fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [IconButton(icon: const Icon(Icons.add, color: kInk), onPressed: addItem)],
      ),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('routine_subtitle'), style: const TextStyle(fontSize: 13, color: kInk3, height: 1.5)),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(child: Text(tr('routine_empty'), style: const TextStyle(color: Color(0xFF94A3B8)), textAlign: TextAlign.center)),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (c, i) {
                          final it = items[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(16)),
                            child: Row(children: [
                              Container(
                                width: 46,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(color: kTealBg, borderRadius: BorderRadius.circular(10)),
                                child: Text(it.time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTeal)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(it.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
                              Switch(
                                value: it.reminder,
                                activeColor: kTeal,
                                onChanged: (_) => toggleReminder(i),
                              ),
                              GestureDetector(onTap: () => removeItem(i), child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close, size: 16, color: Color(0xFF94A3B8)))),
                            ]),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
