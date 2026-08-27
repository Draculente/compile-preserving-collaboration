#import "../utils/lab-notes-prelude.typ": *

== Die große Hirnverknotung

/* #todo[Wir haben bisher vor allem eine Idee und sind tief in die Theorie eingebuddelt (siehe unser WissSem Paper und hier abschnitt "buddeln.typ"). Wir sehen das Problem vor lauter Ansätzen nicht mehr. Wie gehen wir weiter vor, um unsere Probleme zu lösen? Was wollen wir eigentlich erreichen? Wir gucken zurück: Wir haben unser Thema von sehr breit immer weiter eingeschränkt. Aber vielleicht denken wir immer noch zu breit? Wir setzen uns zusammen und brainstormen. Wir können unser Problem eigentlich herunterbrechen auf die Frage: Gegeben eine Menge von eingehenden Änderungen: Welche dieser Änderungen sollen angewendet werden?]

#todo[Vielleicht kriegst du hier auch die Umbenennung in CPC unter? Das hattest du in einem anderen Kapitel geschrieben, aber ich glaube, hier würde es besser passen: Aus EAR wurde letztlich #cpc (CPC). Wir vermeiden Fehler ja nicht wirklich; wir können mit den Fehlern unser Ziel verfolgen, den Zustand möglichst kompiliert zu halten.
Zumindest sollten andere Kollaborierende möglichst nicht das lokale Kompilieren unseres Dokuments ohne unser Zutun verhindern können.]

#todo[Gerne im Hinblick auf diesen text dann auch nochmal maltes testsuite anfang anpassen :), LG Sören] 

Zu diesem Zeitpunkt hatten wir eigentlich alles, was man für ein Forschungsprojekt braucht:

Eine Idee, einen Prototypen und _sehr_ viele Paper. 

Und langsam keine Ahnung mehr, was genau wir eigentlich lösen wollten.

Aus "Malte, hör auf das Typst-Dokument kaputt zu machen!" entstanden viel zu viele Anschlussfragen.

Müssen wir Änderungen schon im CRDT als Draft markieren? Müssen wir uns Syntaxbäume oder inkrementelles Parsing anschauen? Brauchen wir die semantischen Informationen zu den unterschiedlichen Abschnitten?

Alles davon wirkte irgendwie relevant und interessant. 

Zeit also, nochmal einen Schritt zurückzutreten. Was war das ursprüngliche Problem, das wir mit dieser ganzen Recherche versucht haben zu lösen?

Wir wollten den Zustand auflösen, in dem eine Korrektur eines Drafts durch einen anderen Nutzer dazu führt, dass beide Nutzenden endlos weiter als Draft schreiben. Dazu haben wir recherechiert, ob wir möglicherweise durch komplexe Verfahren zusammengehörige Codestellen erkennen können und diese zusammen kompilieren lassen.

Bisher sind wir immer wie selbstverständlich davon ausgegangen, dass die Prüfung der Kompilierfähigkeit auf der Seite passiert, auf der die Änderung generiert wird. Das ist zunächst auch naheliegend, da es Rechenleistung spart: Es müssen nur die eigenen Änderungen geprüft werden und das kann gleichzeitig mit dem sowieso notwendigen Kompilieren passieren.

Aber neben dem bereits erwähnten Problem bringt das noch weitere Schwierigkeiten mit. Denn dadurch, dass wir den Zustand der Drafts über ein CRDT synchronisieren müssen wir uns auch über deren konsistenz Gedanken machen, was nicht besonders trivial ist. 
Beispielsweise wäre ein Szenario denkbar, bei dem Nicole einen Fehler in ihrem Draft korrigiert, wodurch dieser committed wird. Durch die Natur der CRDTs können wir allerdings keine Annahme darüber treffen, in welche Reihenfolge Änderungen eintreffen. Es wäre also auch möglich, dass bei Sören der Commit eintrifft, bevor die Korrektur da ist. Dann würde hier wieder ein fehlerhafter Zustand versucht zu kompilieren -- unser ursprüngliches Problem wäre nicht gelöst.

Als wir an dieser Stelle angekommen waren, hatten wir den zweiten Schlüsselmoment: Denn viel einfacher sollte es sein, die Kompilierfähigkeit auf der Seite zu prüfen, auf der die Änderungen ankommen. Statt wie bisher Drafts und Commits zu synchronisieren, würde das vollständig lokal erfolgen. Jede am System teilnehmende Instanz könnte in den angewendeten Änderungen und Drafts divergieren.
Das einfachste Modell wäre dabei, dass wir den Dokumentenzustand in drei Versionen vorhalten: Eine Version enthält alle committeten, sowie unsere lokalen Änderungen. Eine zweite Version enthält statt unserer lokalen Änderungen die noch nicht committeten eingehenden Änderungen. Die dritte Version kombiniert die beiden vorherigen Zustände, enhält also sowohl die committeten und uncommitteten eingehenden, sowie unsere lokalen Änderungen. Die erste Version wird genutzt, um die angezeigte Dokumentenvorschau zu kompilieren. Version zwei und drei werden unabhängig voneinander versucht zu kompilieren. Kompiliert eine der Versionen, können die darin vorhandenen uncommitteten Änderungen committet werden, wenn nicht, werden sie weiterhin als Draft behandelt. Das bedeutet im Worst-Case zwei Kompilierungen mehr als bisher. 

Allerdings hat dieses Vorgehen einen zentralen Nachteil: Wir können entweder alle eingehenden Änderungen annehmen oder gar keine. Nehmen wir an, Nicole hat schlechtes Internet. Sie schreibt gerade daran, Doom in Typst zum Laufen zu bekommen, verfasst also sehr viele Funktionen. Als plötzlich ihr Internet wieder kommt, ist sie noch nicht fertig, das ganze kompiliert also nicht. Sören möchte ihr jetzt helfen und einige der bereits funktionierenden Funktionen nutzen. Das kann er allerdings nicht richtig, da alle Änderungen Nicoles als Draft bei ihm vorliegen. 

Also versuchten wir das Problem in Isolationshaft zu bringen.

Angenommen wir haben einen Zustand des Dokuments, der funktioniert. Dann kommen Änderungen von Kollaborierenden rein. Einige davon funktionieren gemeinsam; andere nicht. Manche funktionieren erst, wenn eine andere Änderung ebenfalls dabei ist.

Am Ende müssen wir eigentlich nur eine Frage beantworten: Welche der momentan vorhanden Änderungen sollen wir denn nun anwenden?

der commit eines drafts trifft vor der änderung ein, die den fehler des drafts korrigiert


Diesen zweiten Schlüsselmoment beschlossen wir mit einer weiteren Umbenennung des Projekts gebührend zu feiern. 

//Das war wesentlich weniger sexy als unsere Überlegungen zu Compilerbäumen, aber etwas an dem wir arbeiten konnten. 
// Dadurch mussten wir nicht mehr sofort verstehen, warum zwei Änderungen miteinander einen Compilerfehler erzeugen. Wir mussten nur entscheiden, welche Kombination von Änderungen einen Zustand ergibt, mit dem wir weiterarbeiten können.

// === Und dann schnitten wir das Ohr ab (Van Gogh Style)

// Mit dieser neuen Sichtweise passte auch auf einmal unser Name "Error-Avoidant-Rendering" nicht mehr besonders gut. 

Aus EAR wurde daher letztlich #cpc (CPC). Wir vermeiden Fehler ja nicht wirklich; wir können mit den Fehlern unser Ziel verfolgen, den Zustand möglichst kompiliert zu halten.

// Zumindest sollten andere Kollaborierende möglichst nicht das lokale Kompilieren unseres Dokuments ohne unser Zutun verhindern können.

// Das bedeutet auch, dass unser CRDT nicht nur "korrekten" Code enthalten muss. Die Menge der synchronisierten Änderungen kann weiterhin sämtliches Chaos enthalten, das bei Zusammenarbeit entsteht. Eine Änderung besitzt nicht unbedingt für sich allein die Eigenschaft "kompiliert"; sie kompiliert (oder eben nicht) immer in Kombination mit dem Zustand des Dokuments und anderen Änderungen.

Wir hatten unsere Problemstellung also endlich klein genug bekommen, um sie ordentlich kaputt zu spielen.

Und dafür brauchten wir Tests.



// #todo[Das ist ja sozusagen der Abschluss unserer Einleitung, jetzt kommt der wirklich inhaltliche Teil. D.h. vielleicht würden hier diese Notes to our future selves gut reinpassen:] 
*/

