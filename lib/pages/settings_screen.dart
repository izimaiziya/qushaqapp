import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_data.dart';
import '../data/storage_service.dart';
import '../l10n/strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String appearance = 'light';

  void changeLang(String code) async {
    await AppData.instance.setLang(code);
    QushaqApp.localeNotifier.value = code;
    if (mounted) setState(() {});
  }

  void confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(tr('settings_clear_confirm_title')),
        content: Text(tr('settings_clear_confirm_body')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(tr('common_cancel'))),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(tr('common_delete'), style: const TextStyle(color: Color(0xFFC0392B)))),
        ],
      ),
    );
    if (ok != true) return;

    final email = AppData.instance.userEmail;
    await StorageService.instance.remove('${SKeys.child}_$email');
    await StorageService.instance.remove('${SKeys.episodes}_$email');
    await StorageService.instance.remove('${SKeys.chat}_$email');
    await StorageService.instance.remove('${SKeys.sensoryKit}_$email');
    AppData.instance.resetForNewUser();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = AppData.instance.lang;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: kInk),
        title: Text(tr('settings_title'), style: const TextStyle(color: kInk, fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(tr('settings_language'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: kInk3, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(children: [
            langChip('Русский', 'ru', currentLang),
            const SizedBox(width: 8),
            langChip('Қазақша', 'kk', currentLang),
            const SizedBox(width: 8),
            langChip('English', 'en', currentLang),
          ]),
          const SizedBox(height: 22),
          Text(tr('settings_appearance'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: kInk3, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(children: [
            optChip(tr('settings_light'), 'light', appearance, (v) => setState(() => appearance = v)),
            const SizedBox(width: 8),
            optChip(tr('settings_dark'), 'dark', appearance, (v) => setState(() => appearance = v)),
            const SizedBox(width: 8),
            optChip(tr('settings_system'), 'system', appearance, (v) => setState(() => appearance = v)),
          ]),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kLine)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('settings_about'), style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.5)),
              const SizedBox(height: 8),
              Text(tr('settings_version'), style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ]),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: confirmClear,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFC0392B)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(tr('settings_clear_data_btn'), style: const TextStyle(color: Color(0xFFC0392B), fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget langChip(String label, String code, String current) {
    final on = current == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => changeLang(code),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: on ? kTealBg : Colors.white,
            border: Border.all(color: on ? kTeal : kLine, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: on ? kTeal : kInk3)),
        ),
      ),
    );
  }

  Widget optChip(String label, String code, String current, Function(String) onTap) {
    final on = current == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(code),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: on ? kTealBg : Colors.white,
            border: Border.all(color: on ? kTeal : kLine, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: on ? kTeal : kInk3)),
        ),
      ),
    );
  }
}
