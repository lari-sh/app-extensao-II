import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/animal.dart';

/// Demonstration storage, not a production clinical record database.
class AnimalStore extends ChangeNotifier {
  AnimalStore(this.preferences);
  final SharedPreferencesAsync preferences;
  List<Animal> _animals = List.of(demoAnimals);
  Set<String> _favorites = {};
  List<Animal> get animals => List.unmodifiable(_animals);
  Set<String> get favorites => Set.unmodifiable(_favorites);
  Future<void> load() async {
    final raw = await preferences.getString('demo_animals_v1');
    if (raw != null) {
      _animals = (jsonDecode(raw) as List)
          .map((value) => Animal.fromJson(value as Map<String, dynamic>))
          .toList();
    }
    _favorites = (await preferences.getStringList('favorites_v1') ?? [])
        .toSet();
    notifyListeners();
  }

  Future<void> save(Animal animal) async {
    final next = List<Animal>.of(_animals);
    final index = next.indexWhere((item) => item.id == animal.id);
    if (index < 0) {
      next.add(animal);
    } else {
      next[index] = animal;
    }
    await preferences.setString(
      'demo_animals_v1',
      jsonEncode(next.map((item) => item.toJson()).toList()),
    );
    _animals = next;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final next = Set<String>.of(_favorites);
    next.contains(id) ? next.remove(id) : next.add(id);
    await preferences.setStringList('favorites_v1', next.toList());
    _favorites = next;
    notifyListeners();
  }
}
