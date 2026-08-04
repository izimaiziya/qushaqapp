import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_data.dart';
import '../l10n/strings.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/primary_button.dart';

class LogEpisodeScreen extends StatefulWidget {
  const LogEpisodeScreen({super.key});

  @override
  State<LogEpisodeScreen> createState() => _LogEpisodeScreenState();
}

List<List<String>> tagOptions() => [
      ['tag_loud_sound', 'Громкий звук'],
      ['tag_env_change', 'Смена обстановки'],
      ['tag_crowd', 'Много людей'],
      ['tag_tired', 'Усталость'],
      ['tag_transition', 'Переход между делами'],
      ['tag_bright_light', 'Яркий свет'],
    ];

class _LogEpisodeScreenState extends State<LogEpisodeScreen> {
  DateTime pickedDate = DateTime.now();
  final placeCtrl = TextEditingController();
  final whatCtrl = TextEditingController();
  final triggerCtrl = TextEditingController();
  String? activeTag;
  double duration = 10;

  Future pickDate() async {
    final d = await showDatePicker(context: context, initialDate: pickedDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (d != null) setState(() => pickedDate = d);
  }

  void saveEpisode() async {
    final place = placeCtrl.text.trim().isEmpty ? tr('not_specified') : placeCtrl.text.trim();
    final what = whatCtrl.text.trim().isEmpty ? tr('not_specified') : whatCtrl.text.trim();
    final trig = triggerCtrl.text.trim().isEmpty ? null : triggerCtrl.text.trim();

    AppData.instance.episodes.add(Episode(date: pickedDate, place: place, what: what, trigger: trig, durationMin: duration.round(), childId: AppData.instance.activeChildId));
    await AppData.instance.saveEpisodes();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('log_saved_toast'))));
    Navigator.popUntil(context, (route) => route.settings.name == '/main' || route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: kInk),
        title: Text(tr('log_episode_title'), style: const TextStyle(color: kInk, fontSize: 17, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FadeSlideIn(delay: const Duration(milliseconds: 40), child: field(tr('log_date'), GestureDetector(
            onTap: pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: kLine)),
              child: Text('${pickedDate.day.toString().padLeft(2, '0')}.${pickedDate.month.toString().padLeft(2, '0')}.${pickedDate.year}'),
            ),
          ))),
          FadeSlideIn(delay: const Duration(milliseconds: 90), child: field(tr('log_place'), TextField(
            controller: placeCtrl,
            decoration: inputDeco(tr('log_place_hint')),
          ))),
          FadeSlideIn(delay: const Duration(milliseconds: 140), child: field(tr('log_what'), TextField(
            controller: whatCtrl,
            maxLines: 3,
            decoration: inputDeco(tr('log_what_hint')),
          ))),
          FadeSlideIn(delay: const Duration(milliseconds: 190), child: field(tr('log_trigger'), Column(
            children: [
              TextField(controller: triggerCtrl, decoration: inputDeco(tr('log_trigger_hint'))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tagOptions().map((t) {
                  final label = tr(t[0]);
                  final canonical = t[1];
                  final active = activeTag == canonical;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        activeTag = canonical;
                        triggerCtrl.text = canonical;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: active ? kTealBg : Colors.white,
                        border: Border.all(color: active ? kTeal : kLine, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: active ? kTeal : kInk3)),
                    ),
                  );
                }).toList(),
              )
            ],
          ))),
          FadeSlideIn(
            delay: const Duration(milliseconds: 220),
            child: field(
              '${tr('log_duration')}: ${duration.round()} ${tr('minutes_short')}',
              Slider(
                value: duration,
                min: 1,
                max: 90,
                divisions: 89,
                activeColor: kTeal2,
                inactiveColor: kLine,
                onChanged: (v) => setState(() => duration = v),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeSlideIn(
            delay: const Duration(milliseconds: 240),
            child: PrimaryButton(label: tr('log_save_btn'), onPressed: saveEpisode),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: kLine), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(tr('common_cancel'), style: const TextStyle(color: kInk3, fontWeight: FontWeight.w600)),
            ),
          )
        ],
      ),
    );
  }

  InputDecoration inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kLine)),
    );
  }

  Widget field(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kInk3, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
