#import "../utils/lab-notes-prelude.typ": *

== Vernünftig kollab#strike[or]ieren

Schon lange träumen wir von einem Editor, der es uns tatsächlich erlaubt gut miteinander zusammen zu arbeiten. 
Viele unserer Arbeiten in der Uni erledigen wir daher bereits mit der Web-App von Typst.
Typst ist quasi das bessere LaTeX. Kollaborativ, compiled schnell, erlaubt es Funktionen zu basteln und hat einen Namen, bei dem Leute einen nicht komplett komisch angucken, wenn man ihn erwähnt.

Allerdings sind einige Funktionen in Typst hinter einer Paywall. Daher kam die Idee auf, dass wir einen eigenen Editor bauen könnten...

Der sollte schon die klassischen Editorfunktionen haben: Änderungsvorschläge, Kommentare, Undo, Redo, eine Art "Version Control" und die Möglichkeit, offline und online Versionen sinnvoll miteinander zu synchronisieren.

Und in dem Rahmen (und bereits im Rahmen von Sörens Bachelorarbeit), kamen wir auf CRTDs - Conflict-free Replicated Data Types.

Allerdings war das nur das grobe Themengebiet. Uns interessierte beispielsweise, wie man eigentlich überprüft, dass ein CRDT korrekt funktioniert. Welche Eigenschaften muss es erfüllen? Wie lassen sich diese formal testen? Was gibt es dafür für Werkzeuge?

Inspiriert waren wir auch davon, wie kollaboratives Arbeiten an Code statt reinem Text funktionieren könnte. Gerade bei Typst schien uns dies naheliegend. Unser Text besteht nicht nur aus einfachen Zeichen, sondern auch aus syntaktischen und semantischen Bedeutungen.

In diese Richtung haben Sören und Nicole sich weiter reingelesen und im Rahmen ihres wissenschaftlichen Seminars ein Survey-Paper geschrieben, um herauszufinden, wie sich Code gegenseitig beeinflussen kann und ob es bereits Lösungsansätze gibt, die die Zusammengehörigkeit jener möglichst schnell und korrekt erkennt. 

Bei all diesen Überlegungen schrieben wir bereits gemeinsam an Typst-Dokumenten. Und immer wieder kam Malte daher und machte das Dokument kaputt. Malte mag es nämlich Funktionen zu schreiben. Und während er Funktionen wie
```typ
#let name = 
```

schrieb, konnten wir anderen unser schickes kompiliertes .pdf-Preview nicht mehr ansehen. Denn: Jedes Mal, wenn ein nicht kompilierender Zustand in Typst erreicht wird, kriegen alle die Fehlermeldungen und die Vorschau kann nicht mehr angezeigt werden.

Das ist gerade beim Bearbeiten von Grafiken nervig. Wir wollen diese möglichst präzise gestalten. Ein dauerhaftes Unterbrechen macht diese Arbeit noch zeitaufwendiger. 

Das CRDT macht an dieser Stelle überhaupt nichts falsch. Maltes Änderung wird schnell an alle anderen übertragen und alle besitzen denselben aktuellen Zustand. Nur möchten wir das eventuell gar nicht.

=== Was wäre, wenn eine Änderung erst einmal nur ein Draft wäre?

alternativer Titel:
Phantastische Namen und wo sie zu finden sind (nicht in meinem Kopf)

Eine Änderung könnte weiterin sofort zwischen den Beteiligten synchronisiert werden, aber zunächst nur als Pending Change bzw. als Draft gelten. Der lokale Editor kann sie anzeigen, für die gemeinsame Vorschau wird aber weiterhin der letzte bekannte kompilierbare Zustand verwendet.

Erst wenn Typst mit der neuen Änderung wieder erfolgreich kompiliert, wird sie auch für diesen Zustand übernommen.

Unser erster Name war dafür "Conflict-Avoidant-Rendering" (CAR). Die Idee war, dass wir Konflikte vermeiden können und sich die Preview weiterhin rendern ließe.

Bei der Recherche zum Kompilieren stießen wir beispielsweise auf Red-Green Trees und inkrementelles Parsing. Daraus entstand schnell die Überlegung, ob wir tief in die Struktur von Compilern einsteigen müssen, um herauszufinden, welche Teile eines Dokuments noch gültig sind.

Dabei entstand jedoch eine viel wichtigere Frage:

Brauchen wir das überhaupt?

Vielleicht reicht es ja, den Compiler selber ausprobieren zu lassen.

Änderung anwenden. Kompilieren. Wenn es funktioniert, übernehemn. Wenn nicht: Draft.

Ist deutlich weniger spektakulär als ein eigener inkrementeller Syntaxbaum-Algorithmus, aber auch deutlich besser für unsere mentale Gesundheit.

Wir kehrten daher noch einmal zu den Basics zurück und bauten eine kleine Spielwiese mit Automerge. // hier kann man auf den Beispieleditor verweisen

=== Wie aus einem Auto ein Ohr wird

Beim Arbeiten am Prototypen fiel auf, dass unser ursprünglicher Name nicht so richtig passte. 

Wir versuchen ja nicht Konflikte - wie sie im Bereich der CRDTs zu verstehen sind - zu vermeiden.

Daher wurde aus CAR dann Error-Avoidant-Rendering (EAR).

Und unsere einfache Draft-Idee stoß an ihre Grenzen. 
// hier gerne Beispiele einführen, mir fällt da gerade nichts richtig Gutes ein. also gerne so etwas wie, wenn zwei Personen zusammen arbeiten und vllt. Zwischenstände nicht mehr kompilieren, obwohl sie für sich genommen kompilieren können; finde da gerade so gar keinen schönen Weg das wegzuformulieren

=== Towards #cpc
Die Probleme, die wir beim Herumtollen auf unserer Spielwiese gefunden haben, waren die, die uns am Ende am meisten interessierten.

Aus dem einfachen Gedanken unsere Vorschau bitte immer ansehen zu können, entstand die Frage, wie wir aus einer Menge an Änderungen, diejenigen erkennen und auswählen können, die gemeinsam einen kompilierbaren Zustand ergeben.

Und genau aus dieser Frage ergab sich unsere neue Namensfindung für dieses Projekt:

Aus EAR wurde letztlich #cpc (CPC). Wir vermeiden Fehler ja nicht wirklich; wir können mit den Fehlern unser Ziel verfolgen, den Zustand möglichst kompiliert zu halten.

=== Notes to future selves
