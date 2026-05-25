import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class WorkoutSet {
  int reps;
  double weight;

  WorkoutSet({this.reps = 0, this.weight = 0.0});

  WorkoutSet clone() => WorkoutSet(reps: reps, weight: weight);

  // --- NUOVO: Converti in JSON e viceversa ---
  Map<String, dynamic> toJson() => {'reps': reps, 'weight': weight};
  
  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
        reps: json['reps'] ?? 0,
        weight: (json['weight'] ?? 0.0).toDouble(),
      );
}

class Exercise {
  String name;
  String unit; // <-- NUOVO CAMPO
  List<WorkoutSet> sets;

  Exercise({
    this.name = '', 
    this.unit = 'Kg', // Di default impostiamo Kg
    List<WorkoutSet>? sets
  }) : sets = sets ?? [WorkoutSet()];

  Exercise clone() => Exercise(
    name: name, 
    unit: unit, // Cloniamo anche l'unità
    sets: sets.map((s) => s.clone()).toList()
  );

  Map<String, dynamic> toJson() => {
        'name': name,
        'unit': unit, // Salviamo nel JSON
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        name: json['name'] ?? '',
        unit: json['unit'] ?? 'Kg', // Se il salvataggio è vecchio, usa Kg
        sets: (json['sets'] as List?)?.map((s) => WorkoutSet.fromJson(s)).toList() ?? [],
      );
}

class WorkoutSession {
  DateTime date;
  String muscleGroup;
  List<Exercise> exercises;

  WorkoutSession({required this.date, required this.muscleGroup, required this.exercises});

  // --- NUOVO: Converti in JSON e viceversa (Data salvata come stringa ISO) ---
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'muscleGroup': muscleGroup,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        date: DateTime.parse(json['date']),
        muscleGroup: json['muscleGroup'] ?? '',
        exercises: (json['exercises'] as List?)?.map((e) => Exercise.fromJson(e)).toList() ?? [],
      );
}

List<WorkoutSession> globalWorkoutHistory = [];

// === NUOVE FUNZIONI DI SALVATAGGIO E CARICAMENTO GLOBALI ===

// --- AGGIUNGI IN FONDO A lib/models/exercise.dart ---

// Notificatore globale per il tema attuale (Default: Neon Cyber)
ValueNotifier<String> currentThemeNotifier = ValueNotifier('Neon Cyber');

Future<void> saveWorkoutHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final String jsonString = jsonEncode(globalWorkoutHistory.map((e) => e.toJson()).toList());
  await prefs.setString('history_data', jsonString);
  
  // Salva anche il tema attuale
  await prefs.setString('selected_theme', currentThemeNotifier.value);
}

Future<void> loadWorkoutHistory() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Carica lo storico
  final String? jsonString = prefs.getString('history_data');
  if (jsonString != null) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    globalWorkoutHistory = jsonList.map((e) => WorkoutSession.fromJson(e)).toList();
  }

  // Carica il tema salvato (se esiste)
  final String? savedTheme = prefs.getString('selected_theme');
  if (savedTheme != null) {
    currentThemeNotifier.value = savedTheme;
  }
}