#import "../utils/lab-notes-prelude.typ": *


== Algorithmen

In @kap:testsuite haben wir unsere Problemstellung schon sehr weit definiert und eine Testsuite entworfen an der wir Algorithmen messen können. 

Jetzt fehlen nur noch die Algorithmen.

Zur Erinnerung: 
Als Eingabe bekommen unsere Algorithmen eine Menge von Änderungen und ein valides Dokument als Ausgangszustand. 
Sie sollen aus der Änderungsmenge die größte Teilmenge bestimmen, die, 
+ wenn sie auf den Ausgangszustand angewendet wird, das Dokument valide lässt und
+ die Absicht hinter den Änderungen bewahrt.

Da wir bewusst von Kollaborations-Algorithmen wie CRDTs abstrahieren wollen, können wir keine Aussage darüber treffen in welcher Aufteilung die Änderungen in den Algorithmus eingehen. 
Damit unsere Algorithmen möglichst allgemeingültig sind, gehen wir also davon aus, dass die Änderungen in atomarer Form vorliegen. 
Wenn das nicht der Fall ist, teilen wir die Änderungen entsprechend auf, dass sie atomar sind.

Für den Test ob ein Dokument valide ist, verwenden die Algorithmen den Typst-Compiler.

Für die Bewertung der Algorithmen nutzen wir Metriken, die wir auf Basis unserer Testsuite erheben.
Besonders relevant ist dabei die Zahl der Testfälle, die der Algorithmus exakt lösen kann.
Wichtig ist aber auch die Laufzeit, sowie...
#todo[Weitere Metriken]

Aber wie entscheiden wir, welche Änderungen übernommen werden?

// Wir haben einen kompilierbaren Ausgangszustand und eine Reihe neuer Änderungen. Im besten Fall können wir einfach alles anwenden und nach Hause fahren. Im schlechtesten funktioniert die Kombination nicht, die Änderungen müssen weiter an der Bushaltestelle stehen bleiben und hoffen, dass irgendwann dieser blöde Bus kommt.

Die Aufgabe klingt im ersten Augenblick erst einmal überschaubar:
Finde möglichst viele der eingehenden Änderungen, die zusammen einen kompilierbaren Zustand ergeben.

=== Einfach mal draufhauen
Der erste Ansatz, den wir implementiert haben, war alle Teilmengen auszuprobieren.
Der Algorithmus gibt dann die größte Teilmenge, die das längste valide Dokument erzeugt, aus.
Dabei war uns aber schon klar, dass diese Lösung nicht skaliert. 
Der Algorithmus konstruiert die Potenzmenge der eingehenden Änderungsmenge $M$ mit $|M| = n$. 
Dann probiert er alle $2^n$ Elemente aus. \
Dafür muss jeweils der Text zusammengesetzt werden und das Dokument dann durch den Typst-Compiler laufen. 
Da wir diese Berechnungen bei jeder eingehenden Änderung ausführen möchten, sind hier schnell Laufzeit-Grenzen erreicht. \
Um den Algorithmus trotzdem testen zu können, haben wir eine tatsächliche Grenze von $n >= "LIMIT"$ eingezogen. 
Ist die Änderungemenge größer oder gleich der Grenze, wird die leere Menge zurückgegeben.\
Zur Verbesserung der Laufzeit tetsen wir die Teilmengen absteigend nach ihrer Größe sortiert. 
Finden wir eine Teilmengengröße, die ein valides Dokument produziert, brechen wir an dieser Stelle den Algorithmus ab und geben die Teilmenge zurück, die das längste Dokument erzeugt.

