#import "@preview/clean-acmart:0.0.1": acmart
#import "@preview/glossy:0.9.2": *
#import "utils/todo.typ": *

#show: init-glossary.with(yaml("glossary.yaml"))

#let comment(..any) = highlight(..any)


#let title = [
  Compile-Preserving Collaboration
]
#let authors = (
  (
    name: [Nicole Einbrodt],
    email: [nicole.einbrodt\@stud.th-luebeck.de],
  ),
  (
    name: [Malte Fischer],
    email: [malte.fischer\@stud.th-luebeck.de],
  ),
  (
    name: [Sören Fischer],
    email: [soeren.fischer\@stud.th-luebeck.de],
  ),
  (
    name: [Jan Hopp],
    email: [jan.hopp\@stud.th-luebeck.de],
  ),
)

#show: acmart.with(
  title: text(
    lang: "de",
    size: 14pt,
    title
  ),
  authors: authors,
  copyright: none,
)
#set text(lang: "en")

/*Examples:
Input device:
Baudisch et al. (2006). Soap: A pointing device that works in mid‐air.
http://dx.doi.org/10.1145/1166253.1166261
System:
Dixon et al. (2010). Prefab: Implementing advanced behaviors using
pixel‐based reverse… http://dx.doi.org/10.1145/1753326.1753554
Hardware Toolkit:
Greenberg et al. (2001). Phidgets: Easy development of physical
interfaces through physical widgets. http://dx.doi.org/
10.1145/502348.502388
Input Technique:
Grossman et al. (2005). The Bubble Cursor: Enhancing target
acquisition by dynamic resizing of the cursor’s… http://dx.doi.org/
10.1145/1054972.1055012
Envisionment:
Ishii et al. (1997). Tangible bits: Towards seamless interfaces between
people, bits… http://dx.doi.org/10.1145/258549.258715
Wobbrock, J. O., & Kientz, J. A. (2016). Research contributions in human-computer interaction. interactions, 23(3), 38-44.*/
/*
*Artefakt* \
Artifact contributions arise from Generative Design-driven Activities (Invention).
- Artifacts, often prototypes, include:
  - new systems
  - architectures
  - tools
  - toolkits
  - techniques
  - sketches
  - mockups
  - envisionments
- that:
  - reveal new possibilities
  - enable new explorations
  - facilitate new insights
  - compel us to consider new possible futures
*/

/* ABSTRACT
+ Eingrenzung des Forschungsbereichs (In welchem Themengebiet ist die Arbeit angesiedelt? Wie ist das Verhältnis zum Thema der Konferenz/des Journals?)
+ Beschreibung des Problems, das in dieser Arbeit gelöst werden soll (Was ist das Problem, und warum ist es wichtig, es zu lösen?)
+ Mängel an existierenden Arbeiten bzgl. des Problems (Warum ist es ein Problem, obwohl sich schon andere mit dem gleichen Thema beschäftigt haben?)
+ Eigener Lösungsansatz (Welcher Ansatz wurde in dieser Arbeit verwendet, um das Problem zu lösen? Was ist der Beitrag dieses Artikels?)
+ Art der Validierung + Ergebnisse (Wie wurde nachgewiesen, dass die Arbeit die versprochenen Verbesserung wirklich vollbringt (Fallstudie, Experiment, o.ä.); Was waren die Ergebnisse der Validierung (idealerweise Prozentsatz der Verbesserung)?)
*/
= Abstract
- in einem Satz das Problem nennen
  - kollab Editoren können den kompilierbaren Zustand für alle kaputt machen
- vorschlag:
    - stattdessen pending changes, sodass immer ein möglichst kompilierbarer Zustand vorhanden ist
- hat's funktioniert? ja, nein, vielleicht? wenn ja wie gut / schlecht?

= Einleitung // Was ist das Problem, das es zu lösen gilt?
- motivation!
- wenn mehrere Menschen zusammen programmieren, dann
  - kann es durch netzwerkproblem zu konflikten kommen -- gelöst wird dies mit OT oder mit CRDTs
- kollab. schreiben mit typst (oder anderen programmiersprachen)
  - spezielles problem da rendern
- eine änderung kann das gesamte dokument zum nicht-rendern führen, obwohl Personen an unabhängigen Stellen arbeiten
- warum reicht crtd nicht? / die standard anwendung von crtds?
  - vllt crdts auch komplett raus lassen? Wie genau die Synchronisation funktioniert, ist ja erstmal egal?
    - Andererseits nutzen wir ja einen operationsbasierten Ansatz, der schon eher auf CRDTs ausgelegt ist 
- forschungsfragen / probleme
- überblick über das Paper
  - was haben wir für eine lösung?
  - welche zusätzlichen beiträge haben wir? haben wir zusätzliche beiträge?
   - vermutlich evaluation (vllt performance o.ä.)

