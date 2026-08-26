#import "@preview/note-me:0.6.0"

#set text(lang: "de")
#show link: it => underline[#it]

#note-me.note[
Idee dieses Texts: jedes Kapitel agiert quasi als eigener Blogeintrag, heißt, dass wir in jedem Kapitel noch einmal vorangegangenes erklären / in einem Satz zusammenfassen, oder einfach komplett unabhängig schreiben. Inspo sind die Lab Notes von InkAndSwitch, die in ein Dokument -- einem Book -- zusammegefasst werden (https://www.inkandswitch.com/patchwork/notebook/2024-version-control/). Die Perspektive sollte ein bisschen sein, dass wir die Notes sozusagen immer direkt nach einem Teilabschnitt geschrieben haben (d.h. nicht zu viel aus der Zukunft schon zusammenkondensiert -> Das wäre ja sonst wieder ein normales Paper).
]
https://git.mylab.th-luebeck.de/malte.fischer/cpc-testsuite/
= Gliederung

_Unter jedem Kapitel ein Absatz: "Notes to future selves"_

#set enum(start:0)
+ Bemerkung zur Form des Berichts
+ Kapitel: Die Ideenfindung
  #set enum(start: 1)
  + Kapitel: Literaturrecherche
  + Kapitel: 10 weitere Ideen
  + Kapitel: CPC (oder CAR, oder EAR)
+ Kapitel: Wissem-Paper
+ Kapitel: Beispieleditor 
+ Kapitel: Testsuite 
+ Kapitel: Algorithmen
+ Kapitel: Notes to Future selves compiled

#set enum(start: 1)

== Kapitel: Ideenfindung
- Ausgangspunkt CRDTs
- Recherche
  - Verifikation
  - Compiler-Krams
- Welche Themen haben wir uns angeguckt, um zu entscheiden, was wir machen wollen?
  - Einblick in Compilerbau usw.   
== Kapitel CPC (oder CAR, oder EAR)
- was ist das genaue Problem, das CPC lösen könnte

== Kapitel Beispieleditor
- Probleme des gemeinsamen Schreibens
- local-first Ansätze
- aka: AHH! das ist alles kompliziert und komplex zugleich
- Definition der Fragestellung: Wir haben eine Menge von Änderungen: Welche wenden wir auf unser Dokument an?
- CRTDs sind doof, aber auch cool

== Kapitel: Testsuite
- Verfeinerung der Fragestellung durch Anforderungen / Einschränkungen
- erwartetes Verhalten kann unter Nutzenden unterschiedlich sein
- allerdings müssen wir uns ja irgendwie annähern an eine Lösung

== Kapitel Algorithmen
- Brute Force funktioniert viel zu gut
- andere Heuristiken?
- Probleme der Algorithmen vs. unsere definierten Tests
- ML außen vorgelassen (kann man vllt. schon einmal kurz erwähnen)
- was haben die Algos tatsächlich gebracht?
  - da könnten wir nette Ergebnisgrafiken einfließen lassen

== Kapitel Notes to Future Selves Compiled
- alle notes to future selves einmal zusammengefasst, so als schneller Überblick

== Weitere Ideen
- Als HTML-Dokument abgeben? Bzw. als ZIP Datei? Dann könnte man eine kleine Website mit Videos machen -> Keine Ahnung, ob man Videos braucht, aber das hab ich gerade bei InkAndSwitch gesehen xD

= Entwicklung der Algorithmen



== Note for future selves
Wir haben erst recht spät festgestellt, dass wir den Algrithmus aufteilen können in:
+ Aufteilung der Änderungen
+ Auswahl der Änderungen

#pagebreak()
#outline()
#pagebreak()

#counter(page).update(1)
#set page(numbering: "1")
#counter(heading).update(0)


#set heading(numbering: "1.")
#set heading(numbering: (..nums) => {
  let nums = nums.pos()
  if nums.len() == 1 {
    ""
  } else {
    numbering("1.1", ..nums.slice(1))
  }
})

= CRDTs, C#strike[K]ollaboration und Compiler: Lab-Notizen unseres wissenschaftlichen Projekts

#let chapters = (
  "lab-notes/leeres-blatt.typ",
  "lab-notes/die-grundlagen.typ",
  "lab-notes/verifikation.typ",
  "lab-notes/vernuenftig_kollaborieren.typ",
  "lab-notes/beispieleditor.typ",
  "lab-notes/testsuite.typ",
  "lab-notes/algorithmen.typ",
  "lab-notes/notes-to-future-selves-compiled.typ",
)

// Erstmal extra, weil noch nicht sicher, ob das anders formatiert werden soll, weil es Meta ist
#include "lab-notes/first-note.typ"

#for chapter in chapters {
  include chapter
}

#bibliography("zotero.bib")