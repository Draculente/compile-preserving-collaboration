#import "../utils/lab-notes-prelude.typ": *

== Konflikt-freier Text ist nicht gleich Fehler-freier Code // LG Jan

Text-CRDTs lösen ein komplexes Problem: Wie kann man an einem Text kollaborieren, sodass Änderungen asynchron miteinander geteilt werden können, und der Text am Ende überall der gleiche ist? Ohne hier tiefer auf die mathematischen Grundlagen einzugehen, muss ein CRDT Änderungen kommutativ, assoziativ und idempotent anwenden, damit die Text aller Kollaborierenden am Ende zum selben Ergebnis konvergieren.

Wenn wir nun aber Kollaborierende betrachten, die an Programmcode arbeiten, ergibt sich ein Problem: Eine Person könnte invaliden Code schreiben, und damit das Kompilieren des Codes für alle anderen Kollaborierenden auch auf deren Rechnern verhindern!
Wenn man zusammen iteriert und der Compiler nicht besonders schnell ist, stört das vielleicht nicht, aber sobald das Programmier-Setup Live-Änderungen oder Hot-Reloading unterstützt, kann eine Person effektiv alle anderen -- absichtlich oder nicht -- sabotieren.

Um das Problem zu veranschaulichen, sehen wir uns ein Beispiel an: \
Wir arbeiten an unserem wissenschaftlichen Projekt, dokumentieren unser Vorgehen in einem Typst-Dokument mit einem kollaborativen Editor wie _typst.app_.
Ähnlich wie bei _Overleaf.com_ hat man dort eine zweigeteilte Ansicht, bei der links der Typst-Code ist und rechts die PDF-Vorschau.
Nicole tippt fleißig an den Notizen, ohne dass sie dabei etwas schreibt, was den sehr schnellen Compiler Errors werfen lässt, sie tippt zwar Code im linken Editor, sieht sich aber dauerhaft die Live-Vorschau rechts an, um ein Gefühl für die Text-Länge und das Layout zu haben.
Jetzt macht Malte ihr aber einen Strich durch die Rechnung:
Er will eine komplexe Typst-Funktion schreiben, um eine Abbildung mit Typst-Code zu generieren; dabei ist sein Code ab und zu für ein paar Sekunden nicht kompilierbar.
Seine Änderungen landen trotzdem bei Nicole, und somit ist ihre Preview ab dem Zeitpunkt veraltet, an dem der Typst-Compiler versucht, Maltes ungültigen Code zu kompilieren.
Für ein paar Sekunden sieht Nicole dann in der Live-Vorschau ihre Änderungen nicht mehr, tippt weiter und wundert sich, wieso sie nicht sieht, was sie gerade tippt.

Dieses Verhalten, dass der von anderen Kollaborierenden synchronisierter Text zur Konvergenz des gemeinsamen Ergebnisses beiträgt, ist grundsätzlich erwünscht.
Es kollidiert aber mit der Erwartung, dass  Kollaborierende ungestört von den Fehlern anderer Kollaborierender an den eigenen Änderungen arbeiten können.

Hier kommt unsere Idee ins Spiel der Konfliktvermeidenden Kompilation ("Conflict-avoidant Rendering", der Name hat sich im Laufe des Semesters mehrfach geändert) ins Spiel:
Während das CRDT das Problem löst, einen Text über ein Rechnernetz zu synchroniseren, wollen wir das Problem lösen, dass möglichst viele valide Änderungen am Text in den Compiler gesteckt werden, während ungültige Änderungen -- solange sie ungültig sind -- ignoriert werden. \
Ungültige Änderungen anderer Kollaborierenden sollte man wahrscheinlich als solche kenntlich gemacht anzeigen.
Wenn man aber lokal ungültige Änderungen macht, möchte man sicher das Feedback vom Compiler haben; lokale Änderungen sollten also bei einer Anwendung von der fehlervermeidenden Kompilation ignoriert werden.

=== Notes to future selves

Was sieht Nicole, wenn Maltes Code kaputt ist? Bleibt der Text unsichtbar? Farbig hinterlegt? Ausgegraut?

"Lokale Fehler will ich sehen, fremde Fehler will ich ignorieren."
Das bedeutet architektonisch, dass unser lokaler Texteditor zwei Wahrheiten verwalten muss:
Den kompletten CRDT-Zustand (den gesamten Text) und den Zustand für den Typst-Compiler (alles Lokale + nur valide Remote-Änderungen).