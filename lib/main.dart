import 'package:flutter/material.dart';
import 'add_exercise.dart';
import 'hystory_page.dart'; // Mantenuto il nome del file originale
import 'settings_page.dart';
import 'models/exercise.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  // Obbligatorio quando si esegue codice asincrono prima di runApp()
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Carica i dati dal disco alla memoria RAM
  await loadWorkoutHistory(); 
  
  runApp(const FitTrackApp());
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fit Tracker',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        
        // Configurazione globale del font per tutto il testo dell'applicazione
        textTheme: GoogleFonts.oswaldTextTheme(ThemeData.dark().textTheme),

        // Sfondo generale quasi nero
        scaffoldBackgroundColor: const Color(0xFF09090B), 
        
        // Schema colori principale (Dark Mode con accento Verde Neon)
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676), 
          onPrimary: Colors.black,    
          surface: Color(0xFF18181B), 
          onSurface: Colors.white,    
        ),

        // Stile delle Schede (Cards) smussato e piatto
        cardTheme: CardTheme(
          color: const Color(0xFF18181B),
          elevation: 0, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // Stile moderno dei campi di testo (Input)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF27272A), 
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

        // Menu di navigazione inferiore in stile minimalista
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF09090B),
          indicatorColor: const Color(0xFF00E676).withOpacity(0.2), 
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF00E676)); 
            }
            return const IconThemeData(color: Colors.grey); 
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold);
            }
            return const TextStyle(color: Colors.grey);
          }),
        ),

        // Pulsante Fluttuante rotondo per il salvataggio
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00E676),
          foregroundColor: Colors.black, 
          shape: CircleBorder(), 
        ),

        // Barra superiore coerente con lo sfondo scuro
        // 7. Barra superiore
        appBarTheme: AppBarTheme( // Attenzione: ho tolto il "const" qui!
          backgroundColor: const Color(0xFF09090B),
          surfaceTintColor: Colors.transparent, 
          elevation: 0,
          centerTitle: true,
          // --- LA MODIFICA È QUI ---
          // Applichiamo GoogleFonts direttamente al titolo. 
          // Sostituisci "oswald" con il font che hai scelto (es. teko, bebasNeue)
          titleTextStyle: GoogleFonts.oswald(
            fontSize: 32, // Ho aumentato un po' la grandezza per renderlo più d'impatto
            fontWeight: FontWeight.bold, 
            color: Colors.white,
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
  int currentPageIndex = 0;

  // Lista delle pagine associate alle rispettive sezioni del menu
  final List<Widget> pages = [
    const AddExercisePage(), 
    const HistoryPage(),     
    const SettingsPage(),    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
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