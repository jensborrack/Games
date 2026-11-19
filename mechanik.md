# Spielmechanik – Abstract

Dieses Dokument fasst die Spielmechaniken und zugrunde liegenden Logiken der
vier Spiele der Sammlung zusammen. Alle Spiele sind in reinem Vanilla-JavaScript
geschrieben (Canvas-2D bzw. SVG), laufen vollständig offline und sind primär für
Touchsteuerung auf Android-Tablets entworfen (Capacitor-Webview), mit
Tastatur-Eingaben als Desktop-Ersatz. Biblische Verse sind in jedem Spiel an
Spielmeilensteine gekoppelt und kein reiner Zierrat.

```
spiele-app/www/
├── index.html                    Auswahl-Menü (statische Karten)
├── davids-weg.html               Abenteuer in 4 Leveln (Canvas)
├── davids-aufstieg.html          Abenteuer in 5 Leveln (Canvas)
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

## Davids Aufstieg (`davids-aufstieg.html`)

**Konzept.** Ein fünftteiliges Vorabenteuer zu 1. Samuel 16–17 – gewissermaßen
der Prolog zu „Davids Weg“: David sammelt das Holz für die Zwille, baut sie,
trainiert das Zielschießen, verjagt die Wölfe von den Schafen und stellt sich
zum Schluss Goliat. Keine Quizfragen – jedes Level endet direkt mit einem zur
Szene passenden Bibelvers (1. Samuel 16,7; Sprüche 16,3; Philipper 4,13;
1. Samuel 17,37; 1. Samuel 17,45). Beim Start wählt man „Leicht“ (4–6 Jahre)
oder „Normal“ (7–12 Jahre); eine globale Schwierigkeitsfahne wirkt an genau
zwei Stellen als Multiplikator: Tempo ×0,7 und Trefferradius ×1,45 – also
größere Hitboxen statt Gnadenfristen.

**Architektur.** Canvas 960×540, `requestAnimationFrame`-Hauptschleife mit
delta-basiertem Update (dt auf 50 ms geklemmt), Finite-State-Machine
`menu → play → verse | lost → end`. Die fünf Levels sind als Objekt-Array
`L[0..4]` mit einheitlicher Schnittstelle `init/down/move/up/upd/drw`
organisiert; die Level 3–5 teilen sich die Schleuder-Mechanik samt
Eingabe-Handlern. Bedienelemente sind wie in allen Spielen pro Frame neu
registrierte Button-Rechtecke (`btns[]`), abgefragt über einen globalen
`pointerdown`-Handler. Kein Fortschrittsspeicher: „Nochmal“ startet das
aktuelle Level, vom Menü aus beginnt die Reihe wieder bei Level 1.

**Gemeinsame Schleuder (Level 3–5).** Ankerpunkt A(170, 380), David steht
dahinter: Der Spieler zieht mit maximal 130 px Auslenkung (Mindestauslenkung
25 px, 0,25 s Cooldown); beim Loslassen erhält der Stein
`v = Auslenkung × 8` und fliegt ballistisch mit Schwerkraft 900 px/s².
Während des Ziehens zeigt eine gepunktete Vorschau die Trajektorie – 9 Punkte
im Normal-Modus, 16 im Leicht-Modus: die längere Vorschau ist die eigentliche
Erleichterung für die Kleineren.

**Level 1 – Stöcke sammeln (Leit-Mechanik).** David läuft auf den zuletzt
getippten Zielpunkt zu (max. 230 px/s) und sammelt 6 Stöcke (Trefferradius
48 px × R); einer davon leuchtet als markierter Ast – rein szenisch, ohne
Sammelunterschied. Fortschritt als Emoji-Dot-Leiste oben rechts.

**Level 2 – Zwille bauen (Turbo-Tippen).** Drei Bauphasen am Werkbänkchen
(Holzgabel, Gummiband, Lederpolster), jede mit eigener Fortschrittsleiste:
Jeder Tipp bringt +0,09 Fortschritt (+0,14 im Leicht-Modus). Fertige Phasen
bauen den Zwille sichtbar an der Werkbank zusammen; am Ende leuchtet die
fertige Zwille. Fehler oder Verpassen kosten nichts.

**Level 3 – Zielschießen (Zielwurf-Training).** Drei Äpfel pendeln an
Stangen (`y = by + Auslenkung·sin(t·f + ph)`) mit steigender Amplitude
(30/58/86 px) und Frequenz (0,9/1,25/1,6, × sp). Der mittlere Apfel startet
golden und bringt 2 Punkte; nach jedem Treffer (0,9 s unsichtbar, dann
„Respawn“) entscheidet ein Zufallswurf (30 %), ob wieder ein Apfel golden
wird – der Bonus wandert also durch die Äpfel. 6 Treffer (Gold zählt
doppelt) beenden das Level; Trefferradius 37 px × R.

**Level 4 – Die Wölfe (Verteidigung).** Drei Wellen zu 3/5/7 Wölfen, die
von rechts einlaufen (y 430–480, Spawn-Intervall 1,3–2,4 s, im Leicht-Modus
×1,25 verlängert); das Tempo steigt pro Welle (85/105/125 px/s, × sp). Ein
Stein-Treffer (34 px × R um die Wolf-Mitte) verscheucht den Wolf mit
Partikeln; erreicht ein Wolf David (x ≤ 180), kostet das eines von drei
Herzen (Herz-Leiste erscheint ab diesem Level) mit kurzem rotem
Vollbild-Feedback. 2,2 s Verschnaufpause zwischen den Wellen; die dritte
Welle endet das Level.

**Level 5 – David und Goliat (Timing-Duell).** Goliat startet bei x = 860
und marschiert auf David zu, mit jedem verlorenen Schild-HP schneller
(16 px/s + 7 px/s pro verlorener HP, × sp); wird er zu nah (x < 320), ist
das Level verloren. Drei Stirn-Treffer (39 px × R um die leuchtende Stirn,
nur außerhalb der Betäubung) erzeugen je 1,5 s Stun mit Sternchen über ihm
und 70 px Rückstoß und brechen einen begonnenen Lanzenwurf ab. Goliat wirft
alle 4,2 s (Leicht: 6 s) eine Lanze, die auf einer Bogenkurve fliegt
(1,2 s Flugzeit, Leicht: 1,7 s); während des Flugs blinkt „DUCKEN!“, der
Duck-Button legt eine 0,9 s Duckphase fest – nur wer beim Einschlag geduckt
ist, verliert kein Herz. Steine, die nur Goliats Körper treffen (x-Band von
Goliat −125 bis +50 px, y 262–470), prallen ab (vx gespiegelt ×0,3, vy
−220). Nach dem dritten Stirn-Treffer dreht sich Goliat in einer 1,2 s
Fall-Animation um 1,5 rad; danach Vers und Schlussbildschirm „Goliat ist
gefallen!“ mit Konfetti-Partikeln. Der Schild-Balken oben rechts zeigt den
Rest-Zustand der drei Stirn-Treffer.

**Leben und Neustart.** Drei Herzen gelten in Level 4 und 5 (HUD ab
`lv > 2`) und werden pro Levelstart neu gesetzt. „Nochmal“ startet das
aktuelle Level neu – kein Punktabzug, keine Speicherung, das Scheitern ist
bewusst folgenlos.

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
  freundlich, Snake und Davids Aufstieg haben je einen echten Verlustzustand
  (dort mit folgenlosem „Nochmal“-Neustart) – altersgerecht abgestuft
  (4–6 / 6+ / 7–10 / 7–12).
- **Verse pro Meilenstein:** jede Erfahrungsstufe liefert einen Bibelvers,
  der inhaltlich zur Szene passt – die Theologie ist Teil der
  Belohnungsschleife, kein Overlay.
- **Touch-first:** große Trefferflächen, kein Double-Tap-Zoom
  (`touch-action: none`), Canvas/SVG skalieren responsiv zum
  Seitenverhältnis.
- **Komplett offline:** keine externen Assets – Grafik prozedural gezeichnet,
  Sound synthetisch, Texte im Quelltext, Fortschritt ausschließlich lokal.
