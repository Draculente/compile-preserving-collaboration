#import "../utils/lab-notes-prelude.typ": *


== Algorithmen

In @kap:testsuite haben wir unsere Problemstellung schon sehr weit definiert und eine Testsuite entworfen, an der wir Algorithmen messen können.

Jetzt fehlen nur noch die Algorithmen.

Zur Erinnerung:
Als Eingabe bekommen unsere Algorithmen eine Menge von Änderungen und ein valides Dokument als Ausgangszustand.
Wir fordern, dass sie aus der Änderungsmenge die größte Teilmenge bestimmen, die,
+ wenn sie auf den Ausgangszustand angewendet wird, das Dokument valide lässt und
+ die Absicht hinter den Änderungen bewahrt.

Weil wir uns jetzt der praktischen Implementierung nähern, sollten wir eine weitere Anforderung explizit machen: Wenn wir die Algorithmen nach jedem Eingang einer Änderung neu ausführen wollen, dann müssen die Laufzeiten entsprechend schnell sein.
#cite(<glier_systemantwortzeiten_2005>, form: "prose", supplement: "S. 37") stellt fest, dass die Antwortzeiten bei Direktmanipulation (z.B. bei Eingaben) zwischen 50 - 150 ms liegen müssen, damit sich das System direkt reagierend anfühlt.
Für interaktive, kollaborative Systeme liegt die von Nutzenden erwartete Reaktionszeit bei unter 250 ms @glier_systemantwortzeiten_2005.
Ab Verzögerungen im Sekundenbereich sinkt die Leistung bei Zusammenarbeit und der Koordinationsaufwand steigt deutlich (vgl. @davitt_are_2026, @prinz_effects_2002).
Da Kollaborationsanwendungen schon ohne unseren Algorithmus Verzögerungen haben, sollte es unser Ziel sein, die Laufzeit unseres Algorithmus deutlich unter einer Sekunde zu halten.

Da wir bewusst von Kollaborations-Algorithmen wie CRDTs abstrahieren wollen, können wir keine Aussage darüber treffen, in welcher Aufteilung die Änderungen in den Algorithmus eingehen.
Damit unsere Algorithmen möglichst allgemeingültig sind, gehen wir also davon aus, dass die Änderungen in atomarer Form vorliegen.
Wenn das nicht der Fall ist, teilen wir die Änderungen entsprechend so auf, dass sie atomar sind.

Für den Test, ob ein Dokument valide ist, verwenden die Algorithmen den Typst-Compiler.

Für die Bewertung der Algorithmen nutzen wir Metriken, die wir auf Basis unserer Testsuite erheben.
Besonders relevant ist dabei die Zahl der Testfälle, die der Algorithmus exakt lösen kann.
Wichtig ist aber auch die durchschnittliche Laufzeit je Testfall.

=== Einfach mal draufhauen <kap:brute-force>
Aber wie entscheiden wir jetzt, welche Änderungen übernommen werden?

Der erste Ansatz, den wir ausprobieren, ist der einfache `brute-force`-Algorithmus:
Wir probieren einfach alle Teilmengen durch.
Der Algorithmus gibt dann die größte Teilmenge, die das längste valide Dokument erzeugt, aus.
Dabei war uns aber schon klar, dass diese Lösung nicht skaliert.
Der Algorithmus konstruiert die Potenzmenge der eingehenden Änderungsmenge $M$ mit $|M| = n$.
Dann probiert er alle $2^n$ Elemente aus. \
Dafür muss jeweils der Text zusammengesetzt werden und das Dokument dann durch den Typst-Compiler laufen.
Da wir diese Berechnungen bei jeder eingehenden Änderung ausführen möchten, sind hier schnell Laufzeit-Grenzen erreicht, ab denen der Algorithmus die Anforderung nicht mehr realistisch erfüllen kann. \
Um den Algorithmus trotzdem testen zu können und um die Anforderung der schnellen Laufzeit zu erfüllen, haben wir eine Grenze von $n >= "LIMIT"$ eingezogen.
Ist die Änderungsmenge größer oder gleich der Grenze, wird die leere Menge zurückgegeben.\
Zur Verbesserung der Laufzeit testen wir die Teilmengen absteigend nach ihrer Größe sortiert.
Finden wir eine Teilmengengröße, die ein valides Dokument produziert, brechen wir an dieser Stelle den Algorithmus ab und geben die Teilmenge zurück, die das längste Dokument erzeugt.

