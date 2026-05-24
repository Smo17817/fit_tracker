import 'package:flutter/material.dart';
import '../models/exercise.dart'; // Assicurati che il percorso sia corretto

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storico Allenamenti'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: globalWorkoutHistory.isEmpty
          ? const Center(
              child: Text(
                'Nessun allenamento salvato ancora.\nInizia a sudare!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: globalWorkoutHistory.length,
              itemBuilder: (context, index) {
                // Ordine cronologico inverso (il più recente in alto)
                final reversedIndex = globalWorkoutHistory.length - 1 - index;
                final session = globalWorkoutHistory[reversedIndex];

                final dateStr = '${session.date.day.toString().padLeft(2, '0')}/'
                                '${session.date.month.toString().padLeft(2, '0')}/'
                                '${session.date.year}';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ExpansionTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      session.muscleGroup,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(dateStr),
                    
                    // Sostituiamo il ListTile con una struttura più dettagliata
                    children: session.exercises.map((exercise) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nome dell'esercizio con un'icona
                            Row(
                              children: [
                                const Icon(Icons.fitness_center, size: 18, color: Colors.deepOrange),
                                const SizedBox(width: 8),
                                Text(
                                  exercise.name.isEmpty ? 'Esercizio senza nome' : exercise.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 16
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            
                            // Iteriamo per generare una riga di testo per ogni singola serie
                            ...exercise.sets.asMap().entries.map((setEntry) {
                              int setIndex = setEntry.key;
                              WorkoutSet currentSet = setEntry.value;

                              return Padding(
                                // Indentiamo leggermente le serie rispetto al nome dell'esercizio
                                padding: const EdgeInsets.only(left: 26.0, bottom: 4.0),
                                child: Text(
                                  'Set ${setIndex + 1}:   ${currentSet.reps} reps   @   ${currentSet.weight} kg',
                                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                                ),
                              );
                            }),
                            
                            // Un divisore visivo tra un esercizio e l'altro
                            const Divider(height: 20),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}