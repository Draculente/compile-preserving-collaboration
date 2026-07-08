#title[Dev-Log]

#outline(indent: auto)

= Treffen vom 27.03.2026

*Treffen?* \
alle 2 Wochen \
Freitags 12 Uhr

*Ideen zum Vorgehen im Semester*

- Mini-Papers mit kleinen Teilproblemen
- Anfangsthemen
  - Gibt es CRDTs für Code
    - Wie Änderungsvorschläge aussehen müssten
  - Anforderungen
    - Axiome $->$ Test-Suite
    - Axiome ggf. weiterentwickeln
  - "theoretische" Verifikation wie in AlgoVeri
    - LEAN-Solver?
    - LLMs können formalisieren, man kann LLM-Ergebnisse auch so prüfen?
    - Ideen sammeln, was man verifizieren sollte
  - Editor bauen:
    - Ink and Switch Forschungsgruppe
      - Branching
      - Kollaboration
      - Reversibilität
      - Attribution (Wer hat was gemacht?)

Formalia zur Prüfungsleistung klärt Sebastian bis zum nächsten Mal

*TO-DOs für die nächsten Wochen*

- Literaturrecherche

#pagebreak()

= Ziele für Treffen am 17.04.2026

- Gibt es CRDTs für Code?
  - Abstract Syntax Trees
  - Freudenthaler anschreiben wegen seiner Diss?
  - Wie bekommt man es hin syntaktisch korrekten 
- Änderungsvorschläge
  - In Text-CRDTs
  - Gibt es das sonst irgendwo?
- Kommentare
  - Wie können Kommentare in Text-CRDTs integriert werden?
- Welche Ansätze gibt es um CRDTs zu validieren?
  - Welche Eigenschaften muss man validieren?
    - Assoziativität
    - Kommutativität
    - Idempotenz
- Wozu ???
- In Welcher Syntax lässt sich Kollaboration (Kommentare, Vorschläge) valide in eine Programmiersprache

*Wir teilen uns zur Recherche auf in zwei Gruppen:*
- Validation: Nicole & Malte
- AST/Code-CRDTs: Sören & Jan

= Treffen vom 17.04.2026

Beim Treffen haben wir eine Roadmap erarbeitet:
+ Anforderungen erarbeiten/definieren
  - Paper lesen
  - Survey Paper schreiben??
    - Was haben andere schon drum herum erforscht?
    - Freudenthaler's Dissertation: nachfragen, ob der die rausgeben kann
  - Was ist der konsistente State?
  - Was muss ins CRDT und was nicht? *hier fragen: was machen wir mit dem Rest der Zeit*
    - Muss man ein hochintegriertes CRDT implementieren?
      - Gibt es einfach erweiterbare CRDTs?
    - Könnte man eine Art Markup machen, das über das CRDT transparent verarbeitet wird und nur von der Applikation interpretiert wird?
+ Formale Anforderungen definieren
  - Formale Tools vergleichen und eins auswählen
    - propel
    - tla+
    - lean?
    - Andreas fragen?

#pagebreak()

= Research Log vom 24.4.2026

// Idee: Peer-Changes, die evtl. Fehler enthalten werden vorerst als "Pending Changes" angezeigt und nicht "committed".
#let car = [Confict-avoidant Rendering]

// Definition: Red-Green Trees sind eine spezialisierte Datenstruktur für Syntaxbäume in modernen Compilern, die durch die strikte Trennung in unveränderliche, wiederverwendbare grüne Knoten (ohne Elternverweise) und bedarfsweise erzeugte, navigierbare rote Knoten (mit Kontext und Position) sowohl extreme Speichereffizienz als auch performantes inkrementelles Parsing ermöglichen.
#let rgt = [Red-Green-Tree]

- Malte erklärt Compiler
- Nicole recherchiert zu Typst-Compilation
  - stolpert über Red-Green-Trees
  - klingt interessant für #car
- Jan vermutet, dass es in der Praxis einfacher gehen könnte (Simple #car)
  - Idee: Typst-Compiler abwarten, ob er im Watch-Mode Fehler sieht; verhindert #highlight[Denial of Service] durch Malte
    - wenn nicht: super
    - wenn doch: Änderungen nur als "Pending" markiert teilen
- Wir wollen einen Prototypen konstruieren, mit dem wir Hypothesen wie die zu #rgt\s und Simple #car ausprobieren können

*$=>$* Erst nach der Evalutation des Prototyps werden wir uns darauf einigen, ob wir das Thema #car wissenschaftlich tiefer verfolgen möchten.

*Mögliche Outcomes:*
- Wir finden Simple-#car so toll, dass wir das noch tiefer behandeln und richtig krass optimieren wollen
- Wir finden Probleme mit Simple-#car und gucken uns dann nochmal #rgt\s an
- #car funktioniert super und wir wenden uns dem nächsten Thema zu

= Treffen am 08.05.2026

- Wir haben einen Prototypen/eine Spielwiese mit Automerge implementiert, um Dinge testen zu können
- Jan hat in `paper-ideen.typ` Ideen für wissenschaftliche Paper und Erklär-Paper aufgeschrieben und kategorisiert
  - Dopplungen mit den Ideen vom Anfang

= Treffen am 22.05.2026

// Idee: Peer-Changes, die evtl. Fehler enthalten werden vorerst als "Pending Changes" angezeigt und nicht "committed".
#let ear = [Error-avoidant Rendering]

- #car wird zu #ear
- Prototyp hat jetzt basic "Draft"-Feature, zum nicht-Rendern bestimmter Code-Bereiche
- Ziel bis in drei Wochen:
  - Renderer reparieren
  - automatisch Insert/Delete-Ops als Drafts markieren, wenn Compiler/Parser meckert
- Frage:
  - Was passiert, wenn mehr als 1 Personen an einem Änderungsblock arbeiten, oder 2 Änderungsblocke sich überlappen?
    - entweder können die nicht überlappen (ggf. zu einem mergen)
    - oder (problematisch): >1 separate, überlappende, sich beeinflussende Änderungsvorschläge, die zusammen vielleicht sogar funktionieren, aber nicht einzeln, und so nie automatisch einzeln vom Compiler akzeptiert werden können.
      - muss evtl manuell passieren?

#pagebreak()

= Treffen am 19.06.2026

- Präsentation des Zwischenergebnisses
  - Nur kompilierende Änderungen werden tatsächlich als Text übertragen & mitkompiliert, der Rest ist Draft
  - Probleme mit separaten Änderungen analysieren
- Sören erwähnt
  - COAST (CRDT + AST)
  - Program slicing
- Was sind Ansätze, um *gemeinsame* Änderungen aud dem Draft-State zusammenzuführen
  - Wer probiert die Drafts ($O(2^n)$)?
    - erst alle, dann einen raus (alle nacheinander probieren), dann zwei ...
  - Wie werden wessen Drafts gemeinsam ausprobiert?
- Nicole und Sören suchen Ansätze
  - Sebastian sagt, _praxistaugliche_ Lösungen zu suchen