In @atomar-changes-vs-limit sind die Ergebnisse in Abhängigkeit von der Grenze dargestellt.
Zu erkennen ist, dass sowohl die durchschnittliche Dauer als auch die Zahl der exakt gelösten Tests bei einer Grenze von 14 höher sind als bei einer Grenze von 1.
Allerdings ist auch zu erkennen, dass die Laufzeit nicht durchgehend steigt. Hier liegt die Vermutung nahe, dass Messungenauigkeiten durch die vielen Störfaktoren auf einem Live-System für die Schwankungen verantwortlich sind.
Der starke Sprung der Laufzeit zwischen Limit 9 und 10 liegt wahrscheinlich daran, dass in der Testsuite ein besonders "schwieriger" Testfall vorhanden ist, der ab einer Grenze von 10 vom Algorithmus bearbeitet wird und dafür sorgt, dass nahezu alle Teilmengen durchprobiert werden müssen.
Die durchschnittliche Laufzeit bei einer Grenze von $16$ ist übrigens $54$ ms.
Auch hier ist also ein erheblicher Sprung vorhanden.
Im Worst-Case müssen hier schon $#(calc.pow(2, 16))$ Teilmengen validiert werden.\
/*
Der Grund für die Schwankungen in der Zahl der gelösten Tests liegt an der in @kap:testsuite beschriebenen Nicht-Optimalität des `brute-force` Algorithmus.
Der Algorithmus findet zwar die größte Teilmenge, die ein valides Dokument erzeugt, das muss aber nicht immer eine Menge sein, die auch die Absicht hinter den Änderungen bewahrt.
In manchen Fällen mag die richtige Lösung dafür sein, gar keine Änderungen zu akzeptieren.
*/

#note[Die Laufzeiten der `brute-force` Algorithmen dienen dem relativen Vergleich dieser Algorithmen untereinander. Aufgrund der vielen Störgrößen sollte man beim Vergleich von Benchmark-Ergebnissen zwischen verschiedenen Systemen, oder sogar dem gleichen System zu unterschiedlichen Zeiten, große Vorsicht walten lassen.]
//(16, 26, 2789),
// Grenze, bestanden, durschnittliche Zeit in ms
#let raw-data-atomar = (
  (1, 10, 4748), (2, 10, 5331), (3, 10, 50628), (4, 15, 279364), (5, 15, 314002), (6, 15, 368680), (7, 17, 412304), (8, 18, 601584), (9, 18, 563351), (10, 18, 2949961), (11, 18, 2806856), (12, 18, 4096349), (13, 19, 4177848), (14, 21, 4598603), (15, 23, 4923092),
)

#figure(
caption: [Durchschnittliche Laufzeit und Zahl der exakt gelösten Tests in Abhängigkeit von der Limit-Größe des `brute-force` Algorithmus auf atomaren Änderungen.],
limit-plot(raw-data-atomar)
) <atomar-changes-vs-limit>

