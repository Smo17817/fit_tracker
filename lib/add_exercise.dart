import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../data/muscle_groups.dart';

class AddExercisePage extends StatefulWidget {
  const AddExercisePage({super.key});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  // 1. Variabile per il gruppo selezionato
  String? selectedMuscleGroup;
  
  // 2. Definiamo la lista dei gruppi muscolari disponibili
  final List<String> muscleGroups = appMuscleGroups;

  List<Exercise> exercises = [Exercise()];

  // Metodo per estrarre i nomi degli esercizi passati in base al gruppo
  List<String> _getEserciziSuggeriti(String? gruppoAttuale) {
    if (gruppoAttuale == null) return [];
    
    Set<String> nomi = {};
    for (var session in globalWorkoutHistory) {
      if (session.muscleGroup == gruppoAttuale) {
        for (var ex in session.exercises) {
          if (ex.name.trim().isNotEmpty) {
            nomi.add(ex.name.trim());
          }
        }
      }
    }
    return nomi.toList()..sort();
  }

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
              prefixIcon: Icon(Icons.accessibility_new),
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

                // LOGICA DI AUTOCARICAMENTO DELL'ULTIMO ALLENAMENTO
                if (newValue != null) {
                  final pastWorkouts = globalWorkoutHistory.where(
                    (workout) => workout.muscleGroup == newValue
                  );

                  if (pastWorkouts.isNotEmpty) {
                    final lastWorkout = pastWorkouts.last;
                    exercises = lastWorkout.exercises.map((e) => e.clone()).toList();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Caricato ultimo allenamento: $newValue!',
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
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

          // --- IL TUO PULSANTE: AGGIUNGI ESERCIZIO ---
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
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
      
      // --- IL TUO PULSANTE: SALVA ALLENAMENTO (FAB) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Rimuove eventuali esercizi vuoti prima del salvataggio
          exercises.removeWhere((ex) => ex.name.trim().isEmpty);

          if (exercises.isEmpty || selectedMuscleGroup == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Seleziona un gruppo muscolare e inserisci almeno un esercizio!',
                  style: TextStyle(color: Theme.of(context).colorScheme.onError),
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            return;
          }

          final session = WorkoutSession(
            date: DateTime.now(),
            muscleGroup: selectedMuscleGroup!,
            exercises: List.from(exercises), 
          );

          globalWorkoutHistory.add(session);
          
          // Se hai una funzione di salvataggio (es. SharedPreferences), decommenta questa riga
          await saveWorkoutHistory();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Allenamento salvato con successo!', 
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          setState(() {
            selectedMuscleGroup = null;
            exercises = [Exercise()];
          });
        },
        child: const Icon(Icons.save), 
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, int exerciseIndex) {
    return Card(
      key: ObjectKey(exercise), 
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CAMPO NOME ESERCIZIO CON AUTOCOMPLETE ---
                Expanded(
                  flex: 3,
                  child: Autocomplete<String>(
                    // Permette di mostrare il nome precaricato (se carichi l'ultimo allenamento)
                    initialValue: TextEditingValue(text: exercise.name),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      final suggerimenti = _getEserciziSuggeriti(selectedMuscleGroup);
                      return suggerimenti.where((String opzione) {
                        return opzione.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selezione) {
                      exercise.name = selezione;
                    },
                    fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
                      return TextFormField(
                        controller: textController,
                        focusNode: focusNode,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Esercizio ${exerciseIndex + 1}',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        // Aggiorniamo il modello ad ogni lettera digitata
                        onChanged: (val) => exercise.name = val,
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 200, 
                              maxWidth: MediaQuery.of(context).size.width * 0.55,
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(option),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                
                // --- MENU A TENDINA PER L'UNITA' DI MISURA ---
                Expanded(
                  flex: 2, 
                  child: DropdownButtonFormField<String>(
                    value: exercise.unit,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      border: OutlineInputBorder(),
                      isDense: true,
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
                        decoration: const InputDecoration(labelText: 'Reps', isDense: true),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => currentSet.reps = int.tryParse(value) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        initialValue: currentSet.weight > 0 ? currentSet.weight.toString() : '',
                        decoration: InputDecoration(labelText: exercise.unit, isDense: true), 
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