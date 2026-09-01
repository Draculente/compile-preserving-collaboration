#import "../utils/lab-notes-prelude.typ": *
#import "@preview/subpar:0.2.2"
#import "@preview/zebraw:0.6.3": *
#show: zebraw

#let highlight = (color: red, it) => {
 box(fill: (if color == none {red} else {color}).lighten(80%), baseline: 2.5pt, inset: 3pt, radius: 2pt, it) 
}

/*
#show raw.where(block: false): it => {
 box(fill: rgb(red).lighten(80%), baseline: 2.5pt, inset: 3pt, radius: 2pt, it) 
}
*/

== Testsuite <kap:testsuite>

Wir hatten endlich eine schön kleine Frage:

Welche Änderungen sollen angewendet werden?

Bevor wir einfach unsere Lieblingsalgorithmen auf das Problem loslassen konnten, mussten wir erst einmal herausfinden, was wir überhaupt von ihnen erwarten.

Wann ist eine Auswahl von Änderungen gut oder schlecht und wie vergleichen wir zwei Algorithmen, die beide irgendeinen kompilierbaren Zustand erzeugen?
/*
#cpc (CPC) soll es ermöglichen, unabhängiger voneinander an einem gemeinsamen Dokument ($d$) zu kollaborieren, dessen Inhalt einer vorgeschriebenen Syntax und semantischen Regeln folgen soll. 
Insbesondere sollen Situationen vermieden werden, bei denen Änderungen anderer Personen die Syntax des Dokuments invalidieren oder semantische Regeln brechen und so die Weiterverarbeitung (z.B. die Kompilation) verhindern. 
Mithilfe unseres Beispieleditors #footnote[#link("https://git.mylab.th-luebeck.de/soeren.fischer/crdtypewriter") #xtodo[Link ist PRIVAT \@Sören]], haben wir die Frage konkretisiert: 
#quote(block: true)[_Gegeben eine Menge von eingehenden Änderungen: Welche dieser Änderungen sollen angewendet werden?_]

*/

Um diese Fragen beantworten zu können, mussten wir das Problem für uns greifbar und verständlich machen. Was bekommt ein Algorithmus als Eingabe und was soll am Ende herauskommen?

Wir gehen von einem Dokument $d$ aus und einer Änderungsmenge $M$, die während der Kollaboration entstanden ist. Aus diesen Änderungen soll der Algorithmus eine Teilmenge $A$ auswählen, die tatsächlich auf das Dokument angewendet wird:

/* Wir suchen also eine Teilmenge $A$ aller eingehenden Änderungen $M$, deren Änderungen dann auf das Dokument $d$ angewendet werden */ ($d_"new" = d + A$).\

Damit konnten wir anfangen, Situationen durchzuspielen und zu überlegen, welche Auswahl wir jeweils von einem guten, feinen Algorithmus erwarten würden.

Eine Änderungsmenge könnte etwa so aussehen: 

#fig-block[
    #insertion("Der Name Noah") #deletion("Noah") #insertion[Wombat] #insertion("stammt aus der Sprache der Darug.")
  ]

Die Elemente der Menge sind dabei: 
- Einfügen von "Der Name Noah"
- Löschen von "Noah"
- Einfügen von "Wombat"
- Einfügen von "stammt aus der Sprache der Darug."

Wenden wir alle Änderungen der Menge auf ein leeres Dokument an, entsteht folgender Satz: 

#fig-block[
  #normal_text("Der Name Wombat stammt aus der Sprache der Darug.")
]

=== Wer kriegt heute ein Foto von uns? / Was ist überhaupt eine gute Auswahl?

Mit einer formalen Beschreibung allein wissen wir natürlich noch nicht, welche Teilmenge wir eigentlich haben wollen. Also mussten wir anfangen, Erwartungen an diese Auswahl zu formulieren.

/*
Um die Frage, welche Teilmenge einer Änderungsmenge wir anwenden wollen, zufriedenstellend zu beantworten, ist es notwendig, sie zu konkretisieren und unsere Erwartungen an potentielle Algorithmen zu formulieren.
*/

Eine erste Anforderung ergibt sich direkt aus dem Ziel der CPC. 
Die Syntax und Semantik des Dokuments, das aus der Anwendung der vom Algorithmus ausgewählten Änderungen entsteht, sollen valide sein.

