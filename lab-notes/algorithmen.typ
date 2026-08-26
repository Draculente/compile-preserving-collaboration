#import "../utils/lab-notes-prelude.typ": *

== Algorithmen

Nachdem wir unser Problem einigermaßen verstanden und eine Testsuite (@kap:testsuite)
gebastelt hatten, war es nun an der Tagesordnung, einen Algorithmus zu finden.

Aber wie entscheiden wir überhaupt, welche Änderungen übernommen werden?

Wir haben einen kompilierbaren Ausgangszustand und eine Reihe neuer Änderungen. Im besten Fall können wir einfach alles anwenden und nach Hause fahren. Im schlechtesten funktioniert die Kombination nicht, die Änderungen müssen weiter an der Bushaltestelle stehen bleiben und hoffen, dass irgendwann dieser blöde Bus kommt.

Die Aufgabe klingt im ersten Augenblick erst einmal überschaubar:
Finde möglichst viele der eingehenden Änderungen, die zusammen einen kompilierbaren Typst-Zustand ergeben.

=== Einfach mal draufhauen
#todo[Hier darf Malte gerne nochmal seinen Brute-Force Approach näher beschreiben. :)]

=== Wir fragen das komprimierte Textwissen der Menschheit
#todo[
  Jan hat ein LLM darum gebeten, ein paar Algortihmen vorzuschlagen, zu implementieren und zu benchmarken.
  Maltes Brute-Force blieb unfassbar gut.
]


=== Draufhauen und danach nochmal nachdenken <kap:draufhauen-nochmal-nachdenken>
Angenommen jemand fügt ein:
```typ
#set text(size:)
```
Dann lässt sich das nicht kompilieren.

Ein Algorithmus, der auf einzenen Zeichen arbeitet könnte nun feststellen, dass das Entfernen des \# das Dokument wieder zum kompilieren bringt.

Dann bleibt:
```typ
set text(size:)
```

Typst behandelt das also wieder einfach als normalen Text. Technisch haben wir damit einen kompilierbaren Zustand gefunden. Allerdings hat dieser wenig mit der Intention unserer Änderung zu tun.

Eine Art diese Art von Änderungen besser erkennen zu können, kann sein, Änderungen zunächst zusammenzuhalten und diese dann beim eventuellen Fehlschlagen erst kleinschrittiger zu betrachten.

Dafür haben wir uns an Hierarchal Delta Debugging orientiert. Wenn Typst beispielsweise einen Funktionsaufruf als zusammengehörigen Syntaxbereich erkennt, behandeln wir diesen zunächst als Einheit, statt direkt einzelne Buchstaben herauszupicken.

Brute Force spielt dabei weiterhin eine wichtige Rolle. Es wird unabhängig ausgeführt und liefert uns eine Vergleichslösung. Am Ende werden die Ergebnisse beider Verfahren miteinander verglichen. 

Dabei gibt es im wesentlichen zwei Fälle:
Wenn Brute Force und HDD am Ende denselben Text erzeugen, gewinnt die Variante, die mehr Kollaboration erhalten hat, gemessen an mehr übernommenen Indizes.

Wenn beide unterschiedlichen Text erzeugen, wird zunächst die Brute Force Lösung bevorzugt. HDD gewinnt nur dann, wenn es einen erkennbaren strukturellen Fehler, wie z. B. das Entfernen eines ```#```, erkennt. Bestimmte Zeichen wie das \# werden als wichtige syntaktische Marker erkannt. Wird ein solcher Marker entfernt, während der Rest der Änderung erhalten bleibt, wird das Ergebnis schlechter bewertet. Diese Marker haben wir vorher selbst definiert.

=== Sind diese Algorithmen sinnvoll? // Jan

Nachdem wir viel mit verschiedenen Algorithmen herumprobiert haben und Detailprobleme an vielen Stellen gefunden haben, ist uns etwas klar geworden: Ob wir quantitativ oder qualitativ messen, was unsere Algorithmen alles schaffen, spielt keine Rolle, wenn es beim kollaborativen Editieren zu unerwarteten Ergebnissen kommt.

