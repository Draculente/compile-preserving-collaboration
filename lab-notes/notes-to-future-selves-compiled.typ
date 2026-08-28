== Und was jetzt?

Wer die Notes to future selves der letzten Abschnitte aufmerksam gelesen hat, merkt es vielleicht schon -- so ganz zufrieden sind wir nicht damit, wie wir die Testcases erstellt haben.

Die Testsuite an sich hat sich als ganz gelungen herausgestellt: Wir konnten damit alle Arten von Algorithmen implementieren, die uns eingefallen sind. Schwer gefallen ist uns dagegen deren Bewertung.

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

Hätten wir mehr Zeit gehabt, hätten wir solche Strategien gerne z.B. mit Nutzertests herausgearbeitet und darauf aufbauend eine weitere Iteration unserer Testsuite erstellt -- eine, die für jede dieser Strategien eine eigene Lösung anbietet. 
Damit hätten wir unsere Algorithmen gezielt auf eine bestimmte Strategie optimieren können und eine deutlich bessere Vergleichbarkeit gehabt, als sie jetzt vorhanden ist.

Interessant wäre daran noch eine zweite Implikation: Nutzende könnten später selbst auswählen, welche Strategie ihr lokaler Editor verfolgen soll. Denkbar wäre sogar, sie eigene Strategien dafür entwickeln zu lassen (siehe Malleable Software #footnote[https://www.inkandswitch.com/malleable-software/]).