// Themen:
#let perf = highlight[Perf]
#let krypto = highlight[Krypto]
#let ux = highlight[UX]
#let sw-dev = highlight[SW-dev]
#let ti = highlight[TI]
#let co = highlight[co]

#let aktuellesThema = highlight(fill: green)[#h(1fr)$<== "Aktuelles Thema"$]

// Interesse von:
#let jan = highlight(fill: orange)[Jan]
#let malte = highlight(fill: orange)[Malte]
#let nicole = highlight(fill: orange)[Nicole]
#let sören = highlight(fill: orange)[Sören]

= Was könnten wir mal

== wissenschaftlich aufarbeiten?

- *Confict-avoidant Rendering* #sw-dev #ux #co #aktuellesThema
  - Idee: Peer-Changes, die evtl. Fehler enthalten werden vorerst als "Pending Changes" angezeigt und nicht "committed".
  - Problem: Wenn Nutzer A das Dokument kaputt macht und Nutzer B dessen Änderung korrigiert, wird das Dokument nie mehr kompiliert
    - man könnte den AST nutzen
    - man könnte angrenzende CRDT-Drafts mergen und von einem der beiden committen lassen
    - man könnte lokal immer mal wieder probieren, auch mit drafts zu kompilieren
    - neben einem Draft eines anderen Nutzers gibt es einen Button "Join Draft" oder so ähnlich, wodurch auch die eigenen Änderungen dem gleichen Draft zugeordnet werden und mit committed werden
  - Problem: getrennte Probleme/Lösungen: z.B. Variablen-Nutzung und später weiter oben ergänzte Deklaration sind im AST/CRDT nicht unbedingt verbunden
    - man könnte Änderungen von oben nach unten ausprobieren und nacheinander committen (quick & dirty fix)
    - man könnte die zusammengehörigen Änderungen als solche erkennen und als gemeinsame Änderung
  - Problem: Löschungen: Wenn NutzerA als Draft einen Buchstaben löscht, dann muss er bei ihm gelöscht sein, bei den anderen Nutzenden jedoch noch vorhanden
    - Wenn wir Automerge nutzen: Wir müssen das native Löschverhalten von Autmerge überschreiben
  - Problem: Cursor Offsets: Wenn NutzerA einen Draft schreibt, wird der ja nicht an den Compiler von Typst durchgereicht. D.h. Fehlermeldungen sind im Vergleich zum Index im Editor verschoben
- CRDT-Verification für Programmiersprache XY #ti, #sw-dev #malte #sören #jan
  - statt Unit-Tests Model-Checking auf der echten Implementierung
  - Lücke zwischen Checker-Modell und Implementierung schließen
- Typst als Markup-Sprache für einen WYSIWYG-Editor #ux, #sw-dev
  - Wie baut man einen WYSIWYG-Editor für eine Markup-Sprache?
  - Welche UX-Vorteile und Trade-Offs ergeben sich aus einem Markup-WYSIWYG-Hybrid-Editor?
  - Das gibt es schon für Markdown
- Bidirektionale Annotationen #ux, #sw-dev
  - von PDF-Annotation zu Code-Annotation
  - von Code-Annotation zu PDF-Annotation
  - Lässt sich das implementieren?
  - Wie finden UX-Kaninchen die UX?

== als Erklär-Paper/Notizen ordentlich aufschreiben?

- Wie funktionieren Red-Green Trees? #sw-dev, #ti
  - Wozu benötigt man die?
  - Was sind verwandte Konzepte?
  - Wie funktionieren die?
- Wie verifiziert man ein CRDT? #ti, #sw-dev
  - Wie definiert man Kommutativität, Assoziativität, Idempotenz in Verizierungstool XY?
  - Wie modelliert man ein CRDT in Verizierungstool XY?
- Permission-Systeme für P2P-Architekturen #krypto
  - ein Kryptografie-Thema für Sebastian!
  - "Was, wenn es keine zentrale Rechteverwaltung gibt und ich einem Schuft den Schreibzugriff entziehe?"
    - kann man Tokens nur an Berechtigte verteilen und das kryptografisch verifizieren?
    - Post-Quantum? ;P
- Wie funktioniert Strg+Z?
  - Dazu muss man mal das Kleppman Paper lesen, vielleicht gibt's auch noch offene Fragen zu klären, dann wär's ja eher Forschung
- Wie funktioniert unser CRDT?
  - Welches Modell haben wir uns angeschaut? (WOOT)
  - Wie machen wir Performance Optimierung für unser CRDT?
- Was macht ein CRDT?
  - Kommutativität, Assoziativität & Idempotenz
  - 

#pagebreak(weak: true)
    
== sein lassen weil es das schon gibt?

- _Yjs_ vs _Automerge_: Performance-Vergleich #perf, #sw-dev
  - Wie benchmarken? (Method)
  - Was ist das Ergebnis? (Results)
  - Was kann man aus den Ergebnissen ableiten? (Discussion)
  - Was kann man nicht ableiten und was wurde bei der Methodik ignoriert? (Limitations)
  - Gibt's schon: https://josephg.com/blog/crdts-go-brrr/

