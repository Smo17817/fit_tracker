import 'package:flutter/material.dart';
import 'add_exercise.dart';
import 'hystory_page.dart';
import 'settings_page.dart';
import 'models/exercise.dart';

void main() async {
  // Obbligatorio quando si esegue codice asincrono prima di runApp()
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Carica i dati dal disco alla memoria RAM
  await loadWorkoutHistory(); 
  
  runApp(const FitTrackApp());
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fit Tracker',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        // 1. Sfondo generale quasi nero
        scaffoldBackgroundColor: const Color(0xFF09090B), 
        
        // 2. Schema colori principale
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676), // Il tuo Verde Neon
          onPrimary: Colors.black,    // Testo nero sui bottoni verdi per massimo contrasto
          surface: Color(0xFF18181B), // Grigio scuro per le Card (schede)
          onSurface: Colors.white,    // Testo bianco sulle Card
        ),

        // 3. Stile delle Schede (Cards) più smussato e moderno
        cardTheme: CardTheme(
          color: const Color(0xFF18181B),
          elevation: 0, // Togliamo le ombre per un look "flat" e pulito
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // 4. Stile dei campi di testo (Input)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF27272A), // Sfondo del campo di testo
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00E676), width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.grey),
          floatingLabelStyle: const TextStyle(color: Color(0xFF00E676)),
        ),

        // 5. Menu di navigazione inferiore
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF09090B),
          indicatorColor: const Color(0xFF00E676).withOpacity(0.2), // Sfondo icona attiva
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF00E676)); // Icona verde se attiva
            }
            return const IconThemeData(color: Colors.grey); // Grigia se inattiva
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold);
            }
            return const TextStyle(color: Colors.grey);
          }),
        ),

        // 6. Pulsante Fluttuante (FAB) in basso a destra
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00E676),
          foregroundColor: Colors.black, // Icona "+" nera
          shape: CircleBorder(), // Rotondo perfetto
        ),

        // 7. Barra superiore
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF09090B),
          surfaceTintColor: Colors.transparent, // Evita che l'appbar cambi colore scorrendo
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Colors.white
          ),
        ),
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
    const HistoryPage(), // 1: La pagina dello storico che abbiamo già creato
    const SettingsPage(), // 2: La pagina delle impostazioni che abbiamo già creato
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
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Impostazioni',
          ),
        ],
      ),
    );
  }
}