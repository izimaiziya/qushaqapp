import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n/strings.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController ctrl;
  bool running = false;
  int cycles = 0;
  String phase = '';

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    ctrl.addStatusListener((status) {
      if (!running) return;
      if (status == AnimationStatus.completed) {
        setState(() => phase = tr('breathing_out'));
        ctrl.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          cycles++;
          phase = tr('breathing_in');
        });
        ctrl.forward();
      }
    });
  }

  void toggle() {
    setState(() => running = !running);
    if (running) {
      phase = tr('breathing_in');
      ctrl.forward();
    } else {
      ctrl.stop();
      phase = '';
    }
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: kInk),
        title: Text(tr('breathing_title'), style: const TextStyle(color: kInk, fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
            child: Text(tr('breathing_intro'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 13.5, color: kInk3, height: 1.5)),
          ),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: ctrl,
                builder: (c, child) {
                  final scale = 0.55 + ctrl.value * 0.45;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 240, height: 240,
                        child: Center(
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 200, height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(colors: [kTeal2, kTeal]),
                                boxShadow: [BoxShadow(color: kTeal.withValues(alpha: 0.35), blurRadius: 40, spreadRadius: 4)],
                              ),
                              child: Center(
                                child: Text(
                                  running ? phase : '🫶',
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (running) Text('$cycles ${tr('breathing_cycles')}', style: const TextStyle(color: kInk3, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: toggle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: running ? const Color(0xFFDC2626) : kTeal2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(running ? tr('breathing_stop') : tr('breathing_start'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
