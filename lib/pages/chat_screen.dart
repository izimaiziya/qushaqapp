import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_data.dart';
import '../services/gemini_service.dart';
import '../l10n/strings.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class Resp {
  final String detect;
  final String intro;
  final List<Map<String, dynamic>> sections;
  final String followup;
  Resp(this.detect, this.intro, this.sections, this.followup);
}

final Map<String, Resp> resp = {
  'sensory': Resp(
    'Резкий громкий звук, сенсорная перегрузка',
    'Похоже, это была сенсорная перегрузка от резкого звука. Это не каприз, нервная система реагирует острее, чем у большинства детей.',
    [
      {'title': tr('resp_section_why'), 'type': 'bullets', 'items': ['Удары головой - способ справиться с перегрузкой, а не агрессия', 'Обычные наушники снижают общий шум, но не блокируют резкие звуки']},
      {'title': tr('resp_section_helps_now'), 'type': 'steps', 'items': ['Спокойно уйдите в тихое место, не торопитесь', 'Помолчите рядом, не объясняйте и не уговаривайте', 'Если бьётся, тихо скажите «руки отдыхают» один раз']},
      {'title': tr('resp_section_future'), 'type': 'bullets', 'items': ['Наушники с шумоподавлением, специально для резких звуков', 'Надевайте до входа в шумное место, не после']},
    ],
    'Это случилось сразу после звука или напряжение накапливалось до этого?',
  ),
  'sleep': Resp(
    'Возможно, связано с качеством сна',
    'Плохой сон сильно влияет на то, как ребёнок справляется со сложными ситуациями в течение дня.',
    [
      {'title': tr('resp_section_why'), 'type': 'bullets', 'items': ['Даже одна неспокойная ночь повышает чувствительность к стрессу', 'Свет или шум ночью могут мешать глубокому сну']},
      {'title': tr('resp_section_helps_now'), 'type': 'steps', 'items': ['Сохраняйте одинаковое время подъёма', 'Сегодня вечером затемните комнату и включите белый шум', 'Уберите экраны за 30 минут до сна']},
      {'title': tr('resp_section_future'), 'type': 'bullets', 'items': ['Одинаковое время подъёма каждый день, включая выходные', 'Простой ритуал перед сном в картинках, 3-4 шага']},
    ],
    'Ребёнку трудно уснуть вечером или он просыпается среди ночи?',
  ),
  'aba': Resp(
    'Возможно, нет способа попросить перерыв',
    'Скорее всего, у ребёнка пока нет простого способа сказать «мне нужно остановиться». Сложное поведение, это его язык.',
    [
      {'title': tr('resp_section_why'), 'type': 'bullets', 'items': ['Нет простого способа сказать «мне нужен перерыв»', 'Сложное поведение - единственный доступный ему сигнал']},
      {'title': tr('resp_section_helps_now'), 'type': 'steps', 'items': ['Введите простой сигнал «хочу перерыв»', 'Реагируйте сразу каждый раз, когда он его использует', 'Хвалите конкретно за использование сигнала']},
      {'title': tr('resp_section_future'), 'type': 'bullets', 'items': ['Практикуйте сигнал в спокойные моменты', 'Стоит найти специалиста с опытом в сенсорных особенностях']},
    ],
    'Бывало ли, что ребёнок по-своему давал понять, что ему нужна пауза?',
  ),
  'food': Resp(
    'Трудности с едой, частая ситуация при сенсорных особенностях',
    'Отказ от еды у детей с сенсорными особенностями это не каприз. Вкус, запах, текстура могут быть физически невыносимы.',
    [
      {'title': tr('resp_section_why'), 'type': 'bullets', 'items': ['Сенсорная чувствительность к текстуре, запаху или виду еды', 'Тревога и стресс подавляют аппетит']},
      {'title': tr('resp_section_helps_now'), 'type': 'steps', 'items': ['Не заставляйте и не уговаривайте', 'Предложите знакомые продукты без давления', 'Пусть ребёнок просто сидит за столом без требования есть']},
      {'title': tr('resp_section_future'), 'type': 'bullets', 'items': ['Медленно вводите новые продукты рядом с любимыми', 'Специалист может помочь с расширением рациона']},
    ],
    'Ребёнок полностью отказывается от новой еды или есть определённые продукты, которые он ест?',
  ),
  'default': Resp(
    'Анализирую ситуацию',
    'Я слышу вас. Давайте разберём вместе, это поможет найти точный ответ.',
    [
      {'title': tr('resp_section_watch_for'), 'type': 'bullets', 'items': ['Когда именно происходит: время дня, место, ситуация', 'Что было до этого: усталость, смена обстановки, еда', 'Как долго это продолжается и как часто повторяется']},
      {'title': tr('resp_section_now'), 'type': 'steps', 'items': ['Сохраняйте спокойствие', 'Не объясняйте и не уговаривайте в момент срыва', 'Опишите мне подробнее, я дам точные рекомендации']},
      {'title': tr('resp_section_useful'), 'type': 'bullets', 'items': ['Большинство трудных ситуаций имеют конкретную причину', 'Чем больше деталей, тем точнее я смогу помочь']},
    ],
    'Расскажите подробнее: что именно происходит и в какой момент?',
  ),
};

