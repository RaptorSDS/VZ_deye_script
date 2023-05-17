# VZ_deye_script
Script for Readout Deye Solar Inverter for VZ Database 

addtional need for script from dr-ni
https://github.com/dr-ni/mi600


Schritt für Schritt
Wechselrichter über die Weboberfläche ins Netzwerk einbinden

   AP = AP_XXXXXX
   PW = 12345678
   admin/admin

Danach z.B die Internetverbindung des Wechselrichters am Router auf gesperrt setzen.
Zusätzlich sollte, wenn möglich, eine feste IP für den Wechselrichter festgelegt werden.

Abfragescript installieren

    git clone https://github.com/dr-ni/mi600.git

Verzeichnis wechseln

    cd mi600

Installation starten

    sudo make install

Test einer Abfrage (IP-Adresse und Zugangsdaten admin/admin an seinen Wechselrichter anpassen)

    mi600 [IP-Wechselrichter] admin admin webdata_today_e 

Sendescript Datei erstellen
    
   git clone https://github.com/RaptorSDS/VZ_deye_script.git

   nano auslesen.sh

Bitte IP Adressen, Wechselrichter Zugangsdaten, UUID an deine Gegebenheiten anpassen.


Dieses Script sendet nur die aktuelle Leistung an die Middleware, bereits vorbereitet ist alternativ/zusätzlich der Tageszählerstand.
Zeilen mit „#“ sind auskommentiert und können bei Bedarf genutzt werden für Debug oder um einen zweiten Kanal hinzuzufügen.

Datei Speichern und ausführbar machen

    chmod +x auslesen.sh

Datei zu CRON hinzufügen (hier als Beispiel Raspberry Pi mit 5 minuten Intervall)

   */5 * * * * /bin/bash /home/pi/auslesen.sh

Die Weboberfläche hat eine sehr langsame Aktualisierungsrate daher sollte der Cronjob nur alle 3 oder 5 Minuten laufen.