In @atomar-changes-vs-limit sind die Ergebnisse in Abhängigkeit von der Grenze. 
Zu erkennen ist, dass sowohl die durchschnittliche Dauer als auch die exakt gelösten Tests bei einer Grenze von 14 höher sind als bei einer Grenze von 1. 
Allerdings ist auch zu erkennen, dass beide Datenreihen nicht durchgehend steigen. \
Bei der durchschnittlichen Laufzeit liegt die Vermutung nahe, dass Messungenauigkeiten durch die vielen Störfaktoren auf einem Live-System für die Schwankungen verantwortlich sind. 
Der starke Sprung der Laufzeit zwischen Limit 9 und 10 liegt wahrscheinlich daran, dass in der Testsuite ein besonders "schwieriger" Testfall in der vorhanden ist, der ab einer Grenze von 10 vom Algorithmus bearbeitet wird und dafür sorgt, dass nahezu alle Teilmengen durchprobiert werden müssen. 
Die durchschnittliche Laufzeit bei einer Grenze von $16$ sind übrigens $2789$ ms. 
Auch hier ist also ein erheblicher Sprung vorhanden. 
Im Worst-Case müssen hier schon $#(calc.pow(2, 16))$ Teilmengen validiert werden.\
Der Grund für die Schwankungen in der Zahl der gelösten Tests liegt an der in @kap:testsuite beschriebenen Nicht-Optimalität des `brute-force` Algorithmus. 
Der Algorithmus findet zwar die größte Teilmenge, die ein valides Dokument erzeugt, das muss aber nicht immer eine Menge sein, die auch die Absicht hinter den Änderungen bewahrt. 
In manchen Fällen mag die richtige Lösung dafür sein, gar keine Änderungen zu akzeptieren. 
Das scheint die Ursache für den Abfall der gelösten Fälle bei einer Grenze von $6$ zu sein.
#note[Die Laufzeiten der `brute-force` Algorithmen dienen dem relativen Vergleich dieser Algorithmen untereinander. Aufgrund der vielen Störgrüßen sollte man beim Vergleich von Benchmark-Ergebnissen zwischen verschiedenen Sytemen, oder sogar dem gleichen System zu unterschiedlichen Zeiten große Vorsicht walten lassen.]
//(16, 26, 2789),
// Grenze, bestanden, durschnittliche Zeit in ms
#let raw-data-atomar = (
  (1, 10, 32), (2, 10, 32), (3, 10, 32), (4, 16, 35),
  (5, 16, 35), (6, 15, 35), (7, 17, 37), (8, 19, 36),
  (9, 19, 37), (10, 19, 57), (11, 19, 57), (12, 20, 58),
  (13, 21, 60), (14, 23, 64),(15, 25, 66)
)

#figure(
caption: [Durchschnittliche Laufzeit und Zahl der exakt gelösten Tests in Abhängigkeit von der Limit-Größe des `brute-force` Algorithmus auf atomaren Änderungen.],
limit-plot(raw-data-atomar)
) <atomar-changes-vs-limit>

Die Datenreihe der gelösten Testfälle lässt vermuten, dass die Zahl der exakt gelösten Testfälle weiter steigen könnten, wenn wir mehr Änderungen mit einbeziehen würden. 
Das lässt die Laufzeit aber nicht zu. \
Eine Idee ist deshalb die eingehende Änderungemenge $M$ zu verkleinern. 
Das ist möglich, weil Änderungsmengen unterschiedlich aufgeteilt werden können, ohne dass sich das resultierende Dokument verändert (siehe @kap:testsuite).
Eine valide Aufteilung jeder Änderungsmenge, ist die Kambination alle aufeinanderfolgenden Änderungen. \
Aus 
#fig-block("Hallo Welt".split("").map(e => insertion(e)).join(" ")) wird also 
#fig-block(insertion("Hallo Welt"))
Die Größe der Änderungsmenge kann damit also deutlich reduziert werden. 
Es gibt aber auch Fälle bei denen diese Neu-Aufteilung keine Auswirkungen hat: \
#fig-block[#insertion("a")#normal_text("bc")#insertion("d")]

In @org-changes-vs-limit sind die Ergebnisse eines `brute-force` Algorithmuses zu sehen, sich genau diese Kombinationstechnik zu nutze macht, sonst aber exakt dem voher beschriebenen Algorithmus entspricht.
Zu erkennen ist, dass der Algorithmus bei vergleichbarer Laufzeit deutlich mehr Testfälle (75%) löst und, dass schon bei einer geringen Grenze von $4$ mehr als die Hälfte aller Testfälle exakt gelöst werden. 

#let raw-data-combined = (
 (1, 10, 32), (2, 10, 30), (3, 12, 32), (4, 60, 53), (5, 75, 60), (6, 76, 62), (7, 78, 69), (8, 78, 69), (9, 79, 71), (10, 79, 71), (11, 79, 70), (12, 79, 70), (13, 79, 71), (14, 79, 70), (15, 79, 71),  
)

#figure(
  caption: [Durchschnittliche Laufzeit und Zahl der exakt gelösten Tests in Abhängigkeit von der Limit-Größe des `brute-force` Algorithmus auf kombinierten Änderungen.],
  limit-plot(raw-data-combined, legend: (7.25, 1.5) )
)<org-changes-vs-limit>