Die Datenreihe der gelösten Testfälle lässt vermuten je Grenz-Größe der Änderungsmenge, dass die Zahl der exakt gelösten Testfälle weiter steigen könnte, wenn wir mehr Änderungen mit einbeziehen würden.
Dort begrenzt uns aber irgendwann die Laufzeit stark. \
Eine Idee ist deshalb, die eingehende Änderungsmenge $M$ zu verkleinern.
Das ist möglich, weil Änderungsmengen unterschiedlich aufgeteilt werden können, ohne dass sich das resultierende Dokument verändert (siehe @kap:testsuite).
Eine valide Aufteilung jeder Änderungsmenge ist die Zusammenführung aller aufeinanderfolgenden Änderungen. \
Aus
#fig-block("Hallo Welt".split("").map(e => insertion(e)).join(" ")) wird also
#fig-block(insertion("Hallo Welt"))
Die Größe der Änderungsmenge kann damit also deutlich reduziert werden.
Es gibt aber auch Fälle, bei denen diese Neu-Aufteilung keine Auswirkungen hat: \
#fig-block[#insertion("a")#normal_text("bc")#insertion("d")]

In @org-changes-vs-limit sind die Ergebnisse eines `brute-force`-Algorithmus zu sehen, der sich genau diese Kombinationstechnik zunutze macht, sonst aber exakt dem vorher beschriebenen Algorithmus entspricht.
Zu erkennen ist, dass der Algorithmus bei vergleichbarer Laufzeit deutlich mehr Testfälle (64%) löst und dass schon bei einer geringen Grenze von $4$ mehr als die Hälfte aller Testfälle exakt gelöst werden.

#let raw-data-combined = (
  (1, 10, 7343), (2, 10, 3507), (3, 12, 162365), (4, 54, 2232901), (5, 65, 3074631), (6, 66, 3383784), (7, 66, 4142822), (8, 66, 4173797), (9, 67, 4693604), (10, 67, 4591783), (11, 67, 4409561), (12, 67, 4393000), (13, 67, 4349472), (14, 67, 4581906), (15, 67, 4460963),
)

#figure(
  caption: [Durchschnittliche Laufzeit und Zahl der exakt gelösten Tests in Abhängigkeit von der Limit-Größe des `brute-force` Algorithmus auf kombinierten Änderungen.],
  limit-plot(raw-data-combined, legend: (7.25, 2.5) )
)<org-changes-vs-limit>

Die Kombination von Änderungen zur Reduktion der Größe der eingehenden Änderungsmenge ist also eine gute Möglichkeit, den Algorithmus zu verbessern.
Es bleibt aber ein einfacher Vorverarbeitungsschritt, der die Laufzeit in der Praxis deutlich verkürzt, aber die Laufzeitkomplexität nicht verbessert.

Nichtsdestotrotz haben wir uns an einigen weiteren Heuristiken versucht, um die Änderungen möglichst geschickt aufzuteilen.

Eine einfache Idee war beispielsweise, die kombinierten Änderungen an Whitespace zu trennen.
Wie in @whitespace-vs-limit zu sehen ist, steigt bei dieser Methode die Laufzeit zwar fast linear mit der Grenze, der Anteil der exakt gelösten Tests allerdings nicht.
Er stagniert bei etwa $34%$.
Hier liegt die Vermutung nahe, dass die Aufteilung nach Whitespace einfach keine gute Heuristik ist, um nach unserer Testsuite korrekte Lösungen zu bilden.

#let raw-data-whitespace = (
  (1, 10, 6391), (2, 10, 6950), (3, 11, 90441), (4, 16, 670255), (5, 23, 812862), (6, 28, 1559369), (7, 29, 2220269), (8, 29, 3108358), (9, 32, 4494384), (10, 34, 5441899), (11, 34, 5505999), (12, 34, 6468701), (13, 34, 6915008), (14, 34, 7690931), (15, 34, 7740596),
)

#figure(
  caption: [Durchschnittliche Laufzeit und Zahl der exakt gelösten Tests in Abhängigkeit von der Limit-Größe des `brute-force` Algorithmus auf kombinierten Änderungen getrennt nach Whitespace.],
  limit-plot(raw-data-whitespace)
)<whitespace-vs-limit>

