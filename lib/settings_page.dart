import 'dart:convert';
import 'dart:typed_data'; // Necessario per Uint8List
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/exercise.dart'; // Assicurati che questo percorso sia corretto

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // --- LOGICA DI ESPORTAZIONE (WEB SAFE) ---
  Future<void> _exportData() async {
    try {
      // 1. Convertiamo in JSON
      final String jsonString = jsonEncode(globalWorkoutHistory.map((e) => e.toJson()).toList());
      
      // 2. Trasformiamo la stringa in un array di byte (memoria)
      final List<int> bytes = utf8.encode(jsonString);
      
      // 3. Creiamo un XFile virtuale dai byte
      final xfile = XFile.fromData(
        Uint8List.fromList(bytes), 
        name: 'gym_tracker_backup.json', 
        mimeType: 'application/json'
      );
      
      // 4. share_plus capirà automaticamente che su Web deve avviare il download del file
      await Share.shareXFiles(
        [xfile], 
        text: 'Backup Storico Allenamenti',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante l\'esportazione: $e')),
        );
      }
    }
  }

  // --- LOGICA DI IMPORTAZIONE (WEB SAFE) ---
  Future<void> _importData() async {
    try {
      // 1. Aggiungiamo withData: true. È FONDAMENTALE sul web per farci restituire i byte del file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, 
      );

      // Controlliamo che result.files.single.bytes non sia nullo
      if (result != null && result.files.single.bytes != null) {
        // 2. Decodifichiamo i byte in una stringa di testo
        String jsonString = utf8.decode(result.files.single.bytes!);
        
        // 3. Facciamo il parsing del JSON
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final List<WorkoutSession> importedHistory = jsonList.map((e) => WorkoutSession.fromJson(e)).toList();

        if (mounted) {
          _mostraPopupSovrascrittura(importedHistory);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File non valido o corrotto. Impossibile importare. Dettagli: $e')),
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
          content: const Text(
            'Vuoi sostituire il tuo storico attuale con i dati del backup o aggiungerli a quelli esistenti?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  // Aggiungiamo i dati importati alla lista attuale
                  globalWorkoutHistory.addAll(importedData); 
                });
                await saveWorkoutHistory();
                if (mounted) Navigator.of(dialogContext).pop();
                _mostraSuccesso('Dati aggiunti con successo!');
              },
              child: const Text('Aggiungi'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  // Sostituiamo interamente la lista
                  globalWorkoutHistory = importedData;
                });
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

  // --- INTERFACCIA UTENTE ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Gestione Dati',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange),
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