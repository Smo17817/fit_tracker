# Fit Tracker 🏋️‍♂️

Un'applicazione mobile minimalista, potente e completamente offline per tracciare i tuoi allenamenti in palestra. Progettata con un'interfaccia moderna e fluida, Fit Tracker ti permette di concentrarti sull'allenamento, mantenendo il pieno controllo sui tuoi dati e sui tuoi progressi.

![Fit Tracker Banner](https://via.placeholder.com/1200x300/09090B/00E676?text=Fit+Tracker+-+Unleash+Your+Limits) 
*(Consiglio: sostituisci questo link con un bel banner o un collage dei tuoi screenshot!)*

## ✨ Caratteristiche Principali

* 📝 **Tracking Intuitivo:** Registra esercizi, serie, ripetizioni e seleziona l'unità di misura adatta (Kg, Minuti, Secondi, Pace).
* 📈 **Analisi dei Progressi:** Una dashboard dedicata genera automaticamente grafici a barre per visualizzare l'andamento dei carichi e calcola il tuo **PR (Personal Record)** per ogni esercizio.
* 🎨 **Temi Dinamici:** Personalizza l'atmosfera del tuo allenamento con 4 stili unici integrati:
    * 🟩 **Neon Cyber** (Scuro - Default)
    * 🟧 **Sunset Energy** (Chiaro)
    * 🟪 **Ultraviolet Pro** (Scuro)
    * 🟥 **Iron Crimson** (Scuro)
* 💾 **Controllo Totale sui Dati (100% Offline):** Nessun server, nessun account richiesto. Esporta l'intero storico in formato JSON per fare un backup o importalo su un nuovo dispositivo in un click.

## 📸 Screenshots

| Allenamento | Storico | Progressi e PR | Temi (Impostazioni) |
| :---: | :---: | :---: | :---: |
| ![Workout](https://via.placeholder.com/200x400?text=Screenshot+1) | ![History](https://via.placeholder.com/200x400?text=Screenshot+2) | ![Progress](https://via.placeholder.com/200x400?text=Screenshot+3) | ![Settings](https://via.placeholder.com/200x400?text=Screenshot+4) |

*(Aggiungi i tuoi screenshot nella cartella del repository e sostituisci i link qui sopra)*

## 🛠️ Stack Tecnologico

Questo progetto è sviluppato interamente in **Flutter** e **Dart**.
I pacchetti principali utilizzati includono:
* `shared_preferences`: Per il salvataggio locale dei dati e del tema.
* `file_picker` & `share_plus`: Per la gestione, l'importazione e l'esportazione dei backup JSON nativi.
* `google_fonts`: Per la tipografia dinamica e aggressiva (Oswald).

## 🚀 Come Installare e Avviare

### Prerequisiti
Assicurati di aver installato:
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (versione >=3.4.0)
* Android Studio o VS Code
* Java JDK 21 (o compatibile con il tuo Gradle wrapper)

### Clonare il progetto

```bash
git clone [https://github.com/TuoNomeUtente/fit_tracker.git](https://github.com/TuoNomeUtente/fit_tracker.git)
cd fit_tracker
```

### 🤝 Contribuire
I contributi sono sempre i benvenuti! Se hai un'idea per migliorare l'app:
1. Fai un Fork del progetto
2. Crea un tuo Branch (git checkout -b feature/NuovaFunzione)
3. Fai il Commit delle tue modifiche (git commit -m 'Aggiunta NuovaFunzione')
4. Fai il Push sul Branch (git push origin feature/NuovaFunzione)
5. Apri una Pull Request