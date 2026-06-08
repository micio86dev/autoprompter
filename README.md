# Autoprompter

App mobile (Android + iOS) che funziona da **teleprompter intelligente**: crei
i tuoi testi (prompt) in un editor WYSIWYG, li salvi in locale e in fase di
lettura l'app **segue la tua voce** dal microfono, evidenziando le parole e
facendo scorrere automaticamente il testo.

## Funzionalità

- **Lista prompt**: crea, apri, elimina (swipe), **duplica**, **cerca**,
  **ordina** (data/titolo) e **filtra per tag** i tuoi testi, salvati in locale.
- **Editor WYSIWYG** (Markdown): grassetto, corsivo, titoli (H1–H3),
  elenchi puntati/numerati, citazioni, **link** e **codice** (inline e a
  blocco). Include **tag**, **conteggio parole / tempo di lettura stimato** e
  **anteprima del sorgente Markdown** (affiancata su schermi larghi). Il
  contenuto è salvato in **Markdown**.
- **Teleprompter con autoscroll vocale**: riconoscimento vocale **on-device**
  (gratuito, in tempo reale, offline), evidenziazione parola-per-parola e
  scorrimento automatico. Lingua del riconoscimento selezionabile per ogni
  prompt (default Italiano).
  - **Modalità specchio** (flip orizzontale/verticale) per il vetro da
    teleprompter.
  - **Autoscroll a velocità costante** regolabile, alternativo alla voce.
  - **Posizione della riga di lettura** regolabile con guida a schermo.
  - **Tap su una parola** per riposizionare il punto di lettura.
  - Controlli: dimensione testo, "ricomincia", pannello impostazioni.
- **Condivisione/Importazione**: esporta o condividi un prompt come file `.md`,
  importa file Markdown esistenti.
- **Backup/Ripristino**: esporta tutti i dati locali in un file JSON e
  ripristinali.
- **Tema chiaro/scuro/di sistema** per l'intera app, con valori predefiniti del
  teleprompter (font, velocità, riga di lettura) configurabili e persistiti.

## Architettura

```
lib/
  main.dart                       # MaterialApp (locale it, tema chiaro/scuro) + provider
  models/prompt.dart              # modello dati Prompt (con tag)
  data/prompt_repository.dart     # PromptRepository (interfaccia) + impl. sqflite
  state/
    prompt_store.dart             # stato lista: CRUD, ricerca, filtro, ordinamento
    settings_store.dart           # impostazioni persistite (shared_preferences)
  services/
    markdown_service.dart         # Markdown <-> Delta (Quill) <-> testo
    reading_stats.dart            # conteggio parole + tempo di lettura stimato
    speech_service.dart           # SpeechService (interfaccia) + impl. speech_to_text
    word_matcher.dart             # allineamento parole dette <-> testo
    data_service.dart             # condivisione/import .md, backup/ripristino JSON
  screens/
    prompt_list_screen.dart
    prompt_editor_screen.dart
    teleprompter_screen.dart
    settings_screen.dart
  widgets/teleprompter_text.dart  # rendering "karaoke" con evidenziazione + tap
test/                             # test unitari (logica pura) + widget test con mock
```

## Prerequisiti

- Flutter SDK (testato con 3.44). Verifica con `flutter --version`.
- Per **Android**: Android Studio / Android SDK.
- Per **iOS**: Xcode completo + CocoaPods (solo su macOS).

In qualsiasi momento puoi controllare lo stato dell'ambiente con:

```bash
flutter doctor
```

---

## 1. Configura il toolchain mobile

Ti basta **uno** dei due (Android o iOS), in base al telefono che hai.

### Opzione A — Android

1. **Installa Android Studio** da <https://developer.android.com/studio>.
2. Al primo avvio segui il wizard "SDK Components Setup": installa
   **Android SDK**, **SDK Platform-Tools** e **SDK Build-Tools**.
   (Di default l'SDK finisce in `~/Library/Android/sdk` su macOS.)
3. Se Flutter non trova l'SDK, indicagli il percorso:
   ```bash
   flutter config --android-sdk ~/Library/Android/sdk
   ```
4. Accetta le licenze Android:
   ```bash
   flutter doctor --android-licenses
   ```
5. Verifica che sia tutto a posto:
   ```bash
   flutter doctor
   ```
   La voce **[✓] Android toolchain** deve essere verde.

### Opzione B — iOS (solo macOS)

1. **Installa Xcode** completo dall'App Store (non bastano i Command Line Tools).
2. Punta gli strumenti da riga di comando a Xcode e completa il primo avvio:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```
3. **Installa CocoaPods**:
   ```bash
   sudo gem install cocoapods
   # in alternativa: brew install cocoapods
   ```
4. Apri il progetto iOS in Xcode per impostare la firma:
   ```bash
   open ios/Runner.xcworkspace
   ```
   In **Runner ▸ Signing & Capabilities** seleziona un **Team** (va bene anche
   un Apple ID gratuito). Serve per installare l'app su un iPhone reale.
5. Verifica con `flutter doctor` (la voce **[✓] Xcode** deve essere verde).
   `flutter run` esegue `pod install` automaticamente; se serve, puoi farlo a
   mano con `cd ios && pod install`.

---

## 2. Collega un telefono fisico

> ⚠️ **Il riconoscimento vocale richiede un dispositivo reale.** Su simulatore
> iOS / emulatore Android (e su desktop/web) il microfono non è affidabile.

**Android**
1. Sul telefono: **Impostazioni ▸ Info sul telefono** e tocca 7 volte "Numero
   build" per abilitare le **Opzioni sviluppatore**.
2. In **Opzioni sviluppatore** attiva il **Debug USB**.
3. Collega il telefono via USB e, sul telefono, **autorizza** il computer.
4. Assicurati che la **Google app** sia installata (fornisce il motore vocale).

**iOS**
1. Collega l'iPhone via USB e tocca **"Autorizza"** ("Trust") sul telefono.
2. Verifica che la dettatura sia attiva: **Impostazioni ▸ Generali ▸ Tastiera ▸
   Abilita Dettatura**.

Controlla che il dispositivo sia visto da Flutter:

```bash
flutter devices
```

Dovresti vedere il tuo telefono nell'elenco.

---

## 3. Esegui l'app

Dalla cartella del progetto:

```bash
flutter pub get
flutter run                 # usa il dispositivo collegato
# se ne hai più di uno:
flutter run -d <device-id>  # l'id lo trovi con `flutter devices`
```

Al primo avvio della lettura l'app chiederà il **permesso microfono** (su iOS
anche quello di riconoscimento vocale): concedilo per far funzionare l'autoscroll.

## Test

```bash
flutter analyze    # nessun problema
flutter test       # test della logica di matching e della conversione Markdown
```

## Permessi configurati

- **Android** (`android/app/src/main/AndroidManifest.xml`): `RECORD_AUDIO`,
  `INTERNET` e query per `android.speech.RecognitionService`.
- **iOS** (`ios/Runner/Info.plist`): `NSMicrophoneUsageDescription`,
  `NSSpeechRecognitionUsageDescription`.
