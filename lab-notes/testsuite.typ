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

== Testsuite

#cpc (CPC) soll es ermöglichen unabhängiger von einander an einem gemeinsamen Dokument ($d$) zu kollaborieren, dessen Inhalt einer vorgeschriebenden Syntax folgen soll. 
Insbesondere sollen Situationen vermieden werden, bei denen Änderungen anderer Personen die Syntax des Dokuments invalideren und so die Weiterverarbeitung (z.B. die Kompilation) verhindern. 
Mithilfe unseres Beispieleditors (#todo[Link]), haben wir die Frage konkretisiert: 
#quote(block: true)[_Gegeben eine Menge von eingehenden Änderungen: Welche dieser Änderungen sollen angewendet werden?_]

Wir suchen also eine Teilmenge $A$ aller eingehenden Änderungen $M$, deren Änderungen dann auf das Dokument $d$ angewendet werden ($d_"new" = d + A$).\
Um diese Frage zufriedenstellend beantworten zu können, ist es notwendig sie zu konkretisieren und unsere Erwartungen an potentielle Algorithmen zu formulieren.

Eine erste Anforderung ergibt sich direkt aus dem Ziel der CPC. 
Das Dokument, das aus der Anwendung der vom Algorithmus ausgwählten Änderungen entsteht, soll valide sein.

Außerdem fordern wir, dass der Algorithmus so viele Änderungen anwenden soll wie möglich, weil sonst der Algorithmus, der alles ablehnt, eine valide Lösung wäre. 

Diese Anforderung offenbart eine weiter Annahme, die wir implizit getroffen haben: Das Ausgangsdokument, auf das die Änderungen angewendet werden, muss valide sein. 
Sonst wäre der ablehnende Algorithmus keine korrekte Lösung. 
Im ersten Moment scheint das dem typischen Workflow zu wiedersprechen, der verbessert werden soll. 
Wenn die Vorraussetzung für den Algorithmus ein valides Dokument ist, dann schließt das alle Situationen aus, in denen der lokale Schreiberling ein invalides Dokument produziert.  Änderungen anderer nur würden nur dann angwendet, wenn das lokale Dokument valide ist.
Das Problem können wir durch einen einfachen Trick umgehen: Die Änderungsmenge ($M$) für unseren Algorithmus enthält auch die Änderungen des lokalen Schreiberlings ($L$), die damit potentiell aussortiert werden können. 
Erst im Nachhinein sorgen wir dafür, dass alle Änderungen, die der lokale Schreiberling macht, angwendet werden ($d_"new" = d + (L union A)$).

Indem wir hier lokale Änderungen explizit adressieren, wird klar, dass die Einführung unseres Algorithmus dafür sorgt, dass die Dokumente $d$ nicht mehr global auf einen Zustand konvergieren. 
Der Zustand von $d$ ist für jede Instanz anders. 
Das scheint dem Gedanken der Live-Kollaboration fundamental zu wiedersprechen. 
Tatsächlich verschiebt unser Ansatz den global konvergierenden Zustand aber nur: Die Menge aller Änderungen, die jemals in den Algorithmus eingegangen sind ($M_"ges" = M_1 union M_2...union M_n$), muss weiterhin auf allen Instanzen gleich sein. 
Nur die Präsentation dieser Änderungen als Dokument unterscheidet sich je Instanz. 

Zunächst erschienen uns Anforderungen an den Algorithmus damit genug spezifiziert. 
Der optimale Algorithmus wäre damit ein Algorithmus "`brute-force`", der alle Teilmengen $A$ ausprobiert und die größte Teilmenge auswählt, die bei Anwendung ein valides Dokument produziert. 
Die größte Herausforderung wäre dann gewesen die Ressourcen-Nutzung zu optimieren, da der optimale Algorithmus eine Laufzeitkomplexität von $2^n$ hat.

Wie der Konjunktiv vermuten lässt, haben wir schnell festgestellt, das dieser Ansatz Schwachstellen hat. 
In @gegegenbeispiel ist ein Problem des Algorithmus dargestellt. 
Gehen wir davon aus, dass die Eingabe in @a aus atomaren Einfüge-Änderungen besteht, dann ist die größte Teilmenge, die ein valides Dokument erzeugt in @b dargestellt. 
Die Bedeutung der Ausgabe entspricht offensichtlich nicht mehr der Bedeutung, die beim Schreiben der Eingabe angedacht war. 

Wir müssen also eine weitere Anforderung an unseren Algorithmus stellen. 
In Anlehnung an @sun_achieving_1998 nennen wir sie "Intention Preservation" oder "Absichtsbewahrung". 
Wir fordern also, dass der Algorithmus die Absicht hinter den Änderungen der Eingabemenge beibehält. 

\
#subpar.grid(
  figure(```typst
#let name = Noah
#name sagte:
"Wombat" 
  ```, caption: [
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
  supplement: "Listing",
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
Es ist die Aufgabe der Syntax einer Programmiersprache die Bedeutung eines Textes eindeutig festzulegen #todo[Quelle]. 
Anders ausgedrückt bedeutet eine invalide Syntax nichts anderes, als dass die Bedeutung des Textes nicht mehr eindeutig interpretiert werden kann.
Die Absicht eines Text mit invalider Syntax ist also per Definition nicht eindeutig für den Compiler oder Interpreter interpretierbar. 
Natürlich gibt es Fälle in denen man Absicht z.B. aus der Semantik mit hoher Sicherheit rekonstruieren kann. 
In @rekonstruierbare_absicht ist relativ offensichtlich, dass hier ein Zeilenumbruch zu viel reingerutscht ist. 
Fehlt uns der Kontext der Semantik, wie in @nicht_rekonstruierbare_absicht, erscheint auch die Variante, dass hier der Ausdruck hinter dem Gleichzeichen vergessen wurde, wahrscheinlicher. 
Die Absicht einer Änderung, die invaliden Text erzeugt, lässt sich also nicht eindeutig bestimmen.\
*2. Absichtsbewahrung ist nicht eindeutig.*
Selbst wenn man sich auf die Absicht einer Änderungsmenge einigen könnte, ist die absichtsbewahrende Ausgabe nicht eindeutig.
Als Beispiel können wir @mehrdeutige_absichtsbewahrung betrachten. 
Hier ist die Absicht der Einfüge-Änderungen so deutlich, dass man der Versuchung wiederstehen muss, einfach die `()`-Klammern hinter `len` zu ergänzen. 
Aber wir können hier nur Änderungen aussortieren und versuchen auf diesem Wege die Änderungsmenge validen Code erzeugen zu lassen.
Dabei müssen wir jetzt entscheiden welche Lösung die Absicht von @mehrdeutige_absichtsbewahrung am besten bewahrt. \
Wir könnten "`/ values.len`" entfernen und so zwar die Funktionsemantik verändern, aber den Rückgabe-Typ beibehalten. 
Eine andere Variante wäre, den Funktionsaufruf zu entfernen. Sobald die Funktion nicht aufgerufen wird, wird ihr Inhalt von Typst nämlich nicht validiert.
Oder gibt man lieber gar nichts zurück, weil die Absicht dieses Code-Abschnitts kann gar nicht bewahrt werden kann?
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
  ```, caption: [Hier ist die Absicht aufgrund der Semantik relativ deutlich zu erkennen.]), <rekonstruierbare_absicht>,
  figure(
  ```typst
#let variable = 
"Dies ist Text" 
  ```
    , caption: [
      Fehlt Kontext, ist die Absichtserkennung weniger eindeutig.
    ]), <nicht_rekonstruierbare_absicht>,
  columns: (1fr, 1fr),
  caption: [Beispiele zur Absichtserkennung. Beide Beispiele sind invalider Typst-Code, da hinter dem Gleichzeichen ein Ausdruck erwartet wird.],
  label: <absichtserkennung>,
  supplement: "Listing",
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
caption: [Invalider Typst-Code, die Länge eines Arrays ist kein Datenfeld, `values.len` müsste ein Funktionsaufruf sein. Hier lässt sich die Absicht mit großer Sicherheit bestimmen. Trotzdem bleibt unklar wie man sie am besten bewahrt.]
) <mehrdeutige_absichtsbewahrung>

