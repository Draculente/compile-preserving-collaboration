#import "../utils/lab-notes-prelude.typ": *

== Der erste Schlüsselmoment: CAR _oder_ Vernünftig kollab#strike[or]ieren

Den bisherigen Lab-Notes ist vor allem eins zu entnehmen: Das Fühlerausstrecken in viele verschiedene Richtungen. Was gibt es in diesem Bereich für Forschung? Könnte sich dieses Features lohnen, genauer betrachtet zu werden? 

Der erste Schlüsselmoment unserer Arbeit ergab sich während unserer Grundlagenrecherche zur CRDTs und möglichen Funktionen eines Editors.

/*
Schon lange träumen wir von einem Editor, der es uns tatsächlich erlaubt gut miteinander zusammen zu arbeiten. 
Viele unserer Arbeiten in der Uni erledigen wir daher bereits mit der Web-App von Typst.
Typst ist quasi das bessere LaTeX. Kollaborativ, compiled schnell, erlaubt es Funktionen zu basteln und hat einen Namen, bei dem Leute einen nicht komplett komisch angucken, wenn man ihn erwähnt.

Allerdings sind einige Funktionen in Typst hinter einer Paywall. Daher kam die Idee auf, dass wir einen eigenen Editor bauen könnten...

Der sollte schon die klassischen Editorfunktionen haben: Änderungsvorschläge, Kommentare, Undo, Redo, eine Art "Version Control" und die Möglichkeit, offline und online Versionen sinnvoll miteinander zu synchronisieren.

Und in dem Rahmen (und bereits im Rahmen von Sörens Bachelorarbeit), kamen wir auf CRTDs - Conflict-free Replicated Data Types.

Allerdings war das nur das grobe Themengebiet. Uns interessierte beispielsweise, wie man eigentlich überprüft, dass ein CRDT korrekt funktioniert. Welche Eigenschaften muss es erfüllen? Wie lassen sich diese formal testen? Was gibt es dafür für Werkzeuge?

Inspiriert waren wir auch davon, wie kollaboratives Arbeiten an Code statt reinem Text funktionieren könnte. Gerade bei Typst schien uns dies naheliegend. Unser Text besteht nicht nur aus einfachen Zeichen, sondern auch aus syntaktischen und semantischen Bedeutungen.

In diese Richtung haben Sören und Nicole sich weiter reingelesen und im Rahmen ihres wissenschaftlichen Seminars ein Survey-Paper geschrieben, um herauszufinden, wie sich Code gegenseitig beeinflussen kann und ob es bereits Lösungsansätze gibt, die die Zusammengehörigkeit jener möglichst schnell und korrekt erkennt.
*/

Denn bei all diesen Überlegungen schrieben wir bereits gemeinsam an Typst-Dokumenten. Und immer wieder kam Malte daher und machte das Dokument kaputt. Malte mag es nämlich Funktionen zu schreiben. Und während er Funktionen wie
```typ
#let name = 
```

schrieb, konnten wir anderen unser schickes kompiliertes .pdf-Preview nicht mehr ansehen. Denn: Jedes Mal, wenn ein nicht kompilierender Zustand in Typst erreicht wird, kriegen alle die Fehlermeldungen und die Vorschau kann nicht mehr angezeigt werden.

Das ist gerade beim Bearbeiten von Grafiken nervig. Wir wollen diese möglichst präzise gestalten. Ein dauerhaftes Unterbrechen macht diese Arbeit noch zeitaufwendiger. 

Das CRDT macht an dieser Stelle überhaupt nichts falsch. Maltes Änderung wird schnell an alle anderen übertragen und alle besitzen denselben aktuellen Zustand. Nur möchten wir das eventuell gar nicht.

Was wäre also, wenn eine Änderung erst einmal nur ein Draft wäre?

// alternativer Titel:
// Phantastische Namen und wo sie zu finden sind (nicht in meinem Kopf)

Eine Änderung könnte weiterin sofort zwischen den Beteiligten synchronisiert werden, aber zunächst nur als Pending Change bzw. als Draft gelten. Der lokale Editor kann sie anzeigen, für die gemeinsame Vorschau wird aber weiterhin der letzte bekannte kompilierbare Zustand verwendet.

Erst wenn Typst mit der neuen Änderung wieder erfolgreich kompiliert, wird sie auch für diesen Zustand übernommen.

Wir nennen die Idee "Conflict-Avoidant-Rendering" (CAR) und haben unser Thema für den Rest des Semesters gefunden.

=== Notes to future selves

Namen vernünftig durchdenken.
Nicht den erstbesten nehmen, nur weil er cool klingt. 

/*
=== Towards #cpc
Die Probleme, die wir beim Herumtollen auf unserer Spielwiese gefunden haben, waren die, die uns am Ende am meisten interessierten.

Aus dem einfachen Gedanken unsere Vorschau bitte immer ansehen zu können, entstand die Frage, wie wir aus einer Menge an Änderungen, diejenigen erkennen und auswählen können, die gemeinsam einen kompilierbaren Zustand ergeben.

Und genau aus dieser Frage ergab sich unsere neue Namensfindung für dieses Projekt:

Aus EAR wurde letztlich #cpc (CPC). Wir vermeiden Fehler ja nicht wirklich; wir können mit den Fehlern unser Ziel verfolgen, den Zustand möglichst kompiliert zu halten.
Zumindest sollten andere Kollaborierende möglichst nicht das lokale Kompilieren unseres Dokuments ohne unser Zutun verhindern können. 

=== Notes to future selves

Wenn wir eines aus dieser frühen Projektphase mitnehmen können, dann die Erkenntnis, wie wichtig es ist, das eigentliche Problem zu isolieren.
Wir sind mit einer riesigen Vision gestartet – einem komplett eigenen Editor, CRDT-Verifikation, inkrementellen Syntaxbäumen und tiefen Compiler-Eingriffen.
Das war alles spannend, hätte uns aber unweigerlich in endlose Rabbit-Holes geführt.

Die Fokussierung auf CAR, dann EAR hin zu CPC war wichtig und richtig.
Er hat uns gezeigt, dass unsere größte Herausforderung nicht das fehlerfreie Synchronisieren von Zeichen ist (das kann Automerge schon ohne uns), sondern das semantische Zusammenführen von Code-Segmenten.

Für unsere zukünftige Arbeit:
Bevor wir uns in interessanten Themen verrennen, müssen wir uns fragen, ob wir eine fokussierte Problemstellung haben und es auf einer praktischen Ebene auch lösen können.
Unser Fokus soll darauf liegen, wie wir aus einem Haufen von wilden, kollaborativen Änderungen den größtmöglichen, kompilierbaren Zustand extrahieren können -- ohne dabei die Intention oder den Flow der Nutzenden zu (zer)stören.
*/
