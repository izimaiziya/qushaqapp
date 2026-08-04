import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_data.dart';
import '../l10n/strings.dart';
import '../widgets/fade_slide_in.dart';
import 'crisis_screen.dart';
import 'main_shell.dart';
import 'bracelet_screen.dart';
import 'breathing_screen.dart';
import 'log_episode_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String observeText() {
    final data = AppData.instance;
    if (data.activeChildEpisodes.isEmpty) return tr('home_observed_empty');
    final counts = <String, int>{};
    for (var e in data.activeChildEpisodes) {
      final t = (e.trigger ?? '').toLowerCase();
      if (t.isEmpty) continue;
      counts[t] = (counts[t] ?? 0) + 1;
    }
    if (counts.isEmpty) return tr('home_observed_empty');
    var top = counts.keys.first;
    var topN = 0;
    counts.forEach((k, v) {
      if (v > topN) { top = k; topN = v; }
    });
    final cat = resolveCategory(top);
    switch (cat) {
      case 'СЕНСОРНОЕ':
        return _noticeText('sensory');
      case 'СРЕДА':
        return _noticeText('environment');
      case 'ПЕРЕХОД':
        return _noticeText('transition');
      case 'СОСТОЯНИЕ':
        return _noticeText('state');
      default:
        return '${_noticeText('generic')}: $top';
    }
  }

  String _noticeText(String kind) {
    final lang = AppData.instance.lang;
    final map = {
      'sensory': {
        'ru': 'Замечено: сложные ситуации чаще в шумных местах',
        'kk': 'Байқалды: қиын жағдайлар көбіне шулы жерлерде болады',
        'en': 'Noticed: tough moments happen more often in loud places',
      },
      'environment': {
        'ru': 'Сложные ситуации чаще происходят в людных местах',
        'kk': 'Қиын жағдайлар көбіне адам көп жерлерде болады',
        'en': 'Tough moments happen more often in crowded places',
      },
      'transition': {
        'ru': 'Сложности возникают при смене деятельности',
        'kk': 'Қиындықтар іс-әрекет ауысқанда туындайды',
        'en': 'Difficulties tend to come up when switching activities',
      },
      'state': {
        'ru': 'Сложные моменты связаны с усталостью',
        'kk': 'Қиын сәттер шаршаумен байланысты',
        'en': 'Tough moments are linked to tiredness',
      },
      'generic': {
        'ru': 'Замечен повторяющийся триггер',
        'kk': 'Қайталанатын себепкер байқалды',
        'en': 'Noticed a recurring trigger',
      },
    };
    return map[kind]![lang] ?? map[kind]!['ru']!;
  }

  Widget secRow(IconData icon, Color color, Color bg, String title, String sub, VoidCallback onTap) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(sub, style: const TextStyle(fontSize: 11.5, color: kInk3)),
            ]),
          ),
          const Icon(Icons.chevron_right, color: kInk3)
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    final avatar = data.childGender == 'девочка' ? '👧' : '👦';
    final lastEp = data.activeChildEpisodes.isNotEmpty ? data.activeChildEpisodes.last : null;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Row(
                children: [
                  Image.asset('assets/images/logo.png', width: 30, height: 30, fit: BoxFit.contain),
                  const SizedBox(width: 9),
                  Text(tr('app_name'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kInk)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      final shell = context.findAncestorStateOfType<MainShellState>();
                      shell?.goTo(4);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kLine)),
                      child: Row(children: [
                        Text(avatar, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                          Text(data.childLabel(), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: kInk)),
                          Text(data.diagnosisLabel(), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        ]),
                        const SizedBox(width: 4),
                        Text(tr('common_change'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kTeal)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      openNotifications(context);
                      setState(() {});
                    },
                    child: Stack(clipBehavior: Clip.none, children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: kLine)),
                        child: Icon(data.notifRead ? Icons.notifications_none_rounded : Icons.notifications_rounded, size: 17, color: kInk3),
                      ),
                      if (!data.notifRead)
                        Positioned(
                          top: -2, right: -2,
                          child: Container(width: 9, height: 9, decoration: BoxDecoration(color: const Color(0xFFDC2626), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5))),
                        )
                    ]),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('home_heading'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kInk)),
                  const SizedBox(height: 5),
                  Text(tr('home_heading_sub'), style: const TextStyle(fontSize: 13.5, color: kInk3)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Column(
                children: [
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: PulseGlow(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (c) => CrisisScreen()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFB91C1C)]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: const Color(0xFFDC2626).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 6))],
                          ),
                          child: Row(children: [
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
                              child: const Icon(Icons.warning_rounded, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(tr('home_crisis_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 3),
                                Text(tr('home_crisis_sub'), style: const TextStyle(fontSize: 12.5, color: Colors.white70)),
                              ]),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white)
                          ]),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    child: GestureDetector(
                      onTap: () {
                        final shell = context.findAncestorStateOfType<MainShellState>();
                        shell?.goTo(1);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [kTeal2, kTeal]),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(children: [
                          Container(
                            width: 46, height: 46,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
                            child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(tr('home_chat_title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 2),
                              Text(tr('home_chat_sub'), style: const TextStyle(fontSize: 11.5, color: Colors.white70)),
                            ]),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.white)
                        ]),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF8F5FF), border: Border.all(color: const Color(0xFFE9DDFE), width: 1.5), borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.remove_red_eye_outlined, size: 16, color: Color(0xFF5B21B6)),
                    const SizedBox(width: 6),
                    Text(tr('home_observed_label'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5B21B6), letterSpacing: 0.5)),
                  ]),
                  const SizedBox(height: 7),
                  Text(observeText(), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: kInk)),
                ]),
              ),
            ),
            if (lastEp != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(tr('home_last_episode_label'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kInk3)),
                      const Spacer(),
                      const Text('📋'),
                    ]),
                    const SizedBox(height: 6),
                    Text('${lastEp.place}, ${lastEp.trigger ?? lastEp.what}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          final shell = context.findAncestorStateOfType<MainShellState>();
                          shell?.goTo(1);
                        },
                        style: TextButton.styleFrom(backgroundColor: kTealBg, padding: const EdgeInsets.symmetric(vertical: 10)),
                        child: Text(tr('home_repeat_recs'), style: const TextStyle(color: kTeal, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    )
                  ]),
                ),
              ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [Expanded(child: Divider(color: kLine))]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Column(
                children: [
                  secRow(Icons.self_improvement, const Color(0xFF2563EB), const Color(0xFFEFF6FF), tr('breathing_title'), tr('home_breathing_sub'), () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => BreathingScreen()));
                  }),
                  const SizedBox(height: 8),
                  secRow(Icons.spa_outlined, const Color(0xFFD97706), const Color(0xFFFFFBEB), tr('profile_sensory_kit'), tr('home_sensory_sub'), () {
                    Navigator.pushNamed(context, '/sensory-kit');
                  }),
                  const SizedBox(height: 8),
                  secRow(Icons.show_chart, const Color(0xFF2563EB), const Color(0xFFEFF6FF), tr('home_history_title'), tr('home_history_sub'), () {
                    final shell = context.findAncestorStateOfType<MainShellState>();
                    shell?.goTo(2);
                  }),
                  const SizedBox(height: 8),
                  secRow(Icons.edit_note, kTeal, kTealBg, tr('home_add_episode_title'), tr('home_add_episode_sub'), () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => LogEpisodeScreen()));
                  }),
                ],
              ),
            ),
            Padding(

              padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => BraceletScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3F0D1F), kTeal]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.watch_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(tr('bracelet_home_card_title'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 3),
                        Text(tr('bracelet_home_card_sub'), style: const TextStyle(fontSize: 11.5, color: Colors.white70)),
                      ]),
                    ),
                  ]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

void openNotifications(BuildContext context) {
  final data = AppData.instance;
  data.notifRead = true;
  data.saveNotifRead();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (c) {
      final name = data.hasChild ? data.childName : tr('common_child_fallback');
      return Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(tr('notif_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const Spacer(),
              GestureDetector(onTap: () => Navigator.pop(c), child: const Icon(Icons.close, size: 20, color: kInk3)),
            ]),
            const SizedBox(height: 14),
            notifItem('🔔', const Color(0xFFF5F3FF), '${tr('notif_1_title_prefix')} $name', tr('notif_1_body')),
            const SizedBox(height: 10),
            notifItem('📘', kTealBg, tr('notif_2_title'), tr('notif_2_body')),
          ],
        ),
      );
    },
  );
}

Widget notifItem(String emoji, Color bg, String title, String body) {
  return Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(color: kBg, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(14)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 32, height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Text(emoji, style: const TextStyle(fontSize: 15)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(body, style: const TextStyle(fontSize: 11.5, color: kInk3, height: 1.4)),
        ]),
      )
    ]),
  );
}
