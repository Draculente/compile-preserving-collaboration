#import "../utils/lab-notes-prelude.typ": *

== Algorithmen

Nachdem wir unser Problem einigermaßen verstanden und eine Testsuite // hier Testsuite verlinken
gebastelt hatten, war es nun an der Tagesordnung, einen Algorithmus zu finden.

Aber wie entscheiden wir überhaupt, welche Änderungen übernommen werden?

Wir haben einen kompilierbaren Ausgangszustand und eine Reihe neuer Änderungen. Im besten Fall können wir einfach alles anwenden und nach Hause fahren. Im schlechtesten funktioniert die Kombination nicht, die Änderungen müssen weiter an der Bushaltestelle stehen bleiben und hoffen, dass irgendwann dieser blöde Bus kommt.

Die Aufgabe klingt im ersten Augenblick erst einmal überschaubar:
Finde möglichst viele der eingehenden Änderungen, die zusammen einen kompilierbaren Typst-Zustand ergeben.

== Einfach mal draufhauen
// Hier darf Malte gerne nochmal seinen Brute-Force Approach näher beschreiben. :)

==
// Jan darf hier gerne seine kurz beschreiben?

== Draufhauen und danach nochmal nachdenken
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
Wenn Brute Force und HDD am Ende denselben Text erzeugen, gewinnt die Variant, die mehr Kollaboration erhalten hat, gemessen an mehr übernommenen Indizes.

Wenn beide unterschiedlichen Text erzeugen, wird zunächst die Brute Force Lösung bevorzugt. HDD gewinnt nur dann, wenn es einen erkennbaren strukturellen Fehler, wie z. B. das Entfernen eines ```#```, erkennt. Bestimmte Zeichen wie das \# werden als wichtige syntaktische Marker erkannt. Wird ein solcher Marker entfernt, während der Rest der Änderung erhalten bleibt, wird das Ergebnis schlechter bewertet. Diese Marker haben wir vorher selbst definiert.

=== Notes to future selves
- Man kann sich durchaus nochmal Machine Learning anschauen, auch wenn es sich in uns sträubt.
- Intensiver vorher über die Probleme nachdenken. Kann man die Probleme noch weiter aufsplitten?

#todo[Wir haben in testsuite.typ schon festgestellt, dass die Absicht einer Änderung nicht eindeutig rekonstruiert werden kann. Stattdessen kann man nur vermuten welche Absicht einer Änderung wahrscheinlicher ist. Wir haben es also mit Wahrscheinlichkeiten zu tun, einem Feld, für das Maschine-Learning-Algorithmen prädestiniert sind.]