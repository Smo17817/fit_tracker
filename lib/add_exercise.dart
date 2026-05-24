import 'package:flutter/material.dart';
import 'models/exercise.dart';

class AddExercisePage extends StatefulWidget {
  const AddExercisePage({super.key});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  // Variabili di stato: queste mantengono i dati mentre l'utente digita.
  String muscleGroupName = '';
  // Inizializziamo la lista con un esercizio vuoto per avere subito un form a schermo
  List<Exercise> exercises = [Exercise()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuovo Gruppo Muscolare'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // ListView permette lo scorrimento se aggiungi molti esercizi
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Campo per il nome del gruppo muscolare (es: "Petto", "Dorso")
          TextField(
            decoration: const InputDecoration(
              labelText: 'Nome Gruppo Muscolare',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Non serve setState qui se non dobbiamo aggiornare altre parti della UI istantaneamente
              muscleGroupName = value;
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Esercizi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          // Costruiamo la lista di schede (Card) per gli esercizi dinamicamente
          ...exercises.asMap().entries.map((entry) {
            int index = entry.key;
            Exercise exercise = entry.value;
            return _buildExerciseCard(exercise, index);
          }),
        ],
      ),
      // Pulsante fluttuante per aggiungere un nuovo esercizio alla lista
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // setState avvisa Flutter che i dati sono cambiati e deve ridisegnare la UI
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
  Widget _buildExerciseCard(Exercise exercise, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Nome Esercizio
            TextField(
              decoration: InputDecoration(labelText: 'Nome Esercizio ${index + 1}'),
              onChanged: (value) => exercise.name = value,
            ),
            const SizedBox(height: 10),
            // Riga per Serie, Ripetizioni e Carico
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Serie'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => exercise.sets = int.tryParse(value) ?? 0,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Ripetizioni'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => exercise.reps = int.tryParse(value) ?? 0,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Carico (kg)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => exercise.weight = double.tryParse(value) ?? 0.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}