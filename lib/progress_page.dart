import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../data/muscle_groups.dart'; 

class ChartPoint {
  final DateTime date;
  final double value;
  final String unit;

  ChartPoint({required this.date, required this.value, required this.unit});
}

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  // Variabili di stato per i filtri
  String selectedGroup = 'Tutti';
  String searchQuery = '';

  // Creiamo la lista per il dropdown aggiungendo 'Tutti' all'inizio
  final List<String> dropdownGroups = ['Tutti', ...appMuscleGroups];

  // Filtra dinamicamente gli esercizi in base al Gruppo e alla Ricerca
  List<String> get _filteredExercises {
    Set<String> exercises = {};
    for (var session in globalWorkoutHistory) {
      // 1. Controllo del Gruppo Muscolare
      if (selectedGroup == 'Tutti' || session.muscleGroup == selectedGroup) {
        for (var ex in session.exercises) {
          if (ex.name.isNotEmpty) {
            // 2. Controllo della barra di ricerca
            if (searchQuery.isEmpty || ex.name.toLowerCase().contains(searchQuery.toLowerCase())) {
              exercises.add(ex.name);
            }
          }
        }
      }
    }
    return exercises.toList()..sort();
  }

  List<ChartPoint> _getPointsPR(String exerciseName) {
    List<ChartPoint> points = [];
    for (var session in globalWorkoutHistory.reversed) {
      for (var ex in session.exercises) {
        if (ex.name == exerciseName) {
          double maxWeight = 0.0;
          for (var set in ex.sets) {
            if (set.weight > maxWeight) maxWeight = set.weight;
          }
          if (maxWeight > 0) {
            points.add(ChartPoint(date: session.date, value: maxWeight, unit: ex.unit));
          }
        }
      }
    }
    return points;
  }

  List<ChartPoint> _getPointsVolume(String exerciseName) {
    List<ChartPoint> points = [];
    for (var session in globalWorkoutHistory.reversed) {
      for (var ex in session.exercises) {
        if (ex.name == exerciseName) {
          double totalVolume = 0.0;
          for (var set in ex.sets) {
            totalVolume += (set.weight * set.reps);
          }
          if (totalVolume > 0) {
            points.add(ChartPoint(date: session.date, value: totalVolume, unit: ex.unit));
          }
        }
      }
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filteredExercises;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('I Miei Progressi'),
      ),
      body: Column(
        children: [
          // ZONA SUPERIORE: Ricerca e Filtro Gruppo
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            ),
            child: Column(
              children: [
                // Barra di ricerca
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Cerca esercizio...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Dropdown Gruppo Muscolare
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Filtra Gruppo',
                    prefixIcon: Icon(Icons.accessibility_new),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: selectedGroup,
                  items: dropdownGroups.map((group) => DropdownMenuItem(value: group, child: Text(group))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedGroup = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // ZONA INFERIORE: TabController con Liste
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: primaryColor,
                    tabs: const [
                      Tab(icon: Icon(Icons.emoji_events), text: 'Massimale (PR)'),
                      Tab(icon: Icon(Icons.bar_chart), text: 'Volume Totale'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildExerciseList(exercises, isVolume: false, primaryColor: primaryColor),
                        _buildExerciseList(exercises, isVolume: true, primaryColor: primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(List<String> exercises, {required bool isVolume, required Color primaryColor}) {
    if (exercises.isEmpty) {
      return const Center(
        child: Text(
          'Nessun esercizio trovato\ncon i filtri attuali.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24, top: 8),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exName = exercises[index];
        final points = isVolume ? _getPointsVolume(exName) : _getPointsPR(exName);
        final color = isVolume ? primaryColor.withOpacity(0.7) : primaryColor;
        final label = isVolume ? 'Volume Record' : 'Record Assoluto (PR)';

        return _buildGraficoNativo(
          nomeEsercizio: exName,
          punti: points,
          labelRecord: label,
          coloreBarra: color,
        );
      },
    );
  }

  Widget _buildGraficoNativo({
    required String nomeEsercizio,
    required List<ChartPoint> punti,
    required String labelRecord,
    required Color coloreBarra,
  }) {
    if (punti.isEmpty) return const SizedBox.shrink();

    double maxAssoluto = 0.0;
    for (var p in punti) {
      if (p.value > maxAssoluto) maxAssoluto = p.value;
    }
    final unit = punti.first.unit;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    nomeEsercizio,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      labelRecord,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '${maxAssoluto.toStringAsFixed(1)} $unit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: coloreBarra.withOpacity(1.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            SizedBox(
              height: 150, 
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: punti.map((p) {
                    final double altezzaBarra = maxAssoluto == 0 ? 0 : (p.value / maxAssoluto) * 100;

                    return Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            p.value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 24,
                            height: altezzaBarra < 8 ? 8 : altezzaBarra,
                            decoration: BoxDecoration(
                              color: coloreBarra,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${p.date.day}/${p.date.month}',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}