Resp pickResponse(String txt) {
  final lc = txt.toLowerCase();
  if (lc.contains('сенсор') || lc.contains('перегруз') || lc.contains('истерик') || lc.contains('наушник') || lc.contains('шум') || lc.contains('крик') || lc.contains('громк') || lc.contains('звук')) {
    return resp['sensory']!;
  }
  if (lc.contains('сон') || lc.contains('спит') || lc.contains('усталост') || lc.contains('ноч')) {
    return resp['sleep']!;
  }
  if (lc.contains('бьёт') || lc.contains('бьет') || lc.contains('кусает') || lc.contains('царапает') || lc.contains('агресс')) {
    return resp['aba']!;
  }
  if (lc.contains('не ест') || lc.contains('еда') || lc.contains('кушает') || lc.contains('питание')) {
    return resp['food']!;
  }
  return resp['default']!;
}

class _ChatScreenState extends State<ChatScreen> {
  final ctrl = TextEditingController();
  final scrollCtrl = ScrollController();
  bool waiting = false;
  String statusText = '';

  List<String> get chips => [
        tr('chip_transitions'),
        tr('chip_sleep'),
        tr('chip_meltdown'),
        tr('chip_headbanging'),
        tr('chip_not_listening'),
        tr('chip_food'),
      ];

  void scrollDown() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  void send([String? text]) async {
    final txt = (text ?? ctrl.text).trim();
    if (txt.isEmpty) return;
    ctrl.clear();
    final data = AppData.instance;
    setState(() {
      data.chatMessages.add(ChatMsg(true, txt));
      waiting = true;
      statusText = tr('status_analyzing');
    });
    data.saveChat();
    scrollDown();

    try {
      final childCtx = data.hasChild
          ? 'Информация о ребёнке: имя: ${data.childName}, возраст: ${data.childAge}, пол: ${data.childGender}, диагноз/особенности: ${data.diagnosisLabel()}. Обращайся к ребёнку по имени в ответах.'
          : '';
      final sysPrompt = GeminiService.instance.buildSystemPrompt(childCtx);

      final history = data.chatMessages
          .where((m) => m.reply != null || m.fromUser)
          .map((m) => {'role': m.fromUser ? 'user' : 'assistant', 'content': m.text})
          .toList();

      final reply = await GeminiService.instance.send(
        history: history,
        systemPrompt: sysPrompt,
        onStatus: (s) {
          if (mounted) setState(() => statusText = s);
        },
      );

      if (!mounted) return;
      setState(() {
        data.chatMessages.add(ChatMsg(false, reply.intro, reply: reply));
        waiting = false;
      });
      data.saveChat();
      scrollDown();
    } catch (e) {
      debugPrint('gemini failed, falling back to canned reply: $e');
      final r = pickResponse(txt);
      final fallbackReply = GeminiReply(
        detect: r.detect,
        intro: r.intro,
        sections: r.sections
            .map((s) => GeminiSection(s['title'] as String, s['type'] as String, List<String>.from(s['items'] as List)))
            .toList(),
        followup: r.followup,
      );

      if (!mounted) return;
      setState(() {
        data.chatMessages.add(ChatMsg(false, r.intro, reply: fallbackReply, offline: true));
        waiting = false;
      });
      data.saveChat();
      scrollDown();
    }
  }

