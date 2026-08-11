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

= Algo-Ideen

- Bogo-Algo (einfach zufällig probieren)
- Alle Kombinationen ausprobieren und 
  - Heuristiken nach User
  - das größte Subset nehmen
  - erste kompilierende Lösung nehmen (Greedy)
- LLM
- eigenes Machine-Learning-Modell
  - Neuronales Netz
- Language Server fragen
  - Nach Lösungvorschlag
  - Nach Fehler-Location
- jeden Informatik Prof nach Lieblingsalgo fragen, weil man BESTIMMT einen Lieblingsalgo hat!
  - A\*


https://en.wikipedia.org/wiki/List_of_algorithms

== Herrlicher Prompt

Wir arbeiten an einem wissenschaftlichen Projekt, in dem es darum geht, zusammengehörige Änderungen bei kollaborativem Arbeiten zu erkennen. Dazu wollen wir zunächst Testfälle definieren. Da das nicht so einfach ist, möchten wir dafür einen Testeditor programmiert haben.

Dieser soll es ermöglichen, mehrere Testfälle auf einmal zu definieren und als JSON Datei zu exportieren. Diese soll auch auf einem anderen Computer wieder importiert werden können, um genau den gleichen Zustand des Editors wieder herzustellen.

Die Testfälle sollen als Karten untereinander angezeigt werden. Jede Karte enthält links ein Textfeld mit mehreren Tabs. Die Tabs MÜSSEN nacheinander durchgegangen werden. 
In den ersten Tab soll der Ausgangstext eingegeben wird, der praktisch schon "committed" ist. 
In den zweiten Tab alle Änderungen, die Alice an diesem Ausgangstext macht. 
In den dritten Tab werden alle Änderungen eingegeben, die Bob am Ausgangstext macht. 
Dabei sind bei Bob auch schon alle Änderugnen von Alice angewendet! 
Die zweiten und dritten Tab sehen also im Grunde nicht anders aus als der erste Tab. Es ist der Ausgangstext bzw. der Ausgangstext + Alices Änderungen zu sehen und man kann den ganzen Text einfach bearbeiten. 
Indem man dieses bearbeiteten Text mit dem Text davor vergleicht (Ausgangstext bzw. Alices Text), kann man die Änderungen berechnen, die von der jeweiligen Person "gemacht wurden".

Als Beispiel:
1. "committed" schreibt: "" -> "Hallo von Welt"
2. "Alice" schreibt: "Hallo von Welt" -> "Hallo von " -> "Hallo von Alice"
3. "Bob" schreibt: "Hallo von Alice" -> "Hallo von " -> "Hallo von Bob"

Aus diesen Änderungen soll dann eine Liste von Changes abgeleitet werden. Diese sind aus dem Diff-Set zwischen 1. dem Ausgangstext und Alice und 2. dem Text von Bob und dem von Alice generiert werden. Bei der Generierung von Ankerpunkten (Indices) wird davon ausgegangen, dass vorher stehende Änderungen: 
- case deletions: nicht angewendet wurden
- case insertions: angewendet wurden

Die Änderungen beim Beispiel oben würden wie folgt aussehen:

{
  user: "committed",
  type: "insert",
  from: "0",
  "Hallo von Welt"
}

{
  user: "alice",
  type: "deletion",
  from: 10,
  forwards: 4
}

{
  user: "alice",
  type: "insert",
  from: 10,
  text: "Alice"
}

{
  user: "bob",
  type: "deletion",
  from: 10,
  forwards: 5
}

{
  user: "bob",
  type: "insert",
  from: 10,
  text: "Bob"
}

Die Liste von Änderungen soll in der Testcase-karte neben dem textfeld angezeigt werden. Auf der rechten seite befindet sich dann der output. Dort ist dargestellt: Der Ausgangstext mit allen änderungen von alice und bob. Diese Änderungen sind nicht tatsächlich durchgeführt, sondern sind nur markiert. Dieser Text ist nicht bearbeitbar und ändert sich auch nicht nur die nun folgenden änderungsmöglichkeiten:
Rechts neben dem nicht änderbaren text befindet sich ein textfeld in dem der gleiche text nochmal angezeigt wird mit den markierten änderungen. Hier kann der text markiert werden und ändert sich: Der Nutzer markiert hier Changes (von alice und bob, der ausgangstext sind alle änderungen des nutzers "committed" und ist nicht committbar) oder teile von changes mit dem cursor und kann diese durch einen knopfdruck committen (= nutzer auf committed setzen), womit sie angewendet werden und im finalen text stehen oder dort gelöscht sind. 

Der finale text wird unter diesen felder in der karte angezeigt. 

Bitte generiere dafür TypeScript- und Vue-Code mit Tailwind CSS. Nutze Vue 3 mit Composition API und `<script setup lang="ts">`. 

So soll das JSON aussehen:

```ts
type Index = number;

interface TestSuite {
  version: 2,
  testcases: TestCaseV2[]
}

interface TestCaseV2 {
  id: string,
  name?: string,
  input: Input,
  output: Output
}

interface Input {
  // The original Text is saved as the first change with author "committed"
  incoming_changes: Change[];
}

interface Output {
  new_text: string,
}

type Change = Deletion | Insertion

interface Deletion {
  user: "committed" | "alice" | "bob",
  type: "deletion",
  from: Index,
  // Deletes from index from forwards number characters
  forwards: number
}

interface Insertion {
  user: "committed" | "alice" | "bob",
  type: "insert",
  from: Index,
  text: string,
}
```


=== Spielwiese

//I have another idea, tell me if it is similar to one already implemented: could there be an algorithm that tries all changes first, but then removes the last index in the changes if it does not compile? I am sure it is not ideal, but is should not be very complex to implement. Of course both insertion and deletions need to be handled by this strategy. but other than that, it should be a simple algorithm that might fix many errors in O(n)

Wow, interesting results! Since you had some issues with our test suite, it would be interesting to see which algorithm solves or fails on which test case. create a matrix highlighting the results in different colors. also create a diagram which adds the times all algorithms took to compute their solution, so that i can see if there are any especially hard test cases. use \@preview/cetz-plot
  