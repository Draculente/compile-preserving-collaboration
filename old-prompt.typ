

Guten Morgen! Ich möchte eine Testsuite für verteilte Änderungen in einem noch zu entwickelnden kollaborativen System machen. Dafür soll folgendes passieren: Der Nutzer schreibt einen Ausgangstext. Dann wechselt er zu Editor 1 namens Alice und macht Änderungen an dem Ausgangstext. Danach wechselt er zu Editor 2 namens Bob und macht andere Änderungen am gleichen Ausgangstext. 

Die beiden bearbeiteten texte, werden mithilfe der bibliothek diff_match_patch von Google verglichen, um ein Set an Änderungen zu generieren. 

Danach kann der Nutzer auf der rechten Seite manuell eine korrekt zusammengeführte variante des textes schreiben. Dazu steht dort zunächst der ausgangstext und der nutzer kann durch anklicken der vorher generierten änderungen diese einzeln übernehmen. Außerdem kann er das textfeld auch manuell verändern. Danach wird ein weiteres diff-set berechnet und zwar zwischen dem vom nutzer erstellten output text und dem ausgangstext, auf den vorher alle generierten änderungen angwandt worden sind. 

Die Webseite soll in Typescript und Vue mithilfe von Tailwind geschrieben sein. Beschränke dich auf die relevanten Komponenten und den relevanten code; Dinge wie ein package.json müssen nicht geschrieben werden - ich setze die Applikation später selbst zusammen.

Das Layout soll wie folgt aussehen: 

// siehe Bild

Die Testfälle sollen als JSON exportiert und importiert werden können. Dieses soll das folgende Format haben: 

```ts
type Index = number;

interface TestSuite {
  version: 1,
  testcases: TestCaseV1[]
}

interface TestCaseV1 {
  id: string,
  name?: string,
  input: Input,
  output: Output
}

interface Input {
  current_text: string;
  incoming_changes: Change[];
}

interface Output {
  new_text: string,
  draft_changes: Change[]
}

type Change = Deletion | Insertion

interface Deletion {
  user: string;
  type: "deletion",
  from: Index,
  backwards: number
}

interface Insertion {
  user: string;
  type: "insertion",
  from: Index,
  text: string,
}
```

Das gleiche Format soll auch genutzt werden um eine bestehende Test-Suite JSON zu importieren und weiter zu bearbeiten. 

So funktioniert die Diff_match_patch Bibliothek:
Initialization

The first step is to create a new diff_match_patch object. This object contains various properties which set the behaviour of the algorithms, as well as the following methods/functions:
diff_main(text1, text2) → diffs

