import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../l10n/strings.dart';

class SupportContactsScreen extends StatelessWidget {
  const SupportContactsScreen({super.key});

  void call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {'name': tr('support_psych_name'), 'sub': tr('support_psych_sub'), 'phone': '150'},
      {'name': tr('support_child_name'), 'sub': tr('support_child_sub'), 'phone': '111'},
      {'name': tr('support_ambulance_name'), 'sub': tr('support_ambulance_sub'), 'phone': '103'},
    ];

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: kInk),
        title: Text(tr('support_title'), style: const TextStyle(color: kInk, fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: const Color(0xFFFFF7ED), border: Border.all(color: const Color(0xFFFCD34D)), borderRadius: BorderRadius.circular(14)),
            child: Text(tr('support_warning'), style: const TextStyle(fontSize: 12.5, color: Color(0xFF78350F))),
          ),
          ...contacts.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: kTealBg, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.call, color: kTeal, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c['name']!, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                      Text(c['sub']!, style: const TextStyle(fontSize: 11.5, color: kInk3)),
                    ]),
                  ),
                  GestureDetector(
                    onTap: () => call(c['phone']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(color: kTeal, borderRadius: BorderRadius.circular(20)),
                      child: Text(c['phone']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  )
                ]),
              )),
        ],
      ),
    );
  }
}