== Motivation
Kollaborative Systeme, etwa gemeinsame Editoren oder Versionskontrollsysteme, müssen parallele Änderungen koordinieren.
Alle Beteiligten erwarten, denselben Zustand zu sehen oder später zu demselben Zustand zu konvergieren.
Bei der gleichzeitigen Bearbeitung von Quellcode in Echtzeit entsteht dabei eine Herausforderung, die über die Koordination von Textoperationen hinausgeht.

Ein konkretes Beispiel:
Alice strukturiert eine Funktion um. Während dieser Änderung befindet sich ihr Code in einem Zwischenzustand -- er kann nicht geparst werden und kompiliert damit auch nicht.
Da Echtzeit-Kollaborationssysteme Änderungen unmittelbar übertragen, ist auch Bobs lokaler Build sofort betroffen, obwohl der Code, an dem er gerade arbeitet, von Alice Änderung unabhängig und vollständig korrekt ist.

Das ist besonders bei Systemen mit kurzen Build-Zyklen, etwa bei Markup-Sprachen wie Typst oder bei der Entwicklung von Benutzeroberflächen, bei denen Änderungen meist sofort überprüft werden, problematisch.

Das eigentliche Ziel, das wir als @cpc bezeichnen, ist es, genau diesen Zustand zu verhindern: Codestellen, die voneinander unabhängig sind, sollen im Fehlerfall auch getrennt behandelt werden können. 
Bob soll nicht Alices Fehler sehen, Alice soll allerdings ihre eigenen sehen. 
Dafür muss das System verstehen, wann die Änderung einer Entwicklerin eine andere Code-Stelle so beeinflusst, dass sie gemeinsam betrachtet werden müssen, und wann beide Stellen unabhängig voneinander sind.

== Gegenstand dieser Arbeit
Am Beispiel der Markup-Sprache Typst entwickeln wir in diesem Paper eine prototpyische Applikation, um @cpc umzusetzen und zu evaluieren.
Dafür überprüfen wir unterschiedliche Ansätze (vllt 2; Jans Brute Force und ein viel zu komplexer, er sicherlich nicht besser sein wird) hinsichtlich ihrer #todo[Metriken definieren] (z.B. zeitliche Performanz, Robustheit, Erkennungsrate...).

   
= Literaturrecherche / Related Work
- Siehe Nicoles und Sörens Paper
- vllt. auch nochmal kollab echtzeit-editoren?
- crtds und automerge?
  - local first?
- typst
- ast? da vllt. das aus unserem paper?
- forschungslücke

Bestehende Arbeiten lösen jeweils Teilprobleme aus der Echtzeitbearbeitung und der automatisierten Integration von Änderungen. Während Synchronisationsverfahren hauptsächlich die Konvergenz der verteilten Dokumentzustände sicherstellen, betrachten strukturbezogene Verfahren die syntaktische oder semantische Korrektheit zusammengeführter Änderungen. Nur wenige Arbeiten untersuchen jedoch explizit, wie während der gemeinsamen Bearbeitung ein möglichst kompilierbarer Zustand erhalten werden kann. In dieser Arbeit soll diese Lücke untersucht werden.

== Synchronisation kollaborativ bearbeiteter Dokumente

Die technische Grundlage vieler kollaborativer Editoren bilden Operational Transformation (OT) oder Conflict-free Replicated Data Types (CRDTs). Beide Ansätze ermöglichen es, gleichzeitig ausgeführte Änderungen so zu verarbeiten, dass die beteiligten Instanzen schließlich zum gleichen Dokumentzustand konvergieren. CRDTs modellieren dafür Datentypen und Operationen, deren parallele Anwendung ohne eine zentrale Konfliktauflösung zu einem deterministischen Ergebnis führt #cite(<shapiro_conflict-free_2011>).

Die Konvergenz eines Dokuments sagt jedoch nichts darüber aus, ob der resultierende Inhalt syntaktisch valide oder kompilierbar ist. Ein CRDT kann zuverlässig sicherstellen, dass alle Instanzen denselben Text sehen, selbst wenn dieser Text einen unvollständigen Ausdruck, eine fehlende Klammer oder eine anderweitig fehlerhafte Änderung enthält. Die Erhaltung eines kompilierbaren Zustands stellt daher eine zusätzliche Herausforderung dar, die nicht nur durch das verwendete Synchronisationsverfahren gelöst werden kann.

== Beeinflussungsanalyse

In einer vorausgehenden Bestandsaufnahme wurden textuelle, syntaktische und semantische Verfahren zur Erkennung von Beeinflussungen zwischen Code-Stellen untersucht #cite(<einbrodt_towards_2026>). 
Die Analyse zeigt, dass textuelle Verfahren schnell und fehlertolerant sind, aber nur lokale Überschneidungen erfassen. Syntaxbasierte Verfahren können strukturelle Zusammenhänge präziser erkennen, während semantische Verfahren auch räumlich entfernte Abhängigkeiten berücksichtigen.
Letztere sind für die fortlaufende Analyse während des Editierens jedoch häufig zu aufwändig und setzen weitgehend vollständigen Code voraus.

