== E-Mail an Sebastian

Moin Sebastian,

Hier einmal unsere groben Notizen, um dir eine Idee vom Thema zu geben.
Da könnte man sich dann raussuchen, worauf man sich fokussiert.

Die grundsätzliche Idee ist, aufbauend auf Sörens Bachelorarbeit ein fertigeres Produkt (Arbeitstitel: “Typst Pro Max Ultra Plus” / “SciDocs” / “CollabPDF”) zu entwickeln. Teil davon könnte sein:

- Andere Ansätze der CRDT-Änderungsvorschläge aus Sörens BA zu evaluieren
    - Hierfür könnte eine umfangreichere Anforderungsdefinition erarbeitet werden
- Ein stabiles und effizientes CRDT entwickeln, das diese Anforderungen erfüllt
    - Da könnte man einen Fokus auf verteilte Systeme aus Sicht der theoretischen Informatik legen (Modellierung, Verifikation, Komplexität, Effizienz & Optimierungen)
- bidirektionale Änderungsvorschläge / Kommentare (das war nur so eine Idee, muss nicht)
  - Ein Änderungsvorschlag im PDF taucht im Quellcode auf und andersherum
  - Mapping-Algorithmen oder -Methoden zwischen Quelltext und PDF-Kompilat entwickeln/vergleichen
- Versionskontrolle
  - Attribution
  - Versionshistorie
  - Darauf aufbauende experimentelle Editierungs-Konzepte wie Branching ausprobieren
- Integration von CRDTs und einem Dateisystem für Bilder, Imports, ...

Das alles reicht wahrscheinlich noch bis zum Teil 2 im Wintersemester ;-) Man könnte z.B., im Sommer die Grundlagen mit dem stabilen CRDT und Experimenten zu bidirektionalen Kommentaren zu legen und das im Winter dann zu einem Produkt zusammenzuführen, bei dem dann auch verschiedene Nutzungskonzepte ausprobiert werden könnten.

Hier ist der Link zum Modul-Handbuch:
https://pubdoc.th-luebeck.de/a3d98eccd3

Viele Grüße
Malte, Nicole, Sören & Jan
