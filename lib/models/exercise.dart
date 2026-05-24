class WorkoutSet {
  int reps;
  double weight;

  WorkoutSet({this.reps = 0, this.weight = 0.0});

  // NUOVO: Metodo per creare una copia esatta ma indipendente
  WorkoutSet clone() {
    return WorkoutSet(reps: reps, weight: weight);
  }
}

class Exercise {
  String name;
  List<WorkoutSet> sets;

  Exercise({
    this.name = '',
    List<WorkoutSet>? sets,
  }) : sets = sets ?? [WorkoutSet()];

  // NUOVO: Metodo per clonare l'esercizio e tutte le sue serie
  Exercise clone() {
    return Exercise(
      name: name,
      // Usiamo .map() per chiamare il clone() su ogni singola serie
      sets: sets.map((s) => s.clone()).toList(),
    );
  }
}

// ... il resto del file (WorkoutSession e globalWorkoutHistory) rimane uguale
class WorkoutSession {
  DateTime date;
  String muscleGroup;
  List<Exercise> exercises;

  WorkoutSession({
    required this.date,
    required this.muscleGroup,
    required this.exercises,
  });
}

// Questo è il nostro "database" in memoria temporaneo.
// In un'app reale, questi dati andrebbero scritti su un DB locale.
List<WorkoutSession> globalWorkoutHistory = [];