import 'package:flutter/material.dart';
import '../models/exercise.dart'; 

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    // Recuperiamo il colore primario del tema attivo
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storico Allenamenti'),
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
                // Ordine cronologico inverso
                final reversedIndex = globalWorkoutHistory.length - 1 - index;
                final session = globalWorkoutHistory[reversedIndex];

                final dateStr = '${session.date.day.toString().padLeft(2, '0')}/'
                                '${session.date.month.toString().padLeft(2, '0')}/'
                                '${session.date.year}';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ExpansionTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          session.muscleGroup,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          tooltip: 'Elimina allenamento',
                          onPressed: () {
                            _mostraPopupConferma(context, reversedIndex);
                          },
                        ),
                      ],
                    ),
                    subtitle: Text(dateStr),
                    
                    children: session.exercises.map((exercise) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // --- FIX 1: L'icona ora usa il colore del tema ---
                                Icon(Icons.fitness_center, size: 18, color: primaryColor),
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
                            
                            ...exercise.sets.asMap().entries.map((setEntry) {
                              int setIndex = setEntry.key;
                              WorkoutSet currentSet = setEntry.value;

                              return Padding(
                                padding: const EdgeInsets.only(left: 26.0, bottom: 4.0),
                                child: Text(
                                  // --- FIX 2: Ripristinato exercise.unit invece di "kg" fisso ---
                                  'Set ${setIndex + 1}:   ${currentSet.reps} reps   @   ${currentSet.weight} ${exercise.unit}',
                                  // --- FIX 3: Rimosso color: Colors.black87. 
                                  // Ora si adatta automaticamente al testo chiaro/scuro del tema ---
                                  style: const TextStyle(fontSize: 15), 
                                ),
                              );
                            }),
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

  void _mostraPopupConferma(BuildContext context, int indexDaEliminare) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Elimina Allenamento'),
          content: const Text(
            'Sei sicuro di voler eliminare questo allenamento dallo storico? L\'azione è irreversibile.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
              },
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  globalWorkoutHistory.removeAt(indexDaEliminare);
                });
                
                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Allenamento eliminato.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Elimina',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}