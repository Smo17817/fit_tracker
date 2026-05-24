import 'package:flutter/material.dart';
import 'add_exercise.dart';

void main() {
  runApp(const FitTrackApp());
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fit Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Questa variabile tiene traccia di quale tab è attualmente selezionato (0 = prima pagina)
  int currentPageIndex = 0;

  // Questa è la lista delle pagine che il menu andrà a scambiare
  final List<Widget> pages = [
    const AddExercisePage(), // 0: La pagina che abbiamo già creato
    const Center(child: Text('Storico Allenamenti in arrivo...')), // 1: Segnaposto
    const Center(child: Text('Profilo Utente')), // 2: Segnaposto
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Il body cambia in base all'indice selezionato
      body: pages[currentPageIndex],
      
      // Ecco il nostro menu in basso
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        // Quando tocchi un'icona, aggiorniamo lo stato con il nuovo indice
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        // Definiamo i bottoni del menu
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.fitness_center),
            icon: Icon(Icons.fitness_center_outlined),
            label: 'Allenamento',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history),
            icon: Icon(Icons.history_outlined),
            label: 'Storico',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }
}