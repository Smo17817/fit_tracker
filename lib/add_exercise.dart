import 'package:flutter/material.dart';
import 'models/exercise.dart';

class AddExercisePage extends StatefulWidget {
  const AddExercisePage({super.key});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  // 1. Variabile per il gruppo selezionato (ora può essere nulla all'inizio)
  String? selectedMuscleGroup;
  
  // 2. Definiamo la lista dei gruppi muscolari disponibili
  final List<String> muscleGroups = [
    'Petto',
    'Dorso',
    'Gambe',
    'Spalle',
    'Bicipiti',
    'Tricipiti',
    'Addome',
    'Full Body',
    'Cardio'
  ];

  List<Exercise> exercises = [Exercise()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuovo Allenamento'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 3. Sostituiamo il TextField con il DropdownButtonFormField
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Gruppo Muscolare',
              border: OutlineInputBorder(),
            ),
            value: selectedMuscleGroup, // Il valore attualmente selezionato
            hint: const Text('Seleziona un gruppo...'),
            // Generiamo le opzioni del menu a tendina mappando la nostra lista
            items: muscleGroups.map((String group) {
              return DropdownMenuItem<String>(
                value: group,
                child: Text(group),
              );
            }).toList(),
            onChanged: (String? newValue) {
              // Quando l'utente seleziona una voce, aggiorniamo lo stato
              setState(() {
                selectedMuscleGroup = newValue;
              });
            },
          ),
          
          const SizedBox(height: 20),
          const Text(
            'Esercizi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          ...exercises.asMap().entries.map((entry) {
            int index = entry.key;
            Exercise exercise = entry.value;
            return _buildExerciseCard(exercise, index);
          }),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            onPressed: () {
              // 4. Aggiorniamo il controllo di validazione
              if (exercises.isEmpty || selectedMuscleGroup == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Seleziona un gruppo muscolare e inserisci almeno un esercizio!')),
                );
                return;
              }

              final session = WorkoutSession(
                date: DateTime.now(),
                muscleGroup: selectedMuscleGroup!, // Usiamo il '!' perché siamo sicuri che non è nullo grazie al controllo sopra
                exercises: List.from(exercises), 
              );

              globalWorkoutHistory.add(session);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Allenamento salvato con successo!')),
              );

              // 5. Ripuliamo la pagina riportando a null il menu a tendina
              setState(() {
                selectedMuscleGroup = null;
                exercises = [Exercise()];
              });
            },
            icon: const Icon(Icons.save),
            label: const Text('Salva Allenamento', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            exercises.add(Exercise());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Metodo helper per tenere il codice del build pulito.
  // Ritorna un Widget che rappresenta il form del singolo esercizio.
  Widget _buildExerciseCard(Exercise exercise, int exerciseIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Riga Intestazione: Nome Esercizio + Cestino di eliminazione scheda
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Nome Esercizio ${exerciseIndex + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => exercise.name = value,
                  ),
                ),
                const SizedBox(width: 8),
                // Pulsante per eliminare l'INTERO esercizio
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: 'Elimina esercizio',
                  onPressed: () {
                    setState(() {
                      // Rimuove l'esercizio dalla lista principale usando l'indice
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

            // Mappiamo la lista delle serie (sets)
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
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Reps'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => currentSet.reps = int.tryParse(value) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Kg'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) => currentSet.weight = double.tryParse(value) ?? 0.0,
                      ),
                    ),
                    // Pulsante per eliminare la singola serie
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
            
            // Pulsante per aggiungere una nuova serie
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