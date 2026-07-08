https://arxiv.org/pdf/2602.19231
- oft als Three-Way-Merge
    - gemeinsamer Ausgangszustand
    - lokale Änderung
    - fremde Änderung
  - daraus wird dann ein neuer gemeinsamer Zustand erzeugt
- Problem bei vielen Reconciliation-Ansätzen
  - sie brauchen oft eine zentrale Stelle mit globalem Wissen
  - das passt nicht so gut zu Local-First-Systemen
  - weil Replikas auch offline / unabhängig weiterarbeiten sollen

- Ansatz aus dem Paper
  - Konflikte sollen nicht nur technisch, sondern semantisch erkannt werden
  - also nicht nur: "zwei Änderungen sind gleichzeitig passiert"
  - sondern: "eine Änderung basiert auf einer Annahme, die durch eine andere Änderung ungültig wurde"

- Dafür nutzt das Modell zwei Beziehungen
  - entails: eine Operation hängt logisch von vorherigen Operationen ab
    - also sowas wie: "diese Änderung setzt voraus, dass diese andere Änderung noch gilt"
  - discards: eine Operation macht die Wirkung einer anderen Operation ungültig
    - also z.B. ein neuer Wert überschreibt einen alten Wert

- Ein Konflikt entsteht dann
  - wenn eine Operation eine bestimmte Prämisse voraussetzt
  - und eine andere parallele Operation genau diese Prämisse verwirft
  - dadurch wird die Intention der ersten Änderung fraglich

- Merging funktioniert hier über Rebasing
  - Operationen werden nicht einfach in irgendeiner Reihenfolge angewendet
  - stattdessen werden sie auf eine neue Merge-Operation "umgehängt"
  - diese Merge-Operation beschreibt dann die gewünschte Auflösung des Konflikts
  - die Merge-Operation kann automatisch entstehen
  - oder interaktiv durch User
  
- Tombstone-Operation
  - Operationen können auch bewusst verworfen werden

https://dl.acm.org/doi/epdf/10.1145/3639478.3643118
- klassische Merge-Tools erkennen vor allem textuelle Konflikte
- also wenn zwei Änderungen dieselben oder direkt benachbarte Zeilen betreffen
- das reicht aber nicht aus, weil Code auch dann kaputt gehen kann, wenn der Merge textuell problemlos funktioniert

- Semantic Conflicts
  - entstehen, wenn der Merge keine textuellen Konflikte meldet
  - der Code danach auch erfolgreich baut
  - aber sich das Programm zur Laufzeit unerwartet verhält

- Definition im Paper:
  - zwei getrennte Änderungen L und R an einem Basisprogramm B interferieren
  - wenn der gemergte Code das geänderte Verhalten von L oder R nicht erhält
  - oder wenn unverändertes Verhalten aus B plötzlich nicht mehr erhalten bleibt
  - Developer A ändert einen Zustand / ein Feld
  - Developer B ändert Code, der diesen Zustand verwendet
  - beide Änderungen liegen textuell nicht direkt aufeinander
  - der automatische Merge klappt
  - aber B hat vllt. auf A aufgebaut

- Bisherige Ansätze lt. Paper
  - theorem proving
    - eher teuer / aufwendig
  - static analysis mit System Dependence Graphs
    - ebenfalls teuer
  - testing / dynamic analysis
    - günstiger, aber erkennt nicht genug Fälle
    - also eher niedriger Recall

- Idee dieses Papers daher
  - lightweight static analysis verwenden
  - Ziel: semantische Konflikte früher erkennen
  - ohne die sehr hohen Kosten von schwergewichtigen Analyseverfahren

- Vorgehen
  - analysiert wird die bereits gemergte Version des Codes
  - diese Version wird mit Metadaten annotiert
  - dadurch weiß die Analyse, welche Instruktionen von welchem Developer verändert oder hinzugefügt wurden

- Die Technik wurde für Java umgesetzt
  - benutzt wurde das Soot Framework
  - Soot dient dabei als Infrastruktur für die statische Programmanalyse

- Fazit des Papers
  - lightweight static analysis kann semantische Konflikte grundsätzlich erkennen helfen
  - aber eher als ergänzendes Werkzeug
  - besonders sinnvoll, um mögliche Interference früh sichtbar zu machen
