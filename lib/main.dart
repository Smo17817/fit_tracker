import 'package:flutter/material.dart';
import 'add_exercise.dart';
import 'hystory_page.dart';
import 'progress_page.dart'; // <-- Re-inserito l'import della pagina progressi
import 'settings_page.dart';
import 'models/exercise.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await loadWorkoutHistory(); 
  runApp(const FitTrackApp());
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  ThemeData _getThemeData(String themeName) {
    final baseTextTheme = themeName == 'Sunset Energy' 
        ? ThemeData.light().textTheme 
        : ThemeData.dark().textTheme;

    final textTheme = GoogleFonts.oswaldTextTheme(baseTextTheme);

    Brightness brightness = Brightness.dark;
    Color scaffoldBg = const Color(0xFF09090B);
    Color primaryColor = const Color(0xFF00E676);
    Color onPrimaryColor = Colors.black;
    Color surfaceColor = const Color(0xFF18181B);
    Color inputColor = const Color(0xFF27272A);

    switch (themeName) {
      case 'Sunset Energy': 
        brightness = Brightness.light;
        scaffoldBg = const Color(0xFFF4F4F5);
        primaryColor = const Color(0xFFFF6D00); 
        onPrimaryColor = Colors.white;
        surfaceColor = Colors.white;
        inputColor = const Color(0xFFE4E4E7);
        break;
      case 'Ultraviolet Pro': 
        brightness = Brightness.dark;
        scaffoldBg = const Color(0xFF07020D); 
        primaryColor = const Color(0xFFB000FF); 
        onPrimaryColor = Colors.white;
        surfaceColor = const Color(0xFF150D22);
        inputColor = const Color(0xFF241935);
        break;
      case 'Iron Crimson': 
        brightness = Brightness.dark;
        scaffoldBg = const Color(0xFF121212);
        primaryColor = const Color(0xFFFF1744); 
        onPrimaryColor = Colors.white;
        surfaceColor = const Color(0xFF1E1E1E);
        inputColor = const Color(0xFF2D2D2D);
        break;
      case 'Neon Cyber':
      default: 
        brightness = Brightness.dark;
        scaffoldBg = const Color(0xFF09090B);
        primaryColor = const Color(0xFF00E676);
        onPrimaryColor = Colors.black;
        surfaceColor = const Color(0xFF18181B);
        inputColor = const Color(0xFF27272A);
        break;
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: onPrimaryColor,
        secondary: primaryColor,
        onSecondary: onPrimaryColor,
        error: Colors.red,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: brightness == Brightness.light ? Colors.black : Colors.white,
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelStyle: BorderSide.none == BorderSide.none ? TextStyle(color: primaryColor) : null,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scaffoldBg,
        indicatorColor: primaryColor.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(color: states.contains(WidgetState.selected) ? primaryColor : Colors.grey);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected) ? primaryColor : Colors.grey,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.bold : FontWeight.normal,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        shape: const CircleBorder(),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.oswald(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: brightness == Brightness.light ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: currentThemeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fit Tracker',
          theme: _getThemeData(currentTheme),
          home: const MainScreen(),
        );
      },
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

  // --- RE-INSERITA LA PAGINA DEI PROGRESSI QUI ---
  final List<Widget> pages = [
    const AddExercisePage(), 
    const HistoryPage(),     
    const ProgressPage(), // Indice 2
    const SettingsPage(), // Indice 3
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
        // --- RE-INSERITA L'ICONA DEI PROGRESSI QUI ---
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.fitness_center), 
            icon: Icon(Icons.fitness_center_outlined), 
            label: 'Allenamento'
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history), 
            icon: Icon(Icons.history_outlined), 
            label: 'Storico'
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.trending_up), 
            icon: Icon(Icons.trending_up_outlined), 
            label: 'Progressi'
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings), 
            icon: Icon(Icons.settings_outlined), 
            label: 'Impostazioni'
          ),
        ],
      ),
    );
  }
}