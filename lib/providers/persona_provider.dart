import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/persona.dart';

class PersonaProvider extends ChangeNotifier {
  static const _storageKey = 'user_personas_v1';
  final List<Persona> _personas = [];

  List<Persona> get personas => List.unmodifiable(_personas);

  PersonaProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = Persona.decodeList(raw);
        _personas.clear();
        _personas.addAll(list);
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Persona.encodeList(_personas));
  }

  Future<void> addPersona(String name, String prompt, {int iconCodePoint = 0xe87c}) async {
    final p = Persona(id: Uuid().v4(), name: name, prompt: prompt, iconCodePoint: iconCodePoint);
    _personas.add(p);
    await _save();
    notifyListeners();
  }

  Future<void> updatePersona(Persona updated) async {
    final idx = _personas.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _personas[idx] = updated;
      await _save();
      notifyListeners();
    }
  }

  Future<void> removePersona(String id) async {
    _personas.removeWhere((p) => p.id == id);
    await _save();
    notifyListeners();
  }
}
