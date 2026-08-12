#import "../utils/lab-notes-prelude.typ": *

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
Das Problem können wir durch einen einfachen Trick umgehen: Die Änderungsmenge ($M$) für unseren Algorithmus enthält auch die Änderungen des lokalen Schreiberlings ($L$). 
Erst im Nachhinein sorgen wir dafür, dass alle Änderungen, die der lokale Schreiberling macht, angwendet werden ($d_"new" = d + (L union A)$).

Indem wir hier lokale Änderungen explizit adressieren, wird klar, dass die Einführung unseres Algorithmus dafür sorgt, dass die Dokumente $d$ nicht mehr global auf einen Zustand konvergieren. 
Der Zustand von $d$ ist für jede Instanz anders. 
Das scheint dem Gedanken der Live-Kollaboration fundamental zu wiedersprechen. 
Tatsächlich verschiebt unser Ansatz den global konvergierenden Zustand aber nur: Die Menge aller Änderungen, die jemals auf das Dokument angewendet wurden, muss weiterhin auf allen Instanzen gleich sein. 
Nur die Präsentation dieser Änderungen als Dokument unterscheidet sich je Instanz. 

Zunächst erschienen uns Anforderungen an den Algorithmus damit genug spezifiziert. 
Der optimale Algorithmus wäre damit ein Algorithmus, der alle Teilmengen $A$ ausprobiert und die größte Teilmenge auswählt, die bei Anwendung ein valides Dokument produziert. 
Die größte Herausforderung wäre dann gewesen die Ressourcen-Nutzung zu optimieren, da der optimale Algorithmus eine Laufzeitkomplexität von $2^n$ hat.

#todo[Gegenbeispiel]