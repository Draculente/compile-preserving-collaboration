#import "../utils/lab-notes-prelude.typ": *

== Die große Hirnverknotung

Zu diesem Zeitpunkt hatten wir eigentlich alles, was man für ein Forschungsprojekt braucht: eine Idee, einen Prototypen und _sehr_ viele Paper. Und langsam keine Ahnung mehr, was genau wir eigentlich lösen wollten.

Aus "Malte, hör auf, das Typst-Dokument kaputt zu machen!" waren viel zu viele Anschlussfragen entstanden. Müssen wir Änderungen schon im CRDT als Draft markieren? Müssen wir uns Syntaxbäume oder inkrementelles Parsing anschauen? Brauchen wir semantische Informationen? Alles davon wirkte irgendwie relevant und interessant.

Zeit also, nochmal einen Schritt zurückzutreten: Was war das ursprüngliche Problem, das wir mit dieser ganzen Recherche zu lösen versucht haben?

Wir wollten den Zustand auflösen, in dem die Korrektur eines Drafts durch eine andere Person dazu führt, dass beide endlos weiter als Draft schreiben. Dazu hatten wir recherchiert, ob sich durch komplexe Verfahren zusammengehörige Codestellen erkennen und gemeinsam kompilieren lassen.

=== Wo prüfen wir eigentlich?

Bisher sind wir immer wie selbstverständlich davon ausgegangen, dass die Prüfung der Kompilierfähigkeit auf der Seite passiert, auf der die Änderung entsteht. Das ist zunächst auch naheliegend, weil es Rechenleistung spart: Es müssen nur die eigenen Änderungen geprüft werden, und das kann gleichzeitig mit dem sowieso notwendigen Kompilieren passieren.

Neben dem bereits erwähnten Problem bringt das aber weitere Schwierigkeiten mit sich. Denn dadurch, dass wir den Zustand der Drafts über ein CRDT synchronisieren, müssen wir uns auch über deren Konsistenz Gedanken machen -- und das ist alles andere als trivial.

Denkbar wäre etwa folgendes Szenario: Nicole korrigiert einen Fehler in ihrem Draft, wodurch dieser committet wird. Durch die Natur der CRDTs können wir allerdings keine Annahme darüber treffen, in welcher Reihenfolge Änderungen bei den anderen Teilnehmenden eintreffen. Es wäre also auch möglich, dass bei Sören der Commit ankommt, bevor die Korrektur da ist. Dann würde hier wieder versucht, einen fehlerhaften Zustand zu kompilieren.

=== Der zweite Schlüsselmoment

Als wir an dieser Stelle angekommen waren, hatten wir den zweiten Schlüsselmoment: Viel einfacher sollte es sein, die Kompilierfähigkeit auf der Seite zu prüfen, auf der die Änderungen ankommen. Draft-Status und Commits müssten dann gar nicht mehr synchronisiert werden, sondern wären eine rein lokale Angelegenheit. Jede am System teilnehmende Instanz dürfte in den angewendeten Änderungen und Drafts divergieren.

Das einfachste Modell dafür ist, den Dokumentenzustand in drei Versionen vorzuhalten:

+ alle committeten Änderungen sowie unsere lokalen Änderungen,
+ alle committeten Änderungen sowie die noch nicht committeten eingehenden Änderungen,
+ die Kombination aus beidem, also committete und uncommittete eingehende sowie unsere lokalen Änderungen.

Die erste Version wird genutzt, um die angezeigte Dokumentenvorschau zu kompilieren. Für Version zwei und drei wird unabhängig voneinander versucht zu kompilieren. Klappt das bei einer der beiden, können die darin enthaltenen uncommitteten Änderungen committet werden; wenn nicht, werden sie weiterhin als Draft behandelt. Das bedeutet im Worst Case zwei Kompilierungen mehr als bisher.

=== Alles oder nichts

Allerdings hat dieses Vorgehen einen zentralen Nachteil: Wir können entweder alle eingehenden Änderungen annehmen oder gar keine.

Nehmen wir an, Nicole hat schlechtes Internet. Sie schreibt gerade daran, Doom in Typst zum Laufen zu bekommen, verfasst also sehr viele Funktionen. Als ihr Internet plötzlich wiederkommt, ist sie noch nicht fertig, das Ganze kompiliert also nicht. Sören möchte ihr jetzt helfen und einige der bereits funktionierenden Funktionen nutzen. Das kann er aber nicht, weil sämtliche Änderungen Nicoles bei ihm als Draft vorliegen.

Also versuchten wir, das Problem in Isolationshaft zu bringen. Angenommen, wir haben einen Zustand des Dokuments, der funktioniert. Dann kommen Änderungen von Kollaborierenden rein. Einige davon funktionieren gemeinsam, andere nicht. Manche funktionieren erst, wenn eine bestimmte andere Änderung ebenfalls dabei ist.

Am Ende müssen wir eigentlich nur eine Frage beantworten: Welche der momentan vorhandenen Änderungen sollen wir denn nun anwenden?

Diesen zweiten Schlüsselmoment beschlossen wir, mit einer weiteren Umbenennung des Projekts gebührend zu feiern. Aus EAR wurde daher letztlich #cpc (CPC). Wir vermeiden Fehler ja nicht wirklich -- wir verfolgen mit ihnen unser Ziel, den Zustand möglichst kompilierbar zu halten.

Mit dieser Neuformulierung ist die Recherche des Survey-Papers aus dem Projekt herausgefallen. Solange wir eine Teilmenge von Änderungen suchen und ihre Gültigkeit ohnehin vom Compiler prüfen lassen, brauchen wir keine eigene Analyse, welche Codestellen sich gegenseitig beeinflussen -- der Compiler beantwortet diese Frage implizit und deutlich zuverlässiger als wir es könnten. Einzelne Teile wie das fehlertolerante Parsing und Syntaxbäume könnten wir allerdings später als Heuristiken zur Auswahl der Änderungen heranziehen.

Ähnlich erging es der formalen Verifikation aus Abschnitt 5. Da wir kein eigenes CRDT mehr entwickeln, sondern Automerge nutzen, und da unsere Draft-Logik jetzt rein lokal ist, bleibt an dieser Stelle nichts mehr zu beweisen, was Automerge nicht schon für uns bewiesen hätte.

Wir hatten unsere Problemstellung also endlich klein genug bekommen, um sie ordentlich kaputt zu spielen. Der prototypische Texteditor hatte damit vorerst seinen Zweck erfüllt. Statt uns wieder mit Indizes herumzuschlagen, beschlossen wir, die Fragestellung, die wir jetzt isoliert hatten, auch weiterhin nur isoliert und herausgelöst zu betrachten. Und dafür brauchten wir Tests.

=== Notes to future selves

Wenn wir eines aus dieser frühen Projektphase mitnehmen können, dann die Erkenntnis, wie wichtig es ist, das eigentliche Problem zu isolieren.
Wir sind mit riesigen Visionen gestartet – einem komplett eigenen Editor, CRDT-Verifikation, inkrementellen Syntaxbäumen und tiefen Compiler-Eingriffen.
Das war alles spannend, hätte uns aber unweigerlich in endlose Rabbit-Holes geführt.

// Die Fokussierung von CAR über EAR hin zu CPC war wichtig und richtig. Sie hat uns gezeigt, dass unsere eigentliche Herausforderung weder das fehlerfreie Synchronisieren von Zeichen ist -- das kann Automerge ohne uns -- noch die semantische Analyse von Code-Segmenten. Übrig bleibt eine einzige Frage: Welche der eingehenden Änderungen wollen wir überhaupt anwenden?