Außerdem fordern wir, dass der Algorithmus so viele Änderungen anwenden soll wie möglich, weil sonst der Algorithmus, der alles ablehnt, eine valide Lösung wäre.

Diese Anforderung offenbart eine weitere Annahme, die wir implizit getroffen haben: Das Ausgangsdokument, auf das die Änderungen angewendet werden, muss valide sein. 
Sonst wäre der ablehnende Algorithmus keine korrekte Lösung. 
Im ersten Moment scheint das dem typischen Workflow zu widersprechen, der verbessert werden soll. 
Wenn die Voraussetzung für den Algorithmus ein valides Dokument ist, dann schließt das alle Situationen aus, in denen der lokale Schreiberling ein invalides Dokument produziert. Änderungen anderer würden nur dann angewendet, wenn das lokale Dokument valide ist.
Das Problem können wir durch einen einfachen Trick umgehen: Die Änderungsmenge ($M$) für unseren Algorithmus enthält auch die Änderungen des lokalen Schreiberlings ($L$), die damit potentiell aussortiert werden können. 
Erst im Nachhinein sorgen wir dafür, dass alle Änderungen, die der lokale Schreiberling macht, angewendet werden ($d_"local" = (d + A) + L$).

Indem wir hier lokale Änderungen explizit adressieren, wird auch formal nochmal klar, was durch die Verschiebung der Kompilationsprüfung vom Sender auf den Empfänger passiert: Die Dokumente $d_"local"$ konvergieren nicht mehr global auf einen Zustand, d.h., der Zustand von $d_"local"$ ist auf jeder Instanz anders. 
Das betrifft allerdings eben nur die "Präsentation" des Dokuments, d.h., welche Änderungen angenommen werden und welche nicht.
Die Menge aller Änderungen, die jemals in den Algorithmus eingegangen sind ($M_"ges" = M_1 union M_2...union M_n$), und die totale Ordnung darüber müssen weiterhin auf allen Instanzen gleich sein. 

=== Viel hilft nicht immer viel

Bis hierhin klang unser Ziel eigentlich ganz einfach. Das Ergebnis soll valide sein und dabei möglichst viele Änderungen erhalten.

Damit hätten wir ja ziemlich schnell einen optimalen Algorithmus bauen können.

Zunächst erschienen uns die Anforderungen an den Algorithmus damit genug spezifiziert. 
Der optimale Algorithmus wäre damit ein Algorithmus "`brute-force`", der alle Teilmengen $A$ ausprobiert und die größte Teilmenge auswählt, die bei Anwendung ein valides Dokument produziert. 
Die größte Herausforderung wäre dann gewesen, die Ressourcen-Nutzung zu optimieren, da der optimale Algorithmus eine Laufzeitkomplexität von $2^n$ hat.

Wie der Konjunktiv vermuten lässt, haben wir schnell festgestellt, dass dieser Ansatz Schwachstellen hat. 
In @gegegenbeispiel ist ein Problem des Algorithmus dargestellt. 
Gehen wir davon aus, dass die Eingabe in @a aus atomaren Einfüge-Änderungen besteht, dann ist die größte Teilmenge, die ein valides Dokument erzeugt, in @b dargestellt. 
Die Bedeutung der Ausgabe entspricht offensichtlich nicht mehr der Bedeutung, die beim Schreiben der Eingabe angedacht war. 

#note[
      #insertion("Hallo Welt"), 
      #insertion("Hallo ") #insertion("Welt") und
      #"Hallo Welt".split("").map(e => insertion(e)).join(" ") 
      sind drei verschiedene Änderungsmengen, die aber das gleiche Dokument erzeugen, sofern sie vollständig angewendet werden. \
      Anders betrachtet, stellen die Änderungsmengen verschiedene *Aufteilungen* der Änderungen dar. \
      Änderungsmengen, die nicht weiter aufgeteilt werden können, bezeichnen wir als *atomar*. 
]

Wir müssen also eine weitere Anforderung an unseren Algorithmus stellen. 
In Anlehnung an #cite(<sun_achieving_1998>, form: "prose") nennen wir sie "Intention Preservation" oder "Absichtsbewahrung". 
Wir fordern also, dass der Algorithmus die Absicht hinter den Änderungen der Eingabemenge beibehält. 

