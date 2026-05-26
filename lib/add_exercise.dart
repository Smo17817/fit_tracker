import 'package:flutter/material.dart';
import 'models/exercise.dart';
import 'data/muscle_groups.dart'; // <-- Importiamo la lista centralizzata dei gruppi muscolari

class AddExercisePage extends StatefulWidget {
  const AddExercisePage({super.key});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  // 1. Variabile per il gruppo selezionato (ora può essere nulla all'inizio)
  String? selectedMuscleGroup;
  
  // 2. Definiamo la lista dei gruppi muscolari disponibili
  final List<String> muscleGroups = appMuscleGroups;

  List<Exercise> exercises = [Exercise()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout del Giorno'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Menu a tendina per il muscolo
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Gruppo Muscolare',
              border: OutlineInputBorder(),
            ),
            value: selectedMuscleGroup,
            hint: const Text('Seleziona un gruppo...'),
            items: muscleGroups.map((String group) {
              return DropdownMenuItem<String>(
                value: group,
                child: Text(group),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedMuscleGroup = newValue;

                if (newValue != null) {
                  final pastWorkouts = globalWorkoutHistory.where(
                    (workout) => workout.muscleGroup == newValue
                  );

                  if (pastWorkouts.isNotEmpty) {
                    final lastWorkout = pastWorkouts.last;
                    exercises = lastWorkout.exercises.map((e) => e.clone()).toList();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Caricato ultimo allenamento: $newValue!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    exercises = [Exercise()];
                  }
                }
              });
            },
          ),
          
          const SizedBox(height: 20),
          const Text(
            'Esercizi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          // Lista delle schede degli esercizi
          ...exercises.asMap().entries.map((entry) {
            int index = entry.key;
            Exercise exercise = entry.value;
            return _buildExerciseCard(exercise, index);
          }),

          const SizedBox(height: 20),

          // --- NUOVO PULSANTE: AGGIUNGI ESERCIZIO ---
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              // Usiamo il colore primario del tema attivo invece di un colore fisso
              side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2), 
              foregroundColor: Theme.of(context).colorScheme.primary, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              setState(() {
                exercises.add(Exercise());
              });
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Aggiungi Nuovo Esercizio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          
          const SizedBox(height: 80), // Spazio extra per evitare che il FAB copra l'ultimo bottone
        ],
      ),
      
      // --- NUOVO PULSANTE: SALVA ALLENAMENTO (FAB) ---
      // Usiamo .extended per avere sia l'icona che il testo
      // --- PULSANTE: SALVA ALLENAMENTO (Solo Icona) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (exercises.isEmpty || selectedMuscleGroup == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Seleziona un gruppo muscolare e inserisci almeno un esercizio!')),
            );
            return;
          }

          final session = WorkoutSession(
            date: DateTime.now(),
            muscleGroup: selectedMuscleGroup!,
            exercises: List.from(exercises), 
          );

          globalWorkoutHistory.add(session);
          await saveWorkoutHistory();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar( // ATTENZIONE: ho rimosso il "const" qui prima di SnackBar
              content: Text(
                'Allenamento salvato con successo!', 
                style: TextStyle(
                  // Il testo prende il colore ideale per essere letto sullo sfondo primario
                  color: Theme.of(context).colorScheme.onPrimary, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Lo sfondo prende il colore primario del tema attualmente selezionato
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );

          setState(() {
            selectedMuscleGroup = null;
            exercises = [Exercise()];
          });
        },
        child: const Icon(Icons.save), // <--- Solo l'icona qui
      ),
    );
  }

  // Metodo helper per tenere il codice del build pulito.
  // Ritorna un Widget che rappresenta il form del singolo esercizio.
  Widget _buildExerciseCard(Exercise exercise, int exerciseIndex) {
    return Card(
      key: ObjectKey(exercise), 
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // CAMPO NOME ESERCIZIO
                Expanded(
                  flex: 3, // Prende il 60% dello spazio
                  child: TextFormField(
                    initialValue: exercise.name, 
                    decoration: InputDecoration(
                      labelText: 'Esercizio ${exerciseIndex + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => exercise.name = value,
                  ),
                ),
                const SizedBox(width: 8),
                
                // --- NUOVO: MENU A TENDINA PER L'UNITA' DI MISURA ---
                Expanded(
                  flex: 2, // Prende il 40% dello spazio
                  child: DropdownButtonFormField<String>(
                    value: exercise.unit,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(),
                    ),
                    items: ['Kg', 'Sec', 'Min', 'Pace'].map((String u) {
                      return DropdownMenuItem(value: u, child: Text(u));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue != null) exercise.unit = newValue;
                      });
                    },
                  ),
                ),
                
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    setState(() {
                      exercises.removeAt(exerciseIndex);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Serie:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            ...exercise.sets.asMap().entries.map((entry) {
              int setIndex = entry.key;
              WorkoutSet currentSet = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text('Set ${setIndex + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        initialValue: currentSet.reps > 0 ? currentSet.reps.toString() : '',
                        decoration: const InputDecoration(labelText: 'Reps'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => currentSet.reps = int.tryParse(value) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        initialValue: currentSet.weight > 0 ? currentSet.weight.toString() : '',
                        // --- LA MAGIA: L'ETICHETTA CAMBIA DINAMICAMENTE ---
                        decoration: InputDecoration(labelText: exercise.unit), 
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) => currentSet.weight = double.tryParse(value) ?? 0.0,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          exercise.sets.removeAt(setIndex);
                        });
                      },
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    exercise.sets.add(WorkoutSet());
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi Serie'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}