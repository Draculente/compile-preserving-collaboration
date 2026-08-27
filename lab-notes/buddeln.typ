#import "../utils/lab-notes-prelude.typ": *

== Wir buddeln tiefer

Wir haben einen Editor! Aber als wir da zu mehreren drin herumgetippt haben, ist uns ziemlich schnell ein relativ großes Problem in unserem Konzept aufgefallen:

Angenommen, Sören tippt den Fehler:

```typst
#let best_animal = "wombat
```

Dann kompiliert das Dokument bei ihm lokal nicht mehr (alles ab dem `=` ist kein gültiger Code) und seine Änderung wird bei Jan als Draft markiert. Wenn Jan dann Sörens Fehler korrigiert, indem er einfach ein Anführungszeichen hinzufügt, dann wird Sörens Änderung als Draft nicht in die Prüfung der Kompilierfähigkeit bei Jan einbezogen. Für diese Prüfung steht dort also

```typst
#let best_animal = "
```

was ebenfalls kein gültiger Code ist. Auch Jans Änderung würde so nicht kompilieren und als Draft markiert werden. An sich ist das die gewünschte Funktionsweise. Das Problem ist allerdings, dass dieser Zustand im aktuellen Modell nicht mehr aufgelöst werden könnte: Sowohl bei Jan als auch bei Sören werden die "rettenden" Zeichen nie in die Prüfung der Kompilierfähigkeit einbezogen, sodass auch alle zukünftigen Änderungen als Draft geschehen würden.

Ungefähr zu der Zeit, zu der wir unseren Editor schreiben, sind Sören und Nicole auch auf der Suche nach einem Thema für das Survey-Paper, das sie im Rahmen des Wissenschaftlichen Seminars schreiben müssen. Dieses Problem bietet sich dafür geradezu an -- denn eine mögliche Lösung dafür könnte es sein, zu erkennen, wann Code-Stellen zusammengehören und diese gemeinsam als Draft zu betrachten, deren Kompilierung also gemeinsam zu prüfen. Das würde es sogar ermöglichen, dass, wenn gemeinsam an einer spezifischen Codestelle gearbeitet wird, auch Kompilierungsfehler bei allen bearbeitenden Parteien angezeigt werden.

Das Survey-Paper beschäftigte sich also mit der Frage, wie Beeinflussungen zwischen Codestellen erkannt werden können. Diese können in drei verschiedene Ebenen eingeteilt werden: textuelle, syntaktische und semantische Beeinflussung.

Textuelle Beeinflussungen liegen vor, wenn zwei Änderungen dieselben oder benachbarte Zeilen betreffen und daher eine besondere Behandlung benötigen, um zusammengeführt werden zu können @einbrodt_towards_2026. Dafür eignen sich beispielsweise CRDTs, die wir ja bereits einsetzen. Interessanter sind für uns daher die syntaktische und semantische Ebene.

Syntaktische Beeinflussungen beziehen sich auf die strukturelle Integrität des Programms. Eine Änderung beeinflusst eine andere syntaktisch, wenn sie zusammengehörige Konstrukte -- etwa Klammerpaare oder Anweisungsblöcke -- in einer Art und Weise verändert, die zu syntaktischen Fehlern führt. Diff-Verfahren wie GumTree @falleri_fine-grained_2024 nutzen abstrakte Syntaxbäume (ASTs), um Änderungen auf dieser Ebene zu erfassen @einbrodt_towards_2026. Um diese zu erstellen, kann beispielsweise inkrementelles, fehlertolerantes Parsing, wie es etwa TreeSitter implementiert, genutzt werden. Dabei kann auch Source Code, der Fehler enthält, geparsed werden. An den Stellen, an denen Fehler vorhanden sind, werden explizite Fehlerknoten in den Baum eingefügt. So kann der Fehler später auch im Quellcode genau isoliert werden @treesitter_autoren_tree-sittertree-sitter_nodate.

Semantische Beeinflussungen liegen vor, wenn zwei Änderungen textuell und syntaktisch unabhängig sind, aber in einer logischen Abhängigkeit stehen. Solche Abhängigkeiten entstehen durch Typen, Signaturen, Kontrollflüsse oder Datenflüsse @ferrante_program_1987: Ändert etwa eine Entwicklerin den Namen einer Methode, ist potentiell jede Aufrufstelle dieser Methode betroffen -- unabhängig davon, wie weit entfernt im Text diese Stellen liegen.

Semantische Beeinflussungen können dazu führen, dass Code selbst nach einem textuell und syntaktisch konfliktfreien Merge nicht mehr kompilierbar ist oder unerwartetes Verhalten zur Laufzeit zeigt @jesus_detecting_2023. Verfahren wie Program Slicing, Abhängigkeitsgraphen und Change Impact Analysis können für die Erkennung von Beeinflussungen auf dieser Ebene verwendet werden.

An dieser Stelle beschäftigten wir uns auch nochmal mit unserem Namen. Conflict-Avoidant-Rendering schien uns nicht mehr passend: Wir nutzen Beeinflussungen inzwischen, um zusammengehörige Codestellen zu erkennen -- vermeiden tun wir sie nicht. Aus CAR wurde deshalb Error-Avoidant-Rendering (EAR).

=== Notes to future selves

In diesem Fall war es schon ein wenig mitgeplant, weil wir aufgrund der getrennten Bewertung ein etwas separates Thema für das Wissenschaftliche Seminar brauchten, aber prinzipiell sollte man sich ein wenig mehr Gedanken darüber machen, ob man ein Thema, in das man viel Recherchearbeit steckt, auch wirklich für ein Projekt braucht.