\
#subpar.grid(
  figure(```typst
#let name = Noah
#name sagte: "Wombat" 
```
, caption: [
Die Änderungsmenge: Jedes Zeichen ist eine Einfüge-Änderung. 
  ]), <a>,
  figure(
```typst
#let name = "Wombat" 
```
    , caption: [
Die Ausgabe des `brute-force` Algorithmus.
  ]), <b>,
  columns: (1fr, 1fr),
  caption: [Beispiel der Bedeutungsverzerrung des `brute-force` Algorithmus.],
  label: <gegegenbeispiel>,
  kind: raw,
  grid-styles: (c) => {
    set grid(
      align: top,
      gutter: 1em
    )
    c
  }
)


Leider verkompliziert diese Anforderung die Bewertung potentieller Algorithmen deutlich. 
Das hat mehrere Gründe: 

*1. Absicht ist nicht eindeutig.*
Ziel der Spezifikation einer Programmiersprache ist es, die Bedeutung eines Textes eindeutig festzulegen.
Dabei definiert die Syntax, welche Texte wohlgeformte Programme darstellen, während die Semantik diesen syntaktischen Strukturen eine Bedeutung zuordnet @aho_compiler_2008.
Anders ausgedrückt bedeutet eine invalide Syntax oder die Verletzung semantischer Regeln nichts anderes, als dass die Bedeutung des Textes nicht mehr eindeutig interpretiert werden kann.
Die Absicht eines Textes mit invalider Syntax oder fehlerhafter Semantik ist also per Definition nicht eindeutig für den Compiler oder Interpreter interpretierbar. 
Natürlich gibt es Fälle, in denen man Absicht z.B. aus dem Kontext des Textes mit hoher Sicherheit rekonstruieren kann. 
In @rekonstruierbare_absicht ist relativ offensichtlich, dass hier ein Zeilenumbruch zu viel reingerutscht ist. 
Fehlt uns der Kontext, wie in @nicht_rekonstruierbare_absicht, erscheint auch die Variante, dass hier der Ausdruck hinter dem Gleichzeichen vergessen wurde, wahrscheinlicher. 
Die Absicht einer Änderung, die invaliden Text erzeugt, lässt sich also nicht eindeutig bestimmen#footnote[Das gleiche gilt streng genommen auch für validen Text: Auch die Absicht hinter einer formal korrekten Änderung, muss nicht immer ihrer tatsächlichen Wirkung entsprechen. So entstehen Software-Bugs. Im Unterschied zum invaliden Text, ist hier aber die Wirkung durch die Spezifikation der Programmiersprache im besten Fall exakt definiert. Da wir nicht die Gedanken der Schreiberlinge lesen können, müssen wir davon ausgehen, dass die Wirkung eines valides Programms auch ihre Absicht wiederspiegelt.].\
*2. Absichtsbewahrung ist nicht eindeutig.*
Selbst wenn man sich auf die Absicht einer Änderungsmenge einigen könnte, ist die absichtsbewahrende Ausgabe nicht eindeutig.
Als Beispiel können wir @mehrdeutige_absichtsbewahrung betrachten. 
Hier ist die Absicht der Einfüge-Änderungen so deutlich, dass man der Versuchung widerstehen muss, einfach die `()`-Klammern hinter `len` zu ergänzen. 
Aber wir können hier nur Änderungen aussortieren und versuchen, auf diesem Wege die Änderungsmenge validen Code erzeugen zu lassen.
Dabei müssen wir jetzt entscheiden, welche Lösung die Absicht von @mehrdeutige_absichtsbewahrung am besten bewahrt. \
Wir könnten "`/ values.len`" entfernen und so zwar die Funktionsemantik verändern, aber den Rückgabe-Typ beibehalten. 
Eine andere Variante wäre, den Funktionsaufruf zu entfernen. Sobald die Funktion nicht aufgerufen wird, wird ihr Inhalt von Typst nämlich nicht validiert.
Oder gibt man lieber gar nichts zurück, weil die Absicht dieses Code-Abschnitts gar nicht bewahrt werden kann?
Auch die Absichtsbewahrung ist also nicht eindeutig.\

