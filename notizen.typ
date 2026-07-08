= Notizen

== Ideen für coole Editor-Funktionen
- Statistiken
  - Z.B. wie viele Grafiken hast du? Wie viele Unterübschriften? Was ist deine tiefste Überschrift?
  - Auch zu Zitationen: Wen hast du am häufigsten zitiert?
- Zitations HeatMap
  - Ein kleiner Streifen am Rand, der anzeigt, wie viele Zitationen im jeweiligen Textabschnitt sind
- Ein "restlicher Platz"-Zähler
  - Du hast sind 7.2 von 8 beschrieben
  - Wenn man Seitenbegrenzungen hat und Dinge verschiebt muss man dann nicht immer runter scrollen

== Ideen für Optimierung
- Statt bei commits jeden Draft-Buchstaben einzeln zu committen, generieren wir uns für alle lokalen Änderungen bis zu einem Commit eine SessionID, die wir dann mit nur einer einzelnen Operation committen können. Nach dem Commit nutzen wir dann eine neue Session ID
  - Was ist, wenn eine Person draftet, eine andere das comitted, aber deren Operation länger bis zu Person A braucht? Die schreibt weiterhin Drafts mit der gleichen Id, die dann auch alle comitted werden, obwohl sie das vielleicht gar nicht sollten -> stattdessen eine Liste aller zu comittenden Buchstaben in einer Operation?
  - Ähnliches könnte bei Änderungsvorschlägen funktionieren, dort ist das oben beschriebene Verhalten vielleicht auch erwünscht


== Mögliche Metriken

- Robustheit (inkl. Qualität?)
  - Gibt es Edge-Cases in denen das nicht funktioniert? Wie kann man die allgemein testen?
    - Z.B. könnte eine Lösung davon abhängen, wie vollständig wir einen Syntaxbaum auch bei fehlerhafter Syntax aufbauen können
  - Gibt es False Positives, bei denen Dinge nicht gerendert werden, obwohl sie keinen Zusammenhang mit einer fehlerhaften Änderung eines Kollaborators haben
  - Ein Dataset von Tests generieren/erstellen mit dem weiter getestet werden kann
    - Kombination aus zufälligen generierten Eingaben und manuellem Katalog von Edge-Cases und Happy Paths
- zeitliche Performanz
  - 
- Erkennungsrate (Was erkennen?)t?
  - Idee: Ein *Testkatalog* und jede Methode kriegt halt ein Rating welche Kategorien von Zuständen sie erkennen kann

=== Testfall-Typen:
- eindeutig richtige Antwort?
- ambivalente Testfälle (mehrere Antworten möglich)
$=>$ 

=== Wie sieht ein Testfall aus?
- Instanzen: Alice, Bob
- Ausgangstext
- Compiler validiert Ergebnistext
- Changesets mehrerer Instanzen

*Ziel:* alle Instanzen haben einen Ergebnistext, der
- alles, was kompilieren kann, wird zusammen kompiliert

Dadurch dass wir davon ausgehen und wollen, dass die Zustände zweier Instanzen divergieren, müssen wir bei den Testfällen nur eine einzelne Instanz betrachten.

```typescript
func compile(text: string): success | failure

interface Input {
  current_text: string,
  incoming_changes: Change[] //union current_draft,
}

interface Output {
  new_text: string, 
  draft_changes: Change[]
}

func apply(input: Input): Output
```

Angenommen, dass incoming_changes.size > 0 && compile(Output.new_text) == success
- Worst-Case:
  - Input.incoming_changes == Output.draft_changes // keine Änderungen werden angewendet
- Best-Case:
  - Output.draft_changes.size == 0 // alle Änderungen werden angewendet
- Best-Effort-Case:
  - Output.draft_changes.size soll möglichst klein sein // möglichst viele Änderungen werden angewendet
  - Output.draft_changes.sum { change -> change.length } soll möglichst klein sein // möglicht viel von möglichst vielen Änderungen wird angewendet
    - Wieso diese Mühe? Im Average-Case werden Änderungen maximal ein paar Zeichen lang sein
  - Output ist möglichst nah an einer von Hand definierten Lösungen => __supervised learning__ ✅️

Problem bei Output.draft_changes.sum { change -> change.length }:
Der beste Algorithmus würde alle Änderungen in ihre kleinsten Bestandteile (z.B. Buchstaben) aufteilen und am Ende würde dann etwas raus kommen, das nicht besonders viel Sinn ergibt. 
```
Hallo #name 
```

```
Hallo name
```

```
#let hello = "abc"

Hallo #ll
```

```
#let ll = "abc"

Hallo #ll
```

Beispiel kollaborative Änderungen, sodass eine Person der anderen beim Kompilieren helfen kann:
Ziel: Es kompiliert bei beiden.
```typst
Lorem ipsum
```
Alice:
```typst
Lorem #ipsum
```
Alice $->$ Bob, weil //# 
nicht kompiliert, wird es nicht übernommen
Bob ist aber ein Lieber
Bob:
```typst
#let ipsum = [ipsum]
Lorem ipsum
```
Bob probiert nacht seiner Änderung die Änderung von Alice erneut aus.
Bob $->$ Alice, Alice' Text ist valide.

------

Beispiel kollaborative Änderungen, sodass eine Person der anderen beim Kompilieren helfen kann:
Ziel: Es kompiliert bei beiden:
```typst
#let alicesFunktion = () => {}

#let bobsFunktion = () => {}
```
Alice:
```typst
#let besteFunktion = () => {}
```
Bob:
```typst
#let tollsteFunktion = () => {}
```

------

Beispiel kollaborative Änderungen, sodass eine Person der anderen beim Kompilieren helfen kann:
Ziel: Es kompiliert bei beiden:
```typst
#let alicesFunktion = () => {}

#let bobsFunktion = () => {}
```
Alice:
```typst
#let besteFunktion = () => {}
```
Bob:
```typst
#let besteFunktion = () => {}
```
Lösungen bei Konflikten:
- Alice' Lösung bei beiden anwenden (Hierarchie über den Instanzen)
- Bobs Lösung bei beiden anwenden (Hierarchie über den Instanzen)
- keine Lösung bei beiden anwenden (Patt-Situation)
Was geht nicht? (weil es vllt. divergiert oder so)
- 


Wie betrachten wir Änderungen auf einer Instanz? (Implementierung)
- alle eingehenden Änderungen erhalten Draft-Status,
  wenn sie nicht mit dem eigenen Zustand kompilieren
  - bei jeder eingehenden, oder lokalen Änderung:
    - alle Drafts in jeder Kombination mit den anderen Drafts ausprobieren

== Implementierungsdetails / Algorithmusideen


```jan an alice - [] markieren je eine eingehende Änderung
[fun][ ][m][a][i][n][() {
  [pint("Hello")]
}]
// -> wir müssen mehr oder weniger alles miteinander ausprobieren
// => Laufzeit UNFASSBAR SCHEIßE
// ==> Optimierungen: Möglichst große Chunks (zusammengehörige, d.h. Änderungen aneinander -- vllt von einer Instanz?) testen
```

== Todos

- Simulationsframework definieren
  - Format definieren, wie Testfälle aufgeschrieben werden


