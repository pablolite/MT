# NUMER, DATA i NAZWA SKRYPTU
:global vernr 300;;
:global vernazwa "vlany";;
:global verdata "2024-01-18";;


# USTAW WERSJE SKRYPTU W ROUTERZE KTORA JEST WYMAGANA DO URCHOMIENIA TEGO SKRYPTU
:global WymaganaWersja 290;;

# NIE ZMIENIAC
:global OstatniaWersja 0;;

# SKRYPT WYKONUJE SIE GDY SPELNIONY JEST WARUNEK WERSJI POPRZEDNIEGO SKRYPTU
{:foreach wersja in=[/queue tree find] do={:local teraz;;:set teraz [/queue tree get number=$wersja name];;:if (OstatniaWersja<teraz) do={:set OstatniaWersja $teraz;;}}}


:if ($WymaganaWersja=$OstatniaWersja) do={
# SKRYPT DO WYKONANIA
# -------------------------------------------------------------------------------------------------------------


##############################################################################
###################            STALE PARAMETRY             ###################
##############################################################################


# SERWERY DNS
# INTERNET
:global DNSinternet1 [:toip 8.8.8.8];
:global DNSinternet2 [:toip 1.1.1.1];
# CENTRALA
:global DNSdoz1 10.198.1.130;
:global DNSdoz2 10.198.2.17;
:global DNSdoz3 10.198.2.131;
:global DNSdoz4 10.198.2.18;
:global DNSfortigate 10.198.4.5;
# KOMENTARZE
:global vlan99com "Siec Blackhole (VLAN99)";
:global vlan200com "Siec Apteczna (VLAN200)"
:global vlan201com "Siec Demeter (VLAN201)"
:global vlan202com "Siec Izolowana do WAN (VLAN202)"
:global vlan203com "Siec Izolowana do VPN (VLAN203)"
:global vlan204com "Siec Izolowana do WAN VPN (VLAN204)"
:global vlan299com "Siec MGMT (VLAN299)"


##############################################################################
################### POBIERANIE DANCH I TWORZENIE ZMIENNYCH ###################
##############################################################################
# POBIERAM ADRES IP ROUTERA
:global adresIPlan [/ip address get [find interface="bridge1" comment!="Siec Euro"] address];
:set adresIPlan [:pick $adresIPlan 0 [:find $adresIPlan "/" -1]];

# TWORZE ADRESY DLA VLAN201 VLAN202 VLAN203 VLAN204 VLAN299
:global MASKvlan26 "/26";
:global MASKvlan24 "/24";

:global IPvlan201 ($adresIPlan+6553600);
:global NETWORKvlan201 ($IPvlan201-1);

:global IPvlan202 ($IPvlan201+64);
:global NETWORKvlan202 ($IPvlan202-1);

:global IPvlan203 ($IPvlan202+64);
:global NETWORKvlan203 ($IPvlan203-1);

:global IPvlan204 ($IPvlan203+64);
:global NETWORKvlan204 ($IPvlan204-1);

:global IPvlan299 ($adresIPlan+65536);
:global NETWORKvlan299 ($IPvlan299-1);

##############################################################################
################### 			 	BRIDGE 			       ###################
##############################################################################
# CZYSZCZENIE
:do {/interface bridge vlan remove [find]} on-error={};

# KONFIGURACJA PORTOW BRIDGE
:do {/interface bridge port add bridge=bridge1 hw=no interface=ether3 pvid=200} on-error={/interface bridge port set bridge=bridge1 hw=no pvid=200 [find interface=ether3]};
:do {/interface bridge port add bridge=bridge1 hw=no interface=ether4 frame-types=admit-only-vlan-tagged} on-error={/interface bridge port set bridge=bridge1 hw=no frame-types=admit-only-vlan-tagged [find interface=ether4]};
:do {/interface bridge port add bridge=bridge1 hw=no interface=ether5 frame-types=admit-only-vlan-tagged} on-error={/interface bridge port set bridge=bridge1 hw=no frame-types=admit-only-vlan-tagged [find interface=ether5]};

# KONFIGURACJA VLANow BRIDGE
/interface bridge vlan add bridge=bridge1 tagged=bridge1,ether4,ether5 untagged=ether3 vlan-ids=200 comment="$vlan200com"
/interface bridge vlan add bridge=bridge1 tagged=bridge1,ether3,ether4,ether5 vlan-ids=201 comment="$vlan201com"
/interface bridge vlan add bridge=bridge1 tagged=bridge1,ether3,ether4,ether5 vlan-ids=202 comment="$vlan202com"
/interface bridge vlan add bridge=bridge1 tagged=bridge1,ether3,ether4,ether5 vlan-ids=203 comment="$vlan203com"
/interface bridge vlan add bridge=bridge1 tagged=bridge1,ether3,ether4,ether5 vlan-ids=204 comment="$vlan204com"
/interface bridge vlan add bridge=bridge1 tagged=bridge1,ether3,ether4,ether5 vlan-ids=299 comment="$vlan299com"

##############################################################################
################### 			 	VLANy 			       ###################
##############################################################################

# CZYSZCZENIE VLAN
:do {/interface vlan remove [find name~"VLAN" interface=bridge1]} on-error={};
# DODANIE INTERFACE VLAN
/interface vlan add vlan-id=99 name=VLAN99 interface=bridge1 comment="$vlan99com"
/interface vlan add vlan-id=200 name=VLAN200 interface=bridge1 comment="$vlan200com"
/interface vlan add vlan-id=201 name=VLAN201 interface=bridge1 comment="$vlan201com"
/interface vlan add vlan-id=202 name=VLAN202 interface=bridge1 comment="$vlan202com"
/interface vlan add vlan-id=203 name=VLAN203 interface=bridge1 comment="$vlan203com"
/interface vlan add vlan-id=204 name=VLAN204 interface=bridge1 comment="$vlan204com"
/interface vlan add vlan-id=299 name=VLAN299 interface=bridge1 comment="$vlan299com"


##############################################################################
################### 			 INTERFACE			       ###################
##############################################################################
# CZYSZCZENIE
:do {/interface list member remove [find list~"LAN"]} on-error={};
:do {/interface list member remove [find list~"SIEC"]} on-error={};

# ZMIANA NAZW GRUP
:do {/interface list set name="SIEC_APTECZNA" [find name="LAN_APTECZNY"]} on-error={};
:do {/interface list set name="SIEC_IZOLOWANA_WAN" [find name="LAN_IZOLOWANY"]} on-error={};

# DODANIE NOWYCH GRUP
:do {/interface list add name="SIEC_IZOLOWANA_WAN_VPN"} on-error={};
:do {/interface list add name="SIEC_IZOLOWANA_VPN"} on-error={};
:do {/interface list add name="SIEC_MGMT"} on-error={};

# PRZYPISANIE VLAN DO GRUP
:do {/interface list member add interface=VLAN200 list=SIEC_APTECZNA} on-error={};
:do {/interface list member add interface=VLAN201 list=SIEC_IZOLOWANA_WAN_VPN} on-error={};
:do {/interface list member add interface=VLAN202 list=SIEC_IZOLOWANA_WAN} on-error={};
:do {/interface list member add interface=VLAN203 list=SIEC_IZOLOWANA_VPN} on-error={};
:do {/interface list member add interface=VLAN204 list=SIEC_IZOLOWANA_WAN_VPN} on-error={};
:do {/interface list member add interface=VLAN299 list=SIEC_MGMT} on-error={};


##############################################################################
################### 			 	ADRESY 			       ###################
##############################################################################

# CZYSZCZENIE
:do {/ip address remove [find comment ~"VLAN2"]} on-error={};

# DODANIE ADRESOW DO VLANow
/ip address add interface=VLAN200 address=("$adresIPlan"."$MASKvlan24") comment="$vlan200com"
/ip address add interface=VLAN201 address=("$IPvlan201"."$MASKvlan26") comment="$vlan201com"
/ip address add interface=VLAN202 address=("$IPvlan202"."$MASKvlan26") comment="$vlan202com"
/ip address add interface=VLAN203 address=("$IPvlan203"."$MASKvlan26") comment="$vlan203com"
/ip address add interface=VLAN204 address=("$IPvlan204"."$MASKvlan26") comment="$vlan204com"
/ip address add interface=VLAN299 address=("$IPvlan299"."$MASKvlan26") comment="$vlan299com"


##############################################################################
################### 			 	DHCP 			       ###################
##############################################################################

# CZYSZCZENIE
:do {/ip dhcp-server lease remove numbers=[find dynamic=yes]}
:do {/ip pool remove [find name~"dhcp_vlan"]} on-error={};
:do {/ip dhcp-server network remove [find gateway!="$adresIPlan"]} on-error={};
:do {/ip dhcp-server remove [find name~"dhcp_vlan"]} on-error={};

# DODANIE PULI
# VLAN200
{
:local poolod ($adresIPlan+64);
:local pooldo ($adresIPlan+124);
/ip pool add name=dhcp_vlan200 ranges="$poolod-$pooldo" comment="$vlan200com"
}
# VLAN201
{
:local poolod ($IPvlan201+1);
:local pooldo ($IPvlan201+61);
/ip pool add name=dhcp_vlan201 ranges="$poolod-$pooldo" comment="$vlan201com"
}
# VLAN202
{
:local poolod ($IPvlan202+1);
:local pooldo ($IPvlan202+61);
/ip pool add name=dhcp_vlan202 ranges="$poolod-$pooldo" comment="$vlan202com"
}
# VLAN203
{
:local poolod ($IPvlan203+1);
:local pooldo ($IPvlan203+61);
/ip pool add name=dhcp_vlan203 ranges="$poolod-$pooldo" comment="$vlan203com"
}
# VLAN204
{
:local poolod ($IPvlan204+1);
:local pooldo ($IPvlan204+61);
/ip pool add name=dhcp_vlan204 ranges="$poolod-$pooldo" comment="$vlan204com"
}
# VLAN299
{
:local poolod ($IPvlan299+1);
:local pooldo ($IPvlan299+61);
/ip pool add name=dhcp_vlan299 ranges="$poolod-$pooldo" comment="$vlan299com"
}
# DODANIE KONFIGURACJI SERWERA DHCP
# VLAN200
{
/ip dhcp-server add disabled=yes address-pool=dhcp_vlan200 interface=VLAN200 lease-time=1d name=dhcp_vlan200
/ip dhcp-server network set [find gateway=$adresIPlan] dhcp-option=unifi comment="$vlan200com"
}

# VLAN201
{
/ip dhcp-server add disabled=yes address-pool=dhcp_vlan201 interface=VLAN201 lease-time=1d name=dhcp_vlan201
/ip dhcp-server network add address=("$NETWORKvlan201"."$MASKvlan26") gateway=$IPvlan201 dns-server=$IPvlan201 comment="$vlan201com"
}

# VLAN202
{
/ip dhcp-server add disabled=yes address-pool=dhcp_vlan202 interface=VLAN202 lease-time=1d name=dhcp_vlan202
/ip dhcp-server network add address=("$NETWORKvlan202"."$MASKvlan26") gateway=$IPvlan202 dns-server="$DNSinternet1,$DNSinternet2" comment="$vlan202com"
}

# VLAN203
{
/ip dhcp-server add disabled=yes address-pool=dhcp_vlan203 interface=VLAN203 lease-time=1d name=dhcp_vlan203
/ip dhcp-server network add address=("$NETWORKvlan203"."$MASKvlan26") gateway=$IPvlan203 dns-server=$IPvlan203 comment="$vlan203com"
}

# VLAN204
{
/ip dhcp-server add disabled=yes address-pool=dhcp_vlan204 interface=VLAN204 lease-time=1d name=dhcp_vlan204
/ip dhcp-server network add address=("$NETWORKvlan204"."$MASKvlan26") gateway=$IPvlan204 dns-server=$IPvlan204 comment="$vlan204com"
}

# VLAN299
{
/ip dhcp-server add disabled=yes address-pool=dhcp_vlan299 interface=VLAN299 lease-time=7d name=dhcp_vlan299
/ip dhcp-server network add address=("$NETWORKvlan299"."$MASKvlan26") gateway=$IPvlan299 dns-server=$IPvlan299 dhcp-option=unifi comment="$vlan299com"
}


##############################################################################
###################		  	       WIFI		               ###################
##############################################################################

# CZYSZCZENIE
:do {/caps-man datapath remove [find name~"vlan"]} on-error={};
:do {/caps-man configuration remove [find name=cfg_czujniki_temp]} on-error={};
:do {/caps-man access-list remove [find comment="Czujnik Temperatur"]} on-error={};

# MODFYFIKACJA USTAWIEN CAP
:do {/interface wireless cap set discovery-interfaces=bridge1,VLAN200,VLAN201,VLAN202,VLAN203,VLAN204,VLAN299} on-error={};

# DODANIE KONFIGURACJI DATAPATHS DO CAPSMAN
:do {/caps-man datapath add bridge=bridge1 name=vlan200 vlan-id=200 vlan-mode=use-tag comment="$vlan200com"} on-error={};
:do {/caps-man datapath add bridge=bridge1 name=vlan201 vlan-id=201 vlan-mode=use-tag comment="$vlan201com"} on-error={};
:do {/caps-man datapath add bridge=bridge1 name=vlan202 vlan-id=202 vlan-mode=use-tag comment="$vlan202com"} on-error={};
:do {/caps-man datapath add bridge=bridge1 name=vlan203 vlan-id=203 vlan-mode=use-tag comment="$vlan203com"} on-error={};
:do {/caps-man datapath add bridge=bridge1 name=vlan204 vlan-id=204 vlan-mode=use-tag comment="$vlan204com"} on-error={};
:do {/caps-man datapath add bridge=bridge1 name=vlan299 vlan-id=299 vlan-mode=use-tag comment="$vlan299com"} on-error={};

# USTAWIENIE KONFIGURACJI DATAPATHS DLA SSID CAPSMAN
:do {/caps-man configuration unset [find] datapath.bridge} on-error={};
:do {/caps-man configuration set [find ssid="DEMETER"] datapath=vlan201 datapath.local-forwarding=no comment="$vlan201com"} on-error={};
:do {/caps-man configuration set [find ssid="doz_kolektor"] datapath=vlan200 datapath.local-forwarding=no comment="$vlan200com"} on-error={};
:do {/caps-man configuration set [find ssid="doz_kolektor_5"] datapath=vlan200 datapath.local-forwarding=no comment="$vlan200com"} on-error={};
:do {/caps-man configuration set [find ssid="doztab"] datapath=vlan202 datapath.local-forwarding=no comment="$vlan202com"} on-error={};
:do {/caps-man configuration set [find ssid="terminal"] datapath=vlan200 datapath.local-forwarding=no comment="$vlan200com"} on-error={};

# USTAWIENIE KONFIGURACJI VLAN DLA SSID W ZWYKLYM WIFI
# DODATKOWO DODANIE WIRTUALNYCH INTERFACE WIFI DO BRIDGE
:do {/interface wireless set [find ssid=DEMETER] vlan-id=201 vlan-mode=use-tag comment="$vlan201com"} on-error={};
:do {/interface bridge port add bridge=bridge1 interface=[/interface wireless get [find ssid="DEMETER"] name]} on-error={};
:do {/interface wireless set [find ssid=doz_kolektor] vlan-id=200 vlan-mode=use-tag comment="$vlan200com"} on-error={};
:do {/interface bridge port add bridge=bridge1 interface=[/interface wireless get [find ssid="doz_kolektor"] name]} on-error={};
:do {/interface wireless set [find ssid=doz_kolektor_5] vlan-id=200 vlan-mode=use-tag comment="$vlan200com"} on-error={};
:do {/interface bridge port add bridge=bridge1 interface=[/interface wireless get [find ssid="doz_kolektor_5"] name]} on-error={};
:do {/interface wireless set [find ssid=doztab] vlan-id=202 vlan-mode=use-tag comment="$vlan202com"} on-error={};
:do {/interface bridge port add bridge=bridge1 interface=[/interface wireless get [find ssid="doztab"] name]} on-error={};
:do {/interface wireless set [find ssid=terminal] vlan-id=200 vlan-mode=use-ta comment="$vlan200com"} on-error={};
:do {/interface bridge port add bridge=bridge1 interface=[/interface wireless get [find ssid="terminal"] name]} on-error={};

# DODANIE SIECI DO CZUJNIKOW TEMPERATUR
# ACCESSLISTA
/caps-man access-list add action=accept allow-signal-out-of-range=10s comment="Czujnik Temperatur" disabled=no interface=any mac-address=40:22:D8:00:00:00 mac-address-mask=FF:FF:FF:00:00:00 ssid-regexp=doztemp
/caps-man access-list add action=accept allow-signal-out-of-range=10s comment="Czujnik Temperatur" disabled=no interface=any mac-address=6C:96:CF:00:00:00 mac-address-mask=FF:FF:FF:00:00:00 ssid-regexp=doztemp
/caps-man access-list add action=accept allow-signal-out-of-range=10s comment="Czujnik Temperatur" disabled=no interface=any mac-address=FA:D3:1D:00:00:00 mac-address-mask=FF:FF:FF:00:00:00 ssid-regexp=doztemp
/caps-man access-list add action=accept allow-signal-out-of-range=10s comment="Czujnik Temperatur" disabled=no interface=any mac-address=B0:A7:32:00:00:00 mac-address-mask=FF:FF:FF:00:00:00 ssid-regexp=doztemp
/caps-man access-list remove numbers=[find action=reject]
/caps-man access-list add action=reject disabled=no interface=any ssid-regexp=""

# ZABEZPIECZENIA
/caps-man security add authentication-types=wpa2-psk encryption=aes-ccm,tkip name=security_temp passphrase=DozTemperatura#583

# KONFIGURACJA
/caps-man configuration add name=cfg_czujniki_temp security=security_temp ssid=doztemp datapath=vlan204 country=poland hide-ssid=no hw-protection-mode=cts-to-self keepalive-frames=enabled multicast-helper=full datapath.local-forwarding=no comment="$vlan204com"

# MODYFIKUJE PROVISIONING
# 2.4GHz
/caps-man provisioning set [find master-configuration=cfg1] slave-configurations=([get value-name=slave-configurations number=[find master-configuration=cfg1]]+"cfg_czujniki_temp")
# 5GHz
/caps-man provisioning set [find master-configuration=cfg_5] slave-configurations=([get value-name=slave-configurations number=[find master-configuration=cfg_5]]+"cfg_czujniki_temp")

#" 


##############################################################################
###################		  	    REGULY FW		           ###################
##############################################################################
# CZYSZCZENIE
:do {/ip firewall filter remove [find comment~"Izolacja"]} on-error={};
:do {/ip firewall filter remove [find comment~"Dostep SIEC_"]} on-error={};
:do {/ip firewall filter remove [find comment~"Dostep VPN"]} on-error={};
:do {/ip firewall filter remove [find comment="Blokuj dostep do Routera"]} on-error={};
:do {/ip firewall filter remove [find comment="Blokuj wszystko inne"]} on-error={};
:do {/ip firewall filter set in-interface-list="VPN" [find comment="Dostep z Centrum VPN"]} on-error={};

# NOWE REGULY

# DOSTEP Z VPN
:do {/ip firewall filter add action=accept chain=forward comment="Dostep VPN do SIEC_IZOLOWANA_WAN_VPN" in-interface-list=VPN out-interface-list=SIEC_IZOLOWANA_WAN_VPN} on-error={};
:do {/ip firewall filter add action=accept chain=forward comment="Dostep VPN do SIEC_IZOLOWANA_VPN" in-interface-list=VPN out-interface-list=SIEC_IZOLOWANA_VPN} on-error={};
:do {/ip firewall filter add action=accept chain=forward comment="Dostep VPN do SIEC_APTECZNA" in-interface-list=VPN out-interface-list=SIEC_APTECZNA} on-error={};
:do {/ip firewall filter add action=accept chain=forward comment="Dostep VPN do SIEC_MGMT" in-interface-list=VPN out-interface-list=SIEC_MGMT} on-error={};

# DOSTEP DO VPN
:do {/ip firewall filter add action=accept chain=forward comment="Dostep SIEC_IZOLOWANA_WAN_VPN do VPN" in-interface-list=SIEC_IZOLOWANA_WAN_VPN out-interface-list=VPN} on-error={};
:do {/ip firewall filter add action=accept chain=forward comment="Dostep SIEC_IZOLOWANA_VPN do VPN" in-interface-list=SIEC_IZOLOWANA_VPN out-interface-list=VPN} on-error={};
:do {/ip firewall filter add action=accept chain=forward comment="Dostep SIEC_APTECZNA do VPN" in-interface-list=SIEC_APTECZNA out-interface-list=VPN} on-error={};
:do {/ip firewall filter add action=accept chain=forward comment="Dostep SIEC_MGMT do VPN" in-interface-list=SIEC_MGMT out-interface-list=VPN} on-error={};

# DOSTEP DO WAN
:do {/ip firewall filter add action=accept chain=forward comment="Dostep SIEC_IZOLOWANA_WAN_VPN do WAN" in-interface-list=SIEC_IZOLOWANA_WAN_VPN out-interface-list=WAN} on-error={};
:do {/ip firewall filter add action=accept chain=forward comment="Dostep SIEC_IZOLOWANA_WAN do WAN" in-interface-list=SIEC_IZOLOWANA_WAN out-interface-list=WAN} on-error={};
:do {/ip firewall filter add action=accept chain=forward comment="Dostep SIEC_APTECZNA do WAN" in-interface-list=SIEC_APTECZNA out-interface-list=WAN} on-error={};
:do {/ip firewall filter add action=accept chain=forward comment="Dostep SIEC_MGMT do WAN" in-interface-list=SIEC_MGMT out-interface-list=WAN} on-error={};

# DOSTEP DO ROUTERA
:do {/ip firewall filter add action=accept chain=input comment="Dostep SIEC_APTECZNA do Routera" in-interface-list=SIEC_APTECZNA} on-error={};
:do {/ip firewall filter add action=accept chain=input comment="Dostep SIEC_MGMT do Routera" in-interface-list=SIEC_MGMT} on-error={};
:do {/ip firewall filter add action=accept chain=input comment="Dostep do DNS Routera" dst-port=53 protocol=tcp} on-error={};
:do {/ip firewall filter add action=accept chain=input comment="Dostep do DNS Routera" dst-port=53 protocol=udp} on-error={};
:do {/ip firewall filter add action=accept chain=input comment="Dostep dla CAPsMAN" dst-port=5246-5247 in-interface-list=!WAN protocol=udp} on-error={};
:do {/ip firewall filter add action=accept chain=input comment="Dostep dla CAPsMAN" in-interface-list=!WAN protocol=udp src-port=5246-524} on-error={};

# IZOLACJA DOSTEPU INNYCH SIECI
:do {/ip firewall filter add action=drop chain=forward connection-state=!established,related comment="Izolacja SIEC_APTECZNA" in-interface-list=SIEC_APTECZNA} on-error={};
:do {/ip firewall filter add action=drop chain=forward connection-state=!established,related comment="Izolacja SIEC_IZOLOWANA_WAN" in-interface-list=SIEC_IZOLOWANA_WAN} on-error={};
:do {/ip firewall filter add action=drop chain=forward connection-state=!established,related comment="Izolacja SIEC_IZOLOWANA_WAN_VPN" in-interface-list=SIEC_IZOLOWANA_WAN_VPN} on-error={};
:do {/ip firewall filter add action=drop chain=forward connection-state=!established,related comment="Izolacja SIEC_IZOLOWANA_VPN" in-interface-list=SIEC_IZOLOWANA_VPN} on-error={};
:do {/ip firewall filter add action=drop chain=forward connection-state=!established,related comment="Izolacja SIEC_MGMT" in-interface-list=SIEC_MGMT} on-error={};




# BLOKADA DOSTEPU DO ROUTERA
:do {/ip firewall filter add action=drop chain=input connection-state=!established,related comment="Blokuj dostep do Routera"} on-error={};

# UKLADANIE REGUL
:do {/ip firewall filter move [find action=drop]} on-error={};


##############################################################################
###################		       REGULY NAT    		       ###################
##############################################################################
# CZYSZCZENIE
:do {/ip firewall nat remove [find out-interface~"ether"]} on-error={};
:do {/ip firewall nat remove [find out-interface~"lte"]} on-error={};
:do {/ip firewall nat remove [find out-interface~"ppp"]} on-error={};

# USTAWIENIE MASKARADY DLA WAN
:do {/ip firewall nat get [find chain=srcnat out-interface-list="WAN" comment~"WAN"] action} on-error={/ip firewall nat remove [find comment~"WAN"];/ip firewall nat add chain=srcnat out-interface-list=WAN action=masquerade comment="NAT dla WAN";};


##############################################################################
###################		     REGULY ROUTINGU		       ###################
##############################################################################
# ROUTER OS 7.x
# CZYSZCZENIE
/routing rule remove [find comment~"Lan"]
/routing rule remove [find interface=VLAN202]

# WYJATKI DLA SIEC_IZOLOWANA_WAN
/routing rule add action=lookup dst-address=($NETWORKvlan201.$MASKvlan24) comment="VLAN202 dostep do LAN" interface=VLAN202 table=main
/routing rule add action=lookup dst-address=($NETWORKvlan299.$MASKvlan24) comment="VLAN202 dostep do LAN" interface=VLAN202 table=main
/routing rule add action=lookup dst-address=([/ip address get [find interface=VLAN200] network].$MASKvlan24) comment="VLAN202 dostep do LAN" interface=VLAN202 table=beztunelu
/routing rule add action=lookup-only-in-table comment="VLAN202 dostep tylko do WAN bez VPN" interface=VLAN202 table=beztunelu


##############################################################################
###################		     REGULY RADIUS		       ###################
##############################################################################
# DODANIE AUTORYZACJI DLA TUNELU ZAPASOWEGO
:global adresIPvpn2 [ip address get [find interface=tunel-zapasowy] network];
:do {:set $adresIPvpn2 ($adresIPvpn2+2)} on-error={};
:do {/radius add address=10.198.4.23 comment="Autoryzacja ADDOZ - logowanie do MT zapasowe" secret=vjYxroWGY8oVwdDx service=login src-address=$adresIPvpn2 timeout=2s;} on-error={};


##############################################################################
###################		     INNE		       ###################
##############################################################################

# CZYSZCZENIE
:do {/system logging remove [find action=FAZ]} on-error={};
:do {/system logging action remove [find bsd-syslog=yes name=FAZ remote=10.198.4.20 target=remote]} on-error={};

# DODAJE LOGOWANIE DO FAZ
:do {/system logging action add bsd-syslog=yes name=FAZ remote=10.198.4.20 target=remote} on-error={};
:do {/system logging add action=FAZ topics=info,account,system,!debug} on-error={};
:do {/system logging add action=FAZ topics=critical,!dhcp} on-error={};
:do {/system logging add action=FAZ prefix="[DHCP]" topics=critical,dhcp,error} on-error={};
:do {/system logging add action=FAZ prefix="[DHCP]" topics=bridge,warning} on-error={};

# DODAJE ALERTY O OBCYCH SERWERACH DHCP
:do {/ip dhcp-server alert add alert-timeout=1d disabled=no interface=bridge1} on-error={};
:do {/ip dhcp-server alert add alert-timeout=1d disabled=no interface=bridge2} on-error={};
:do {/ip dhcp-server alert add alert-timeout=1d disabled=no interface=bridge3} on-error={};
:do {/ip dhcp-server alert add alert-timeout=1d disabled=no interface=bridge4} on-error={};
:do {/ip dhcp-server alert add alert-timeout=1d disabled=no interface=VLAN99} on-error={};
:do {/ip dhcp-server alert add alert-timeout=1d disabled=no interface=VLAN200} on-error={};
:do {/ip dhcp-server alert add alert-timeout=1d disabled=no interface=VLAN201} on-error={};
:do {/ip dhcp-server alert add alert-timeout=1d disabled=no interface=VLAN202} on-error={};
:do {/ip dhcp-server alert add alert-timeout=1d disabled=no interface=VLAN203} on-error={};
:do {/ip dhcp-server alert add alert-timeout=1d disabled=no interface=VLAN204} on-error={};
:do {/ip dhcp-server alert add alert-timeout=1d disabled=no interface=VLAN299} on-error={};

# WLACZAM DHCP SNOOPING i OPTION82 (przypominajace)
/interface bridge set add-dhcp-option82=yes dhcp-snooping=yes [find]

##############################################################################
###################		  	    CZYSZCZENIE		           ###################
##############################################################################
# CZYSZCZENIE DHCP i PULI
# BRIDGE1 POZOSTAWIAMY WYLACZONE w RAZIE CZEGO
:do {/ip dhcp-server set disabled=yes address-pool=dhcp_vlan200 [find interface=bridge1]} on-error={};
:do {/ip dhcp-server remove [find interface~"bridge" disabled=no]} on-error={};
:do {/ip pool remove [find where !comment]} on-error={};

# CZYSZCZNIE STAREJ ADRESACJI
# BRIDGE1 POZOSTAWIAMY WYLACZONE w RAZIE CZEGO
:do {/ip address set [find interface=bridge1] disabled=yes} on-error={};
:do {/ip address remove [find interface~"bridge" disabled=no]} on-error={};
# CZYSZCZENIE BRIDGE INNE NIZ BRIDGE1
:do {/interface bridge remove [find name!=bridge1]} on-error={};


##############################################################################
###################		  	    URCHOMIENIE VLAN           ###################
##############################################################################
# WLACZENIE OBLUSGI NA BRIDGE
/interface bridge set fast-forward=no pvid=200 vlan-filtering=yes [find name=bridge1]
# URCHOMIENIE SEREROW DHCP
/ip dhcp-server enable [find name~"dhcp_vlan"]
# URUCHOMIENIE DOSTEPU AWARYJNEGO DO SWITCHA (ROMON)
/tool romon set enabled=yes secrets="cS3-Z7WrHdWQ"

:delay 1s;











# ZAPISANIE WERSJI WYKONANEGO SKRYPTU
/queue tree add name="$vernr" parent=global queue=default comment="$verdata|$vernazwa|ok";;

# MODYFIKACJA TUNELU IPSEC (zawezenie do protokolu gre)
/ip ipsec policy set protocol=47 [find peer=tunel-podstawowy] 

# -------------------------------------------------------------------------------------------------------------
# KONIEC SKRYPTU DO WYKONANIA
}

# WYKONANIE SKRYPTU NIEZALEZENIE OD SPELNIENIA WARUNKU
# -------------------------------------------------------------------------------------------------------------
#/system script run get_router;


# -------------------------------------------------------------------------------------------------------------
:delay 1ms;;