Eine weitere Idee war es, dem Typst-Compiler das Dokument, auf das alle Änderungen angewendet wurden, zu geben und ihn zu fragen, wo die Fehler sind.
Der Compiler kreist Stellen ein, die er als relevant für syntaktische oder semantische Fehler betrachtet.
Diese Highlights machen wir uns zunutze und teilen die zusammengeführten Änderungen an diesen Stellen auf.
Die Hoffnung ist hier, dass wir uns die Vorteile der stark reduzierten Größe der Änderungsmenge zu nutze machen können, während wir aber dem Algorithmus mehr Möglichkeiten geben, fehlerhafte Zeichen auszusortieren.

Wie in @error-split-vs-limit zu erkennen ist, ist die Laufzeit dieses Algorithmus im Vergleich zu den bisher betrachteten Algorithmen höher.
Das liegt an der zusätzlichen Kompilierung, die zur Fehlersuche notwendig ist.
Mit Fehler-Aufteilung löst der Algorithmus mehr Testfälle exakt als bei der Aufteilung nach Wörtern über Whitespace (vgl. @whitespace-vs-limit) oder ohne geschickte Aufteilung auf atomaren Änderungen (vgl. @atomar-changes-vs-limit), aber die hohe Rate der reinen zusammengeführten Änderungen (@org-changes-vs-limit) erreicht er nicht.

#let raw-data-error-split = (
  (1, 10, 1560509), (2, 10, 1557072), (3, 12, 1664464), (4, 24, 2255267), (5, 33, 3119577), (6, 39, 5368934), (7, 42, 7150099), (8, 42, 6994578), (9, 43, 7382937), (10, 43, 7636021), (11, 43, 7914908), (12, 43, 8015039), (13, 43, 8037032), (14, 43, 7990598), (15, 43, 8038927),
)

#figure(
  caption: [Durchschnittliche Laufzeit und Zahl der exakt gelösten Tests in Abhängigkeit von der Limit-Größe des `brute-force` Algorithmus auf kombinierten Änderungen getrennt nach Fehlern.],
  limit-plot(raw-data-error-split)
)<error-split-vs-limit>

=== Wir fragen das komprimierte Textwissen der Menschheit <kap:algo:agentic>
// Maltes Brute-Force-Ansätze und die Testsuite waren in Rust bereits wunderbar vorbereitet.
Da wir wissen wollten, ob sich das Problem der exponentiellen Laufzeit ($2^n$) mit geschickteren Heuristiken umgehen lässt, ohne die Lösungsqualität zu zerstören, brauchten wir mehr Algorithmen.
Statt Wochen damit zu verbringen, diese alle von Hand in Rust zu implementieren, haben wir einen KI-Coding-Agenten auf die Codebase losgelassen.

Der OpenCode-KI-Agent sollte die Schnittstellen der Testsuite mit verschiedene etablierten Strategien zur Konfliktauflösung implementieren. 
Herausgekommen sind sieben weitere Algorithmen:
- *Brute Force (Maltes Lösung, abgeändert):* Probiert alle Kombinationen von ganzen Änderungen aus und nimmt die größte valide Teilmenge. Das wird wie oben erklärt bei vielen Änderungen extrem langsam.
- *Atomic Bounded:* Teilt Änderungen in einzelne Zeichen auf, lässt den Typst-Compiler den Ort des Fehlers einkreisen und wendet Brute-Force nur auf diese Fehler-Region an.
- *Incremental Typed:* Simuliert echtes Tippen. Wendet zunächst ganze Änderungen an; schlägt dies fehl, wird die Änderung zeichenweise von vorne nach hinten hinzugefügt, bis der Compiler meckert.
- *Greedy Remove:* Wendet zunächst alle Änderungen an (was meistens zu einem invaliden Dokument führt) und wirft dann von hinten nach vorne einzelne Zeichen weg, bis es wieder kompiliert.
- *Error-Span Guided:* Fragt den Typst-Compiler nach der genauen Fehler-Koordinate und wirft relativ stumpf alle Änderungen weg, die in diesen Bereich fallen.
- *Delta Debugging:* Halbiert die Änderungsmenge iterativ (Divide and Conquer), um die Fehlerquelle systematisch einzukreisen, und fügt den Rest zeichenweise wieder hinzu.
- *Bracket Balance:* Ein leichtgewichtiger Ansatz, der nur öffnende und schließende Klammern (`[]`, `()`, `{}`) zählt und alles wegwirft, was die Balance stört. Ignoriert die restliche Typst-Syntax, erinnert einen an Kellerautomaten aus _Theoretische Informatik_ im Bachelor.
- *Greedy Keep:* Startet beim Originaldokument und fügt zeichenweise Änderungen hinzu. Jedes Zeichen, das den Zustand valide lässt, wird behalten, der Rest ignoriert.

