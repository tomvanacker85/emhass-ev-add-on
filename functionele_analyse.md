    • Ik heb forks gemaakt van de Github repositories davidusb-geek/emhass en davidusb-geek/emhass-add-on en deze hernoemd naar tomvanacker85/emhass-ev en tomvanacker85/emhass-ev-add-on. Mogelijks moeten er paden in de repositories aangepast worden om naar de juiste repository te verwijzen (= tomvanacker85/…)
    • De folder die gebruikt moet worden om configuratie en andere files op te slaan is /share/emhass-ev. De webserver moet beschikbaar zijn op poort 5001 ipv 5000
    • Ik wil aanpassingen doorvoeren aan deze packages om een EV als deferrable load toe te voegen, en zo het laadproces te optimaliseren. 
    • Deze packages worden uiteindelijk gebruikt om EMHASS beschikbaar te stellen in Home Assistant 
    
    • Toe te voegen functionaliteiten
        ○ Google Calendar bevat de events waarop de EV niet thuis is. Er staat bij deze events ook een adres waarnaar gereden wordt met de EV. De kalender wordt ingelezen in Home Assistant via de Google Calendar integration.
        ○ Het adres van deze events wordt gebruikt als bestemming, startende van thuis. De berekening van het aantal km gebeurt best in Node-red via een specifieke flow.
        ○ Op basis hiervan worden 2 arrays gepopuleerd in Node-red:
            § Array met laadmomenten: buiten de events om wordt er verondersteld dat de auto thuis staat. Per tijdsstap bevat het array 0 (afwezig) of 1 (aan de lader, beschikbaar om te laden)
            § Array met minimum rijbereik: dit is minimum het instelbare minimum rijbereik (bv. 100 km) en dient rekening te houden met de geplande bestemmingen obv de kalender. Als er geen aansluitend event is, hou dan rekening met een verplaatsing terug naar Wachtebeke. Als bv. morgen om 8h een rit gepland staat naar Terneuzen, dan moet er tegen 8h zeker het minimum rijbereik + heen en terug autonomie zijn
        ○ Emhass optimaliseert het laden en schrijft dit weg in sensor.p_ev, die analoog aan sensor.p_deferrable en het vermogen bevat per tijdsstap
        ○ Beschouw de batterij van de EV als een batterij met haar eigen SOC_EV
        ○ De EV moet geconfigureerd kunnen worden diverse parameters. De EV optimalisatie moet aan en uit kunnen worden gezet. In de folder moet een config.json file gelezen worden
            "ev_conf": {
              "number_of_ev_loads": 1,
              "ev_battery_capacity": [77000],
              "ev_charging_efficiency": [0.9],
              "ev_nominal_charging_power": [4600],
              "ev_minimum_charging_power": [1380],
              "ev_consumption_efficiency": [0.15]
            }
    • De visualisatie van de webserver moet uitgebreid worden. P_EV moet getoond worden in de grafiek, net als SOC_EV. Neem deze entiteiten ook op in de tabel. De configuratie moet via de gui kunnen worden aangepast. Maak hiervoor een nieuwe sectie aan waarin de ev parameters worden gegroepeerd. Gebruik de lay-out van de bestaande pagina