#import "../utils/lab-notes-prelude.typ": *
#import "@preview/cetz:0.4.1"
#import "../utils/item-row.typ": item-row

== Die #strike[langweiligen] Grundlagen <kap:grundlagen>

Der Hauptbestandteil eines Texteditors ist Text. Wenn man einen kollaborativen Texteditor bauen möchte, muss man sich also zwangsläufig damit beschäftigen, wie Text sich bei der Zusammenarbeit mehrerer Menschen verhält.

Sören hat das in seiner Bachelorarbeit schon einmal zusammengefasst @fischer_live-kommentare_2025. Da das Verständnis davon für das Projekt allerdings relevant ist (und die anderen Gruppenmitglieder sich dort ebenfalls einarbeiten mussten), soll es hier auf dieser Basis nochmal kurz ausgeführt werden.

Wenn mehrere Personen an einem Dokument arbeiten, klingt das erstmal nach einem einfachen Problem. Alle Änderungen werden gesammelt, verteilt und bei allen Beteiligten angewendet.

Angenommen in dem Dokument steht:
```typ
Hallo Welt!
```

und Jan fügt nach Hallo ein Komma ein:
```typ
Hallo, Welt!
```

Währenddessen ersetzt Sören Welt durch CRDT:
```typ
Hallo CRDT!
```

Jetzt haben wir zwei Änderungen, die auf demselben ursprünglichen Dokument basieren. Beide Clients müssen diese Änderungen miteinander kombinieren.

Zur Lösung solcher Probleme gibt es z. B. _Conflict-free Replicated Data Types_ (CRDTs). Der Name deutet schon an, dass CRDTs ein relativ weit gefasstes Thema sind.
Im Prinzip sind CRDTs geteilte Datentypen, die auf unterschiedlichen Softwareinstanzen lokal vorliegen, jedoch immer irgendwann zum gleichen Zustand konvergieren. Konfliktfrei heißen sie, da sie versuchen, Konflikte schon in ihrem Design zu umgehen. Gleichzeitige Änderungen, die in anderen Systemen als Konflikt betrachtet werden, den es zu lösen gilt, sind hier Teil des natürlichen Verhaltens.

Die wohl einfachste Art eines CRDTs ist ein nur hochzählender Zähler. Dieser liegt lokal auf allen Instanzen vor und wird dort jeweils hochgezählt. Soll der Zustand synchronisiert werden, schickt jede Instanz ihren lokalen Zustand an alle anderen Instanzen und erhält von ihnen wiederum deren Zustand. Behalten wird auf jeder Instanz nur der höchste Zähler.

Diese Art von CRDT nennt sich zustandsbasiert. Die zweite Kategorie von CRDTs, die in der kollaborativen Textbearbeitung deutlich relevanter ist, sind operationsbasierte CRDTs.

Statt hier den gesamten Zustand eines Dokuments zu teilen, wird der Zustand stattdessen aus der Historie aller Änderungen (wir nennen sie hier die Änderungsmenge $M_"ges"$) hergeleitet. Der Kern des CRDTs ist nun ein geschickter Algorithmus, der aus den Änderungen $M_"ges"$ den Zustand des Systems ableitet.

Gängig ist es dabei, dass bei CRDTs für Textkollaboration jeder Buchstabe eine eigene ID erhält, oft abgeleitet von der ID der Änderung, die ihn erzeugt hat. Über die ungeordnet in der Änderungsmenge vorliegenden Buchstaben wird dann eine totale Ordnung erzeugt. Das funktioniert meist, indem jeder Buchstabe eine Referenz zum vor ihm stehenden Buchstaben enthält.

Statt den Text dann also nur als eine Zeichenkette zu betrachten, besitzt jeder Buchstabe eine ID (die Abbildung ist der aus Sörens Bachelorarbeit nachempfunden):

#let items_with_deleted = (
  (content: "H", id: "9@B", deleted: false),
  (content: "a", id: "2@A"),
  (content: "l", id: "3@A"),
  (content: "l", id: "4@A"),
  (content: "o", id: "5@B"),
  (content: "␣", id: "6@B"),
  (content: "W", id: "7@B"),
  (content: "e", id: "10@B"),
  (content: "l", id: "11@B"),
  (content: "t", id: "12@B"),
  (content: "!", id: "13@B"),
)

#cetz.canvas({
  import cetz.draw: *

  item-row((0, 0), items_with_deleted, deleted-row: false, initial-marker-padding: 1.5)
})

Eine Einfügung ist dann nicht mehr einfach "füge '`W`' an Position 6 ein", sondern "füge das neue Element mit der ID `7@B` nach dem Element mit der ID `6@B` ein".

Dadurch wissen alle Instanzen, dass das `W` hinter genau diesem Leerzeichen eingefügt werden soll, unabhängig davon, welche anderen Änderungen noch passiert sind.

Das ist das Grundprinzip der allermeisten Text-CRDTs. Sie unterscheiden sich dann in Details wie der ID-Generierung, der Frage, an welche Zeichen die Buchstaben geheftet werden (nur an das davorstehende Zeichen, an das dahinterstehende Zeichen oder an beide), oder den genutzten Datentypen.

Eine interessante Implikation dieser Technik sei hier noch erwähnt: Da jedes Zeichen ein -- potentieller -- Ankerpunkt für eine vorhandene oder noch zukünftig eintreffende Änderung ist, ist es nicht möglich, Zeichen wieder zu entfernen. Stattdessen werden Zeichen als gelöscht markiert. Das erhöht den Speicherbedarf über die Zeit, allerdings erlaubt es auch uneingeschränkte Zeitreisen, indem die gesamte Änderungshistorie -- oder eben nur Teile davon -- neu eingespielt werden kann.

=== Notes to future selves

Text-CRDTs sind in der Theorie toll, weil sie, anders als andere Technologien (looking at you, Operational Transformation), Indizes wegabstrahieren. In der Praxis bleibt allerdings leider oft wenig von dieser schönen Abstraktion übrig, und man muss sich spätestens dann mit Indizes herumschlagen, wenn man ein CRDT an einen Texteditor anbinden möchte.