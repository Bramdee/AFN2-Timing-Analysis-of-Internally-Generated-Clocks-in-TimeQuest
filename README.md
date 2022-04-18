# AFN2 Timing Analysis of Internally Generated Clocks in TimeQuest

## Vorwort
Dieses Tutorial wurde für die AFN2 ILV des Studienganges ESD (FH OÖ Campus Hagenberg) erstellt.
In der AFN2 ILV erstellen die Studierenden ein Tutorial mit einem beliebigen Thema passend zu Advanced-FPGA-Design, um sich tiefer mit FPGAs beschäftigen zu können und zu lernen, wie man Tutorials hält, wie es in Firmen üblich ist.

In der SLL1 LVA war ich in meinem Team zuständig für das FPGA-Design. Für die Kommunikation mit Sensoren habe ich den SPI-Master-VHDL-Code von Digikey ([Link](https://forum.digikey.com/t/spi-master-vhdl/12717)) verwendet, da Design-Reuse Zeit spart.
Bei der Wahl dieser IP habe ich mir den Implementierung angesehen und bemerkt, dass der SPI-Takt SCLK intern über einen Clock-Divider erzeugt wird.
Ich habe dieses Thema gewählt, weil ich mich näher mit der Timing-Analyse intern generierter Taktsignale befassen wollte.

## Verwendete Software
 Quartus Prime 21.1 Lite

## Einführung

> **Info:** Vor dem Tutorial wird den LVA-Teilnehmer zur Einführung die Einführung-Powerpoint präsentiert. Diese findet man hier (TODO Github link)

Moderne FPGA-Designs sind heute größtenteils Syncrhon-Sequentiell aufgebaut. Überblicherweise verwenden diese externe Taktsignale, wie auch intern generiterte Taktsignale. Diese können *Gated* oder *Derived* sein. Dieses Tutorial soll den LVA-Teilnehmern verschiedenen Typen intern generiterer Taktsignale näherbringen und Empfehlungen für die Implementierung und Timing-Analyse für Intel FPGAs bieten.

Generell ist die Verwendung extern erzeugter Taktsignale zu empfehlen. Inter generite Taktsignale können Funktions- und Timing-Probleme verursachen.
Takte, die mit Kombinatorik erzeugt werden (Gated-Clocks), können Glitches verursachen, welche zu Hold-Time-Verletzungen führen können.

Leider ist es mit heutigen komplexen Designs nicht möglch ganz ohne intern generierter Taktsignale auszukommen. Beispielsweise bieten Mikrocontroller beispielsweise häufig die Möglichkeit über Multiplexer zwischen verschiedenen Taktsignalen zu wählen, über Clock-Divider und PLLs verschiedene Taktfrequenzen einzustellen. Auch das Ein- und Abschalten von Peripherals kann über intern generitere Clocks (Enabled Clocks) bewerkstelligt werden.
Grund für das interne Verringern der Taktrate oder Deaktivieren des Taktes kann beispiesweise das Energiesparen sein.
Grund für das interne Erhöhen der Taktrate kann sein, dass die Kommunikation mit anderen Chips eine höhere Taktrate erfordert, welche aber von den externen Referenz-Takten nicht erreicht wird.

Es gibt zwei Kategorieren von intern genertieren Taktsignalen: *Gated-Clocks* und *Derived-Clocks*
Gated-Clocks sind kombinatorische Schaltungen und stellen keine *Timing-Nodes* (Register, Latches oder PLLs) dar. Aus diesem Grund werden sie nicht von Timing-Contrints beeinflusst.
Derived-Clocks bestehen aus Registern, Latches oder PLLS (=Timing-Nodes). Sie erzeugen üblichweise neue Taktsignale im Design

### Gates Clocks
- Inverted-Clocks
- Buffered-Clocks
- Enabled-Clocks
- Multiplexed-Clocks
- Fed-Back-Clocks

### Derived Clocks
- Toggle-Flop-Clocks
- Ripple-Counter-Clocks
- Sync-Counter-Clocks
- PLL-Clocks

## Tutorial

### Gated Clocks
Es gibt eine große Vielfalt an Gated-Clocks. Sie reichen von einfacher *Inverted-Clocks* zu *extern rückgekoppelten Takten (=Fed Back Clocks)*.
Üblichweise werden diese zum wechseln und abschalten von Taktsignalen verwenden. Dies kann für Energiesparmaßnahen, für Tests und für das Wechseln zwischen verschiedenen Taktfrequenzen zur Laufzeit von Nutzen sein.

### Inverted-Clocks
1. In synchronen Schaltungen kann es nötig sein, dass etwas in weniger als einem Taktzyklus erledigt werden muss. Ein bekanntes Beispiel dafür sind Double-Data-Rate-Schaltungen (z.B. DDR-Speicher).

    Es gibt zwei Möglichkeiten Inverted-Clocks zu erzeugen. Entweder man invertiert ein bereits vorhandenes Taktsignal, oder man erzeugt aus dem Taktsignal, welches um 180° Phasenverschoben ist. Dies könnte beispielsweise mit einer PLL erreicht werden. Von letzterem ist aber abzuraten, da ersteres bei weitem einfacher implementiert werden kann.

    Eine LUT (Look-Up-Table) zu verwenden wäre ein Weg dies zu erreichen. Diese Methode würde *Clock-Skew* am Ziel-Register erzeugen und wird daher nicht empfohlen

    ![NOT-Gatter am Clock-Eingang](./md_pics/not_gate_clk_is_bad.PNG)


    Stattdessen verwendet man den bereits vorhanden invertierten Takt-Eingang von Registern.

    ![Invertierter Takteingang v. Regs](./md_pics/inverted_clk_input_reg.PNG)


2. Versuchen wir mittels VHDL Beschreibung eine Inverted-Clock zu erzeugen. Sehen wir uns dafür den Code von inverted_clk_gated an.
In inverted_clk_gated wird auf 3 verschiedene Arten eine Inverted-Clock beschrieben.

3. Synthetisiere das Design und sieh dir im Technology-Map-Viewer das Ergebnis an. Fällt etwas auf?

4. Das Ergebnis: Egal, wie die Inverted-Clock beschrieben wird, die Synthese erzeugt immer die ideale Lösung und verwendet die den invertierten Takt-Eingang der Register.
Die meisten Altera/Intel FPGAs haben eine programmierbare Einstellung zwischen invertiertem und nicht-invertiertem Takteingang.

    Man braucht nicht zu befüchten, versehentlich die schlechtere Variante implementiert zu haben.

    ![inverted_clk_gated ergebnis](./src/inverted_clk_gated/doc/result.PNG)

5. Öffne die SDC-Datei inverted_clk_gated.sdc.

    Welche Timing-Constaints müssen für die Inverted-Clock in der SDC-Datei gesetzt werden?
    Die Antwort ist: Gar keine. 
    
    Inverted-Clocks sind Gated-Clocks. Gated-Clocks bestehen aus Kombinatorik und beinhalten keine Timing-Nodes (wie z.B. Register).
    In unserem Fall ist nicht einmal zusätzliche Kombinatorik erzeugt worden.
    Die SDC-Datei muss daher für die Inverted-Clock nicht verändert werden.
    Der Timing-Analyzer versteht the invertierung und zieht sie in seine Berechnungen mit ein. Einzig ein *create_clock* Statement wird in der SDC-Datei benötigt.

6. Um zu sehen, dass der Timing-Analyzer die Inverted-Clock automatisch erkennt können wir den Timing-Analyzer verwenden.

    Öffne diesen und führe den Task *Report Timing...* aus.
    Es öffnet sich das *Report Timing*-Fenster. Wähle unter *Analysis type* *Setup* aus, um die Setup-Analyse durchzuführen. Lass alle andere Felder unverändert und drück auf den Button *Report Timing*.
    

7. Wie wir sehen können ist die Latch-Edge **nicht** die auf die Launch-Edge folgende steigende Flanke, wie wir es aus AFN2 Lab0, Lab2 und Lab3 kennen. Die Latch-Edge ist die auf die Launch-Edge folgende fallende Flanke!

    Die *Setup Relationship* ist mit 10 ns die Hälfte eines Taktzyklus (definiert in der SDC-Datei mit 20 ns)

    Der Timing-Analyzer hat das Design also tatsächlich automatisch richtig verstanden.

8. Ein Problem mit dieser Methode gibt es, wenn das für die Invertierung verwendete Taktsignal nicht 50%-Duty-Cycle hat. In diesem Fall ist die Inverted-Clock nicht um 180° Phasen-Verschoben.  
   In diesem Fall könnte es sein, dass das Timing nicht eingehalten werden kann.  
   Möchte man in diesem Fall dennoch eine Phasenverschiebung von 180° erreichen, kann man eine PLL verwenden.

### Buffered-Clocks
1. Taktsignale können in den FPGA über extra dafür vorgesehende Takt-Inputs, aber auch über einfache I/O-Inputs eingespeist werden.  
In den meisten fällen ist es ratsam die für Taktsignal vorgesehenen Inputs zu verwenden. Das erlaubt dem Tacktsignal the Low-Skew-Global-Buffer (Clock-Trees) zu verwenden, was für die interne Timing-Analyse einfacher zu handhaben ist.  

    Takte über einfache I/O-Inputs einzuspeisen sollte grundsätzlich vermieden werden, außer man ist sich sicher, dass man einen niedrigen Fan-Out hat und, dass es zu keinen Timing-Problemen kommen wird.
    Es gibt keine speziellen SDC-Constraints für einfache I/O-Puffer.  
    Bei Takten, die nicht dem Global-Buffer verwenden, sind Hold-Zeit-Verletzungen möglich, da es beim Place-And-Rout weniger Möglichkeiten gibt solche Timing-Probleme auszugleichen.
    Im Falle einer Hold-Zeit-Verletzung sollte man nicht **nicht** versuchen manuell kombinatorische Verzögerungen einzubauen. Solche Verzögerungsketten sind nicht zuverlässig, da die Verzögerung je nach Fertigungsprozess, der Spannung und der Temperatur variiert.

2. Öffne das VHDL-Code von bufferd_clk_gated und mache dich mit der Implementierung vertraut.   
   Es werden 2x 512 Register angelegt. Einmal werden sie mit einem Takt von einem Clock-Input versorgt und einmal mit einem Takt aus einem GPIO-Pin.
   Für die SDC- und die *.qsf-Datei dienten jene vom Terasic DE1-SoC-Board als basis.
   In der SDC-Datei wurde der GPIO-Input mit *create_clock* als Taktsignal definiert, damit dieser im Timing-Analyzer betrachtet werden kann.


3. Synthetisiere das Design, öffne den Timing-Analyzer und führe mit den Task *Report Timing...* für beide Taktsignale eine Setup-Timing-Analyse durch. Was fällt dir auf?

4. Bei beiden Taktsignalen ergibt sich haben einen ähnlich hohen Slack. Aber warum?  
   Der Grund dafür ist unser FPGA, der Cyclone V. Dieser verfügt nicht nur über ein Global-Buffer. Der Cyclone V FPGA verfügt über folgende Clock-Networks:  
   - Global clock (GCLK) networks  
   - Regional clock (RCLK) networks  
   - Periphery clock (PCLK) network  
  
    <pr> </pr>
5.  Speziell die Regional-Clock-Networks sind für uns hier interessant:  
    "RCLK networks are only applicable to the quadrant they drive into. RCLK networks provide the lowest
    clock insertion delay and skew for logic contained within a single device quadrant. The Cyclone V IOEs
    and internal logic within a given quadrant **can also drive RCLKs to create internally generated regional
    clocks and other high fan-out control signals**."  
    [Quelle: Cyclone V Device Handbook Volume 1: Device Interfaces and Integration Seite 64](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/cyclone-v/cv_52006.pdf)

6. Im Falle, dass man eine FPGA hat der so eine so eine Technologie nicht hat und aus bestimmten Gründen keinen Takt-Eingang verwenden kann kann man sich mit einem "Work-Arround" helfen.  
Man kann die Buffered-Clock mit dem Eingang einer PLL verbinden.  
Auf das wird in diesem Tutorial nicht weiter eingegangen, da neueres FPGAs dieses Problem lösen.