Zu diesem Zeitpunkt hatten wir eigentlich alles, was man für ein Forschungsprojekt braucht: eine Idee, einen Prototypen und _sehr_ viele Paper. Und langsam keine Ahnung mehr, was genau wir eigentlich lösen wollten.

Aus "Malte, hör auf, das Typst-Dokument kaputt zu machen!" waren viel zu viele Anschlussfragen entstanden. Müssen wir Änderungen schon im CRDT als Draft markieren? Müssen wir uns Syntaxbäume oder inkrementelles Parsing anschauen? Brauchen wir die semantischen Informationen zu den unterschiedlichen Abschnitten? Alles davon wirkte irgendwie relevant und interessant.

Zeit also, nochmal einen Schritt zurückzutreten: Was war das ursprüngliche Problem, das wir mit dieser ganzen Recherche zu lösen versucht haben?

Wir wollten den Zustand auflösen, in dem die Korrektur eines Drafts durch eine andere Person dazu führt, dass beide endlos weiter als Draft schreiben. Dazu hatten wir recherchiert, ob sich durch komplexe Verfahren zusammengehörige Codestellen erkennen und gemeinsam kompilieren lassen.

=== Wo prüfen wir eigentlich?

Bisher sind wir immer wie selbstverständlich davon ausgegangen, dass die Prüfung der Kompilierfähigkeit auf der Seite passiert, auf der die Änderung entsteht. Das ist zunächst auch naheliegend, weil es Rechenleistung spart: Es müssen nur die eigenen Änderungen geprüft werden, und das kann gleichzeitig mit dem sowieso notwendigen Kompilieren passieren.