/*
#xtodo[Ich kommentiere das hier mal aus, weil exakt das schon im Kapitel Testsuite beschriebe habe]
Bei der Analyse der Ergebnisse ist aufgefallen, dass es viele "falsche" Lösungen gibt, die bei genauerem Betrachten gar nicht so schlecht sind.
Woran das liegt?
Wir haben eine Testsuite, die nur eine Lösung kennt.
Was ist, wenn es eine andere Lösung gibt, die wir nicht bedacht haben?
*/
/*Jan hat den Agenten eine weitere Metrik für Teilerfolge implementieren lassen.
Ein Teilerfolg bedeutet, dass der Algorithmus zwar ein anderes Ergebnis als unsere Referenz geliefert hat, dieses Dokument aber fehlerfrei kompiliert und dabei mindestens genauso viele Zeichen der Nutzenden erhalten hat wie unsere händische Musterlösung.
Dieser Ansatz flaggt vor allem interessante Edge-Cases der Algorithmen, theoretisch lässt diese Metrik aber wieder Lücken für Schummeleien mit Typst-relevanten Zeichen wie dem `#`-Symbol zu, die wir in @kap:draufhauen-nochmal-nachdenken genauer betrachten.*/

Zunächst aber einmal die Ergebnisse unseres Agenten-Benchmarks auf unseren 104 Testfällen.
Die besseren Benchmark-Ergebnisse in @fig:algo-benchmark sind farblich hinterlegt:

#let to_percent = a => [#(calc.round(a / 104 * 100, digits: 2))%]

