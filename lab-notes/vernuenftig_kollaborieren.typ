#import "../utils/lab-notes-prelude.typ": *
== Der erste Schlüsselmoment: CAR _oder_ Vernünftig kollab#strike[or]ieren
Den bisherigen Lab-Notes ist vor allem eins zu entnehmen: das Fühlerausstrecken in viele verschiedene Richtungen. Was gibt es in diesem Bereich für Forschung? Könnte sich dieses Feature lohnen, genauer betrachtet zu werden?

Der erste Schlüsselmoment unserer Arbeit ergab sich während unserer Grundlagenrecherche zu CRDTs und möglichen Funktionen eines Editors.

Denn bei all diesen Überlegungen schrieben wir bereits gemeinsam an Typst-Dokumenten. Und immer wieder kam Malte daher und machte das Dokument kaputt. Malte mag es nämlich, Funktionen zu schreiben. Und während er Funktionen wie
```typ
#let name = 
```
schrieb, konnten wir anderen unser schickes kompiliertes .pdf-Preview nicht mehr ansehen. Denn: Jedes Mal, wenn ein nicht kompilierender Zustand in Typst erreicht wird, kriegen alle die Fehlermeldungen und die Vorschau kann nicht mehr angezeigt werden.

Das ist gerade beim Bearbeiten von Grafiken nervig. Wir wollen diese möglichst präzise gestalten. Ein dauerhaftes Unterbrechen macht diese Arbeit noch zeitaufwendiger.

Das CRDT macht an dieser Stelle überhaupt nichts falsch. Maltes Änderung wird schnell an alle anderen übertragen und alle besitzen denselben aktuellen Zustand. Nur möchten wir das eventuell gar nicht.

Was wäre also, wenn eine Änderung erst einmal nur ein Draft wäre?
Eine Änderung könnte weiterhin sofort zwischen den Beteiligten synchronisiert werden, aber zunächst nur als Pending Change bzw. als Draft gelten. Der lokale Editor kann sie anzeigen -- so könnte man z.B. weiterhin gemeinsam debuggen --, für die lokale Vorschau wird aber weiterhin der letzte bekannte kompilierbare Zustand verwendet.

Erst wenn Typst mit der neuen Änderung wieder erfolgreich kompiliert, wird sie auch für diesen Zustand übernommen.
Wir nennen die Idee "Conflict-Avoidant-Rendering" (CAR) und haben unser Thema für den Rest des Semesters gefunden.

=== Notes to future selves

Namen vernünftig durchdenken.
Nicht den erstbesten nehmen, nur weil er cool klingt.