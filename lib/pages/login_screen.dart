import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_data.dart';
import '../l10n/strings.dart';
import '../widgets/primary_button.dart';
import 'child_wizard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool hidePass = true;
  bool busy = false;

  void doLogin() async {
    final email = emailCtrl.text.trim().toLowerCase();
    final pass = passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('err_enter_email_pass'))));
      return;
    }
    setState(() => busy = true);
    final ok = await AppData.instance.tryLogin(email, pass);
    if (!mounted) return;
    setState(() => busy = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('err_wrong_creds'))));
      return;
    }
    if (AppData.instance.hasChild) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', width: 26, height: 26, fit: BoxFit.contain),
            const SizedBox(width: 8),
            Text(tr('app_name'), style: const TextStyle(color: kInk, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: kInk),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('login_title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kInk)),
            const SizedBox(height: 6),
            Text(tr('login_sub'), style: const TextStyle(fontSize: 13.5, color: kInk3)),
            const SizedBox(height: 32),
            Text(tr('label_email'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kInk3, letterSpacing: 0.5)),
            const SizedBox(height: 7),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'example@mail.com',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kLine)),
              ),
            ),
            const SizedBox(height: 14),
            Text(tr('label_password'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kInk3, letterSpacing: 0.5)),
            const SizedBox(height: 7),
            TextField(
              controller: passCtrl,
              obscureText: hidePass,
              decoration: InputDecoration(
                hintText: '••••••••',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(hidePass ? Icons.visibility_off : Icons.visibility, size: 18),
                  onPressed: () => setState(() => hidePass = !hidePass),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kLine)),
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(label: tr('login_btn'), onPressed: doLogin, loading: busy),
            const SizedBox(height: 20),
            Row(children: [
              const Expanded(child: Divider()),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(tr('or_divider'), style: const TextStyle(fontSize: 11, color: kInk3))),
              const Expanded(child: Divider()),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ChildWizardScreen(mode: WizardMode.newAccount))),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: kLine), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(tr('create_account_btn'), style: const TextStyle(color: kInk, fontWeight: FontWeight.w600)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
