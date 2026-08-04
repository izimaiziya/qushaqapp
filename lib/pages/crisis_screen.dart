import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_data.dart';
import '../l10n/strings.dart';
import 'log_episode_screen.dart';

class CrisisScreen extends StatelessWidget {
  const CrisisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = AppData.instance.hasChild ? AppData.instance.childName : tr('common_child_fallback');
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 13, 18, 15),
              color: const Color(0xFFDC2626),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text('$name ${tr('crisis_child_hard_moment')}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                        ]),
                        const SizedBox(height: 3),
                        Text(tr('crisis_follow_steps'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.4))),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFFF7ED), border: Border.all(color: const Color(0xFFFCD34D), width: 1.5), borderRadius: BorderRadius.circular(12)),
                    child: Text('🫁 ${tr('crisis_calm_note')}, $name ${tr('crisis_calm_note_2')}', style: const TextStyle(fontSize: 13, color: Color(0xFF78350F))),
                  ),
                  const SizedBox(height: 16),
                  Text(tr('crisis_steps_label'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: kInk3, letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  crisisStep(1, tr('crisis_step1_title'), tr('crisis_step1_desc')),
                  crisisStep(2, tr('crisis_step2_title'), tr('crisis_step2_desc')),
                  crisisStep(3, tr('crisis_step3_title'), tr('crisis_step3_desc')),
                  crisisStep(4, tr('crisis_step4_title'), tr('crisis_step4_desc')),
                  crisisStep(5, tr('crisis_step5_title'), tr('crisis_step5_desc')),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(11),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                    child: Text(tr('crisis_disclaimer'), style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.5)),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => LogEpisodeScreen()));
                      },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 13), side: const BorderSide(color: kLine), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: Text(tr('crisis_log_btn'), style: const TextStyle(color: kTeal, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: Text(tr('crisis_gotit_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget crisisStep(int n, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
            child: Text('$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
