# Spiele – eine Spielesammlung für christliche Kinder

Eine kleine, liebevoll gestaltete Spielesammlung für Kinder: biblische Geschichten zum Mitmachen und ein Klassiker zum Entspannen. Alles läuft komplett offline, ohne Werbung, ohne Tracking, ohne In-App-Käufe – sicher für kleine Finger und Elternherzen.

Die Android-App (APK) wird automatisch von GitHub gebaut (kostenlos).

## Die Spiele

### 🐑 Davids Weg

Ein Abenteuer in 4 Levels über den Hirtenjungen David und seinen Weg zu Gott – mit Quizfragen, Bibelversen und einem Schlussvers:

1. **Der Hirtenjunge** – David hütet die Schafe: Führe David über das Feld und bring alle Schafe ins Gehege. *„Der HERR ist mein Hirte." (Psalm 23,1)*
2. **Die Harfe** – David spielt König Saul auf der Harfe vor: Triff die Noten im Takt. *„Gott ist bei dir – er wird dich erretten." (1. Samuel 17,37)*
3. **Der Weg ins Tal** – Sammle 5 glatte Steine und weiche den Felsen aus.
4. **David und Goliat** – Mit Schleuder und Stein, aber vor allem im Vertrauen auf Gott: *„Der HERR hilft nicht durch Schwert oder Spieß; denn der Streit ist des HERRN." (1. Samuel 17,47)*

In allen Levels gibt es Quizfragen zur Geschichte und einen Gebets-Bonus (+1 Mut). So lernen die Kinder die biblische Geschichte spielerisch kennen.

### 🐑 Wo ist mein Schaf?

Ein Suchspiel für die Kleinsten (4-6 Jahre) nach dem Gleichnis vom verlorenen Schaf (Lukas 15) und Psalm 23: Der Hirte sucht sein Schäfchen hinter Büschen, Heuballen, Felsen und im dunklen Tal – 4 Suchbilder mit steigender Zahl an Verstecken, ohne Zeitdruck und ohne Verlieren. Jedes gefundene Schaf bringt einen Vers aus Psalm 23, am Ende feiern alle mit Lukas 15,6. Mit deutscher Sprachausgabe (falls verfügbar), freundlichen Tönen, Lautsprecher-Button zum Stummschalten und gemerkter höchster Stufe.

### 🐍 Snake

Der Klassiker mit Swipe-Steuerung: Füttere die Schlange und werde länger – ohne Zeitdruck, perfekt zum Abschalten.

## Für Eltern und Kommunitoren

- **Komplett offline**: Keine externen Dateien, keine Internetverbindung nötig.
- **Keine Werbung, keine Käufe, kein Tracking**: Die App sammelt nichts und sendet nichts.
- **Kinderleichte Steuerung**: Alles per Fingertipp bzw. Wischen, große Knöpfe, keine Werbung zwischen den Levels.
- **Ohne Internet-Berechtigung:** Wer sicher sein will, dass die App nie ins Netz kann, entfernt im Workflow-Schritt „App anpassen" die Zeile `android.permission.INTERNET` aus der AndroidManifest.xml (per `sed -i '/permission.INTERNET/d'`). Danach bitte kurz testen, ob alles noch startet.

## APK holen (für Eltern ohne Entwickler-Umgebung)

1. Im Repository oben auf **Actions** klicken. Der Lauf „APK bauen" startet automatisch bei jedem Push (ca. 5-8 Minuten).
2. Wenn er grün ist: Lauf öffnen, unten bei **Artifacts** `spiele-apk` herunterladen und entpacken.
3. `app-debug.apk` aufs Tablet kopieren, antippen und installieren.
   (Android fragt einmal nach „Installation aus unbekannten Quellen".)

Die App heißt auf dem Startbildschirm **Spiele** und zeigt das Auswahl-Menü. Von jedem Spiel kommt man über den Pfeil-oben-„← Spiele"-Button zurück ins Menü.

## Mitentwickeln – Einmalig einrichten

Voraussetzungen: Node 20+, Java 17 (Temurin), Android SDK (oder Android Studio installiert). Die APK-Dateien (`.github/`, `.gitignore`) müssen im Repository-Root liegen.

1. Auf github.com ein Konto anlegen und ein neues **privates** Repository erstellen (z. B. `spiele-app`), ohne README. Den **Inhalt dieses Ordners** (`spiele-app/` samt dem versteckten `.github`-Ordner) ins Repository-Root legen, nicht den übergeordneten Ordner.
2. Diesen Ordner in VSCodium öffnen (Datei → Ordner öffnen).
3. Im VSCodium-Terminal:
   ```
   git init -b main
   git add .
   git commit -m "Spiele-App"
   git remote add origin https://github.com/DEIN-NAME/spiele-app.git
   git push -u origin main
   ```
   (GitHub fragt nach Anmeldung bzw. Token.)
   Alternativ: Repository per GitHub Desktop hochladen – `.github/` und `.gitignore` müssen mit übertragen werden.

## Änderungen hochladen (neue APK entsteht automatisch)

- Menü: `www/index.html`
- Davids Weg: `www/davids-weg.html`
- Wo ist mein Schaf? `www/wo-ist-mein-schaf/index.html`
- Snake: `www/snake.html`

Danach wie gewohnt commit & push:
```
git add . && git commit -m "Änderung" && git push
```
Die neue APK entsteht automatisch. Manuell starten geht unter Actions → „APK bauen" → Run workflow.

## Auf dem eigenen Rechner bauen (optional, Android Studio nicht nötig)

```
npm install
npx cap add android        # nur beim ersten Mal
npx cap sync android
cd android && ./gradlew assembleDebug
```

Die APK liegt dann unter `android/app/build/outputs/apk/debug/app-debug.apk`.
Der GitHub-Workflow (`.github/workflows/build-apk.yml`) erzwingt zusätzlich Querformat und Vollbild per `sed` – wer lokal baut, muss diese zwei Zeilen ggf. selbst in `AndroidManifest.xml` und `res/values/styles.xml` eintragen.

## Hinweise und Ideen für die Zukunft

- **App-Name / Paket-ID:** In `capacitor.config.json` (`appName`, `appId`) und `package.json` einstellen.
- **App-Icon:** Standard-Icon von Capacitor. Ein eigenes Icon lässt sich später ergänzen (Ordner `android/app/src/main/res/mipmaps-*`).
- **Fehler im Lauf?** Den roten Schritt aufklappen und die Fehlermeldung anschauen.

Ideen für weitere biblische Spiele (PRs willkommen!): Noa arche, Jona im Wal, Mose und das Rote Meer, Daniel in der Löwengrube.