Die Kombination von Änderungen zur Reduktion der Größe der eingehenden Änderungsmenge ist also eine gute Möglichkeit den Algorithmus zu verbessern. 
Es bleibt aber ein einfacher Vorverarbeitungsschritt, der die Laufzeit in der Praxis deutlich verkürzt, aber die Laufzeitkomplexität nicht verbessert.

Nichtsdestotrotz haben wir uns an einigen weiteren Heuristiken versucht, um die Änderungen möglichst geschickt aufzuteilen. 

Eine einfache Idee war beispielweise die kombinierten Änderungen an Whitespace zu trennen. 


#let raw-data-whitespace = (
 (1, 10, 33), (2, 10, 32), (3, 11, 33), (4, 20, 37), (5, 28, 41), (6, 34, 47), (7, 36, 57), (8, 38, 64), (9, 40, 79), (10, 42, 85), (11, 42, 88), (12, 43, 91), (13, 44, 95), (14, 44, 99), (15, 44, 105) 
)

#figure(
  caption: [Durchschnittliche Laufzeit und Zahl der exakt gelösten Tests in Abhängigkeit von der Limit-Größe des `brute-force` Algorithmus auf kombinierten Änderungen getrennt nach Whitespace.],
  limit-plot(raw-data-whitespace)
)<whitespace-vs-limit>

=== Wir fragen das komprimierte Textwissen der Menschheit <kap:algo:agentic>
Maltes Brute-Force-Ansatz und die Testsuite waren in Rust bereits wunderbar vorbereitet.
Da wir aber wissen wollten, ob sich das Problem der exponentiellen Laufzeit ($2^n$) mit geschickteren Heuristiken umgehen lässt, ohne die Lösungsqualität zu zerstören, brauchten wir mehr Algorithmen.
Statt Wochen damit zu verbringen, diese alle von Hand in Rust zu implementieren, haben wir einen KI-Coding-Agenten auf die Codebase losgelassen.

Der OpenCode-KI-Agent sollte die Schnittstellen der Testsuite mit verschiedene etablierten Strategien zur Konfliktauflösung implementieren. 
Herausgekommen sind sieben weitere Algorithmen:
- *Brute Force (Maltes Lösung, abgeändert):* Probiert alle Kombinationen von ganzen Änderungen aus und nimmt die größte valide Teilmenge. Das wird wie oben erklärt bei vielen Änderungen extrem langsam.
- *Atomic Bounded:* Teilt Änderungen in einzelne Zeichen auf, lässt den Typst-Compiler den Ort des Fehlers einkreisen und wendet Brute-Force nur auf diese Fehler-Region an.
- *Incremental Typed:* Simuliert echtes Tippen. Wendet zunächst ganze Änderungen an; schlägt dies fehl, wird die Änderung zeichenweise von vorne nach hinten hinzugefügt, bis der Compiler meckert.
- *Greedy Remove:* Wendet zunächst alle Änderungen an (was meistens zu einem invaliden Dokument führt) und wirft dann von hinten nach vorne einzelne Zeichen weg, bis es wieder kompiliert.
- *Error-Span Guided:* Fragt den Typst-Compiler nach der genauen Fehler-Koordinate und wirft relativ stumpf alle Änderungen weg, die in diesen Bereich fallen.
- *Delta Debugging:* Halbiert die Änderungsmenge iterativ (Divide and Conquer), um die Fehlerquelle systematisch einzukreisen, und fügt den Rest zeichenweise wieder hinzu.
- *Bracket Balance:* Ein leichtgewichtiger Ansatz, der nur öffnende und schließende Klammern (`[]`, `()`, `{}`) zählt und alles wegwirft, was die Balance stört. Ignoriert die restliche Typst-Syntax, erinnert einen an Kellerautomaten aus _Theoretische Informatik_.
- *Greedy Keep:* Startet beim Originaldokument und fügt zeichenweise Änderungen hinzu. Jedes Zeichen, das den Zustand valide lässt, wird behalten, der Rest ignoriert.

