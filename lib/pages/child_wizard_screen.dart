import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_data.dart';
import '../l10n/strings.dart';
import '../widgets/primary_button.dart';

enum WizardMode { newAccount, addChild, editChild }

class ChildWizardScreen extends StatefulWidget {
  final WizardMode mode;
  const ChildWizardScreen({super.key, required this.mode});

  @override
  State<ChildWizardScreen> createState() => _ChildWizardScreenState();
}

class _ChildWizardScreenState extends State<ChildWizardScreen> {
  int step = 0;
  final nameCtrl = TextEditingController();
  double age = 4;
  String gender = 'мальчик';
  Set<String> selectedDiag = {};
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final passCtrl2 = TextEditingController();
  String? err;
  bool busy = false;

  int get totalSteps => widget.mode == WizardMode.newAccount ? 4 : 3;

  @override
  void initState() {
    super.initState();
    if (widget.mode == WizardMode.editChild) {
      final d = AppData.instance;
      nameCtrl.text = d.childName;
      age = double.tryParse(d.childAge) ?? 4;
      gender = d.childGender;
      selectedDiag = d.diagnosis.toSet();
    }
  }

  void next() async {
    if (step == 0 && nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('onb_name_hint'))));
      return;
    }
    if (step < totalSteps - 1) {
      setState(() => step++);
      return;
    }
    await finish();
  }

  void back() {
    if (step == 0) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else if (widget.mode == WizardMode.editChild) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (r) => false);
      }
      return;
    }
    setState(() => step--);
  }

  Future<void> finish() async {
    final name = nameCtrl.text.trim().isEmpty ? tr('common_child_fallback') : nameCtrl.text.trim();
    final ageStr = age.round().toString();
    final diag = selectedDiag.toList();

    if (widget.mode == WizardMode.newAccount) {
      final email = emailCtrl.text.trim().toLowerCase();
      final pass = passCtrl.text;
      final pass2 = passCtrl2.text;
      if (email.isEmpty || pass.isEmpty) {
        setState(() => err = tr('err_enter_email_pass'));
        return;
      }
      if (!email.contains('@') || !email.contains('.')) {
        setState(() => err = tr('err_real_email'));
        return;
      }
      if (pass.length < 8) {
        setState(() => err = tr('err_password_min'));
        return;
      }
      if (pass != pass2) {
        setState(() => err = tr('err_password_mismatch'));
        return;
      }
      setState(() => busy = true);
      final failMsg = await AppData.instance.tryRegister(email, pass);
      if (!mounted) return;
      setState(() => busy = false);
      if (failMsg != null) {
        setState(() => err = failMsg);
        return;
      }
      AppData.instance.childName = name;
      AppData.instance.childAge = ageStr;
      AppData.instance.childGender = gender;
      AppData.instance.diagnosis = diag;
      await AppData.instance.saveChild();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/main', (r) => false);
    } else if (widget.mode == WizardMode.addChild) {
      await AppData.instance.addChild(ChildProfile(name: name, age: ageStr, gender: gender, diagnosis: diag));
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      AppData.instance.childName = name;
      AppData.instance.childAge = ageStr;
      AppData.instance.childGender = gender;
      AppData.instance.diagnosis = diag;
      await AppData.instance.saveChild();
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (r) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 20, 0),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: kInk), onPressed: back),
                const Spacer(),
                Row(children: List.generate(totalSteps, (i) => dot(i <= step))),
              ]),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(key: ValueKey(step), child: buildStep()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 20 : 7,
      height: 7,
      decoration: BoxDecoration(color: active ? kTeal : kLine, borderRadius: BorderRadius.circular(4)),
    );
  }

  Widget buildStep() {
    switch (step) {
      case 0:
        return step1();
      case 1:
        return step2();
      case 2:
        return step3();
      default:
        return step4();
    }
  }

  Widget wizardScaffold({required IconData icon, required String title, String? sub, required Widget body}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [kTeal2, kTeal]), borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kInk)),
          if (sub != null) ...[
            const SizedBox(height: 8),
            Text(sub, style: const TextStyle(color: kInk3, fontSize: 13.5, height: 1.4)),
          ],
          const SizedBox(height: 26),
          body,
        ],
      ),
    );
  }

  Widget step1() {
    return wizardScaffold(
      icon: Icons.sentiment_satisfied_alt,
      title: tr('onb_step1_title'),
      sub: tr('onb_step1_sub'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('onb_name_label'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kInk3)),
          const SizedBox(height: 6),
          TextField(
            controller: nameCtrl,
            autofocus: true,
            decoration: InputDecoration(hintText: tr('onb_name_hint'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kLine))),
          ),
          const SizedBox(height: 20),
          Text(tr('onb_gender_label'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kInk3)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: genderBtn('мальчик', tr('onb_boy'))),
            const SizedBox(width: 8),
            Expanded(child: genderBtn('девочка', tr('onb_girl'))),
          ]),
          const SizedBox(height: 30),
          PrimaryButton(label: tr('onb_next_btn'), onPressed: next),
        ],
      ),
    );
  }

  Widget genderBtn(String g, String label) {
    final on = gender == g;
    return GestureDetector(
      onTap: () => setState(() => gender = g),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: on ? kTealBg : Colors.white,
          border: Border.all(color: on ? kTeal : kLine, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: on ? kTeal : kInk3)),
      ),
    );
  }

  Widget step2() {
    return wizardScaffold(
      icon: Icons.cake_outlined,
      title: tr('onb_step2_title'),
      sub: tr('onb_step2_sub'),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              roundBtn(Icons.remove, () => setState(() => age = (age - 1).clamp(1, 18))),
              const SizedBox(width: 24),
              Text('${age.round()}', style: const TextStyle(fontSize: 46, fontWeight: FontWeight.bold, color: kTeal)),
              const SizedBox(width: 24),
              roundBtn(Icons.add, () => setState(() => age = (age + 1).clamp(1, 18))),
            ],
          ),
          const SizedBox(height: 24),
          Slider(
            value: age,
            min: 1,
            max: 18,
            divisions: 17,
            activeColor: kTeal2,
            inactiveColor: kLine,
            onChanged: (v) => setState(() => age = v),
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: tr('onb_next_btn'), onPressed: next),
        ],
      ),
    );
  }

  Widget roundBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: kTealBg, shape: BoxShape.circle),
        child: Icon(icon, color: kTeal, size: 20),
      ),
    );
  }

  Widget step3() {
    return wizardScaffold(
      icon: Icons.extension_outlined,
      title: tr('onb_step3_title'),
      sub: tr('onb_diag_note'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: diagOptions.map((d) => diagChip(d)).toList(),
          ),
          const SizedBox(height: 20),
          Text(tr('onb_privacy_note'), style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
          const SizedBox(height: 24),
          PrimaryButton(label: widget.mode == WizardMode.newAccount ? tr('onb_next_btn') : tr('onb_start_btn'), onPressed: next),
        ],
      ),
    );
  }

  Widget diagChip(String d) {
    final on = selectedDiag.contains(d);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (on) {
            selectedDiag.remove(d);
          } else {
            selectedDiag.add(d);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: on ? kTealBg : Colors.white,
          border: Border.all(color: on ? kTeal : kLine, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(diagLabel(d), style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: on ? kTeal : kInk3)),
      ),
    );
  }

  Widget step4() {
    return wizardScaffold(
      icon: Icons.lock_outline,
      title: tr('onb_step4_title'),
      sub: tr('onb_step4_sub'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (err != null)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
              child: Text(err!, style: const TextStyle(color: Color(0xFFC0392B), fontSize: 12.5)),
            ),
          Text(tr('label_email'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kInk3)),
          const SizedBox(height: 6),
          TextField(controller: emailCtrl, decoration: InputDecoration(hintText: 'example@mail.com', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kLine)))),
          const SizedBox(height: 14),
          Text(tr('label_password'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kInk3)),
          const SizedBox(height: 6),
          TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(hintText: tr('register_password_hint'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kLine)))),
          const SizedBox(height: 14),
          Text(tr('label_confirm_password'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kInk3)),
          const SizedBox(height: 6),
          TextField(controller: passCtrl2, obscureText: true, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kLine)))),
          const SizedBox(height: 24),
          PrimaryButton(label: tr('register_btn'), onPressed: next, loading: busy),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              child: Text(tr('already_have_account'), style: const TextStyle(color: kTeal, fontWeight: FontWeight.w600)),
            ),
          )
        ],
      ),
    );
  }
}
