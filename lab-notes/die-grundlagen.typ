#import "../utils/lab-notes-prelude.typ": *

== Die #strike[langweiligen] Grundlagen <kap:grundlagen>

#todo[Hier noch Quellenangaben???]

Der Hauptbestandteil eines Texteditors ist Text. Wenn man einen kollaborativen Texteditor bauen möchte, muss man sich also zwangsläufig damit beschäftigen, wie Text sich bei der Zusammenarbeit mehrerer Menschen verhält.

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

Zur Lösung solcher Probleme gibt es z. B. _Conflict-free Replicated Data Types_ (CRTDs). Der Name deutet schon an, dass CRDTs ein relativ weit gefasstes Thema sind. 
Im Prinzip sind CRDTs geteilte Datentypen, die auf unterschiedlichen Softwareinstanzen lokal vorliegen, jedoch immer irgendwann zum gleichen Zustand konvergieren. Konfliktfrei heißen sie, da sie Konflikte versuchen schon in ihrem Design zu umgehen. Gleichzeitige Änderungen, die in anderen Systemen als Konflikt, den es zu lösen gilt, betrachtet werden, sind hier Teil des natürlichen Verhaltens.

Die wohl einfachste Art eines CRDTs ist ein nur hochzählender Zähler. Dieser liegt lokal auf allen Instanzen vor und wird dort jeweils hochgezählt. Soll der Zustand synchronisiert werden, schickt jede Instanz ihren lokalen Zustand an alle anderen Instanzen und erhält von ihnen wiederum ihren Zustand. Behalten wird auf jeder Instanz nur der höchste Zähler. 

Diese Art von CRDT nennt sich zustandsbasiert. Die zweite Kategorie von CRDTs, die in der kollaborativen Textbearbeitung deutlich relevanter ist, sind operationsbasierte CRDTs. 

Statt hier den gesamten Zustand eines Dokument zu teilen, wird der Zustand stattdessen aus der Historie aller Änderungen (wird nennen sie hier die Änderungsmenge $M$) hergeleitet. Der Kern des CRDT ist nun ein geschickter Algorithmus, der aus den Änderungen $M$ den Zustand des Systems ableitet. 

Gängig ist es dabei, dass bei CRDTs für Textkollaboration jeder Buchstabe eine eigene ID erhält, oft abgeleitet von der ID der Änderung, die ihn erzeugt hat. Über die ungeordnet in der Änderungsmenge vorliegenden Buchstaben wird dann eine totale Ordnung erzeugt. Das funktioniert meist, indem jeder Buchstabe eine Referenz zum vor ihm stehenden Buchstaben enthält. 

Statt den Text dann also nur als
```typ
H a l l o  W e l t !
```
zu betrachten, besitzt jeder Buchstabe eine ID:

#todo[*Abbildung nochmal anpassen, gerade sehen die IDs wie Indizes aus ^^* - hab mal einfach Text in die Abbildung geklatscht]

```typ
H a l l o  W e l t !
0 1 2 3 4  5 6 7 8 9 <- sind keine Indizes, sondern IDs
```

Eine Einfügung ist dann nicht mehr einfach, füge "," an Position 5 ein, sondern füge das neue Element mit der ID 42 nach dem Element mit der ID 4 ein.

Dadurch wissen alle Instanzen, dass das Komma hinter genau diesem o eingefügt werden soll, unabhängig davon, welche anderen Änderungen noch passiert sind.

#todo[
  - _Hier Text zu CRDTs einfügen_
    - oder ist das das hierdrüber? LG Jan
  - hier noch weiteren Text einfügen? Gerne so als Übergang zu dem CAR-Punkt -> Das kann ich gerne machen :), LG Sören
]

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

*Eine UI/UX-Herausforderung:*
Was sieht Nicole, wenn Maltes Code kaputt ist? Bleibt der Text unsichtbar? Farbig hinterlegt? Ausgegraut?

*Lokaler vs. Globaler Zustand:*
"Lokale Fehler will ich sehen, fremde Fehler will ich ignorieren."
Das bedeutet architektonisch, dass unser lokaler Texteditor zwei Wahrheiten verwalten muss:
Den kompletten CRDT-Zustand (den gesamten Text) und den Zustand für den Typst-Compiler (alles Lokale + nur valide Remote-Änderungen).