Bei der Analyse der Ergebnisse ist aufgefallen, dass es viele "falsche" Lösungen gibt, die bei genauerem Betrachten gar nicht so schlecht sind.
Woran das liegt?
Wir haben eine Testsuite, die nur eine Lösung kennt.
Was ist, wenn es eine andere Lösung gibt, die wir nicht bedacht haben?
Jan hat den Agenten eine weitere Metrik für Teilerfolge implementieren lassen.
Ein Teilerfolg bedeutet, dass der Algorithmus zwar ein anderes Ergebnis als unsere Referenz geliefert hat, dieses Dokument aber fehlerfrei kompiliert und dabei mindestens genauso viele Zeichen der Nutzenden erhalten hat wie unsere händische Musterlösung.
Dieser Ansatz flaggt vor allem interessante Edge-Cases der Algorithmen, theoretisch lässt diese Metrik aber wieder Lücken für Schummeleien mit Typst-relevanten Zeichen wie dem `#`-Symbol zu, die wir in @kap:draufhauen-nochmal-nachdenken genauer betrachten.

Zunächst aber einmal die Ergebnisse unseres Agenten-Benchmarks auf unseren 104 Testfällen.
Besonders herausragende Werte in @fig:algo-benchmark sind grün hinterlegt:

#figure(
  table(
    columns: (2fr, 1fr, 1fr, 1fr),
    inset: 8pt,
    align: (left, right, right, right),
    stroke: 0.5pt + luma(200),
    fill: (_, row) => if row == 0 { luma(240) } else { none },
    table.header(
      [*Algorithmus*],
      [*Exakt*],
      [*Teilerfolg*],
      [*Ø Dauer*]
    ),
    [Brute Force (Malte)], highlight(fill: green.lighten(50%))[67], [17], highlight(fill: green.lighten(50%))[0.06 ms],
    [Atomic Bounded], highlight(fill: green.lighten(50%))[44], [49], [5.46 ms],
    [Incremental Typed], [37], [44], highlight(fill: green.lighten(50%))[0.05 ms],
    [Greedy Remove], [36], [42], [0.27 ms],
    [Error-Span Guided], [26], [25], highlight(fill: green.lighten(50%))[0.04 ms],
    [Delta Debugging], [22], [67], [0.86 ms],
    [Bracket Balance], [21], [14], highlight(fill: green.lighten(50%))[0.01 ms],
    [Greedy Keep], [15], [67], [5.43 ms]
  ),
  caption: [Benchmark-Ergebnisse der verschiedenen Strategien (bei 104 Testfällen)]
) <fig:algo-benchmark>

Es fällt zuallererst auf: Maltes _Brute-Force_-Ansatz blieb bei den exakten Treffern unfassbar gut.
Der Grund dafür ist simpel: Unsere Testsuite ist (wie oft im echten Leben) von überschaubarer Komplexität.
Solange nicht hunderte Änderungen gleichzeitig eintreffen, ist der Suchraum für Brute-Force klein genug, um alle Heuristiken zu schlagen.
Die durchschittliche Dauer pro Test-Case war zwar nur im Mittelfeld, aber mit unter 0.10 ms waren die vier schnellsten Algorithmen sehr nah aneinander.

Ein weiterer herausragender Algorithmus war _Atomic Bounded_ auf Platz 2 -- zumindest wenn die Teilerfolge berücksichtigt.
Bei denen müsste man jetzt aber individuell die Qualität ermitteln können, was nicht so richtig objektiv möglich ist, wo wir doch extra _eine_ Musterlösung haben.
Die durchschittliche Dauer pro Test-Case war die zweitlangsamste.
Ohne die Qualität der Teilerfolge zu bewerten, bleibt der Brute-Force-Ansatz also der Preis-Leistungssieger des Benchmarks.

Der nächste Algorithmus nach exakten Treffern ist _Incremental Typed_, auch wenn die Trefferzahl nur etwas über der Hälfte unseres Spitzenreiters war.
Wie bei einem so simplen Algorithmus zu erwarten, bewegt er sich bei der Performance mit Platz 3 im oberen Mittelfeld.
Das Tolle im Vergleich zu den potenziell exponenziell wachsenden Laufzeiten der anderen beiden Top-Algorithmen dürfte aber seine linear mit der Menge der Änderungen wachsende Komplexität sein.
Vielleicht ist dieser Algorithmus am Ende doch nicht so schlecht, wie die exakten Treffer auf den ersten Blick vermuten lassen.

Es könnte hier natürlich auch passiert sein, dass nicht alle Algorithmen gleich nah an der Idee implementiert wurden.
Die Beispiele der Testsuite könnten auch für einzelne Algorithmen besonders geeignet gewesen sein, was die Ergebnisse beeinflusst hätte.

