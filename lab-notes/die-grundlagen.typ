== Die #strike[langweiligen] Grundlagen

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

Zur Lösung solcher Probleme gibt es z. B. Conflict-free Replicated Data Types (CRTDs). Vereinfacht gesagt sorgen diese dafür, dass mehrere Kopien eines gemeinsamen Dokuments unabhängig voneinander berabeitet und wieder zusammengeführt werden können. 

_Hier Text zu CRDTs einfügen_

_Hier Text dazu einfügen, wie daraus die Idee für CAR entstanden ist_