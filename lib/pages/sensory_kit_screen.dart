import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_data.dart';
import '../l10n/strings.dart';

class SensoryKitScreen extends StatefulWidget {
  const SensoryKitScreen({super.key});

  @override
  State<SensoryKitScreen> createState() => _SensoryKitScreenState();
}

class _SensoryKitScreenState extends State<SensoryKitScreen> {
  void addItem() async {
    final ctrl = TextEditingController();
    final res = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(tr('sensory_add_title')),
        content: TextField(controller: ctrl, autofocus: true, decoration: InputDecoration(hintText: tr('sensory_add_hint'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(tr('common_cancel'))),
          TextButton(onPressed: () => Navigator.pop(c, ctrl.text.trim()), child: Text(tr('common_add'))),
        ],
      ),
    );
    if (res == null || res.isEmpty) return;
    if (!mounted) return;
    setState(() => AppData.instance.sensoryKit.add(res));
    AppData.instance.saveSensoryKit();
  }

  void removeItem(int i) {
    setState(() => AppData.instance.sensoryKit.removeAt(i));
    AppData.instance.saveSensoryKit();
  }

  @override
  Widget build(BuildContext context) {
    final items = AppData.instance.sensoryKit;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: kInk),
        title: Text(tr('sensory_title'), style: const TextStyle(color: kInk, fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [IconButton(icon: const Icon(Icons.add, color: kInk), onPressed: addItem)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('sensory_subtitle'), style: const TextStyle(fontSize: 13, color: kInk3, height: 1.5)),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(child: Text(tr('sensory_empty'), style: const TextStyle(color: Color(0xFF94A3B8)))),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: items.asMap().entries.map((e) {
                  return Container(
                    width: 150,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFFFF7ED), border: Border.all(color: const Color(0xFFFED7AA)), borderRadius: BorderRadius.circular(16)),
                    child: Stack(children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => removeItem(e.key),
                          child: const Icon(Icons.close, size: 15, color: Color(0xFF94A3B8)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: kInk)),
                      ),
                    ]),
                  );
                }).toList(),
              )
          ],
        ),
      ),
    );
  }
}