  Widget _bubbleAnim(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      builder: (c, v, kid) {
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, (1 - v) * 10), child: kid),
        );
      },
      child: child,
    );
  }

  Widget replyCard(GeminiReply r, {bool offline = false}) {
    final sectionColors = [const Color(0xFF5B21B6), kTeal, const Color(0xFF2563EB), const Color(0xFFD97706)];
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.86),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (r.detect.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(color: const Color(0xFFF5F3FF), border: Border.all(color: const Color(0xFFDDD6FE), width: 1.5), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.search, size: 14, color: Color(0xFF5B21B6)),
                  const SizedBox(width: 7),
                  Flexible(child: Text(r.detect, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF3B0764)))),
                ]),
              ),
            if (r.intro.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))),
                child: Text(r.intro, style: const TextStyle(fontSize: 13, color: kInk, height: 1.4)),
              ),
            if (r.sections.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: r.sections.asMap().entries.map((entry) {
                    final s = entry.value;
                    final color = sectionColors[entry.key % sectionColors.length];
                    final last = entry.key == r.sections.length - 1;
                    return Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: last ? Colors.transparent : const Color(0xFFF1F5F9)))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title.toUpperCase(), style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5)),
                          const SizedBox(height: 6),
                          if (s.type == 'steps')
                            ...s.items.asMap().entries.map((it) => Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Container(
                                      width: 16, height: 16,
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(top: 1),
                                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                      child: Text('${it.key + 1}', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(child: Text(it.value, style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.4))),
                                  ]),
                                ))
                          else
                            ...s.items.map((it) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text('•  $it', style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.4)),
                                )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            if (r.followup.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), border: Border.all(color: kLine), borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))),
                child: Text(r.followup, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF334155))),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    final avatar = data.childGender == 'девочка' ? '👧' : '👦';

    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: kLine))),
            child: Row(children: [
              Stack(children: [
                Container(
                  width: 34, height: 34,
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 6)]),
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                ),
                Positioned(bottom: 0, right: 0, child: Container(width: 9, height: 9, decoration: BoxDecoration(color: const Color(0xFF22C55E), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
              ]),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('app_name'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                Text(tr('chat_status'), style: const TextStyle(fontSize: 11, color: kTeal)),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: kTealBg, border: Border.all(color: const Color(0xFFB6E0D3), width: 1.5), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(avatar, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(data.childLabel(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ]),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: kInk3),
                onPressed: () {
                  setState(() {
                    data.chatMessages = [ChatMsg(false, tr('chat_welcome'))];
                  });
                  data.saveChat();
                },
              )
            ]),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: data.chatMessages.length + (waiting ? 1 : 0),
              itemBuilder: (c, i) {
                if (i >= data.chatMessages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kLine), borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 8),
                        Text(statusText, style: const TextStyle(fontSize: 12, color: kInk3, fontStyle: FontStyle.italic)),
                      ]),
                    ),
                  );
                }
                final m = data.chatMessages[i];

                if (!m.fromUser && m.reply != null) {
                  return _bubbleAnim(replyCard(m.reply!, offline: m.offline));
                }

                return _bubbleAnim(Align(
                  alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                    decoration: BoxDecoration(
                      color: m.fromUser ? kTeal : Colors.white,
                      border: m.fromUser ? null : Border.all(color: kLine),
                      borderRadius: m.fromUser
                          ? const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(4), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))
                          : const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                    ),
                    child: Text(m.text, style: TextStyle(color: m.fromUser ? Colors.white : kInk, fontSize: 13, height: 1.4)),
                  ),
                ));
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: kLine))),
            child: Column(
              children: [
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: chips.map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => setState(() => ctrl.text = c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: kBg, border: Border.all(color: kLine, width: 1.5), borderRadius: BorderRadius.circular(16)),
                            child: Text(c, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kInk3)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: kBg, border: Border.all(color: kLine, width: 1.5), borderRadius: BorderRadius.circular(22)),
                      child: TextField(
                        controller: ctrl,
                        onSubmitted: (v) => send(),
                        decoration: InputDecoration(border: InputBorder.none, hintText: tr('chat_input_hint')),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => send(),
                    child: Container(
                      width: 36, height: 36,
                      decoration: const BoxDecoration(color: kTeal, shape: BoxShape.circle),
                      child: const Icon(Icons.send, color: Colors.white, size: 16),
                    ),
                  )
                ])
              ],
            ),
          )
        ],
      ),
    );
  }
}
