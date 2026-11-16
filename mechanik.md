# Spielmechanik – Abstract

Dieses Dokument fasst die Spielmechaniken und zugrunde liegenden Logiken der
drei Spiele der Sammlung zusammen. Alle Spiele sind in reinem Vanilla-JavaScript
geschrieben (Canvas-2D bzw. SVG), laufen vollständig offline und sind primär für
Touchsteuerung auf Android-Tablets entworfen (Capacitor-Webview), mit
Tastatur-Eingaben als Desktop-Ersatz. Biblische Verse sind in jedem Spiel an
Spielmeilensteine gekoppelt und kein reiner Zierrat.

```
spiele-app/www/
├── index.html                    Auswahl-Menü (statische Karten)
├── davids-weg.html               Abenteuer in 4 Leveln (Canvas)
├── snake.html                    Arcade-Klassiker (Canvas)
└── wo-ist-mein-schaf/index.html  Suchspiel für Kleinkinder (SVG)
```

---

## Davids Weg (`davids-weg.html`)

**Konzept.** Ein Level-basiertes Abenteuer über 1. Samuel 16–17: vier Levels mit
jeweils eigener Kernmechanik (Hüten, Rhythmus, Jump-'n'-Run, Physik-Zielwurf),
dazwischen je ein Quiz. Empfohlenes Alter 7–10.

**Architektur.** Canvas 960×540, eine `requestAnimationFrame`-Hauptschleife mit
delta-basiertem Update (`dt`, auf 50 ms geklemmt). Eine Finite-State-Machine
steuert den Spielzustand: `menu → l1 → l2 → l3 → play → won/lost → quiz →
done → end`. Bedienelemente sind pro Frame neu registrierte Button-Rechtecke
(`btns[]`), abgefragt über einen globalen `pointerdown`-Handler. Die
Levelfolge ist fest verdrahtet; `startLevel(n)` setzt alles zurück – nur die
im dritten Level gesammelten Steine (`carry`) bleiben erhalten.

**Level 1 – Der Hirtenjunge (Leit-Mechanik).**
David bewegt sich direkt auf einen Tipp-Zielpunkt zu (210 px/s). Die fünf
Schafe haben ein einfaches Schwarmverhalten: Innerhalb von 160 px um David
gehen sie auf ihn zu (45 px Radius als „angekommen“-Zone), außerhalb bleiben
sie stehen. Ziel ist das Gehege (Hitbox x 810–930, y 210–330). Zwei Wölfe
verfolgen jeweils das nächste freie Schaf (75 px/s). Kommt David einem Wolf
näher als 110 px, flieht dieser für 3 s (Schreck-Timer) von David weg.
Erreicht ein Wolf ein Schaf, kostet das einen der drei „Mut“-Punkte. Alle
Schafe im Gehege → Level geschafft, `hp ≤ 0` → verloren.

**Level 2 – Die Harfe (Rhythmus-Mechanik).**
Alle 850 ms erscheint eine Note auf einer von drei zufälligen Bahnen
(x = 330/480/630) und fällt mit 270 px/s auf die Trefferlinie bei y = 440.
Die Toleranz beträgt ±55 px. Tippt der Spieler eine Bahn (oder drückt A/S/D),
wird die am nächsten an der Linie liegende, noch nicht verpasste Note dieser
Bahn als getroffen markiert. 12 von 20 Treffern bedeuten Erfolg; verpasste
Noten haben keine direkte Strafe, nur die Erfolgsquote zählt. Feedback:
„Sauls Stimmung“ als Fortschrittsbalken, der zusätzlich die
Hintergrundfarbe interpoliert; Fehlgriffe und Verpassen lassen die
Trefferlinie kurz rot aufblitzen.

