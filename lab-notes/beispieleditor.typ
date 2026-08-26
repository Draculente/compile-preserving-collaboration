#import "../utils/lab-notes-prelude.typ": *

== Beispieleditor <kap:beispieleditor>

#todo[
  Wir basteln uns eine Spielwiese und müssen uns dafür entscheiden: Entwickeln wir nun unser eigenes CRDT oder machen nutzen wir ein bereits existierendes?
]

=== Funktionen eines Editors

Während wir uns in die Grundlagen der Textkollaboration einlasen (siehe @kap:grundlagen), notierten wir uns Ideen für Funktionen, die unser Wunsch-Texteditor enthalten sollte. Ideen, aus denen wir uns später ein Teilgebiet heraussuchen konnten.
Wir haben uns darauf beschränkt, einen Typst-Editor ähnlich zu Typst-App untersuchen zu wollen.

#todo[Hier Rechercheergebnisse zu möglichen Funktionen ergänzen]

- Kollaboration für eine Markup-Sprache (Typst) in Echtzeit und Konvergenz bei verzögerter Synchronisation
  - ermöglicht über Text-Synchronisation eines CRDTs
  - gelöstes Problem (z.B. Automerge)
- Kommentare an Text-Bereiche anheften (eine Spanne von Buchstabe n zu Buchstabe m)
  - gelöstes Problem (z.B. Automerge#footnote[#link("https://automerge.org/docs/cookbook/rich-text-prosemirror-vanilla/")], Peritext#footnote[#link("https://www.inkandswitch.com/peritext/")])
- Änderungsvorschläge an Text-Bereiche anheften, die von Kollaborierenden akzeptiert werden können
  - gelöstes Problem (z.B. Automerge)
- Branching von einem Zustand, um ungestört von anderen und ohne andere zu stören schreiben und Dinge ausprobieren zu können
- *Änderungen am Text, die (von anderen) synchronisiert wurden, zunächst als Vorschlag betrachten und nicht mitkompilieren*

=== CRDT: Eigenbau oder Automerge?

#todo[tippen]

=== Erkenntnisse aus dem Beispieleditor

#todo[tippen]

=== Notes to future selves

#todo[Raum für Notizen als Fließtext]
