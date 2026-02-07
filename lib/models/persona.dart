import 'dart:convert';

class Persona {
  final String id;
  final String name;
  final String prompt;
  final int iconCodePoint;

  Persona({
    required this.id,
    required this.name,
    required this.prompt,
    this.iconCodePoint = 0xe87c, // default: person icon
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'prompt': prompt,
        'iconCodePoint': iconCodePoint,
      };

  static Persona fromJson(Map<String, dynamic> j) => Persona(
        id: j['id'] as String,
        name: j['name'] as String,
        prompt: j['prompt'] as String,
        iconCodePoint: j['iconCodePoint'] as int? ?? 0xe87c,
      );

  static String encodeList(List<Persona> list) => jsonEncode(list.map((p) => p.toJson()).toList());

  static List<Persona> decodeList(String jsonStr) {
    final data = jsonDecode(jsonStr) as List<dynamic>;
    return data.map((e) => Persona.fromJson(e as Map<String, dynamic>)).toList();
  }
}