**Level 3 – Der Weg zum Schlachtfeld (Jump-'n'-Run).**
Seitlicher Auto-Runner: David läuft von selbst (230 px/s), die Welt scrollt
unter ihm mit (Kamera = David-x − 200). Physik: Schwerkraft 1700 px/s²,
Sprungimpuls −650 px/s, nur am Boden (Einfach-Sprung). Felsen sind
Hindernisse an festen Weltkoordinaten (Kollisionsradius 34 px): ein Treffer
kostet einen Mut-Punkt, danach 1,2 s Unverwundbarkeit mit Blink-Feedback.
Fünf „glatte Steine“ sind Sammelobjekte (Kollisionsradius 40 px); ihre Anzahl
bestimmt die Munition im finalen Level (`carry = max(2, gesammelt)`,
Mindestwert 2). Zielmarke bei x = 3200.

**Level 4 – David und Goliat (Zielwurf).**
Schleuder nach dem Angry-Birds-Prinzip: Der Spieler zieht vom Ankerpunkt
zurück (maximal 120 px Auslenkung, normiert in `pull()`); beim Loslassen
wird der Stein mit `v = Auslenkung × 8` abgeschossen und folgt einer
ballistischen Flugbahn mit Schwerkraft 900 px/s². Während des Ziehens zeigt
eine gepunktete Vorschau die Trajektorie. Trefferlogik: Kontakt mit der Stirn
(< 30 px von Goliat-Kopf) → Sieg mit Fallanimation (Goliat rotiert schrittweise
um die Querachse); Treffer des Körpers oder Miss zeigen Hilfetexte, jeweils
ein neuer Versuch. Ohne Steine → verloren. Der „Beten“-Button gewährt einmal
einen Zusatzstein.

**Quiz und Fortschritt.** Jedes Level endet mit 2–3 Multiple-Choice-Fragen:
Eine richtige Antwort bringt 1 Stern und öffnet den Weg zum nächsten Level;
bei einer falschen Antwort wird die richtige Lösung grün und die gewählte rot
markiert – das Spiel geht trotzdem weiter (Lerneffekt statt Strafmechanik). Am Ende steht eine
9-Sterne-Bilanz plus Schlussvers. Der Gebets-Bonus ist pro Level einmalig
(`prayed`-Flag): +1 Mut bzw. +1 Stein; im Bildschirm „Verloren“ kann er als
sofortiger Wiedereinstieg genutzt werden.

---

## Wo ist mein Schaf? (`wo-ist-mein-schaf/index.html`)

**Konzept.** Ein Wimmelbild-Suchspiel nach dem Gleichnis vom verlorenen Schaf
(Lukas 15) und Psalm 23 für 4–6-Jährige: das verlorene Schäfchen in vier
Szenen hinter Verstecken suchen. Bewusste Entschärfung: kein Zeitlimit, kein
Game-Over, kein Zähler mit Folgen – Fehlklicks sind Teil des Entdeckens.

**Architektur.** Statisch erzeugtes SVG (viewBox 1000×620), dessen `innerHTML`
pro Szene aus String-Bausteinen zusammengesetzt wird (Hintergrund, Verdeck,
Schaf, Hirte, Hinweisstern). Eine CSS-Animationspalette (`pop`, `wegda`,
`wiggle`, `bob`, ...) liefert die Pop- und Wackel-Effekte ohne
JavaScript-Renderloop; nur der Hirte wird in `requestAnimationFrame`
animiert. Spielzustand: `start | play | found | finale`.

**Kernschleife.** Jede Stufe in `LEVELS` definiert feste Versteckpositionen
und Verdecktypen (Busch, Heuballen, Teich, Fels, Baum, Höhleneingang, ...).
Randomisierung: Die Reihenfolge der Orte wird gemischt, auf dem ersten Ort
wartet das Schaf, alle übrigen bekommen zufällig gemischte Tiere aus dem
Szenen-Pool – dieselbe Stufe spielt sich also nie identisch. Ein Tipp auf
einen Trefferkreis (unsichtbarer Kreis, r = 75) deckt auf:

- **Schaf gefunden** → Mäh-Ton, Siegesmelodie, Wackelanimation, Vers-Karte
  (ein Psalm-23-Vers pro Stufe), danach Freischaltung der nächsten Stufe
  (`storeUnlocked`) bzw. Feier-Finale mit Lukas 15,6.
