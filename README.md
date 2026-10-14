# VZ_deye_script

![Shell](https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white)
![Volkszähler](https://img.shields.io/badge/Volksz%C3%A4hler-Middleware-blue)
![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)

Bash-Skripte, die einen **Deye-Mikrowechselrichter** (z. B. SUN600 / Bosswerk MI600) über dessen Weboberfläche auslesen und die Werte an die **[Volkszähler](https://volkszaehler.org)**-Datenbank übergeben.

Das eigentliche Auslesen übernimmt das Tool **[dr-ni/mi600](https://github.com/dr-ni/mi600)**.

Zwei Varianten stehen zur Verfügung:

| Variante | Skript | Funktionsweise |
|---|---|---|
| **1 – Cron** | `auslesen.sh` | Liest den Wechselrichter per Cron-Job aus und schreibt direkt per HTTP in die Middleware |
| **2 – vzlogger exec** *(empfohlen)* | `deye_read_exec.sh` | Wird vom `vzlogger` über das `exec`-Protokoll aufgerufen und gibt `Name = Wert` aus |

---

## Inhalt

- [Voraussetzungen](#voraussetzungen)
- [Wechselrichter vorbereiten](#wechselrichter-vorbereiten)
- [mi600 installieren](#mi600-installieren)
- [Installation](#installation)
- [Variante 1: Cron-Job](#variante-1-cron-job)
- [Variante 2: vzlogger exec](#variante-2-vzlogger-exec)
- [Lizenz](#lizenz)

---

## Voraussetzungen

**Hardware**

- Deye-Mikrowechselrichter mit integriertem WLAN-Logger und Weboberfläche (bzw. baugleiche Geräte wie Bosswerk MI600)

**Software**

- Volkszähler-Installation (Middleware erreichbar)
- `bash`, `git`, `make`
- [mi600](https://github.com/dr-ni/mi600) unter `/usr/local/bin/mi600`
- Variante 1: `wget`
- Variante 2: `vzlogger`

```bash
sudo apt install git make wget
```

---

## Wechselrichter vorbereiten

1. Mit dem Access Point des Wechselrichters verbinden und die Weboberfläche öffnen:

   | | |
   |---|---|
   | WLAN | `AP_XXXXXX` |
   | WLAN-Passwort | `12345678` |
   | Login Weboberfläche | `admin` / `admin` |

2. Den Wechselrichter in das eigene WLAN einbinden.

> [!TIP]
> Danach am Router z. B. den **Internetzugang des Wechselrichters sperren** und, wenn möglich, eine **feste IP-Adresse** vergeben.

---

## mi600 installieren

```bash
git clone https://github.com/dr-ni/mi600.git
cd mi600
sudo make install
```

Test einer Abfrage (IP-Adresse und Zugangsdaten anpassen):

```bash
mi600 <IP-Wechselrichter> admin admin webdata_today_e
```

Die verwendeten Werte:

| mi600-Parameter | Reading | Bedeutung |
|---|---|---|
| `webdata_now_p` | `ACTUAL` | Aktuelle Leistung (W) |
| `webdata_today_e` | `DAY` | Tagesertrag (kWh) |
| `webdata_total_e` | `TOTAL` | Gesamtertrag / Zählerstand (kWh) |

---

## Installation

```bash
git clone https://github.com/RaptorSDS/VZ_deye_script.git
cd VZ_deye_script
chmod +x auslesen.sh deye_read_exec.sh
```

---

## Variante 1: Cron-Job

Das Skript liest die **aktuelle Leistung** sowie den **Zählerstand** aus und schreibt beide per HTTP-Aufruf direkt in die Middleware. Ein Zählerstand von `0` wird nicht gesendet.

### 1. Skript anpassen

```bash
nano auslesen.sh
```

| Variable | Bedeutung |
|---|---|
| `host_pv` | IP-Adresse des Wechselrichters |
| `user` / `password` | Zugangsdaten der Weboberfläche (Standard: `admin` / `admin`) |
| `host_db` | IP-Adresse des Volkszähler-Servers |
| `UUID1` | Kanal-UUID für die Leistung (`ACTUAL`) |
| `UUID2` | Kanal-UUID für den Zählerstand (`TOTAL`) |

Für den Leistungskanal kann im Frontend die Auflösung `1` verwendet werden.
Mit `#` auskommentierte Zeilen dienen zum Debuggen oder als Vorlage für weitere Kanäle (z. B. Tagesertrag `DAY`).

### 2. Cron-Job einrichten

```bash
crontab -e
```

Beispiel für einen Raspberry Pi mit einem Intervall von 5 Minuten:

```cron
*/5 * * * * /bin/bash /home/pi/VZ_deye_script/auslesen.sh
```

> [!IMPORTANT]
> Die Weboberfläche des Wechselrichters aktualisiert ihre Werte nur sehr langsam. Der Cron-Job sollte daher nur **alle 3 bis 5 Minuten** laufen. Aus demselben Grund ist der Zählerstand nur grob darstellbar.

---

## Variante 2: vzlogger exec

Das Skript wird mit der IP-Adresse und den gewünschten Readings aufgerufen:

```text
deye_read_exec.sh <IP> <Reading1> [Reading2] ...
```

Erlaubte Readings: `ACTUAL`, `DAY`, `TOTAL`.
Beispielausgabe:

```console
$ ./deye_read_exec.sh 192.168.1.60 ACTUAL TOTAL
ACTUAL = 312
TOTAL = 1234.5
```

> [!NOTE]
> Liefert der Wechselrichter für `TOTAL` den Wert `0`, gibt das Skript stattdessen `undefine = 0` aus. So landet kein falscher Zählerstand in der Datenbank.

### 1. Zugangsdaten anpassen

Falls die Weboberfläche nicht mit `admin` / `admin` erreichbar ist, die Variablen `user` und `password` in `deye_read_exec.sh` anpassen.

### 2. Skript an einen festen Ort kopieren

```bash
sudo mkdir -p /etc/deye
sudo cp deye_read_exec.sh /etc/deye/
```

### 3. Kanäle im Volkszähler-Frontend anlegen

Lege für jedes Reading einen Kanal an und notiere dir die jeweilige UUID.

### 4. vzlogger konfigurieren

Füge in der `vzlogger.conf` unter `meters` folgenden Block hinzu und passe IP und UUIDs an:

```json
{
  "enabled": true,
  "allowskip": true,
  "interval": 240,
  "aggtime": -1,
  "aggfixedinterval": false,
  "protocol": "exec",
  "command": "/etc/deye/deye_read_exec.sh 192.168.x.xx ACTUAL TOTAL",
  "format": "$i = $v",
  "channels": [
    {
      "api": "volkszaehler",
      "uuid": "e4f6a700-xxxxx",
      "identifier": "TOTAL",
      "middleware": "http://localhost/middleware.php",
      "aggmode": "none",
      "duplicates": 3600
    },
    {
      "api": "volkszaehler",
      "uuid": "35edd970-xxxxx",
      "identifier": "ACTUAL",
      "middleware": "http://localhost/middleware.php",
      "aggmode": "none",
      "duplicates": 0
    }
  ]
}
```

| Einstellung | Wirkung |
|---|---|
| `interval: 240` | Der Wechselrichter wird alle 240 s abgefragt |
| `duplicates: 3600` | Der Zählerstand wird auf Duplikate geprüft und spätestens nach 3600 s erneut geschrieben, auch ohne neuen Wert |
| `identifier` | Muss exakt dem Reading-Namen entsprechen (`ACTUAL`, `DAY`, `TOTAL`) |

### 5. vzlogger neu starten

```bash
sudo systemctl restart vzlogger
```

---

## Lizenz

Veröffentlicht unter der [MIT-Lizenz](LICENSE).
© 2023 Tobias Baumann aka **RaptorSDS**
