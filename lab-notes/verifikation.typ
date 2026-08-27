#import "../utils/lab-notes-prelude.typ": *

== Verifikation von CRDTs

#todo[Mehr wie ein Blogeintrag! - Ich finde das klingt schon bloggig genug eig. - GaLiGrü Nicole]\

Nicht nur für die Funktionen eines Texteditors interessierten wir uns zu Beginn.
Nachdem wir uns für das Themengebiet der Textkollaboration entschieden hatten, eröffnete sich uns auch die Welt der formalen Verifikation.
Denn wenn man z.B. ein eigenes CRDT mit einer unserer Wunschfunktionen entwickeln würde, dann sollte es auch funktionieren.

"Funktionieren" ist in verteilten Systemen allerdings ein gefährlich dehnbarer Begriff.
Sobald mehrere Nutzer gleichzeitig tippen, löschen und formatieren, können die Updates in einer schier unendlichen Anzahl von Reihenfolgen (Interleavings) bei den anderen Clients eintreffen.
Je komplexer die Datenstruktur, desto schneller wächst dieser Zustandsraum exponentiell an @zhang_model-checking-driven_2024.

Das Tückische daran: Ein CRDT kann alle Testläufe bestehen und zur Laufzeit in Produktion die Daten zerschießen (divergieren).
Die Forschung nennt diese fiesen, schwer zu reproduzierenden Fehler treffend Deep Bugs @zhang_model-checking-driven_2024.
Gegen diese exponentielle Anzahl an möglichen Operationen sind normale Unit-Tests nicht geeignet.

Um das Problem effektiv zu bändigen, kann man Mathematik$trademark$ einsetzen.
Die Kernfähigkeit eines CRDTs -- das Zusammenführen (Mergen) zweier abweichender Zustände -- darf kein Zufallsprodukt sein, sondern muss strengen algebraischen Regeln folgen.
Ein Verifikations-Tool muss idealerweise beweisen, dass die Merge-Operation folgende Eigenschaften besitzt:

- *Kommutativität:* Die Reihenfolge der eintreffenden Knoten ist egal ($A "merge" B = B "merge" A$).
- *Assoziativität:* Gruppierungen spielen keine Rolle ($(A "merge" B) "merge" C = A "merge" (B "merge" C)$).
- *Idempotenz:* Ein doppeltes Merge desselben Zustands verändert nichts mehr ($A "merge" A = A$).

Bei der Konfliktauflösung (z.B. einer `#max`-Funktion, bei der "der Höchste gewinnt") kommen zusätzlich relationale Eigenschaften wie Reflexivität, Symmetrie und Antisymmetrie hinzu @zakhour_type-checking_2023.

=== Forschung zur Verifikation von CRDTs

#todo[Das muss weniger KI generiert klingen \
upsi, hab versucht die KI-Tells zu entfernen - LG Jan \
Was haltet ihr davon, die Details hier unten einfach rauszulassen? - LG Sören]

Bei unserer Literaturrecherche sind wir auf drei ungleiche, aber spannende Ansätze gestoßen:

*Crust: Der pragmatische Werkzeugkasten* \
Crust ist weniger ein reiner Beweisführer und mehr ein ganzheitliches "Framework".
Es soll die "Developer Experience" verbessern und deckt alles ab: von Datenstrukturen über Netzwerkkommunikation bis hin zum Benchmarking @zhu_crust_2025.
Um Korrektheit zu prüfen, nutzt es einen Set-basierten Ansatz und unterscheidet strikt, ob das CRDT ganze Zustände, Operationen oder nur Deltas synchronisiert.
Leider konnten wir den Programm-Code zu diesem Paper nirgendwo finden...

*MET: Das Orakel aus TLA+* \
Wenn bloßes Testen nicht reicht, kommt Model-Checking ins Spiel.
@zhang_model-checking-driven_2024 schlagen ein Framework vor, das exploratives Testen mit formaler Spezifikation kreuzt.
Zuerst wird das System in der Spezifikationssprache TLA+ modelliert (weil Leslie Lamport in wirklich keinem Informatik-Paper fehlen darf!).
Der Model-Checker generiert daraus Ausführungs-Traces.
Diese Traces dienen dem eigentlichen Code dann als Test-Orakel:
Weicht die Implementierung bei gleichen Events vom erwarteten Verhalten ab, hat man einen Bug gefunden.

*Propel: Beweise per Compiler* \
Warum Fehler zur Laufzeit suchen, wenn der Compiler sie schon abfangen kann?
Propel (eingebettet in Scala) nutzt Type-Checking, um die algebraischen Eigenschaften schon zur Kompilierzeit zu beweisen @zakhour_type-checking_2023.
Das System führt im Hintergrund "Rewrites" und tiefgreifende Fallanalysen für alle Code-Branches durch.
Frei nach dem Motto: Kompiliert es, dann stimmt auch die Mathematik.

=== Notes to future selves

/*
Trotz dieser Tools scheint das Problem der CRDT-Verifikation noch nicht endgültig gelöst.
Propel scheitert wohl aktuell beispielsweise noch daran, Beweise durch Gegenbeispiele zu erbringen – ein Feature, das noch viel mehr Edge-Cases abdecken könnte.

Auch bei komplexen Datenstrukturen wie dem Replicated Growable Array (RGA), dem Kern aktueller Implementierungen wie Automerge#footnote[#link("https://automerge.org/docs/reference/documents/")], stoßen die Methoden an ihre Grenzen.
Ihnen fehlt anscheinend die Fähigkeit, die Lemmas für komplexe Listenoperationen selbstständig zu generieren.
*/

Es gibt ziemlich viel Theorie zu dem Thema, aber noch nicht so viele praktische Werkzeuge. Cool wäre es ja, eine echte CRDT-Implementierung in einer Programmiersprache wie Rust zur Compile-Time verifizieren zu können.