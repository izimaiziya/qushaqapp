import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_data.dart';
import '../l10n/strings.dart';
import 'log_episode_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

const _monthsRu = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
const _monthsKk = ['қаң', 'ақп', 'нау', 'сәу', 'мам', 'мау', 'шіл', 'там', 'қыр', 'қаз', 'қар', 'жел'];
const _monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

List<String> _months() {
  switch (AppData.instance.lang) {
    case 'kk':
      return _monthsKk;
    case 'en':
      return _monthsEn;
    default:
      return _monthsRu;
  }
}

class _DiaryScreenState extends State<DiaryScreen> {
  String dominantCategory() {
    final counts = <String, int>{};
    for (var e in AppData.instance.activeChildEpisodes) {
      final cat = resolveCategory(e.trigger);
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    if (counts.isEmpty) return 'СЕНСОРНОЕ';
    var best = counts.keys.first;
    var bn = 0;
    counts.forEach((k, v) { if (v > bn) { best = k; bn = v; } });
    return best;
  }

  String mostFrequentTrigger(List<Episode> eps) {
    final counts = <String, int>{};
    for (var e in eps) {
      final t = e.trigger;
      if (t == null || t.trim().isEmpty) continue;
      counts[t] = (counts[t] ?? 0) + 1;
    }
    if (counts.isEmpty) return tr('diary_stat_none');
    var best = counts.keys.first;
    var bn = 0;
    counts.forEach((k, v) { if (v > bn) { best = k; bn = v; } });
    return best;
  }

  int averageDuration(List<Episode> eps) {
    if (eps.isEmpty) return 0;
    final total = eps.fold<int>(0, (sum, e) => sum + e.durationMin);
    return (total / eps.length).round();
  }

  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    final eps = List<Episode>.from(data.activeChildEpisodes.reversed);
    final dom = dominantCategory();
    final months = _months();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kTeal,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (c) => LogEpisodeScreen()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 13, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${tr('diary_title_prefix')} ${data.hasChild ? data.childName : ''}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(tr('diary_subtitle'), style: const TextStyle(fontSize: 12.5, color: kInk3)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 22),
                children: [
                  Row(children: [
                    Expanded(child: diaryStatCard(Icons.bar_chart, const Color(0xFF2563EB), '${eps.length}', tr('diary_stat_count'))),
                    const SizedBox(width: 9),
                    Expanded(child: diaryStatCard(Icons.access_time, const Color(0xFFD97706), '${averageDuration(eps)} ${tr('minutes_short')}', tr('diary_stat_avg_duration'))),
                  ]),
                  const SizedBox(height: 9),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('diary_stat_frequent_trigger'), style: const TextStyle(fontSize: 11, color: kInk3, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(mostFrequentTrigger(eps), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kInk)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(tr('diary_noticed_label'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: kInk3, letterSpacing: 0.5)),
                  const SizedBox(height: 9),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(11)),
                            child: const Icon(Icons.show_chart, size: 19, color: Color(0xFF2563EB)),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              eps.isEmpty ? tr('diary_no_episodes_yet') : categoryLabel(dom),
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                              maxLines: 2,
                            ),
                          )
                        ]),
                        const SizedBox(height: 11),
                        if (eps.isEmpty)
                          Text(tr('diary_no_episodes_yet'), style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.5))
                        else
                          Text('${eps.length} · ${categoryLabel(dom)}', style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.5)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 60,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: eps.isEmpty
                                ? [Expanded(child: barWidget(0.3, categoryColor('НЕ ОПРЕДЕЛЕНО')))]
                                : eps.take(7).toList().reversed.map((e) {
                                    final cat = resolveCategory(e.trigger);
                                    final c = categoryColor(cat);
                                    return Expanded(child: barWidget(categoryWeight(cat), c));
                                  }).toList(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(spacing: 10, runSpacing: 6, children: [
                          legendDot(tr('cat_sensory'), categoryColor('СЕНСОРНОЕ')),
                          legendDot(tr('cat_environment'), categoryColor('СРЕДА')),
                          legendDot(tr('cat_transition'), categoryColor('ПЕРЕХОД')),
                          legendDot(tr('cat_state'), categoryColor('СОСТОЯНИЕ')),
                          legendDot(tr('cat_unknown'), categoryColor('НЕ ОПРЕДЕЛЕНО')),
                        ])
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(tr('diary_recent_label'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: kInk3, letterSpacing: 0.5)),
                  const SizedBox(height: 9),
                  if (eps.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(20)),
                      child: Center(child: Text(tr('diary_no_episodes'), style: const TextStyle(color: kInk3))),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: eps.asMap().entries.map((entry) {
                          final e = entry.value;
                          final last = entry.key == eps.length - 1;
                          final cat = resolveCategory(e.trigger);
                          return episodeRow(e, cat, last, months);
                        }).toList(),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget diaryStatCard(IconData icon, Color color, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: kInk)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10.5, color: kInk3, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget barWidget(double h, Color c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: FractionallySizedBox(
        heightFactor: h.clamp(0.1, 1.0),
        child: Container(decoration: BoxDecoration(color: c, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))),
      ),
    );
  }

  Widget legendDot(String label, Color c) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kInk3)),
    ]);
  }

  Widget episodeRow(Episode e, String cat, bool last, List<String> months) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: last ? Colors.transparent : const Color(0xFFF1F5F9)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Column(children: [
              Text('${e.date.day}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(months[e.date.month - 1], style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: kInk3)),
            ]),
          ),
          const SizedBox(width: 10),
          Container(width: 10, height: 10, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(color: categoryColor(cat), shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.place, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('${e.what} · ${e.durationMin} ${tr('minutes_short')}', style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                if (e.trigger != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: categoryColor(cat).withValues(alpha: 0.1), border: Border.all(color: categoryColor(cat).withValues(alpha: 0.4)), borderRadius: BorderRadius.circular(20)),
                    child: Text(e.trigger!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: categoryColor(cat))),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
