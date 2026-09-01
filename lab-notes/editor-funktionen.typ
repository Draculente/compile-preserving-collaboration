#import "../utils/lab-notes-prelude.typ": *
== Unsere Wunschfunktionen
Während wir uns in die Grundlagen der Textkollaboration einlasen (siehe @kap:grundlagen), notierten wir uns Ideen für Funktionen, die unser Wunsch-Texteditor enthalten sollte. Ideen, aus denen wir uns später ein Teilgebiet heraussuchen konnten.

*Undo und Redo* klingen erstmal ziemlich simpel. Als wir uns da ein wenig eingelesen haben, wurde aber klar: In einer kollaborativen Umgebung weiß man nicht mal genau, was Nutzende überhaupt erwarten, wenn sie die Tastenkombination drücken: Wird die letzte eigene Änderung rückgängig gemacht, oder die letzte Änderung im Dokument, egal von wem sie kam? Und was passiert, wenn jemand anderes die Stelle inzwischen weiterbearbeitet hat? Bevor man hier irgendetwas implementiert, muss man sich also erst auf das gewünschte Verhalten festlegen. Zu dieser Frage gibt es Vorarbeit @stewen_undo_2024.

Mit *Änderungsvorschlägen* meinen wir das, was man aus Google Docs oder Word kennt: Man schreibt in ein fremdes Dokument, der Vorschlag ist für alle sichtbar, wird aber erst dann Teil des eigentlichen Dokuments, wenn jemand sie annimmt.

Dazu hat Sören in seiner Bachelorarbeit @fischer_live-kommentare_2025 schon gearbeitet. Wir könnten das fortführen oder einen anderen Ansatz ausprobieren: Man könnte einen Vorschlag direkt aus den Änderungen der Änderungsmenge heraus generieren.

Auch bei *Kommentaren* könnte man sowas ausprobieren: Sie könnten ebenfalls Teil des normalen CRDTs sein. Ein Kommentar hätte dann zwei Parents, jeweils für Anfang und Ende der kommentierten Stelle, sodass er an den Zeichen hängt und nicht an einer Position im Text -- was auch dann noch funktioniert, wenn davor jemand einen Absatz einfügt. Im Endeffekt wären die Zeichen des Kommentars also Teil des ganz normalen Textflusses, sie hätten nur eine spezielle Markierung. Das könnte auch UX-mäßig interessant sein: Man sieht dann Kommentaren live beim Tippen zu.

Zwei weitere Ideen drehen sich darum, den Verlauf eines Dokuments sichtbar zu machen: *History Replays*, also das Abspielen der Entstehung eines Dokuments, und die Frage, wer eigentlich was geschrieben hat. Im Prinzip so etwas wie *Git-Blame*, allerdings auf Zeichen- statt auf Zeilenebene.

Beides ist vor allem eine Performance-Frage. Die Information ist in den Änderungen prinzipiell vorhanden. Allerdings optimieren viele CRDTs sie mit der Zeit heraus, um Speicherplatz zu sparen. Für diese Art von Problem wäre Egwalker @gentle_collaborative_2025 ein Ansatz, den wir uns anschauen müssten.