Die Bestandsaufnahme schlägt daher einen hybriden Ansatz vor, bei dem zunächst schnelle textuelle oder syntaktische Informationen genutzt und aufwändigere Analysen nur für unklare Fälle durchgeführt werden. 

In der Mark-Up Sprache Typst können Änderungen normalerweise unmittelbar in einer Dokumentvorschau sichtbar gemacht werden. Gleichzeitig können syntaktische oder semantische Fehler die Erzeugung dieser Vorschau verhindern, wodurch sich Typst für die Untersuchung von @cpc eignet.

Die betrachteten Arbeiten liefern damit Grundlagen, behandeln jedoch nicht gemeinsam die konkrete Kombination aus textbasierter Echtzeitsynchronisation, sichtbar bleibenden fehlerhaften Drafts und einem automatisch aktualisierten, kompilierbaren Typst-Zustand. An dieser Stelle setzt diese Arbeit mit einem prototypischen System an.

= #todo[Lösung / Konzept und Implementierung / Prototyp / Umsetzung / Ansatz]

- den prototypen beschreiben

== Anforderungen an kollaborative Programmierlösungen
- vllt. die ziele? #comment[Ich glaub das gehört vor die Resultate - Jan]
  - committed state möglichst kompilierbar
  - drafts handhaben
  - wann sind änderungen zusammengehörig, wann nicht?

  
- was ist das zu erwartende verhalten bei änderungen?
- wie funktioniert unser ear / car / whatever system?
- vllt. einmal den gesamtablauf erklären
  - join
  - edit
    - delete + add
    - draft
    - committed
  - leave

= Evaluation // Ergebnisse?
- verschiedene anwendungsfälle / szenarien durchgehen?
- haben wir nette metriken? was ist sinnvoll zu erheben?
- wo funktioniert unser ansatz nicht?

= Diskussion
- trade-offs diskutieren
  - also limitationen usw.
- ggf. performance

= Zusammenfassung
- problem nochmal zusammenfassen
- lösung zusammenfassen (falls wir es gelöst haben)
- was sind unsere wichtigsten ergebnisse?
- was sind unsere einschränkungen?
- netten abschlusssatz 

= Zukünftige Arbeiten
- was können wir in dem bereich zusätzlich noch tun?
  - ux
  - nutzendenstudien grr
- weitere konfliktstrategien
- kann man die performance noch verbessern?

#bibliography("zotero.bib")

/* = Abstract

In this paper we analyze ...
We do not take into consideration ...
We have found several gaps in the current state of research ...

= Introduction

Conflict-free Replicated Data-Types (CRDTs) allow for simultaneous changes on shared state in a distributed system.
The properties of such CRDTs have been examined and verified in several papers.
We seek to find similarities, differences , as well as possible gaps in the verification tooling, methods, and process.

= Literature overview
One key problem described in several scientific contributions is the occurence of differing data states in CRDT implementations #cite(<zhu_crust_2025>) #cite(<zhang_model-checking-driven_2024>).

To combat the error-proneness of CRTD implementations, a few different frameworks and testing suites have been suggested. 

"Crust" - for instance - is a framework coded in Rust to enhance the development experience of implementing CRTDs by providing tools that allow testing and performance evaluations #cite(<zhu_crust_2025>). It offers five modules that cover the handling of "data structures, operations and synchronization settings" #cite(<zhu_crust_2025>), configurations (e.g. for Kubernetes), network communication, validations and benchmarking #cite(<zhu_crust_2025>). To ensure correctness, they chose a mathematical approach using sets for different types of CRDT. As of now, these are state-based, operation-based and delta-based. They define the different states as follows:

State-based:
"Sharing and merging the full state of nodes"

Operation-based:
"Broadcasting and causally applying operations"

Delta-based:
"Partial state changes (deltas)" being merged

// hier kann man glaube ich noch gut tiefer reingehen; habe erstmal nur einen Überblick mit reingenommen.

\
Another proposed approach //ist vllt. gar kein another approach aber egal
is a "model-checking-driven explorative testing (MET) framework" #cite(<zhang_model-checking-driven_2024>) in which test cases are automatically generated based on model-checking traces. // was sind model-checking traces 


= Verification and testing

#cite(<zhang_model-checking-driven_2024>, form: "author") suggest a testing explorative model-checking-driven testing framework.
The formal model-checking is conducted using the formal specification language TLA+ #footnote[#link("https://en.wikipedia.org/wiki/TLA%2B")].
The test cases are then automatically generated from the traces generated by the model-checking tool.



= Classification of literature

We grouped the papers into two distinct categories:
1. IDK
2. WT

= Tools used for analysis

= Possible gaps for further research

= Conclusion */