Neben dem bereits erwähnten Problem bringt das aber weitere Schwierigkeiten mit sich. Denn dadurch, dass wir den Zustand der Drafts über ein CRDT synchronisieren, müssen wir uns auch über deren Konsistenz Gedanken machen -- und das ist alles andere als trivial.

Denkbar wäre etwa folgendes Szenario: Nicole korrigiert einen Fehler in ihrem Draft, wodurch dieser committet wird. Durch die Natur der CRDTs können wir allerdings keine Annahme darüber treffen, in welcher Reihenfolge Änderungen eintreffen. Es wäre also auch möglich, dass bei Sören der Commit ankommt, bevor die Korrektur da ist. Dann würde hier wieder versucht, einen fehlerhaften Zustand zu kompilieren -- unser ursprüngliches Problem wäre nicht gelöst.

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

Diesen zweiten Schlüsselmoment beschlossen wir mit einer weiteren Umbenennung des Projekts gebührend zu feiern. Aus EAR wurde daher letztlich #cpc (CPC). Wir vermeiden Fehler ja nicht wirklich -- wir verfolgen mit ihnen unser Ziel, den Zustand möglichst kompiliert zu halten.

Mit dieser Neuformulierung ist die Recherche des Survey-Paper aus dem Projekt herausgefallen. Solange wir eine Teilmenge von Änderungen suchen und ihre Gültigkeit ohnehin vom Compiler prüfen lassen, brauchen wir keine eigene Analyse, welche Codestellen sich gegenseitig beeinflussen -- der Compiler beantwortet diese Frage implizit und deutlich zuverlässiger als wir es könnten. Einzelne Teile wie das fehlertolerante Parsing könnten wir allerdings später als Heuristiken zur Auswahl der Änderungen heranziehen.

Ähnlich erging es der formalen Verifikation aus Abschnitt 5. Da wir kein eigenes CRDT mehr entwickeln, sondern Automerge nutzen, und da unsere Draft-Logik nach dem zweiten Schlüsselmoment rein lokal ist, bleibt an dieser Stelle nichts mehr zu beweisen, was Automerge nicht schon für uns bewiesen hätte.

Wir hatten unsere Problemstellung also endlich klein genug bekommen, um sie ordentlich kaputt zu spielen. Der prototypische Texteditor hatte damit vorerst seinen Zweck erfüllt. Statt uns wieder mit Indizes herumzuschlagen, beschlossen wir, die Fragestellung, die wir jetzt isoliert hatten, weiterhin nur so isoliert und herausgelöst zu betrachten. Und dafür brauchten wir Tests.

=== Notes to future selves

Wenn wir eines aus dieser frühen Projektphase mitnehmen können, dann die Erkenntnis, wie wichtig es ist, das eigentliche Problem zu isolieren.
Wir sind mit riesigen Visionen gestartet – einem komplett eigenen Editor, CRDT-Verifikation, inkrementellen Syntaxbäumen und tiefen Compiler-Eingriffen.
Das war alles spannend, hätte uns aber unweigerlich in endlose Rabbit-Holes geführt.

Die Fokussierung von CAR über EAR hin zu CPC war wichtig und richtig. Sie hat uns gezeigt, dass unsere eigentliche Herausforderung weder das fehlerfreie Synchronisieren von Zeichen ist -- das kann Automerge ohne uns -- noch die semantische Analyse von Code-Segmenten. Übrig bleibt eine einzige Frage: Welche der eingehenden Änderungen wollen wir überhaupt anwenden?

/* Für unsere zukünftige Arbeit:
Bevor wir uns in interessanten Themen verrennen, müssen wir uns fragen, ob wir eine fokussierte Problemstellung haben und es auf einer praktischen Ebene auch lösen können.
Unser Fokus soll darauf liegen, wie wir aus einem Haufen von wilden, kollaborativen Änderungen den größtmöglichen, kompilierbaren Zustand extrahieren können -- ohne dabei die Intention oder den Flow der Nutzenden zu (zer)stören. */