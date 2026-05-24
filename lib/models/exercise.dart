class WorkoutSet {
  int reps;
  double weight;

  WorkoutSet({
    this.reps = 0,
    this.weight = 0.0,
  });
}

class Exercise {
  String name;
  // Ora abbiamo una lista di serie al posto delle singole variabili
  List<WorkoutSet> sets;

  Exercise({
    this.name = '',
    List<WorkoutSet>? sets,
  }) : sets = sets ?? [WorkoutSet()]; // Inizializza l'esercizio con almeno 1 serie vuota di default
}

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