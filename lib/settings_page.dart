import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/exercise.dart'; 

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Lista dei temi disponibili per la selezione
  final List<String> appThemes = [
    'Neon Cyber',
    'Sunset Energy',
    'Ultraviolet Pro',
    'Iron Crimson'
  ];

  Future<void> _exportData() async {
    try {
      final String jsonString = jsonEncode(globalWorkoutHistory.map((e) => e.toJson()).toList());
      final List<int> bytes = utf8.encode(jsonString);
      final xfile = XFile.fromData(
        Uint8List.fromList(bytes), 
        name: 'gym_tracker_backup.json', 
        mimeType: 'application/json'
      );
      await Share.shareXFiles([xfile], text: 'Backup Storico Allenamenti');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante l\'esportazione: $e')),
        );
      }
    }
  }

  Future<void> _importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, 
      );

      if (result != null && result.files.single.bytes != null) {
        String jsonString = utf8.decode(result.files.single.bytes!);
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final List<WorkoutSession> importedHistory = jsonList.map((e) => WorkoutSession.fromJson(e)).toList();

        if (mounted) {
          _mostraPopupSovrascrittura(importedHistory);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File non valido o corrotto: $e')),
        );
      }
    }
  }

  void _mostraPopupSovrascrittura(List<WorkoutSession> importedData) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Importa Backup'),
          content: const Text('Vuoi sostituire il tuo storico attuale con i dati del backup o aggiungerli a quelli esistenti?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Annulla')),
            TextButton(
              onPressed: () async {
                setState(() { globalWorkoutHistory.addAll(importedData); });
                await saveWorkoutHistory();
                if (mounted) Navigator.of(dialogContext).pop();
                _mostraSuccesso('Dati aggiunti con successo!');
              },
              child: const Text('Aggiungi'),
            ),
            TextButton(
              onPressed: () async {
                setState(() { globalWorkoutHistory = importedData; });
                await saveWorkoutHistory();
                if (mounted) Navigator.of(dialogContext).pop();
                _mostraSuccesso('Storico sovrascritto con successo!');
              },
              child: const Text('Sovrascrivi', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _mostraSuccesso(String messaggio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messaggio), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- NUOVA SEZIONE: STILE APP ---
          const Text(
            'Personalizzazione',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stile Interfaccia',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Ascoltiamo il notifier per mostrare il valore corretto nel Dropdown
                  ValueListenableBuilder<String>(
                    valueListenable: currentThemeNotifier,
                    builder: (context, currentTheme, child) {
                      return DropdownButtonFormField<String>(
                        value: currentTheme,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: appThemes.map((String theme) {
                          return DropdownMenuItem<String>(
                            value: theme,
                            child: Text(theme),
                          );
                        }).toList(),
                        onChanged: (String? newValue) async {
                          if (newValue != null) {
                            // Aggiorna il tema globalmente
                            currentThemeNotifier.value = newValue;
                            // Salva la scelta in memoria locale
                            await saveWorkoutHistory(); 
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),

          // --- SEZIONE GESTIONE DATI (ESISTENTE) ---
          const Text(
            'Gestione Dati',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Esporta Storico'),
                  subtitle: const Text('Salva un backup dei tuoi allenamenti (JSON)'),
                  onTap: _exportData,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Importa Storico'),
                  subtitle: const Text('Ripristina i dati da un file locale'),
                  onTap: _importData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}