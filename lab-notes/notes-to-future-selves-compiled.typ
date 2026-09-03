== Und was jetzt?

Wer die Notes to future selves der letzten Abschnitte aufmerksam gelesen hat, merkt es vielleicht schon -- so ganz zufrieden sind wir nicht damit, wie wir die Testcases erstellt haben.

Die Testsuite an sich hat sich als ganz gelungen herausgestellt:
Wir konnten damit alle Arten von Algorithmen implementieren, die uns eingefallen sind.
Schwer gefallen ist uns dagegen deren Bewertung.

Beim Implementieren der Algorithmen ist uns nämlich aufgefallen, dass es für eine "korrekte" Lösung meist mehrere unterschiedliche Strategien gibt. Nehmen wir noch mal den Fehler aus @mehrdeutige_absichtsbewahrung:

```typst
#let durchschnitt = (values) => {
  values.sum() / values.len
}
#durchschnitt((5, 10))
```

Eine Möglichkeit ist, mit möglichst wenigen Drafts einen validen Zustand herzustellen:

```typ 
#let durchschnitt = (values) => {
  values.sum()
}
#durchschnitt((5, 10))
```

Genauso gut könnte aber auch der erst nach der Funktion verfasste Funktionsaufruf als Draft behandelt werden, weil der Typfehler in Typst ja erst durch das Übergeben eines Arrays entsteht:

```typst
#let durchschnitt = (values) => {
  values.sum() / values.len
}
```

Oder man behandelt gleich die ganze Funktion als Draft, weil sie so nun mal keine valide Durchschnittsberechnung ist.

Unsere Algorithmen optimieren auf gänzlich unterschiedliche Strategien. 
Der Brute-Force-Ansatz passt anscheinend am besten zu unseren impliziten Erwartungen beim Schreiben der Testcases. 
Der Incremental-Typed Algorithmus hingegen könnte ein sehr gebrauchstauglicher Ansatz sein, schneidet aber schlechter ab, weil die Testcases nicht stringent durchdacht sind.

Hätten wir mehr Zeit gehabt, hätten wir gerne einige Strategien z.B. mit Nutzertests herausgearbeitet und darauf aufbauend eine weitere Iteration unserer Testsuite erstellt -- eine, die für jede dieser Strategien eine eigene Lösung anbietet. 
Damit hätten wir unsere Algorithmen gezielt auf eine bestimmte Strategie optimieren können und eine deutlich bessere Vergleichbarkeit gehabt, als sie jetzt vorhanden ist.

Interessant wäre dabei noch eine zweite Implikation: 
Nutzende könnten später selbst auswählen, welche Strategie ihr lokaler Editor verfolgen soll. 
Denkbar wäre sogar, sie eigene Strategien dafür entwickeln zu lassen (siehe Malleable Software #footnote[https://www.inkandswitch.com/malleable-software/]).

Angefangen haben wir mit vielen Ideen: Ein eigener Editor, CRDT-Verifikation und inkrementellen Syntaxbäumen. Geworden ist daraus eine Frage: Welche Änderungen sollten angewendet werden und welche nicht? Ein Problem, klein genug, um es ordentlich kaputt zu spielen, und groß genug, dass wir nach 26 Wochen noch nicht fertig sind. Dafür haben wir jetzt eine Testsuite und einige vielversprechende Ansätze, um das Problem zu lösen.

Malte macht das Dokument zwar immer noch kaputt. Wir haben jetzt aber eine deutlich präzisere Vorstellung davon, was wir dagegen tun müssten.

/* Vorschlag 1:
Letztlich hat uns dieses Projekt gezeigt, dass die größte Herausforderung kollaborativer Editoren nicht im fehlerfreien Synchronisieren von Zeichen liegt, sondern im semantischen Verstehen von Absichten.
Wir haben das Problem von der abstrakten CRDT-Ebene auf eine greifbare, testbare Ebene gehoben.
Der Weg zu einem Editor, der sich unseren Workflow-Strategien dynamisch anpasst und wirklich mit uns statt gegen uns arbeitet, ist noch lang – aber wir haben zumindest schon mal ein paar sehr verlässliche Wegweiser aufgestellt.
*/

/* Vorschlag 2:
Wir sind losgezogen, um eigentlich nur unser Typst-Preview vor Blockaden zu bewahren – und sind tief im Kaninchenbau von Verifikation, Nutzerintentionen und Editor-Design gelandet.
Auch wenn die Suche nach dem absolut perfekten Algorithmus zur Absichtsbewahrung wohl nie ganz endet, haben wir gezeigt, dass kollaboratives Arbeiten an Code weit mehr sein kann als das blinde Synchronisieren von fehlerhaftem Text.
Und bis wir unseren ultimativen Traum-Editor fertig programmiert haben, wissen wir jetzt zumindest, wie wir die Änderungen der anderen im Hintergrund halten können, wenn sie mal wieder unser schickes Dokument kaputt machen.
*/
