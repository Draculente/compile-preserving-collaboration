#import "../utils/lab-notes-prelude.typ": *

== Probieren geht über studieren <kap:beispieleditor>

CAR soll es also sein. Nichtkompilierende Änderungen sollen als solche markiert und nicht in die Kompilierung der Vorschau einbezogen werden.

Ein paar Probleme, auf die wir dabei stoßen könnten, konnten wir uns schon vorstellen. Über den Fluss von Änderungen in einem verteilten System nachzudenken ist ohnehin komplex genug und wenn ein Teil dieser Änderungen gar nicht wirklich angewendet wird, macht das die Sache nicht einfacher.

Wie also finden wir die ganz praktischen Probleme, die CAR mit sich bringen kann? Richtig: Wir probieren es #strike[einfach] aus.

Dazu brauchen wir einen kollaborativen Texteditor mit einer ersten Implementierung von CAR. Der besteht aus zwei Komponenten: einem CRDT, das sich um die korrekte Zusammenführung kollaborativer Änderungen kümmert, und einem Frontend, in das man tatsächlich Text eingeben kann.

Das Frontend war schnell gefunden; wir haben uns für das Editorframework CodeMirror#footnote[https://codemirror.net/] entschieden, da dieses ziemlich flexibel zu erweitern ist.

Vor ein schwierigeres Problem stellte uns die Auswahl eines CRDTs. Einfache Textkollaboration unterstützen viele Frameworks, wir brauchen aber mehr:

- Änderungen müssen überhaupt als Draft markierbar sein.
- Draft-Einfügungen müssen in den lokalen Editor-Zustand übernommen werden, nicht aber in den Text, der kompiliert wird.
- Draft-Löschungen dürfen nicht einmal im lokalen Editor-Zustand angewendet, sondern lediglich gesondert hervorgehoben werden.
- Die Draft-Markierung muss sich wieder entfernen lassen, wenn der Zustand kompiliert.

Wir hatten schon im Rahmen des Einlesens in CRDTs angefangen, ein kleines eigenes CRDT zu implementieren, um das Thema vollständig zu durchdringen. Es lag also zunächst nahe, einfach dieses zu erweitern. Trivial ist das allerdings nicht:

- Zum einen müssen die Änderungen an sich erst einmal annotierbar gestaltet werden.
- Dann müssen neue Änderungsarten eingeführt werden. Diese beziehen sich nun nicht mehr ausschließlich auf das Hinzufügen und Löschen von Zeichen, sondern auch auf deren Draft-Zustand -- und müssten selbstverständlich ebenfalls kommutativ und idempotent sein.
- Dazu kommt die Komplexität der Anbindung an einen Texteditor. Es werden zahlreiche Hilfsmethoden notwendig, um etwa zwischen Indizes und internen IDs zu übersetzen (Indizes: ein notorisch schweres Problem) oder die Draft-Textranges gesondert abrufen zu können.

Wir schauten uns also erst einmal nach Alternativen um. Und tatsächlich fanden wir ein bereits existierendes CRDT, das geeignet war und noch dazu eine fertige Anbindung an den CodeMirror-Editor mitbringt: Automerge#footnote[https://automerge.org/].
Automerge setzt nicht auf eine direkte Annotation von Änderungen oder Zeichen, sondern nutzt eine Idee des theoretischen Peritext-Modells @litt_peritext_2022: 
Ranges von Text werden mithilfe eines zweiten CRDTs mit beliebigen Annotationen versehen. Genau das, was wir brauchen.

Wir entschieden uns also für die Nutzung von Automerge. Um Änderungen wie gewünscht annotieren zu können, führen wir zwei sogenannte `marks` ein:
Solange unser lokaler Dokumentenzustand nicht kompiliert#footnote[Wie können wir feststellen, ob unser Code kompiliert? Wir haben es uns erstmal einfach gemacht, indem wir nur Typst betrachten, dessen Kompilierung in den meisten Fällen extrem schnell funktioniert -- wir können also einfach kompilieren und schauen, was dabei herauskommt.
Bei aufwendigeren Compilern wäre das keine Option.
Dort ließen sich aber Kniffe aus dem Bau von Sprachservern übernehmen (siehe z.B. https://clangd.llvm.org/design/ oder https://github.com/rust-lang/rust-analyzer), bei denen meist nur das Compiler-Frontend genutzt wird, während die Code-Generierung und das Linking im Backend entfallen.
Dasselbe Prinzip ist in vielen Toolchains auch als eigenes Kommando verfügbar, z.B. `cargo check`. Das ist deutlich schneller und deckt den Großteil der Kompilierfehler ab, ist aber keine Garantie, da manche Fehler erst bei der Codegenerierung oder beim Linken auftreten.], markieren wir unsere lokalen Einfügungen mit dem `mark` `draft-insert` und unsere Löschungen mit dem `mark` `draft-deletion`.
Die Löschungen werden dabei nicht tatsächlich durchgeführt.#footnote[Das ist mit CodeMirror gar nicht so leicht darzustellen. Hier mussten wir länger herumprobieren, bis wir es hinbekommen haben, das Lösch-Event abzufangen und nicht im Editor-Zustand anzuwenden.]

Sobald der lokale Zustand wieder kompiliert, werden die `marks` entfernt (wir nennen das einen "commit").
Bei `draft-insert`-Markierungen muss dabei nichts weiter gemacht werden, weil wir den Text ja bereits eingefügt hatten.
Wird die Markierung dagegen von den Löschungen entfernt, muss diese Löschung jeweils noch tatsächlich durchgeführt werden.

Der erwähnte "lokale Zustand" ist im Übrigen zweigeteilt:

- Zur Überprüfung der Kompilierfähigkeit sowie zur Kompilierung selbst werden alle bereits committeten Änderungen sowie die eigenen Draft-Änderungen herangezogen.
- Zur Anzeige im Texteditor kommen zusätzlich die Draft-Änderungen der anderen Instanzen dazu.

So haben wir tatsächlich eine erste "funktionale" Version von CAR implementiert: Wir können den Editor in zwei oder mehr Instanzen im lokalen Netz öffnen.
Wenn in der einen Instanz getippt wird, erscheinen die Änderungen in den anderen Instanzen.
Wird ein Fehler getippt, werden die Änderungen bei den anderen als Draft angezeigt und nicht in die Kompilierung einbezogen.

"Funktional" ist hier übrigens in Anführungszeichen gesetzt, weil zwar die beschriebene Funktionalität vorhanden ist, sich aber schnell -- wie wir es uns erhofft hatten -- konzeptionelle Probleme zeigten, die es noch zu lösen galt.

=== Notes to future selves

Indizes sind böse! Sie machen alles nur schlimmer.
Idee: Texteditor ohne Indizes entwickeln.



