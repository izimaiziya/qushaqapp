import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../data/app_data.dart';
import '../l10n/strings.dart';
import '../widgets/fade_slide_in.dart';
import 'bracelet_screen.dart';
import 'child_wizard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void openInstagram() async {
    final uri = Uri.parse('https://www.instagram.com/mamapro_almaty');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void openWebsite() async {
    final uri = Uri.parse('https://qushaq.app');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void openProjectInstagram() async {
    final uri = Uri.parse('https://www.instagram.com/qushaq.app');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void logout() async {
    await AppData.instance.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  void switchChild(int i) async {
    await AppData.instance.switchChild(i);
    if (mounted) setState(() {});
  }

  void editChild(int i) async {
    await AppData.instance.switchChild(i);
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (c) => ChildWizardScreen(mode: WizardMode.editChild)));
    if (mounted) setState(() {});
  }

  void addChildFlow() async {
    await Navigator.push(context, MaterialPageRoute(builder: (c) => ChildWizardScreen(mode: WizardMode.addChild)));
    if (mounted) setState(() {});
  }

  void removeChild(int i) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(tr('remove_child_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(tr('common_cancel'))),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(tr('common_delete'), style: const TextStyle(color: Color(0xFFC0392B)))),
        ],
      ),
    );
    if (ok != true) return;
    await AppData.instance.removeChild(i);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    final avatar = data.childGender == 'девочка' ? '👧' : '👦';
    final colors = [kTeal, const Color(0xFFC0392B), const Color(0xFF2563EB), const Color(0xFFD97706), const Color(0xFF5B21B6)];

    return SafeArea(
      child: ListView(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
            decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: kLine))),
            child: Column(
              children: [
                Container(
                  width: 68, height: 68,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFCF6E), Color(0xFFF59E0B)]), shape: BoxShape.circle),
                  child: Text(avatar, style: const TextStyle(fontSize: 30)),
                ),
                const SizedBox(height: 11),
                Text(data.hasChild ? data.childName : tr('common_child_fallback'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text('${data.childAge} · ${data.diagnosisLabel()}', style: const TextStyle(fontSize: 12.5, color: kInk3)),
                const SizedBox(height: 11),
                Wrap(
                  spacing: 7, runSpacing: 7, alignment: WrapAlignment.center,
                  children: data.diagnosis.asMap().entries.map((e) {
                    final color = colors[e.key % colors.length];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                      child: Text(diagLabel(e.value), style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: logout,
                  child: Text(tr('profile_logout'), style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 18, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('children_label'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                const SizedBox(height: 9),
                ...data.children.asMap().entries.map((e) => childRow(e.key, e.value)),
                GestureDetector(
                  onTap: addChildFlow,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(border: Border.all(color: kLine, width: 1.5), borderRadius: BorderRadius.circular(18)),
                    child: Center(child: Text(tr('add_child_btn'), style: const TextStyle(color: kTeal, fontWeight: FontWeight.bold, fontSize: 13))),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 18, 15, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('profile_for_parents'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                const SizedBox(height: 9),
                secBtn(Icons.camera_alt_outlined, 'MamaPro Almaty', tr('profile_community_sub'), const Color(0xFFFD5949), openInstagram),
                const SizedBox(height: 22),
                Text(tr('profile_progress_label'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: kInk3, letterSpacing: 0.5)),
                const SizedBox(height: 9),
                Row(children: [
                  Expanded(child: statCard(Icons.bar_chart, kTeal, '8', tr('profile_weeks'), tr('profile_in_program'))),
                  const SizedBox(width: 9),
                  Expanded(child: statCard(Icons.access_time, const Color(0xFF2563EB), '2', tr('profile_sessions_week'), tr('profile_next_session'))),
                ]),
                const SizedBox(height: 22),
                Text(tr('profile_developing_label'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: kInk3, letterSpacing: 0.5)),
                const SizedBox(height: 9),
                progItem(tr('profile_self_regulation'), tr('profile_badge_good'), 0.44),
                progItem(tr('profile_ask_help'), tr('profile_badge_stable'), 0.38),
                progItem(tr('profile_transitions'), tr('profile_badge_emerging'), 0.30),
                const SizedBox(height: 22),
                secBtn(Icons.medical_services_outlined, tr('profile_support_contacts'), tr('profile_support_contacts_sub'), const Color(0xFFC0392B), () => Navigator.pushNamed(context, '/support-contacts')),
                const SizedBox(height: 6),
                secBtn(Icons.watch_later_outlined, tr('profile_routine'), tr('routine_subtitle'), const Color(0xFF2B8CC4), () {
                  Navigator.pushNamed(context, '/routine');
                }),
                const SizedBox(height: 6),
                secBtn(Icons.spa_outlined, tr('profile_sensory_kit'), tr('profile_sensory_kit_sub'), const Color(0xFFD97706), () => Navigator.pushNamed(context, '/sensory-kit')),
                const SizedBox(height: 6),
                secBtn(Icons.settings_outlined, tr('profile_settings'), tr('profile_settings_sub'), kInk3, () => Navigator.pushNamed(context, '/settings')),
                const SizedBox(height: 6),
                secBtn(Icons.watch_rounded, tr('bracelet_nav_label'), tr('bracelet_badge'), kTeal, () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => BraceletScreen()));
                }),
                const SizedBox(height: 30),
                Center(child: Text(tr('follow_title'), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  followBtn(Icons.public, tr('follow_website'), openWebsite),
                  const SizedBox(width: 10),
                  followBtn(Icons.camera_alt_outlined, tr('follow_instagram'), openProjectInstagram),
                ]),
              ],
            ),
          )
        ],
      ),
    );
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

  Widget childRow(int index, ChildProfile c) {
    final active = index == AppData.instance.activeChildIndex;
    final av = c.gender == 'девочка' ? '👧' : '👦';
    return GestureDetector(
      onTap: () => switchChild(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: active ? kTealBg : Colors.white,
          border: Border.all(color: active ? kTeal : kLine, width: active ? 1.5 : 1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(children: [
          Text(av, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name.isEmpty ? tr('common_child_fallback') : c.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
              Text(c.diagnosis.isEmpty ? c.age : '${c.age} · ${c.diagnosis.map(diagLabel).join(", ")}', style: const TextStyle(fontSize: 10.5, color: kInk3), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          GestureDetector(onTap: () => editChild(index), child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.edit_outlined, size: 16, color: kInk3))),
          if (AppData.instance.children.length > 1)
            GestureDetector(onTap: () => removeChild(index), child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.close, size: 16, color: Color(0xFF94A3B8)))),
        ]),
      ),
    );
  }

  Widget secBtn(IconData icon, String title, String sub, Color color, VoidCallback onTap) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
              Text(sub, style: const TextStyle(fontSize: 10.5, color: kInk3)),
            ]),
          ),
          const Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8))
        ]),
      ),
    );
  }

  Widget statCard(IconData icon, Color color, String value, String label, String note) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(height: 9),
          Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: kInk3)),
          const SizedBox(height: 2),
          Text(note, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: kTeal)),
        ],
      ),
    );
  }

  Widget progItem(String name, String badge, double v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: kTealBg, borderRadius: BorderRadius.circular(20)),
              child: Text(badge, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTeal)),
            )
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: v, minHeight: 7, backgroundColor: kLine, color: kTeal),
          )
        ],
      ),
    );
  }
}
