import 'package:flutter/material.dart';
import '../models/exercise.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  String? selectedMuscleGroup;

  final List<String> muscleGroups = [
    'Petto', 'Dorso', 'Gambe', 'Spalle', 'Bicipiti', 'Tricipiti', 'Addome', 'Full Body', 'Cardio'
  ];

  Map<String, List<_ProgressPoint>> _elaboraProgressi() {
    Map<String, List<_ProgressPoint>> mappaProgressi = {};

    for (var session in globalWorkoutHistory) {
      if (session.muscleGroup == selectedMuscleGroup) {
        for (var exercise in session.exercises) {
          if (exercise.name.trim().isEmpty) continue;

          double maxValoreSessione = 0;
          for (var s in exercise.sets) {
            if (s.weight > maxValoreSessione) {
              maxValoreSessione = s.weight;
            }
          }

          if (maxValoreSessione > 0) {
            mappaProgressi.putIfAbsent(exercise.name, () => []);
            mappaProgressi[exercise.name]!.add(_ProgressPoint(
              date: session.date,
              value: maxValoreSessione,
              unit: exercise.unit,
            ));
          }
        }
      }
    }
    return mappaProgressi;
  }

  @override
  Widget build(BuildContext context) {
    final datiProgressi = _elaboraProgressi();
    
    // Recuperiamo il colore primario del tema attualmente attivo
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisi Progressi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Seleziona Gruppo Muscolare',
              border: OutlineInputBorder(),
            ),
            value: selectedMuscleGroup,
            hint: const Text('Scegli cosa analizzare...'),
            items: muscleGroups.map((String group) {
              return DropdownMenuItem<String>(value: group, child: Text(group));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedMuscleGroup = newValue;
              });
            },
          ),
          const SizedBox(height: 24),

          if (selectedMuscleGroup == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Text(
                  'Seleziona un gruppo muscolare in alto\nper sbloccare i tuoi grafici.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else if (datiProgressi.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Text(
                  'Nessun dato sufficiente per questo gruppo.\nSalva prima qualche allenamento nello storico!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else
            ...datiProgressi.entries.map((entry) {
              final nomeEsercizio = entry.key;
              final punti = entry.value;

              final prPoint = punti.reduce((a, b) => a.value > b.value ? a : b);

              return Card(
                margin: const EdgeInsets.only(bottom: 20.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            nomeEsercizio,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              // Usiamo il colore dinamico con opacità per lo sfondo del badge
                              color: primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'PR: ${prPoint.value.toStringAsFixed(1)} ${prPoint.unit}',
                              style: TextStyle(
                                color: primaryColor, // Testo del PR col colore del tema
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Passiamo il context per far leggere i colori al grafico
                      _buildGraficoNativo(punti, context),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // Aggiunto il parametro BuildContext per accedere al tema
  Widget _buildGraficoNativo(List<_ProgressPoint> punti, BuildContext context) {
    final ultimiPunti = punti; // Adesso prende tutta la storia dell'esercizio
    
    // Recuperiamo il colore primario
    final primaryColor = Theme.of(context).colorScheme.primary;

    double valoreMassimoAssoluto = ultimiPunti.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    if (valoreMassimoAssoluto == 0) valoreMassimoAssoluto = 1;

    // Avvolgiamo la riga in una SingleChildScrollView orizzontale
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Usiamo reverse: true se vuoi che parta già scorrendo verso gli allenamenti più recenti a destra
      reverse: true, 
      child: Row(
        // Cambiamo l'allineamento per evitare che si allarghino troppo
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: ultimiPunti.map((p) {
          final double altezzaBarra = (p.value / valoreMassimoAssoluto) * 90;
          final dataFormattata = '${p.date.day}/${p.date.month}';

          return Padding(
            // Aggiungiamo 12 pixel di spazio fisso a destra di ogni barra
            padding: const EdgeInsets.only(right: 12.0), 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 28,
                  height: altezzaBarra < 6 ? 6 : altezzaBarra, 
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dataFormattata,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProgressPoint {
  final DateTime date;
  final double value;
  final String unit;
  _ProgressPoint({required this.date, required this.value, required this.unit});
}