[Für Jan] ist hier eigentlich die größte Erkenntnis gewesen:
Mit Musterlösungen wie in dieser Testsuite können wir verschiedene Algorithmen auf quantitative Metriken untersuchen.
Das heißt aber nicht, dass die Testsuite vollständig ist oder gar representativ für den Problemraum.
Vielleicht bräuchte man eine deutlich aufwendiger zu erstellende Sammlung von möglichen Lösungen pro Test-Case.
Vielleicht haben wir uns aber wieder verrannt in Lösungsansätzen, ohne das Problem praxisorientiert betrachtet und verstanden zu haben.

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
#todo[Das verstehe ich nicht. Das haben wir doch gar nicht gemacht? ]

=== Sind diese Algorithmen sinnvoll? // Jan

Nachdem wir viel mit verschiedenen Algorithmen herumprobiert haben und Detailprobleme an vielen Stellen gefunden haben, ist uns etwas klar geworden: Ob wir quantitativ oder qualitativ messen, was unsere Algorithmen alles schaffen, spielt keine Rolle, wenn es beim kollaborativen Editieren zu unerwarteten Ergebnissen kommt.

Ergibt es vielleicht Sinn und ist für Nutzende am Ende intuitiver, zusammenhängende Änderungen einer Person so anzuwenden, wie es getippt wurde, wie es _Incremental Typed_ in @kap:algo:agentic tut? #todo[Das ist doch eine qualitative Bewertung...]

Das Beispiel in @kap:draufhauen-nochmal-nachdenken hat doch gezeigt, dass unsere Ideen immer komplexer wurden und plötzlich Marker der Programmiersprache wie das `#`-Zeichen besonders behandeln mussten. #todo[Hä??? Wann?]
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

Hier müssen wir uns die Frage stellen:
War die Forschung zu Algorithmen sinnvoll und praxisnah?
#todo[Find ich keine sinnvolle Frage. Das was du beschreibst, ist doch ein Algorithmus und damit doch Teil der Forschung.]

#todo[Nach nochmaligem Lesen würde ich dieses ganze Kapitel als einfachen weiteren Algorithmus ansehen. Die Kritik, die du hier unterbringst ist lediglich eine Kritik daran, dass wir unsere Testfälle unstrukturiert erstellt haben und uns eben die Gedanken zu "was ist am intuitivsten" nicht richtig gemacht haben. Denn z.B. "Ergibt es vielleicht Sinn und ist für Nutzende am Ende intuitiver, zusammenhängende Änderungen einer Person so anzuwenden, wie es getippt wurde" sollte eig. mit unser Testsuite abprüfbar sein, wenn wir die besser erstellt hätten. 

Würde das ganze Kapitel zusammenkürzen und unter die restlichen Algorithmen verschieben. Stattdessen vielleicht lieber einen konstruktiveres Kapitel dazu, wie man die Testsuite verbessern könnte (oder halt wie bisher in den Notes lassen).]

=== Notes to future selves

Wir haben bei der Erstellung der Testsuite schon festgestellt, dass die Absicht einer Änderung nicht eindeutig rekonstruiert werden kann.
Stattdessen kann man nur vermuten, welche Absicht einer Änderung wahrscheinlicher ist.
Wir haben es also mit Wahrscheinlichkeiten zu tun, einem Feld, für das Maschine-Learning-Algorithmen prädestiniert sind.
Man kann man sich also durchaus nochmal Machine Learning anschauen, auch wenn es sich in uns sträubt.
Mit Machine Learning lassen sich eventuell Muster erkennen, die näher an der Absicht einer Änderung sind;
es könnte aber sein, dass es nicht so leicht ist, Trainings- und Test-Daten zu bekommen.

Wenn man automatisiert Änderungen prüft und Teile eines kollaborativen Texts noch nicht mitkompiliert, braucht es sicher eine Art "Notausgang" für die Nutzenden, für den Fall, dass der Algorithmus Unfug macht.
Sollte man vielleicht einzelne Bereiche manuell akzeptieren können? Sollte man vielleicht sogar alle eingehenden Änderungen akzeptieren können?

Es lohnt sich, intensiver vorher über die Probleme nachdenken.
Kann man die Probleme noch weiter aufsplitten?
Gibt es einfachere Ansätze?
Was erwarten (wir als) Nutzende?
Misst unsere Testsuite wirklich das, was Nutzende erwarten, oder lässt sich die Nutzendenerwartung nicht so einfach in einer Testsuite festhalten?
