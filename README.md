# Spiele-App – APK bauen

Zwei Spiele in einer App, wählbar über ein Menü:

- **Davids Weg** (`www/davids-weg.html`) – Bibel-Spiel für Kinder, 4 Levels
- **Snake** (`www/snake.html`) – Klassiker mit Swipe-Steuerung

Das Auswahl-Menü liegt in `www/index.html`. Alles läuft komplett offline, es gibt keine externen Dateien. Die APK wird automatisch von GitHub gebaut (kostenlos).

## Einmalig einrichten

1. Auf github.com ein Konto anlegen und ein neues **privates** Repository erstellen (z. B. `spiele-app`), ohne README. Wichtig: den **Inhalt dieses Ordners** (`spiele-app/` samt dem versteckten `.github`-Ordner) ins Repository-Root legen, nicht den übergeordneten Ordner.
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

## APK holen

1. Im Repository oben auf **Actions** klicken. Der Lauf „APK bauen" startet automatisch (ca. 5-8 Minuten).
2. Wenn er grün ist: Lauf öffnen, unten bei **Artifacts** `spiele-apk` herunterladen und entpacken.
3. `app-debug.apk` aufs Tablet kopieren, antippen und installieren
   (Android fragt einmal nach „Installation aus unbekannten Quellen").

Die App heißt auf dem Startbildschirm **Spiele** und zeigt das Auswahl-Menü. Von jedem Spiel kommt man über den Pfeil-oben-„← Spiele"-Button zurück ins Menü.

## Spiele ändern

- Menü: `www/index.html`
- Davids Weg: `www/davids-weg.html`
- Snake: `www/snake.html`

Danach wie gewohnt commit & push:
```
git add . && git commit -m "Änderung" && git push
```
Die neue APK entsteht automatisch. Manuell starten geht unter Actions → „APK bauen" → Run workflow.

## Auf dem eigenen Rechner bauen (optional, Android Studio nicht nötig)

Voraussetzungen: Node 20+, Java 17 (Temurin), Android SDK (oder Android Studio installiert).

```
npm install
npx cap add android        # nur beim ersten Mal
npx cap sync android
cd android && ./gradlew assembleDebug
```

Die APK liegt dann unter `android/app/build/outputs/apk/debug/app-debug.apk`.
Der GitHub-Workflow (`.github/workflows/build-apk.yml`) erzwingt zusätzlich Querformat und Vollbild per `sed` – wer lokal baut, muss diese zwei Zeilen ggf. selbst in `AndroidManifest.xml` und `res/values/styles.xml` eintragen.

## Hinweise

- **App-Name / Paket-ID:** In `capacitor.config.json` (`appName`, `appId`) und `package.json` einstellen.
- **App-Icon:** Standard-Icon von Capacitor. Ein eigenes Icon lässt sich später ergänzen (Ordner `android/app/src/main/res/mipmaps-*`).
- **Ohne Internet-Berechtigung:** Wer sicher sein will, dass die App nie ins Netz kann, entfernt im Workflow-Schritt „App anpassen" die Zeile `android.permission.INTERNET` aus der AndroidManifest.xml (per `sed -i '/permission.INTERNET/d'`). Danach bitte kurz testen, ob alles noch startet.
- **Fehler im Lauf?** Den roten Schritt aufklappen und die Fehlermeldung anschauen.