An array of differences is computed which describe the transformation of text1 into text2. Each difference is an array (JavaScript, Lua) or tuple (Python) or Diff object (C++, C#, Objective C, Java). The first element specifies if it is an insertion (1), a deletion (-1) or an equality (0). The second element specifies the affected text.

diff_main("Good dog", "Bad dog") → [(-1, "Goo"), (1, "Ba"), (0, "d dog")]

Despite the large number of optimisations used in this function, diff can take a while to compute. The diff_match_patch.Diff_Timeout property is available to set how many seconds any diff's exploration phase may take. The default value is 1.0. A value of 0 disables the timeout and lets diff run until completion. Should diff timeout, the return value will still be a valid difference, though probably non-optimal.
diff_cleanupSemantic(diffs) → null

A diff of two unrelated texts can be filled with coincidental matches. For example, the diff of "mouse" and "sofas" is [(-1, "m"), (1, "s"), (0, "o"), (-1, "u"), (1, "fa"), (0, "s"), (-1, "e")]. While this is the optimum diff, it is difficult for humans to understand. Semantic cleanup rewrites the diff, expanding it into a more intelligible format. The above example would become: [(-1, "mouse"), (1, "sofas")]. If a diff is to be human-readable, it should be passed to diff_cleanupSemantic.
diff_cleanupEfficiency(diffs) → null

This function is similar to diff_cleanupSemantic, except that instead of optimising a diff to be human-readable, it optimises the diff to be efficient for machine processing. The results of both cleanup types are often the same.

The efficiency cleanup is based on the observation that a diff made up of large numbers of small diffs edits may take longer to process (in downstream applications) or take more capacity to store or transmit than a smaller number of larger diffs. The diff_match_patch.Diff_EditCost property sets what the cost of handling a new edit is in terms of handling extra characters in an existing edit. The default value is 4, which means if expanding the length of a diff by three characters can eliminate one edit, then that optimisation will reduce the total costs.
diff_levenshtein(diffs) → int

Given a diff, measure its Levenshtein distance in terms of the number of inserted, deleted or substituted characters. The minimum distance is 0 which means equality, the maximum distance is the length of the longer string.
diff_prettyHtml(diffs) → html

Takes a diff array and returns a pretty HTML sequence. This function is mainly intended as an example from which to write ones own display functions.
match_main(text, pattern, loc) → location

Given a text to search, a pattern to search for and an expected location in the text near which to find the pattern, return the location which matches closest. The function will search for the best match based on both the number of character errors between the pattern and the potential match, as well as the distance between the expected location and the potential match.

The following example is a classic dilemma. There are two potential matches, one is close to the expected location but contains a one character error, the other is far from the expected location but is exactly the pattern sought after: match_main("abc12345678901234567890abbc", "abc", 26) Which result is returned (0 or 24) is determined by the diff_match_patch.Match_Distance property. An exact letter match which is 'distance' characters away from the fuzzy location would score as a complete mismatch. For example, a distance of '0' requires the match be at the exact location specified, whereas a threshold of '1000' would require a perfect match to be within 800 characters of the expected location to be found using a 0.8 threshold (see below). The larger Match_Distance is, the slower match_main() may take to compute. This variable defaults to 1000.

Another property is diff_match_patch.Match_Threshold which determines the cut-off value for a valid match. If Match_Threshold is closer to 0, the requirements for accuracy increase. If Match_Threshold is closer to 1 then it is more likely that a match will be found. The larger Match_Threshold is, the slower match_main() may take to compute. This variable defaults to 0.5. If no match is found, the function returns -1.
patch_make(text1, text2) → patches
patch_make(diffs) → patches
patch_make(text1, diffs) → patches

Given two texts, or an already computed list of differences, return an array of patch objects. The third form (text1, diffs) is preferred, use it if you happen to have that data available, otherwise this function will compute the missing pieces.
patch_toText(patches) → text

Reduces an array of patch objects to a block of text which looks extremely similar to the standard GNU diff/patch format. This text may be stored or transmitted.
patch_fromText(text) → patches

Parses a block of text (which was presumably created by the patch_toText function) and returns an array of patch objects.
patch_apply(patches, text1) → [text2, results]

Applies a list of patches to text1. The first element of the return value is the newly patched text. The second element is an array of true/false values indicating which of the patches were successfully applied. [Note that this second element is not too useful since large patches may get broken up internally, resulting in a longer results list than the input with no way to figure out which patch succeeded or failed. A more informative API is in development.]

The previously mentioned Match_Distance and Match_Threshold properties are used to evaluate patch application on text which does not match exactly. In addition, the diff_match_patch.Patch_DeleteThreshold property determines how closely the text within a major (~64 character) delete needs to match the expected text. If Patch_DeleteThreshold is closer to 0, then the deleted text must match the expected text more closely. If Patch_DeleteThreshold is closer to 1, then the deleted text may contain anything. In most use cases Patch_DeleteThreshold should just be set to the same value as Match_Threshold.
Usage

import DiffMatchPatch from 'diff-match-patch';
 
const dmp = new DiffMatchPatch();
const diff = dmp.diff_main('dogs bark', 'cats bark');
 
// You can also use the following properties:
DiffMatchPatch.DIFF_DELETE = -1;
DiffMatchPatch.DIFF_INSERT = 1;
DiffMatchPatch.DIFF_EQUAL = 0;

== Chatties Prompt
Klar — hier ist eine deutlich präzisere, Claude-taugliche Version deines Prompts. Du kannst sie direkt kopieren:


Ich möchte eine moderne, klar strukturierte Weboberfläche für einen Test-Suite-Editor entwickeln. Die Anwendung dient dazu, Testfälle für verteilte Änderungen in einem späteren kollaborativen Text-/Code-Editor zu erstellen.

Bitte generiere dafür TypeScript- und Vue-Code mit Tailwind CSS. Nutze Vue 3 mit Composition API und `<script setup lang="ts">`. Beschränke dich auf die relevanten Komponenten, Types und Hilfsfunktionen. Erstelle kein package.json, kein Build-Setup und keine unnötige Boilerplate. Ich werde die Anwendung später selbst in ein Projekt integrieren.

Ziel der Anwendung
------------------

Der Nutzer soll mehrere Testfälle erstellen können. Jeder Testfall beschreibt folgenden Ablauf:

1. Der Nutzer schreibt einen Ausgangstext.
2. Der Nutzer wechselt den Editor mit einem Tablayout zum Tab „Alice“ und verändert dort den Ausgangstext.
3. Der Nutzer wechselt zum Editor-Tab „Bob“ und verändert dort ebenfalls denselben Ausgangstext, unabhängig von Alice.
4. Aus dem Vergleich zwischen Ausgangstext und Alice-Text sowie Ausgangstext und Bob-Text wird automatisch ein Set von Änderungen erzeugt.
5. Diese Änderungen werden in einer Liste angezeigt.
6. Auf der rechten Seite gibt es einen Output-Editor. Dort steht zunächst standardmäßig der Ausgangstext.
7. Der Nutzer kann einzelne generierte Änderungen anklicken, wodurch sie automatisch auf den Output-Text angewendet werden.
8. Zusätzlich kann der Nutzer den Output-Text frei manuell bearbeiten.
9. Aus dem Unterschied zwischen dem automatisch zusammengeführten Text und dem finalen Output-Text wird automatisch ein weiteres Diff-Set berechnet. Dieses wird als `draft_changes` gespeichert.
10. Drafts sind nicht manuell bearbeitbar. Sie werden nur angezeigt und automatisch aus dem Diff berechnet.

Technischer Kern
----------------

Verwende die Bibliothek `diff_match_patch` von Google, um Diffs zwischen Texten zu berechnen.

Es werden zwei Diffs erzeugt:

- Diff zwischen `current_text` und Alice-Text
- Diff zwischen `current_text` und Bob-Text

Aus diesen Diffs werden `Change`-Objekte generiert.

Danach wird ein automatisch zusammengeführter Text berechnet, indem alle generierten Änderungen auf den Ausgangstext angewendet werden. Der Nutzer kann davon abweichend im Output-Editor eine manuell korrigierte Variante schreiben. Aus dem Vergleich zwischen automatisch zusammengeführtem Text und manuellem Output-Text werden die `draft_changes` erzeugt.

Falls es bei der Anwendung von Änderungen zu Konflikten oder ungültigen Indizes kommt, soll die Anwendung nicht crashen. Zeige stattdessen eine kleine Warnung im UI an und markiere die betroffene Änderung visuell.

Datenformat
-----------

Die Test-Suite muss als JSON importiert und exportiert werden können. Das JSON-Format ist:

```ts
type Index = number;

interface TestSuite {
  version: 1;
  testcases: TestCaseV1[];
}

interface TestCaseV1 {
  id: string;
  name?: string;
  input: Input;
  output: Output;
}

interface Input {
  current_text: string;
  incoming_changes: Change[];
}

interface Output {
  new_text: string;
  draft_changes: Change[];
}

type Change = Deletion | Insertion;

interface Deletion {
  user: string;
  type: "deletion";
  from: Index;
  backwards: number;
}

interface Insertion {
  user: string;
  type: "insertion";
  from: Index;
  text: string;
}
```

Dieses Format soll sowohl beim Export als auch beim Import verwendet werden. Nach dem Import soll die Test-Suite weiter bearbeitet werden können.

Wichtig: Die Arbeitsversion im UI darf zusätzliche temporäre Felder enthalten, zum Beispiel `aliceText`, `bobText`, `selectedChanges`, `warnings` oder `isApplied`. Beim Export darf aber ausschließlich das oben definierte JSON-Format ausgegeben werden.

## Layout und UI

Orientiere dich am folgenden Wireframe, aber gestalte die Oberfläche moderner, sauberer und besser nutzbar.

Die Seite soll ungefähr so aufgebaut sein:

* Oberer Bereich:

  * Titel: „Test Suite Editor“
  * Button: „Upload Catalog“
  * Button: „Download Catalog“
  * Button: „Add Test Case“

  Diese Elemente müssen nicht mit exakt diesem Text versehen sein.

* Darunter eine Liste von Testfällen.

* Jeder Testfall ist eine eigene Card.

* Innerhalb jeder Testfall-Card gibt es vier Hauptbereiche nebeneinander:

1. Editor-Bereich

   * Tabs: „Text“, „Alice“, „Bob“
   * „Text“ zeigt und bearbeitet den Ausgangstext.
   * „Alice“ zeigt eine bearbeitbare Alice-Version des Ausgangstextes.
   * „Bob“ zeigt eine bearbeitbare Bob-Version des Ausgangstextes.
   * Beim Wechsel zu Alice oder Bob soll dort initial der aktuelle Ausgangstext stehen, falls noch kein eigener Text gesetzt wurde.

2. Changes-Bereich

   * Zeigt automatisch generierte Änderungen von Alice und Bob.
   * Jede Änderung zeigt:

     * User: Alice oder Bob
     * Typ: insertion oder deletion
     * Position
     * Text oder Löschlänge
   * Änderungen von Alice und Bob sollen visuell unterscheidbar sein, zum Beispiel über kleine farbige Badges.
   * Änderungen können angeklickt werden.
   * Wenn eine Änderung angeklickt wird, wird sie auf den Output-Text angewendet.
   * Bereits angewendete Änderungen sollen markiert werden.

3. Output-Bereich

   * Ein Text-Editor.
   * Standardmäßig steht dort der Ausgangstext.
   * Der Nutzer kann Änderungen per Klick übernehmen.
   * Der Nutzer kann den Text zusätzlich frei bearbeiten.

4. Drafts-Bereich

   * Zeigt automatisch berechnete `draft_changes`.
   * Drafts sind read-only.
   * Sie zeigen die Differenz zwischen automatisch zusammengeführtem Text und manuell bearbeitetem Output-Text.
   * Verwende dasselbe Change-Format wie oben.

## Design-Anforderungen

Bitte verwende Tailwind CSS und gestalte die UI modern, ruhig und übersichtlich:

* Heller Hintergrund
* Cards mit abgerundeten Ecken
* Dezente Schatten oder Borders
* Klare Spaltenstruktur
* Responsive Layout:

  * Auf großen Screens vier Spalten
  * Auf kleineren Screens untereinander
* Alice visuell eher blau
* Bob visuell eher rot
* Drafts neutral, z. B. grau/violett
* Kleine Status-Badges für Typ und User
* Buttons mit Hover States
* Textareas mit Monospace-Schrift
* Keine überladene Optik

## Komponentenstruktur

Bitte schlage eine sinnvolle Komponentenstruktur vor und gib den Code für die wichtigsten Dateien aus.

Zum Beispiel:

* `types.ts`
* `diffUtils.ts`
* `jsonUtils.ts`
* `App.vue`
* `components/TestCaseCard.vue`
* `components/EditorTabs.vue`
* `components/ChangeList.vue`
* `components/DraftList.vue`

Die genaue Struktur darfst du verbessern, solange sie übersichtlich bleibt. Du kannst gerne auch einen Pinia Store definieren, der die zentrale Datenhaltung übernimmt.

## Funktionale Anforderungen

Die Anwendung soll Folgendes können:

* Neuen Testfall hinzufügen
* Testfallnamen bearbeiten
* Ausgangstext bearbeiten
* Alice-Text bearbeiten
* Bob-Text bearbeiten
* Änderungen automatisch aus Alice/Bob berechnen
* Änderungen einzeln auf Output anwenden
* Output frei bearbeiten
* Draft-Changes automatisch berechnen
* JSON exportieren
* JSON importieren
* Importierte Testfälle weiterbearbeiten
* Fehler beim JSON-Import abfangen
* Leere oder ungültige Test-Suite-Dateien sinnvoll behandeln
* Keine externen Backend-Calls

Bitte achte besonders auf saubere TypeScript-Typisierung.

## Algorithmische Details

Nutze `diff_match_patch` für die Diff-Berechnung. Falls die exakte Abbildung von diff_match_patch-Diffs auf mein `Change`-Format mehrdeutig ist, triff eine sinnvolle, nachvollziehbare Entscheidung und kommentiere sie kurz im Code.

Behandle Indizes konsistent. Dokumentiere kurz im Code, wie `from` und `backwards` interpretiert werden.

## Gewünschtes Ergebnis

Bitte gib mir:

1. Eine kurze Erklärung der Architektur.
2. Die wichtigsten Dateien als Codeblöcke.
3. Sauberen, direkt weiterverwendbaren Vue- und TypeScript-Code.
4. Keine unnötigen Erklärungen, keine package.json, keine Installationsanleitung.
5. Fokus auf Funktionalität, saubere Struktur und eine moderne Tailwind-Oberfläche.

Initialization

The first step is to create a new diff_match_patch object. This object contains various properties which set the behaviour of the algorithms, as well as the following methods/functions:
diff_main(text1, text2) → diffs

An array of differences is computed which describe the transformation of text1 into text2. Each difference is an array (JavaScript, Lua) or tuple (Python) or Diff object (C++, C#, Objective C, Java). The first element specifies if it is an insertion (1), a deletion (-1) or an equality (0). The second element specifies the affected text.

diff_main("Good dog", "Bad dog") → [(-1, "Goo"), (1, "Ba"), (0, "d dog")]

Despite the large number of optimisations used in this function, diff can take a while to compute. The diff_match_patch.Diff_Timeout property is available to set how many seconds any diff's exploration phase may take. The default value is 1.0. A value of 0 disables the timeout and lets diff run until completion. Should diff timeout, the return value will still be a valid difference, though probably non-optimal.
diff_cleanupSemantic(diffs) → null

A diff of two unrelated texts can be filled with coincidental matches. For example, the diff of "mouse" and "sofas" is [(-1, "m"), (1, "s"), (0, "o"), (-1, "u"), (1, "fa"), (0, "s"), (-1, "e")]. While this is the optimum diff, it is difficult for humans to understand. Semantic cleanup rewrites the diff, expanding it into a more intelligible format. The above example would become: [(-1, "mouse"), (1, "sofas")]. If a diff is to be human-readable, it should be passed to diff_cleanupSemantic.
diff_cleanupEfficiency(diffs) → null

This function is similar to diff_cleanupSemantic, except that instead of optimising a diff to be human-readable, it optimises the diff to be efficient for machine processing. The results of both cleanup types are often the same.

The efficiency cleanup is based on the observation that a diff made up of large numbers of small diffs edits may take longer to process (in downstream applications) or take more capacity to store or transmit than a smaller number of larger diffs. The diff_match_patch.Diff_EditCost property sets what the cost of handling a new edit is in terms of handling extra characters in an existing edit. The default value is 4, which means if expanding the length of a diff by three characters can eliminate one edit, then that optimisation will reduce the total costs.
diff_levenshtein(diffs) → int

Given a diff, measure its Levenshtein distance in terms of the number of inserted, deleted or substituted characters. The minimum distance is 0 which means equality, the maximum distance is the length of the longer string.
diff_prettyHtml(diffs) → html

Takes a diff array and returns a pretty HTML sequence. This function is mainly intended as an example from which to write ones own display functions.
match_main(text, pattern, loc) → location

Given a text to search, a pattern to search for and an expected location in the text near which to find the pattern, return the location which matches closest. The function will search for the best match based on both the number of character errors between the pattern and the potential match, as well as the distance between the expected location and the potential match.

The following example is a classic dilemma. There are two potential matches, one is close to the expected location but contains a one character error, the other is far from the expected location but is exactly the pattern sought after: match_main("abc12345678901234567890abbc", "abc", 26) Which result is returned (0 or 24) is determined by the diff_match_patch.Match_Distance property. An exact letter match which is 'distance' characters away from the fuzzy location would score as a complete mismatch. For example, a distance of '0' requires the match be at the exact location specified, whereas a threshold of '1000' would require a perfect match to be within 800 characters of the expected location to be found using a 0.8 threshold (see below). The larger Match_Distance is, the slower match_main() may take to compute. This variable defaults to 1000.

Another property is diff_match_patch.Match_Threshold which determines the cut-off value for a valid match. If Match_Threshold is closer to 0, the requirements for accuracy increase. If Match_Threshold is closer to 1 then it is more likely that a match will be found. The larger Match_Threshold is, the slower match_main() may take to compute. This variable defaults to 0.5. If no match is found, the function returns -1.
patch_make(text1, text2) → patches
patch_make(diffs) → patches
patch_make(text1, diffs) → patches

Given two texts, or an already computed list of differences, return an array of patch objects. The third form (text1, diffs) is preferred, use it if you happen to have that data available, otherwise this function will compute the missing pieces.
patch_toText(patches) → text

Reduces an array of patch objects to a block of text which looks extremely similar to the standard GNU diff/patch format. This text may be stored or transmitted.
patch_fromText(text) → patches

Parses a block of text (which was presumably created by the patch_toText function) and returns an array of patch objects.
patch_apply(patches, text1) → [text2, results]

Applies a list of patches to text1. The first element of the return value is the newly patched text. The second element is an array of true/false values indicating which of the patches were successfully applied. [Note that this second element is not too useful since large patches may get broken up internally, resulting in a longer results list than the input with no way to figure out which patch succeeded or failed. A more informative API is in development.]

The previously mentioned Match_Distance and Match_Threshold properties are used to evaluate patch application on text which does not match exactly. In addition, the diff_match_patch.Patch_DeleteThreshold property determines how closely the text within a major (~64 character) delete needs to match the expected text. If Patch_DeleteThreshold is closer to 0, then the deleted text must match the expected text more closely. If Patch_DeleteThreshold is closer to 1, then the deleted text may contain anything. In most use cases Patch_DeleteThreshold should just be set to the same value as Match_Threshold.
Usage

import DiffMatchPatch from 'diff-match-patch';
 
const dmp = new DiffMatchPatch();
const diff = dmp.diff_main('dogs bark', 'cats bark');
 
// You can also use the following properties:
DiffMatchPatch.DIFF_DELETE = -1;
DiffMatchPatch.DIFF_INSERT = 1;
DiffMatchPatch.DIFF_EQUAL = 0;

==