= Wichtige Funktionen

- Syntaktische Korrektheit des Codes so oft wie möglich garantieren
  - "Malte baut krass komplizierte Funktion, weshalb Typst nicht kompiliert. Gleichzeitig will Sören eine hübsche Grafik basteln, kann die aber nie sehen, weil Malte Fehler macht."
  - Vielleicht reicht auch schon Branching?
    - Sören stellt sich einfach auf offline und schon kompiliert sein Code
  - Siehe @freudenthaler_characters_2025
    - Hier wird anscheinend nur eine Operation übertragen, wenn eine korrekte Syntax vorhanden ist
      - Was ist UX-technisch am klügsten?
        - nur valide ASTs übertragen, um den Compiler glücklich zu halten?
        - immer alles schnellsmöglich übertragen für schnelles Feedback?
        - alle n Sekunden übertragen?
        - Oder man überträgt immer alles (auch falschen Code, so ein bisschen wie bei AI Vorschlägen) aber es wird erst "committed", wenn der Code syntaktisch korrekt ist
            - siehe @adams_grove_2025
  - Bei Änderungsvorschläge gelöschte Chars nicht mehr anzeigen oder zwei Version des Dokuments maintainen (eins um es dem Nutzer anzuzeigen und eins zum Kompilieren)
- Auflösen von Mergekonflikten
  - Wenn wir Branches implementieren wollen, kann es zu größeren Problemen wie gleichen Variablennamen kommen. Gibt es Lösungen, wie man damit umgehen kann?
- Undo/Redo
  - Was ist erwartetes Verhalten?
    - siehe @stewen_undo_2024
- Änderungsvorschläge
  - Könnte man direkt aus den Operationen des Operationsgraphen heraus generieren? Es müsste nur klar sein, wann etwas ein Vorschlag ist (oder wir könnten einfach alles immer zu Vorschlägen machen? Funktioniert das?)
- Kommentare
  - Auch Teil des normalen CRDTs. Haben dann zwei Parents als Beginn und Ende. Außerdem wird jede dazugehörige Operation markiert als Vorschlag
     - Könnte UX-mäßig interessant sein, das Live-Tippen bei Kommentaren zu sehen
- History replays
- Wer war was? Character-Level Blame
- Performance
  - Char Level Blame vs Speichergröße
  - Egwalker? siehe @gentle_collaborative_2025

= Random Notizen
- Ist ein Interleaving-Verhaltensvergleich als Paper schon vorhanden, oder wäre das auch interessant?
  - Sören sagt: @weidner_art_2025
#image("Screenshot 2026-04-16 at 15.09.47.png", width: 60%)
- kann man die Reihenfolge der Cursors fürs Interleaving als Tie-Breaker nutzen?
- SWE-Frage: Lohnt es sich vielleicht, ein Rohtext-Format vom UI interpretieren zu lassen, um unabhängig vom gewählten CRDT-Algorithmus und der Implementierung zu bleiben?
- Move-Operationen sind ein ungelöstes Problem
  - es kann zu doppelten Einträgen kommen
- Automerge benchmarken?


#bibliography("../refs.bib", full: true)