- **Fehlklick** → das Tier wird sichtbar (Emoji) und in Banner samt deutscher
  Sprachausgabe namentlich benannt; nach drei Fehlklicks erscheint ein
  hüpfender Hinweisstern über dem Schafversteck. Positive Verstärkung statt
  Strafe.

**Hirten-Logik.** Tippt das Kind auf freies Gelände, läuft der Hirte weich
dorthin (Lerp, max. 5,5 px/Frame, Blickrichtung folgt dem Ziel,
Schritt-Animation während der Bewegung). Jede Aufdeckung lässt ihn neben das
Versteck laufen – er bleibt die Identifikationsfigur, kein zu steuerndes
Spielobjekt.

**Nebensysteme.** Persistierung in `localStorage` (höchste freigeschaltete
Stufe `wims.unlocked`, Stummschaltung `wims.muted`); Sound rein synthetisch
über die Web Audio API (kein Netz, keine Audiodateien); deutsche
Sprachausgabe über `speechSynthesis` (de-DE), fallende Degradation, falls
nicht verfügbar. Stufe 4 nutzt eine Nachtpalette mit Sternen und Laterne als
szenisches „dunkles Tal“.

---

## Snake (`snake.html`)

**Konzept.** Der Klassiker als entspannendes Geschicklichkeitsspiel ohne
Themenrahmen, bewusst minimal gehalten. Empfohlenes Alter 6+.

**Kernlogik.** Diskrete Schritte auf einem 20×20-Gitter: eine
`setTimeout`-Schleife statt einer Animations-Loop, initial 140 ms pro Schritt.
Der Kopf wird in Bewegungsrichtung verschoben; Kollisionsprüfung per
Koordinatenvergleich mit dem Körper (Selbstkollision) und gegen den Rand
(klassische Wände, kein Wrap-Around) endet das Spiel sofort. Apfel-Treffer:
kein `pop()`, der Körper wächst; der neue Apfel wird per `do/while` nur auf
freie Zellen gesetzt. Das Tempo steigt linear: `T = max(60, 140 − 3 × Punkte)`
ms – die Untergrenze von 60 ms begrenzt die Schwierigkeit und hält sie
kindgerecht moderat.

**Eingaben und Kantenfälle.** Richtungsänderungen werden über einen
gepufferten Zielwert (`naechste`) verarbeitet, der erst zum nächsten Schritt
zur aktiven Richtung wird; direkt zurück in die Gegenrichtung ist verboten.
Das schließt das typische Fehlerfenster, bei dem zwei schnelle Eingaben
innerhalb eines Schritts eine 180°-Wende erzeugen. Steuerung über Wischen
(Schwellwert 20 px, die dominante Achse entscheidet), Pfeiltasten und WASD;
Tippen bzw. Leertaste startet.

**Persistenz.** Höchstpunktzahl in `localStorage` (`snake-rekord`),
fehler-tolerant verpackt, falls der Speicher gesperrt ist.

---

## Gemeinsame Gestaltungslogik

- **Einfache Finite-State-Machines** statt Frameworks; jedes Spiel ist eine
  eigenständige HTML-Datei mit eigenem Zustand.
- **Fehlversuche als Lernanlass:** Davids Weg bietet nach Fehlwürfen
  Hilfetexte statt sofortigem Ende, das Schaf-Spiel benennt Fehlklick-Tiere
  freundlich, Snake ist als einziges Spiel mit echtem Verlustzustand –
  altersgerecht abgestuft (4–6 / 6+ / 7–10).
- **Verse pro Meilenstein:** jede Erfahrungsstufe liefert einen Bibelvers,
  der inhaltlich zur Szene passt – die Theologie ist Teil der
  Belohnungsschleife, kein Overlay.
- **Touch-first:** große Trefferflächen, kein Double-Tap-Zoom
  (`touch-action: none`), Canvas/SVG skalieren responsiv zum
  Seitenverhältnis.
- **Komplett offline:** keine externen Assets – Grafik prozedural gezeichnet,
  Sound synthetisch, Texte im Quelltext, Fortschritt ausschließlich lokal.
