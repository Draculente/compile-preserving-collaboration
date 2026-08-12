== Die #strike[langweiligen] Grundlagen <kap:grundlagen>

*Hier noch Quellenangaben???*

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
Im Prinzip sind CRDTs geteilte Datentypen, die auf unterschiedlichen Softwareinstanzen lokal vorliegen, jedoch immer irgendwann zum gleichen Zustand konvergieren. Konfliktfrei heißen sie, da sie Konflikte vesuchen schon in ihrem Design zu umgehen. Gleichzeitige Änderungen, die in anderen Systemen als Konflikt, den es zu lösen gilt, betrachtet werden, sind hier Teil des natürlichen Verhaltens.

Die wohl einfachste Art eines CRDTs ist ein nur hochzählender Zähler. Dieser liegt lokal auf allen Instanzen vor und wird dort jeweils hochgezählt. Soll der Zustand synchronisiert werden, schickt jede Instanz ihren lokalen Zustand an alle anderen Instanzen und erhält von ihnen wiederum ihren Zustand. Behalten wird auf jeder Instanz nur der höchste Zähler. 

Diese Art von CRDT nennt sich zustandsbasiert. Die zweite Kategorie von CRDTs, die in der kollaborativen Textbearbeitung deutlich relevanter ist, sind operationsbasierte CRDTs. 

Statt hier den gesamten Zustand eines Dokument zu teilen, wird der Zustand stattdessen aus der Historie aller Änderungen (wird nennen sie hier die Änderungsmenge $M$) hergeleitet. Der Kern des CRDT ist nun ein geschickter Algorithmus, der aus den Änderungen $M$ den Zustand des Systems ableitet. 

Gängig ist es dabei, dass bei CRDTs für Textkollaboration jeder Buchstabe eine eigene ID erhält, oft abgeleitet von der ID der Änderung, die ihn erzeugt hat. Über die ungeordnet in der Änderungsmenge vorliegenden Buchstaben wird dann eine totale Ordnung erzeugt. Das funktioniert meist, indem jeder Buchstabe eine Referenz zum vor ihm stehenden Buchstaben enthält. 

Statt den Text dann also nur als
```typ
H a l l o  W e l t !
```
zu betrachten, besitzt jeder Buchstabe eine ID:

*Abbildung nochmal anpassen, gerade sehen die IDs wie Indizes aus ^^*
```typ
H a l l o  W e l t !
0 1 2 3 4  5 6 7 8 9
```

Eine Einfügung ist dann nicht mehr einfach, füge "," an Position 5 ein, sondern füge das neue Element mit der ID 42 nach dem Element mit der ID 4 ein.

Dadurch wissen alle Instanzen, dass das Komma hinter genau diesem o eingefügt werden soll, unabhängig davon, welche anderen Änderungen noch passiert sind.

// hier noch weiteren Text einfügen? Gerne so als Übergang zu dem CAR-Punkt -> Das kann ich gerne machen :), LG Sören



_Hier Text zu CRDTs einfügen_

_Hier Text dazu einfügen, wie daraus die Idee für CAR entstanden ist_

// Nur Notiz, noch auslagern in extra Kapitel
== Funktionen eines Editors

Während wir uns in die Grundlagen der Textkollaboration einlasen (siehe @kap:grundlagen), notierten wir uns Ideen für Funktionen, die unser Wunsch-Texteditor enthalten sollte. Ideen, aus denen wir uns später ein Teilgebiet heraussuchen konnten

// Hier Rechercheergebnisse zu möglichen Funktionen ergänzen

== Verifikation von CRDTs

Nicht nur für die Funktionen eines Texteditors interessierten wir uns zu beginn. Nachdem wir uns für das Themengebiet der Textkollaboration entschieden hatten, eröffnete sich uns auch die Welt der formalen Verifikation. Denn wenn man ein CRDT entwickelt, dann sollte es auch funktionieren. 

// Hier Rechercheergebnisse zu Verifikation ergänzen