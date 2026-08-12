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



=== Notes to future selves
- Man kann sich durchaus nochmal Machine Learning anschauen, auch wenn es sich in uns sträubt.
- Intensiver vorher über die Probleme nachdenken. Kann man die Probleme noch weiter aufsplitten?