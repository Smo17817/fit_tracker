
# 🏋️‍♂️ Fit Tracker

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

Fit Tracker è un'applicazione mobile sviluppata in **Flutter** pensata per offrire un tracciamento degli allenamenti intelligente, rapido e orientato ai dati. Nata dall'esigenza di monitorare costantemente gli allenamenti fisici — dal sollevamento pesi puro fino alle sessioni di cardio ad alta pendenza sul tapis roulant — l'app unisce un'interfaccia pulita a logiche di filtraggio e analisi avanzate.

---

## ✨ Funzionalità Principali

*   🧠 **Smart Logging & Autocompletamento:** Inserimento degli esercizi fulmineo. L'app impara dal tuo storico e ti suggerisce i nomi degli esercizi in base al gruppo muscolare selezionato.
*   🔄 **Auto-Load delle Schede:** Selezionando un gruppo muscolare, l'app carica automaticamente l'ultima scheda eseguita per quello specifico distretto, permettendoti di ripartire esattamente da dove avevi lasciato.
*   📈 **Analisi Avanzata dei Progressi (Dual View):** Grafici interattivi e scorrevoli per monitorare le tue prestazioni con un semplice swipe:
    *   **Massimale (PR):** Traccia il picco di forza e l'evoluzione del carico massimo.
    *   **Volume Totale:** Calcola e visualizza il tonnellaggio totale (Serie × Ripetizioni × Peso), fondamentale per il monitoraggio dell'ipertrofia.
*   🔍 **Storico Filtrabile:** Un database locale completo dei tuoi allenamenti. Cerca per nome dell'esercizio, filtra per distretto muscolare o visualizza rapidamente solo l'ultima sessione eseguita per ogni gruppo.
*   ⚖️ **Unità di Misura Dinamiche:** Supporto completo per tracciare pesi (`Kg`), tempi di recupero o tenute isometriche (`Sec`, `Min`) e ritmi di corsa (`Pace`).
*   🎨 **Theming Dinamico:** Interfaccia utente fluida che si adatta automaticamente al tema di sistema (Chiaro/Scuro) e ai colori primari scelti dall'utente, garantendo un'esperienza visiva sempre coerente.
*   💾 **Offline First & Privacy:** Tutti i dati vengono salvati localmente sul dispositivo (`shared_preferences`), garantendo massima reattività e privacy totale, senza necessità di connessione internet.

---

## 📸 Anteprima (Screenshots)
<p align="center">
   <img width="32%" alt="Image" src="https://github.com/user-attachments/assets/2bd5d71f-8e1f-41d0-996e-bbbef2953dad" />
   <img width="32%" alt="Image" src="https://github.com/user-attachments/assets/44f51086-07d0-4d8b-ba7f-3bfd31d16046" />
   <img width="32%" alt="Image" src="https://github.com/user-attachments/assets/b1d56868-0cb6-4b6b-8b26-33ef9b3caea0" />
</p>

---

## 🚀 Installazione e Avvio

Assicurati di avere [Flutter](https://flutter.dev/docs/get-started/install) installato sul tuo computer.

1. **Clona il repository:**
```bash
git clone https://github.com/Smo17817/fit_tracker.git
```

2. **Entra nella directory del progetto:**
```bash
cd fit_tracker
```

3. **Scarica le dipendenze:**
```bash
flutter pub get
```

4. **Esegui l'app:**
```bash
flutter run
```

### Generare l'APK per Android
Per creare un pacchetto di installazione standalone compresso e ottimizzato:

```bash
flutter build apk --release
```
Troverai il file generato al percorso: ```build/app/outputs/flutter-apk/app-release.apk```.