#figure(
  table(
    columns: (2fr, 1fr, 1fr),
    inset: 8pt,
    align: (left, right, right),
    stroke: 0.5pt + luma(200),
    fill: (_, row) => if row == 0 { luma(240) } else { none },
    table.header(
      [*Algorithmus*],
      [*% Exakt richtige \ Lösungen*],
      [*Ø Dauer*]
    ),
    [Brute Force mit kombinierten Änderungen (Malte)], highlight(fill: green.lighten(50%))[#to_percent(67)], highlight(fill: green.lighten(50%))[0.06 ms],
    [Atomic Bounded], highlight(fill: green.lighten(50%))[#to_percent(44)], [5.46 ms],
    [Incremental Typed], highlight(fill: yellow.lighten(50%))[#to_percent(37)], highlight(fill: green.lighten(50%))[0.05 ms],
    [Greedy Remove], highlight(fill: yellow.lighten(50%))[#to_percent(36)], [0.27 ms],
    [Error-Span Guided], [#to_percent(26)], highlight(fill: green.lighten(50%))[0.04 ms],
    [Delta Debugging], [#to_percent(22)], [0.86 ms],
    [Bracket Balance], [#to_percent(21)], highlight(fill: green.lighten(50%))[0.01 ms],
    [Greedy Keep], [#to_percent(15)], [5.43 ms]
  ),
  caption: [Benchmark-Ergebnisse der verschiedenen Strategien (bei 104 Testfällen)]
) <fig:algo-benchmark>

/*#xtodo[Die Dauer Metrik des Brute Force Algorithmus weicht um den Faktor 1000 von meinen Messungen ab...

uffff

Ja xD. Ich weiß nicht wo der liegt. Ich suche gerade mal bei mir

aber der müsste doch recht schnell sein

vielleicht messen wir anders

Ich habe es jetzt im release Mode versucht und es sind jetzt statt 60 nur noch 8 ms im Durchschnitt.

Andere Archtektur wird wohl kaum noch Faktor 100 Ändern, aber ich hab das gerade ausgeführt und alle tests laufen quasi instantly durch. wirklich beeindruckend

Total time: 1.2s

Habe jetzt tatsächlich noch ein paar Fehlerchen gefunden. Auf 0.06ms komme ich trotzdem nicht. Das beste, was ich erreichen konnte, sind 4.5 ms

Hab dein repo benchmarken lassen:
#[
```
brute_force_atomar: timed out after 30.0s on 39fcf40f-d0d3-41bd-b501-f6d625684c27; skipping the rest
algorithm                  passed failed timeout   total(s)   mean(ms) median(ms) stddev(ms)    min(ms)    max(ms)
brute_force                    79     25      0       0.01     0.1059     0.0508     0.1523     0.0244     0.9950
brute_force_atomar              3      1     99      30.00  6000.2155     0.0387 12000.3391     0.0297 30000.8937
brute_force_split_by_error     55     49      0       0.01     0.0986     0.0605     0.0928     0.0160     0.4412
remove_errors                  63     41      0       0.01     0.0897     0.0632     0.0925     0.0158     0.7631
==================
LLM-Algos:
=== Performance per test case ===
algorithm         passed  partial  failed  total(s)  mean(ms) median(ms) stddev(ms)   min(ms)   max(ms)
brute_force         67/104      17      20      0.01      0.08       0.04      0.13      0.01      0.64
greedy_keep         15/104      67      22      0.55      5.33       1.58     18.13      0.02    138.81
greedy_remove       36/104      42      26      0.03      0.26       0.05      0.69      0.00      4.57
delta_debugging     22/104      67      15      0.09      0.84       0.13      3.40      0.01     30.46
error_span          26/104      25      53      0.00      0.04       0.03      0.05      0.00      0.37
bracket_balance     21/104      14      69      0.00      0.01       0.00      0.01      0.00      0.05
atom_bounded        44/104      49      11      0.52      5.04       0.07     20.43      0.00    167.07
incremental_typed    37/104      44      23      0.01      0.05       0.03      0.06      0.01      0.35
```
]

Ich würde jetzt ableiten, dass der M1-Chip irgendeine Magie macht mit seinem System-on-a-Chip-RAM
]*/

Maltes Brute-Force-Ansatz mit kombinierten Änderungen schneidet bei den exakten Treffern unfassbar gut ab.
Der Grund dafür ist simpel: Unsere Testsuite ist (wie oft im echten Leben) von überschaubarer Komplexität.
Solange nicht hunderte Änderungen gleichzeitig eintreffen, ist der Suchraum für Brute-Force klein genug, um alle anderen Algorithmen zu schlagen.
Die durchschnittliche Dauer pro Test-Case war zwar nur im Mittelfeld, aber mit unter 0.10 ms waren die vier schnellsten Algorithmen sehr nah aneinander.

Ein weiterer herausragender Algorithmus war _Atomic Bounded_ auf Platz 2 nach exakten Treffern.
/*#xtodo[- Das ist die Begründung aus dem Kapitel Testsuite warum wir die Testsuite brauchen... Sehe nicht so richtig den Mehrwert der Teilerfolgsmetrik GaLiGrü Malte
- Wir können sonst Teilerfolge komplett streichen, mir egal GLG Jan]
Bei denen müsste man jetzt aber individuell die Qualität ermitteln können, was nicht so richtig objektiv möglich ist, wo wir doch extra _eine_ Musterlösung haben.*/
Die durchschittliche Dauer pro Test-Case war allerdings die langsamste.
Der Brute-Force-Ansatz bleibt also der Preis-Leistungssieger des Benchmarks.

Der nächste Algorithmus nach exakten Treffern ist _Incremental Typed_, auch wenn die Trefferzahl nur etwas über der Hälfte unseres Spitzenreiters war.
Wie bei einem so simplen Algorithmus zu erwarten, bewegt er sich bei der Performance mit Platz 3 im oberen Mittelfeld.
Das Tolle im Vergleich zu den potenziell exponentiell wachsenden Laufzeiten der anderen beiden Top-Algorithmen dürfte aber seine linear mit der Menge der Änderungen wachsende Komplexität sein.
//Vielleicht ist dieser Algorithmus am Ende doch nicht so schlecht, wie die exakten Treffer auf den ersten Blick vermuten lassen.

Das liegt vermutlich auch daran, dass er dem tatsächlichen Schreibprozess am nächsten kommt: Statt eine beliebige Teilmenge von Änderungen zu suchen, wendet er Änderungen so an, wie sie getippt wurden, und blendet nur den nicht kompilierenden Rest so lange aus, bis er wieder gültig wird.
Für eine Person, die alleine tippt, entspricht @fig:typing genau diesem Verhalten: Die Referenz "`@abs:1`" wird erst dann Teil des sichtbaren Dokuments, wenn sie vollständig getippt ist.

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
  caption: [Statt komplexer Algorithmen wird bei _Incremental Typed_ jedes Zeichen atomar inkrementell ausprobiert, bis es nicht mehr geht. Sobald die getippten Änderungen wieder gültig sind, werden auch diese Zeichen Teil des Dokuments.],
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

So ein Algorithmus löst zwar nicht das eigentliche Problem interdependenter eingehender Änderungen verschiedener Parteien -- dafür bräuchte es weiterhin eines der komplexeren Verfahren --, zeigt aber, dass ein simples, am Tippverhalten orientiertes Modell für den Alleinschreib-Fall überraschend gut funktioniert und intuitiv nachvollziehbar bleibt.

// Letzten Satz würde ich ganz streichen, sehe ich anders und selbst wenn, gehört das finde ich nicht in die Endabgabe ohne einen Ansatz, wie man das anders machen kann -> Es sei denn, du möchtest unbedingt eine schlechtere Note. Die Kritik davor hat Malte schon in den Notes for future selves der Testsuite, wo sie mMn auch hingehören, LG Sören
/*
=== Draufhauen und danach nochmal nachdenken <kap:draufhauen-nochmal-nachdenken>
 In Nicoles Ansatz werden strukturell problematische Änderungen zunächst nicht auf Zeichenebene betrachtet. Stattdessen fasst sie zusammengehörige Bereiche zu größeren Einheiten zusammen und zerlegt diese erst dann schrittweise weiter, wenn auf der gröberen Ebene keine geeignete Lösung gefunden wird. Dieses Vorgehen ist an Hierarchical Delta Debugging (HDD) angelehnt, stellt jedoch eine konkrete Ausgestaltung innerhalb ihres Algorithmus dar.

Erkennt der Typst-Parser beispielsweise einen Funktionsaufruf oder einen anderen zusammengehörigen Syntaxbereich, behandelt Nicole diesen zunächst als Einheit, anstatt unmittelbar einzelne Zeichen daraus zu entfernen. Damit verfolgt sie das Ziel, syntaktische Strukturen möglichst lange zu erhalten.
Ein Beispiel dafür ist die Änderung

```typ
#set text(size:)
```

Ein rein zeichenbasiertes Verfahren könnte feststellen, dass sich durch das Entfernen des \# wieder ein kompilierbarer Zustand herstellen lässt:
```typ
set text(size:)
```

Das Ergebnis ist zwar technisch kompilierbar, wird von Typst jedoch nur noch als gewöhnlicher Text interpretiert. Um solche Fälle in ihrer Umsetzung schlechter zu bewerten, berücksichtigt Nicole zusätzlich bestimmte syntaktische Marker.

Brute Force wird in ihrem Ansatz weiterhin unabhängig ausgeführt und dient als Vergleichsverfahren. Anschließend entscheidet Nicole anhand einer von ihr festgelegten Bewertungslogik, welches Ergebnis bevorzugt wird. Diese Entscheidungsregeln sind dabei kein Bestandteil von HDD oder Brute Force selbst, sondern gehören zu ihrer konkreten Kombination der beiden Verfahren.

Erzeugen Brute Force und HDD denselben resultierenden Text, bevorzugt Nicole die Variante, die einen größeren Anteil der kollaborativen Änderung erhalten hat. Als Maß verwendet sie dabei die Anzahl der übernommenen beziehungsweise erhaltenen Indizes.

Erzeugen beide Verfahren dagegen unterschiedliche Texte, bevorzugt ihre Implementierung zunächst die Brute-Force-Lösung. Das HDD-Ergebnis erhält nur dann Vorrang, wenn die Brute-Force-Lösung nach den von Nicole definierten Kriterien eine erkennbare strukturelle Beschädigung aufweist. Dazu zählt beispielsweise das Entfernen eines syntaktisch wichtigen Markers wie \#, während der übrige Teil der Änderung erhalten bleibt.

Welche Zeichen als syntaktisch relevante Marker gelten und wie stark deren Entfernung gewichtet wird, hat Nicole für ihren Algorithmus selbst festgelegt. Diese Heuristik ist daher ebenfalls keine allgemeine Eigenschaft von Hierarchical Delta Debugging, sondern eine zusätzliche Bewertungsregel ihrer konkreten Implementierung.

Auf diese Weise kombiniert Nicoles Algorithmus zwei unterschiedliche Suchstrategien und ergänzt sie um eigene Heuristiken zur Ergebnisbewertung. Ziel dieser Entscheidungen ist es, nicht nur einen kompilierbaren Zustand zu finden, sondern bei mehreren möglichen Lösungen solche Ergebnisse zu bevorzugen, die die ursprüngliche syntaktische Struktur möglichst gut erhalten.
*/

=== Notes to future selves

Wir haben bei der Erstellung der Testsuite schon festgestellt, dass die Absicht einer Änderung nicht eindeutig rekonstruiert werden kann.
Stattdessen kann man nur vermuten, welche Absicht einer Änderung wahrscheinlicher ist.
Wir haben es also mit Wahrscheinlichkeiten zu tun, einem Feld, für das Machine-Learning-Algorithmen prädestiniert sind.
Man kann man sich also durchaus nochmal Machine Learning anschauen, auch wenn es sich in uns sträubt.
Mit Machine Learning lassen sich eventuell Muster erkennen, die näher an der Absicht einer Änderung sind;
es könnte aber sein, dass es nicht so leicht ist, Trainings- und Test-Daten zu bekommen.

Wenn man automatisiert Änderungen prüft und Teile eines kollaborativen Texts noch nicht mitkompiliert, braucht es sicher eine Art "Notausgang" für die Nutzenden, für den Fall, dass der Algorithmus Unfug macht.
Sollte man vielleicht einzelne Bereiche manuell akzeptieren können? Sollte man vielleicht sogar alle eingehenden Änderungen akzeptieren können?

// Es lohnt sich, intensiver vorher über die Probleme nachdenken.
// Kann man die Probleme noch weiter aufsplitten?
// Gibt es einfachere Ansätze?
// Was erwarten (wir als) Nutzende?
// Misst unsere Testsuite wirklich das, was Nutzende erwarten, oder lässt sich die Nutzendenerwartung nicht so einfach in einer Testsuite festhalten?