Ergibt es vielleicht Sinn und ist für Nutzende am Ende intuitiver, zusammenhängende Änderungen einer Person so anzuwenden, wie es getippt wurde?

Das Beispiel in @kap:draufhauen-nochmal-nachdenken hat doch gezeigt, dass unsere Ideen immer komplexer wurden und plötzlich Marker der Programmiersprache wie das `#`-Zeichen besonders behandeln mussten.
Wenn man sich zurückbesinnt an den Anfang, ging es um kollaboratives Texte-Schreiben.
Eine Änderung nimmt man eigentlich immer in Lese-Richtung vor, also für uns von links nach rechts, sequenziell getippt.
Wenn nun eine Änderung ungültig ist, könnte man mit einem relativ unkomplizieren Algorithmus ungültige Änderungen solange ausblenden, wie sie ungültig sind.

In @fig:typing wird ein Beispiel mit Änderungen von nur einer kollaborierenden Partei betrachtet, wobei Änderungen in Tipp-Reihenfolge probiert werden und nicht mehr angezeigt werden, sobald ein ungüliges Dokument entstehen würde (@fig:typing:before).
Erst, wenn die Änderungen wieder in ein gültiges Dokument erzeugen können, werden die seit der Ungültigkeit nicht ergänzten Zeichen Teil des Dokuments und die Zeichen werden angezeigt (@fig:typing:after).

\

#import "@preview/subpar:0.2.2"
#import "@preview/zebraw:0.6.3": *
#show: zebraw

#subpar.grid(
  figure(
```typst
= Abschnitt 1 <abs:1>
...
Wie in 
```, caption: [Letzter gültiger Zustand des Dokuments, bis die Referenz "`@abs:1`" fertig getippt ist]), <fig:typing:before>,
  figure(
```typst
= Abschnitt 1 <abs:1>
...
Wie in @abs:1
```, caption: [Nächster gültiger Zustand des Dokuments, wenn die Referenz "`@abs:1`" fertig getippt ist]), <fig:typing:after>,
  columns: (1fr, 1fr),
  caption: [Statt komplexe Algorithmen für Änderungen zu programmieren, wird jedes Zeichen atomar inkrementell, ausprobiert, bis es nicht mehr geht. Sobald die getippten Änderungen wieder gültig sind, werden auch diese Änderungen Teil des des Dokuments.],
  label: <fig:typing>,
  supplement: "Listing",
  grid-styles: (c) => {
    set grid(
      align: top,
      gutter: 1em,
    )
    c
  }
)

Dieser Algortihmus löst nicht das Problem von interdependenten eingehenden Änderungen verschiedener Parteien.
Solange keine zyklischen Abhängigkeiten zwischen den interdependenten eingehenden Änderungen existieren, sollten diese Änderungen sobald sie gültig werden nacheinander akzeptiert werden.

=== Notes to future selves

Wir haben bei der Erstellung der Testsuite schon festgestellt, dass die Absicht einer Änderung nicht eindeutig rekonstruiert werden kann.
Stattdessen kann man nur vermuten, welche Absicht einer Änderung wahrscheinlicher ist.
Wir haben es also mit Wahrscheinlichkeiten zu tun, einem Feld, für das Maschine-Learning-Algorithmen prädestiniert sind.
Man kann man sich also durchaus nochmal Machine Learning anschauen, auch wenn es sich in uns sträubt.
Mit Machine Learning lassen sich eventuell Muster erkennen, die näher an der Absicht einer Änderung sind;
es könnte aber sein, dass es nicht so leicht ist, Trainings- und Test-Daten zu bekommen.

Es lohnt sich, intensiver vorher über die Probleme nachdenken.
Kann man die Probleme noch weiter aufsplitten?
Gibt es einfachere Ansätze?
Was erwarten wir als Nutzende?
Misst unsere Testsuite wirklich das, was Nutzende erwarten, oder lässt sich die Nutzendenerwartung nicht so einfach in einer Testsuite festhalten?