In der Folge sorgt das dafür, dass die Erfüllung der Anforderungen nicht mehr rein maschinell prüfbar ist.
/*
*3. Die Erfüllung der Anforderungen ist nicht mehr rein maschinell prüfbar.*
Uns ist kein Algorithmus bekannt, der validieren kann ob die Absicht hinter einer Änderung gewahrt bleibt. Hätten wir einen solchen Algorithmus, bräuchten wir einen solchen Algorithmus auch nicht mehr entwickeln.\
*/
\
#subpar.grid(
  figure(```typst
#let bestes-tier =
"Wombat" 
```, caption: [Hier ist die Absicht aufgrund des Kontextes der Textbedeutung relativ deutlich zu erkennen.]), <rekonstruierbare_absicht>,
  figure(
````typst
#let variable = 
"Dies ist Text" 
````
    , caption: [
      Fehlt Kontext, ist die Absichtserkennung weniger eindeutig.
    ]), <nicht_rekonstruierbare_absicht>,
  columns: (1fr, 1fr),
  caption: [Beispiele zur Absichtserkennung. Beide Beispiele sind invalider Typst-Code, da hinter dem Gleichzeichen ein Ausdruck erwartet wird.],
  label: <absichtserkennung>,
  kind: raw,
  grid-styles: (c) => {
set grid(
  align: top,
  gutter: 1em,
)
c
  }
)

\
#figure(
```typst
#let durchschnitt = (values) => {
  values.sum() / values.len
}

#durchschnitt((5, 10))
```,
caption: [Invalider Typst-Code, da die Länge eines Arrays kein Datenfeld ist, `values.len` müsste ein Funktionsaufruf sein. Hier lässt sich die Absicht mit großer Sicherheit bestimmen. Trotzdem bleibt unklar, wie man sie am besten bewahrt.]
) <mehrdeutige_absichtsbewahrung>

=== Irgendwer muss entscheiden, was richtig ist (ich muss nicht!)

Damit hatten wir nun ein etwas unangenehmeres Problem. Ob ein Ergebnis kompiliert, kann Typst für uns entscheiden. Ob dabei die Absicht hinter einer Änderung sinnvoll erhalten bleibt, können wir dagegen nicht einfach automatisch prüfen.

Für die Prüfung der Anforderung müssen wir also manuell definieren, ob eine Ausgabe zur Eingabe passt.

Dafür haben wir eine Bibliothek von Beispielen definiert.
Jedes Beispiel besteht aus dem validen Ausgangstext und Änderungen von zwei Kollaborierenden.
Mögliche Änderungen sind Einfügungen und Löschungen.
Um von einem Kollaborationsalgorithmus zu abstrahieren, der die Änderungen sortiert, wird die Ordnung der Änderungen schon bei der Erstellung des Beispiels mit angegeben.
Damit konnten wir verschiedene Konfliktszenarien konstruieren.

Zu jedem der Beispiele haben wir außerdem eine mögliche Lösung angegeben, die die Absicht der Änderungen bewahren würde. \
So haben wir eine Bibliothek von Testfällen und können Metriken definieren, mit deren Hilfe wir verschiedene Algorithmen bewerten können. 

Für die Erstellung der Testfälle nutzen wir eine mithilfe von KI-Tools erstellte Webanwendung, die es uns erlaubt, über Indizes und Änderungsreihenfolgen zu abstrahieren und uns auf die semantische Bedeutung der Testfälle zu konzentrieren #footnote[Live-Version der Webanwendung: #link("https://cpc-testsuite.k8s.draculente.eu/")] #footnote[Quellcode der Webanwendung: #link("https://git.mylab.th-luebeck.de/malte.fischer/cpc-testsuite/")]. 


#note[Die aktuellste Version der Testsuite, die wir zur Bewertung der Algorithmen genutzt haben, ist unter diesem Link zu finden: https://git.mylab.th-luebeck.de/malte.fischer/cpc-algos-malte/-/raw/main/testsuite.json.]

//#todo[Beispiele zeigen?]

=== Notes to future selves

Für die Testsuite haben wir je Beispiel eine korrekte Antwort definiert. 
Wie oben beschrieben, ist das für die meisten Beispiele aber nicht die einzige Lösung. 
Die Testsuite sollte also nicht auf eine Lösung je Beispiel beschränkt sein, sondern die Möglichkeit bieten, eine Lösungsmenge zu definieren. 

Außerdem ist die von uns genutzte Testsuite ohne Systematik auf Basis unserer persönlichen Meinungen entstanden. 
Hier sollte nachgebessert werden. 
Die Testsuite könnte zum Beispiel von User-Tests profitieren. 