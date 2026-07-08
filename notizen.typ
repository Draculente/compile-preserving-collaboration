= Notizen

== Ideen für coole Editor-Funktionen
- Statistiken
  - Z.B. wie viele Grafiken hast du? Wie viele Unterübschriften? Was ist deine tiefste Überschrift?
  - Auch zu Zitationen: Wen hast du am häufigsten zitiert?
- Zitations HeatMap
  - Ein kleiner Streifen am Rand, der anzeigt, wie viele Zitationen im jeweiligen Textabschnitt sind
- Ein "restlicher Platz"-Zähler
  - Du hast sind 7.2 von 8 beschrieben
  - Wenn man Seitenbegrenzungen hat und Dinge verschiebt muss man dann nicht immer runter scrollen

== Ideen für Optimierung
- Statt bei commits jeden Draft-Buchstaben einzeln zu committen, generieren wir uns für alle lokalen Änderungen bis zu einem Commit eine SessionID, die wir dann mit nur einer einzelnen Operation committen können. Nach dem Commit nutzen wir dann eine neue Session ID
  - Was ist, wenn eine Person draftet, eine andere das comitted, aber deren Operation länger bis zu Person A braucht? Die schreibt weiterhin Drafts mit der gleichen Id, die dann auch alle comitted werden, obwohl sie das vielleicht gar nicht sollten -> stattdessen eine Liste aller zu comittenden Buchstaben in einer Operation?
  - Ähnliches könnte bei Änderungsvorschlägen funktionieren, dort ist das oben beschriebene Verhalten vielleicht auch erwünscht
