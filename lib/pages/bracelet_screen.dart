import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../l10n/strings.dart';
import '../widgets/fade_slide_in.dart';

class BraceletScreen extends StatefulWidget {
  const BraceletScreen({super.key});

  @override
  State<BraceletScreen> createState() => _BraceletScreenState();
}

class _BraceletScreenState extends State<BraceletScreen> with SingleTickerProviderStateMixin {
  late final AnimationController ringCtrl;

  @override
  void initState() {
    super.initState();
    ringCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 18, 4),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: kInk), onPressed: () => Navigator.pop(context)),
                const Spacer(),
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 30),
                children: [
                  Center(
                    child: FadeSlideIn(
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(alignment: Alignment.center, children: [
                          AnimatedBuilder(
                            animation: ringCtrl,
                            builder: (c, child) {
                              return Transform.rotate(
                                angle: ringCtrl.value * 6.283,
                                child: Container(
                                  width: 160, height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: SweepGradient(colors: [kTealBg, kTeal2.withValues(alpha: 0.7), kTeal, kTealBg]),
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
                            width: 132, height: 132,
                            decoration: const BoxDecoration(color: kBg, shape: BoxShape.circle),
                          ),
                          Container(
                            width: 112, height: 112,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [kTeal2, kTeal]),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: kTeal.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))],
                            ),
                            child: const Icon(Icons.watch_rounded, color: Colors.white, size: 52),
                          ),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: kTealBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: kTeal.withValues(alpha: 0.3))),
                        child: Text(tr('bracelet_badge'), style: const TextStyle(color: kTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    child: Text(tr('bracelet_title'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kInk, letterSpacing: -0.5)),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 160),
                    child: Text(tr('bracelet_intro'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.6)),
                  ),
                  const SizedBox(height: 26),
                  FadeSlideIn(delay: const Duration(milliseconds: 200), child: infoCard(Icons.psychology_alt_outlined, tr('bracelet_why_title'), tr('bracelet_why_body'), const Color(0xFF5B21B6), const Color(0xFFF8F5FF))),
                  const SizedBox(height: 12),
                  FadeSlideIn(delay: const Duration(milliseconds: 240), child: infoCard(Icons.construction_outlined, tr('bracelet_dev_title'), tr('bracelet_dev_body'), const Color(0xFFD97706), const Color(0xFFFFFBEB))),
                  const SizedBox(height: 18),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 280),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), border: Border.all(color: const Color(0xFFFECACA)), borderRadius: BorderRadius.circular(14)),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.info_outline, size: 16, color: Color(0xFFC0392B)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(tr('bracelet_disclaimer'), style: const TextStyle(fontSize: 12, color: Color(0xFF7F1D1D), height: 1.5))),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 320),
                    child: Center(
                      child: Text(tr('follow_title'), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 340),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      followBtn(Icons.public, tr('follow_website'), openWebsite),
                      const SizedBox(width: 10),
                      followBtn(Icons.camera_alt_outlined, tr('follow_instagram'), openInstagram),
                    ]),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void openWebsite() async {
    final uri = Uri.parse('https://qushaq.app');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void openInstagram() async {
    final uri = Uri.parse('https://www.instagram.com/qushaq.app');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget followBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(24)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: kTeal),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: kInk)),
        ]),
      ),
    );
  }

  Widget infoCard(IconData icon, String title, String body, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withValues(alpha: 0.15))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color))),
          ]),
          const SizedBox(height: 10),
          Text(body, style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.55)),
        ],
      ),
    );
  }
}
