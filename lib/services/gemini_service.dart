import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../data/app_data.dart';
import '../l10n/strings.dart';

class GeminiSection {
  final String title;
  final String type;
  final List<String> items;
  GeminiSection(this.title, this.type, this.items);

  factory GeminiSection.fromJson(Map<String, dynamic> j) {
    final rawItems = (j['items'] as List?) ?? [];
    return GeminiSection(
      j['title']?.toString() ?? '',
      j['type']?.toString() ?? 'bullets',
      rawItems.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {'title': title, 'type': type, 'items': items};
}

class GeminiReply {
  final String detect;
  final String intro;
  final List<GeminiSection> sections;
  final String followup;

  GeminiReply({required this.detect, required this.intro, required this.sections, required this.followup});

  factory GeminiReply.fromJson(Map<String, dynamic> j) {
    final secs = (j['sections'] as List?) ?? [];
    return GeminiReply(
      detect: j['detect']?.toString() ?? '',
      intro: j['intro']?.toString() ?? '',
      sections: secs.map((s) => GeminiSection.fromJson(s as Map<String, dynamic>)).toList(),
      followup: j['followup']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'detect': detect,
        'intro': intro,
        'sections': sections.map((s) => s.toJson()).toList(),
        'followup': followup,
      };
}

class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  static const List<String> _models = [
    'gemini-3.6-flash',
    'gemini-3.5-flash-lite',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
  ];

  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  bool get hasKey => _apiKey.isNotEmpty;

  String buildSystemPrompt(String childContext) {
    const base = '''
Ты Qushaq, помощник для родителей особенных детей. Отвечай как опытный, спокойный специалист, который говорит просто и по делу. Без пафоса, без лишних слов, без поэзии.

ВАЖНО: Ты должен отвечать ТОЛЬКО валидным JSON объектом. Никакого текста до или после JSON. Никаких markdown блоков. Только JSON.

Структура ответа:
{
  "detect": "Короткая фраза, что происходит, 2-5 слов",
  "intro": "1-2 предложения, суть простыми словами",
  "sections": [
    {"color": "purple", "title": "Почему это происходит", "type": "bullets", "items": ["пункт 1", "пункт 2", "пункт 3"]},
    {"color": "teal", "title": "Что делать прямо сейчас", "type": "steps", "items": ["шаг 1", "шаг 2", "шаг 3"]},
    {"color": "blue", "title": "На будущее", "type": "bullets", "items": ["совет 1", "совет 2"]}
  ],
  "followup": "Один конкретный уточняющий вопрос"
}

СТИЛЬ:
Всегда на Вы. Пункты конкретные, 6-12 слов, не обрывай мысль. Без пафоса. Советы выполнимые прямо сейчас.
Не начинай intro с "Понимаю", "Это непросто", "Конечно".

Структурные правила: ровно 3 sections с этими же названиями, "Почему это происходит" ровно 3 пункта, "Что делать прямо сейчас" ровно 3 шага, "На будущее" ровно 2 пункта. Только JSON, ничего кроме JSON.
''';
    final langNote = _langInstruction();
    final withLang = langNote.isEmpty ? base : base + '\n\n' + langNote;
    if (childContext.isEmpty) return withLang;
    return withLang + '\n\n' + childContext;
  }

  String _langInstruction() {
    switch (AppData.instance.lang) {
      case 'kk':
        return 'ВАЖНО: весь текст внутри значений JSON (detect, intro, title, items, followup) пиши на казахском языке.';
      case 'en':
        return 'IMPORTANT: write all text inside the JSON values (detect, intro, title, items, followup) in English.';
      default:
        return '';
    }
  }

  Future<GeminiReply> send({
    required List<Map<String, String>> history,
    required String systemPrompt,
    void Function(String status)? onStatus,
  }) async {
    if (!hasKey) {
      throw Exception('Нет ключа GEMINI_API_KEY в .env');
    }

    final contents = history.map((m) {
      return {
        'role': m['role'] == 'assistant' ? 'model' : 'user',
        'parts': [{'text': m['content']}],
      };
    }).toList();

    final body = jsonEncode({
      'system_instruction': {'parts': [{'text': systemPrompt}]},
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 3000,
        'responseMimeType': 'application/json',
      },
    });

    String lastErr = '';

    for (final model in _models) {
      onStatus?.call(tr('status_analyzing'));
      try {
        final text = await _streamOnce(model, body, onStatus);
        if (text.trim().isEmpty) {
          lastErr = 'Пустой ответ от $model';
          continue;
        }
        return _parseReply(text);
      } catch (e) {
        lastErr = e.toString();
        continue;
      }
    }

    throw Exception(lastErr.isEmpty ? 'Не удалось получить ответ ни от одной модели' : lastErr);
  }

  Future<String> _streamOnce(String model, String body, void Function(String)? onStatus) async {
    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:streamGenerateContent?alt=sse&key=$_apiKey');

    final req = http.Request('POST', uri);
    req.headers['Content-Type'] = 'application/json';
    req.body = body;

    final client = http.Client();
    final streamed = await client.send(req);

    if (streamed.statusCode != 200) {
      final errBody = await streamed.stream.bytesToString();
      client.close();
      String msg = 'HTTP ${streamed.statusCode}';
      try {
        final parsed = jsonDecode(errBody);
        msg = parsed['error']?['message']?.toString() ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }

    final buffer = StringBuffer();
    var fullText = '';

    await for (final chunk in streamed.stream.transform(utf8.decoder)) {
      buffer.write(chunk);
      final lines = buffer.toString().split('\n');
      buffer.clear();
      buffer.write(lines.removeLast());

      for (final line in lines) {
        if (!line.startsWith('data: ')) continue;
        final jsonStr = line.substring(6).trim();
        if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;
        try {
          final chunkJson = jsonDecode(jsonStr);
          final candidates = chunkJson['candidates'] as List?;
          if (candidates == null || candidates.isEmpty) continue;
          final parts = candidates[0]['content']?['parts'] as List?;
          if (parts == null || parts.isEmpty) continue;
          final piece = parts[0]['text']?.toString() ?? '';
          fullText += piece;
          final n = fullText.length;
          if (n < 200) {
            onStatus?.call(tr('status_analyzing'));
          } else if (n < 600) {
            onStatus?.call(tr('status_picking'));
          } else if (n < 1200) {
            onStatus?.call(tr('status_forming'));
          } else {
            onStatus?.call(tr('status_almost'));
          }
        } catch (_) {}
      }
    }

    client.close();
    return fullText;
  }

  GeminiReply _parseReply(String raw) {
    var clean = raw.replaceAll('```json', '').replaceAll('```', '').trim();
    try {
      final j = jsonDecode(clean);
      return GeminiReply.fromJson(j as Map<String, dynamic>);
    } catch (_) {
      final lastBrace = clean.lastIndexOf('}');
      if (lastBrace <= 0) rethrow;
      var attempt = clean.substring(0, lastBrace + 1);
      final opensArr = '['.allMatches(attempt).length - ']'.allMatches(attempt).length;
      final opensObj = '{'.allMatches(attempt).length - '}'.allMatches(attempt).length;
      for (var i = 0; i < opensArr; i++) {
        attempt += ']';
      }
      for (var i = 0; i < opensObj; i++) {
        attempt += '}';
      }
      final j = jsonDecode(attempt);
      return GeminiReply.fromJson(j as Map<String, dynamic>);
    }
  }
}
