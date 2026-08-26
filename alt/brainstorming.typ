= Brainstorming

== Ideen für das wissenschaftliche Projekt

- Messenger (Innovative Inhaltsaustausch Iterationen)
  - Geo-Spacial AR Messenger
    - Digital Graffiti in AR
    - "Die Welt als Briefkasten"
    - "a la Geocaching"
  - CRDT als Messenger
    - alles was du tippst wird live gesendet
      - für Dating Apps (ehrlich/Authentizität)
  - Nachrichten, die ABKEholt werden müssen
- Selbstgebauter Social-Media Feed
  - oder RSS-Feed mit Algorithmus
- Medical AI
  - Ring-oder andere Daten auswerten
- Autonome Boote in Venedig
  - Modellierung als autonome Agenten, die regional den Verkehrsfluss optimieren
- #underline[*Kollaborative Korrekturen ("Typst Pro Max Ultra Plus" / SciDocs / CollaPDF)*]
  - PDF-Annotationen
  - Typst-Korrekturvorschläge
  - bidirektionale Reviews (PDF/Typst)
  - Version Control
  - Universal CRDTs
- Dezentraler Energiehandel in einem Smart Grid
  - Basis
    - Auktion
    - Optimierung von Effizienz
  - Optimierung auf Stabilität des Netzes
  - Optimierung auf möglichst niedrigen Preis für Verbraucher
  - Schicke Visualisierungen (Deutschlandkarte)
- CRDTs x Sex Toys
- Digitale Wahlen kryptografisch betrachten
- Sammelapp
  - Insekten
  - Züge (also eine App, die automatisch erkennt, in welchem Zug man sitzt)
- Sehenswürdigkeiten App 
  - Also man radelt fröhlich durch die Gegend und die App sagt einem dann, wenn man an interessanten Dingen vorbei radelt
- Muster fahren (Routenplanung)
- Weltraum aufräumen
- Texteditor ohne Indizes 


#import "map.typ": map

#figure(
  map(
    center: (52.52, 13.405),
    zoom: 12,
    file: read("map.png", encoding: none),
    width: 13.23cm,
    height: 9.26cm,
    pixel-density: 192,
  ),
  caption: [
    #sym.copyright #link("https://www.openstreetmap.org/copyright")[OpenStreetMap], image created using https://tile.openstreetmap.org/12/2200/1343.png
  ],
)

