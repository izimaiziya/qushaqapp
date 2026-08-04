import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../data/app_data.dart';
import '../l10n/strings.dart';
import '../widgets/fade_slide_in.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  void openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 13, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('learn_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(tr('learn_subtitle'), style: const TextStyle(fontSize: 12.5, color: kInk3)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 22),
              children: [
                Text(tr('learn_all_topics'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: kInk3, letterSpacing: 0.5)),
                const SizedBox(height: 9),
                ...articles.map((a) => articleCard(a)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget articleCard(ArticleItem a) {
    return TapScale(
      onTap: () => openLink(a.url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(16)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 4, height: 44, decoration: BoxDecoration(color: a.accent, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.category.toUpperCase(), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: a.accent, letterSpacing: 0.5)),
                  const SizedBox(height: 5),
                  Text(a.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.3)),
                  const SizedBox(height: 5),
                  Text(a.desc, style: const TextStyle(fontSize: 12, color: kInk3, height: 1.4)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.access_time, size: 12, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 3),
                    Text(a.time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                  ])
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 17, color: Color(0xFF94A3B8))
          ],
        ),
      ),
    );
  }
}
