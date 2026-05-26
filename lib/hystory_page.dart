import 'package:flutter/material.dart';
import '../models/exercise.dart'; 
import '../data/muscle_groups.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Variabili di stato per i filtri
  String searchQuery = '';
  String selectedMuscleGroupFilter = 'Tutti';
  bool showOnlyLatestPerGroup = false;

  final List<String> filterGroups = ['Tutti', ...appMuscleGroups];

  // Metodo "magico" che calcola la lista da mostrare in base ai filtri attivi
  List<WorkoutSession> get filteredHistory {
    // 1. Partiamo dalla lista originale invertita (dal più recente al più vecchio)
    List<WorkoutSession> filtered = globalWorkoutHistory.reversed.toList();

    // 2. Applichiamo il filtro del Gruppo Muscolare
    if (selectedMuscleGroupFilter != 'Tutti') {
      filtered = filtered.where((s) => s.muscleGroup == selectedMuscleGroupFilter).toList();
    }

    // 3. Applichiamo la Ricerca Testuale (cerca nel nome dell'esercizio o nel gruppo)
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((session) {
        final query = searchQuery.toLowerCase();
        final matchesGroup = session.muscleGroup.toLowerCase().contains(query);
        final matchesExercise = session.exercises.any((e) => e.name.toLowerCase().contains(query));
        return matchesGroup || matchesExercise;
      }).toList();
    }

    // 4. Applichiamo il filtro "Solo Ultimo Allenamento"
    if (showOnlyLatestPerGroup) {
      Set<String> seenGroups = {};
      List<WorkoutSession> latestOnly = [];
      
      for (var session in filtered) {
        // Visto che la lista è dal più recente, il primo che incontriamo è l'ultimo fatto!
        if (!seenGroups.contains(session.muscleGroup)) {
          latestOnly.add(session);
          seenGroups.add(session.muscleGroup);
        }
      }
      filtered = latestOnly;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final currentList = filteredHistory; // Calcoliamo la lista una volta sola per la UI

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storico Allenamenti'),
      ),
      body: Column(
        children: [
          // --- ZONA FILTRI SUPERIORE ---
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            ),
            child: Column(
              children: [
                // Barra di ricerca testuale
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Cerca esercizio o gruppo...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Riga con Dropdown e Switch
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: selectedMuscleGroupFilter,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          labelText: 'Filtra Gruppo',
                        ),
                        items: filterGroups.map((String group) {
                          return DropdownMenuItem(value: group, child: Text(group));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            if (newValue != null) selectedMuscleGroupFilter = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Solo Ultimo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Switch(
                            activeColor: primaryColor,
                            value: showOnlyLatestPerGroup,
                            onChanged: (bool value) {
                              setState(() {
                                showOnlyLatestPerGroup = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- LISTA ALLENAMENTI ---
          Expanded(
            child: currentList.isEmpty
                ? const Center(
                    child: Text(
                      'Nessun allenamento trovato.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: currentList.length,
                    itemBuilder: (context, index) {
                      // Ora peschiamo direttamente dalla lista filtrata
                      final session = currentList[index];

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
                                  // Passiamo l'OGGETTO sessione, non più l'indice!
                                  _mostraPopupConferma(context, session);
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
                                        'Set ${setIndex + 1}:   ${currentSet.reps} reps   @   ${currentSet.weight} ${exercise.unit}',
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
          ),
        ],
      ),
    );
  }

  // L'eliminazione ora cerca l'oggetto esatto da rimuovere, evitando bug con i filtri
  void _mostraPopupConferma(BuildContext context, WorkoutSession sessionDaEliminare) {
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
                  // Rimuove la sessione specifica dalla lista globale
                  globalWorkoutHistory.remove(sessionDaEliminare);
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