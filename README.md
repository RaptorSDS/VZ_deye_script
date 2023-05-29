# VZ_deye_script
Script for Readout Deye Solar Inverter for VZ Database 

addtional need for script from dr-ni
https://github.com/dr-ni/mi600


==== Schritt für Schritt ====

==== Vorbereitung ====

  * Wechselrichter über die Weboberfläche ins Netzwerk einbinden

   AP = AP_XXXXXX
   PW = 12345678
   admin/admin

<note tip>Danach z.B die Internetverbindung des Wechselrichters am Router auf gesperrt setzen.\\
Zusätzlich sollte, wenn möglich, eine feste IP für den Wechselrichter festgelegt werden.</note>

  * Abfragescript installieren

   git clone https://github.com/dr-ni/mi600.git

  * Verzeichnis wechseln

   cd mi600

  * Installation starten

   sudo make install

  * Test einer Abfrage (IP-Adresse und Zugangsdaten admin/admin an seinen Wechselrichter anpassen)

   mi600 [IP-Wechselrichter] admin admin webdata_today_e 
   
   ==== Möglichkeit 1 CRON ====

  * Sendescript Datei erstellen
   - git clone <code>git clone https://github.com/RaptorSDS/VZ_deye_script.git </code>
   
   
  * darin folgenden Inhalt hinzufügen/editieren


<note>Bitte IP Adressen, Wechselrichter Zugangsdaten, UUID an deine Gegebenheiten anpassen.
Für den Kanal Leistung kann Auflösung "1" genommen werden </note>

Dieses Script sendet nur die aktuelle Leistung an die Middleware, bereits vorbereitet ist alternativ/zusätzlich der Zählerstand. Augrund der langsamen Daten ist eine Zählerstand nicht gut darstellbar\\
Zeilen mit "#" sind auskommentiert und können bei Bedarf genutzt werden für Debug oder um einen zweiten Kanal hinzuzufügen.

  * Datei Speichern und ausführbar machen

   chmod +x auslesen.sh

  * Datei zu CRON hinzufügen (hier als Beispiel Raspberry Pi mit 5 minuten Intervall)

<code>*/5 * * * * /bin/bash /home/pi/auslesen.sh</code>

Die Weboberfläche hat eine sehr langsame Aktualisierungsrate daher sollte der Cronjob nur alle 3 oder 5 Minuten laufen.


==== Möglichkeit 2 VZlogger mit Exec ====

  * Sendescript Datei erstellen

  -  git clone <code>git clone https://github.com/RaptorSDS/VZ_deye_script.git </code>
   
   

<note>
Bitte Zugangsdaten, an deine Gegebenheiten anpassen. 
</note>
<note>
Der Script hat folgende Config  xx.sh hostname reading1 reading2 ... / Reading dürfen sein DAY , TOTAL, ACTUAL
</note>


  * speichern und ausführbar machen 
<code> sudo chmod +x deye_read_exec.sh </code>


  * man kann nun zb nach /etc/deye/ kopiernen oder ander gut erkennbare Orte


  * Kanal Erstellen im Fronend


  * vzlogger.conf editieren oder erstellen mit folgendem Inhalt


<note important>Der Inverter wird nun alle 240s gelesen , ACTUAL und TOTAL an die DB Übergeben , TOTAL wird auf Duplicate getestet und nur spätesten wenn kein neuer Wert vorhanden ist alle 3600s neu übernommen</note>




