# CZYSZCZENIE
:do {/system script add owner=admin name=panel_routerow_dhcp_dodawanie} on-error={};
:do {/system script add owner=admin name=panel_routerow_wifi} on-error={};
:do {/system script add owner=admin name=panel_routerow_wifi_6_dodawanie} on-error={};
:do {/system script add owner=admin name=panel_routerow_wifi_7_dodawanie} on-error={};
:do {/system scheduler remove [find name~"panel_routerow"]} on-error={};
# DODAJE SKRYPTY
/system script
set panel_routerow_dhcp_dodawanie owner=\
    admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    \r\
    \n# DODANIE wpisow DHCP na podstawie listy z Panelu Routerow\r\
    \n#\r\
    \n\r\
    \n{\r\
    \n# POBIERANIE ZMIENNYCH\r\
    \n:global ckk [/system identity get name];\r\
    \n\r\
    \n# Weryfikacja instienia pliku z lista dhcp\r\
    \n:if ( [ :len [ /file find name=\"dhcp\" ] ] >0 ) do={\r\
    \n:local content [/file get [/file find name=\"dhcp\"] contents] ;\r\
    \n:local contentLen [:len \$content];\r\
    \n:local lineEnd 0;\r\
    \n:local line \"\";\r\
    \n:local lastEnd 0;\r\
    \n\r\
    \n:while (\$lineEnd < (\$contentLen-1)) do={\r\
    \n# (kodowanie linux/windows) -> \",\\n\" / \",\\r\\n\"\r\
    \n\t:set lineEnd [:find \$content \",\\n\" \$lastEnd];\r\
    \n\t:if ([:len \$lineEnd] = 0) do={\r\
    \n\t\t:set lineEnd \$contentLen;\r\
    \n\t}\r\
    \n\t:set line [:pick \$content \$lastEnd \$lineEnd];\r\
    \n# \"\\n\" \\ \"\\r\\n\" -> 1 \\ 2 \r\
    \n\t:set lastEnd (\$lineEnd + 1);\r\
    \n# weryfikuje czy MAC i IP nalezy do swojego CKK\r\
    \n\t:if ([:find \$line \$ckk 0]) do={\r\
    \n\t\t:local wiersz [:pick \$line ([:find \$line \",\"]+1) [:len \$line]]\
    \r\
    \n\t\t:local dhcp 0\r\
    \n# ckk z wiersza\r\
    \n\t\t:local ckk [:pick \$wiersz 0 ([:find \$wiersz \";\"] - 0)]\r\
    \n\t\t:local remaining [:pick \$wiersz ([:find \$wiersz \";\"] + 1) [:len \
    \$wiersz]]\r\
    \n# mac z wiersza\r\
    \n\t\t:local mac [:pick \$remaining 0 ([:find \$remaining \";\"] - 0)]\r\
    \n\t\t:set remaining [:pick \$remaining ([:find \$remaining \";\"] + 1) [:\
    len \$remaining]]\r\
    \n# ip z wiersza\r\
    \n\t\t:local ip [:pick \$remaining 0 ([:find \$remaining \";\"] - 0)]\r\
    \n\t\t:set remaining [:pick \$remaining ([:find \$remaining \";\"] + 1) [:\
    len \$remaining]]\r\
    \n# nazwa (komentarz) z wiersza\r\
    \n\t\t:local nazwa [:pick \$remaining 0 ([:find \$remaining \";\"] - 0)]\r\
    \n\t\t:set remaining [:pick \$remaining ([:find \$remaining \";\"] + 1) [:\
    len \$remaining]]\r\
    \n# siec z wiersza\r\
    \n\t\t:local siec [:pick \$remaining 0 ([:find \$remaining \";\"] - 0)]\r\
    \n# przypisanie serwera dhcp nalezacego sieci (interface)\r\
    \n\t\t:set siec [/ip dhcp-server get number=[find interface=\$siec] name]\
    \r\
    \n\t\t:set remaining [:pick \$remaining ([:find \$remaining \";\"] + 1) [:\
    len \$remaining]]\r\
    \n# wifi z wiersza\r\
    \n\t\t:local wifi [:pick \$remaining 0 ([:find \$remaining \";\"] - 0)]\r\
    \n# stan aktywnosci z wiersza\r\
    \n\t\t:local active [:pick \$remaining 2 3]\r\
    \n# jezeli 1 to disabled=no\r\
    \n\t\tif (\$active = 1) do={:set active \"no\"}\r\
    \n# jezeli 2 to disabled=yes\r\
    \n\t\tif (\$active = 0) do={:set active \"yes\"}\r\
    \n#\t\t:put \"-wiersz>\$wiersz<-\"\r\
    \n#\t\t:put \"-ckk>\$ckk<-\"\r\
    \n#\t\t:put \"-mac>\$mac<-\"\r\
    \n#\t\t:put \"-ip>\$ip<-\"\r\
    \n# proba zweryfikowania odczytanych parametrow z ustawieniami w routerze\
    \r\
    \n\t\t:do {:set dhcp [/ip dhcp-server lease get [find mac-address=\"\$mac\
    \" disabled=\$active dynamic=no comment=\"\$nazwa\" server=\$siec] address\
    ];} on-error={};\r\
    \n# weryfikuje czy dane IP ma juz statyczny wpis dla podanego MAC\r\
    \n\t\t\t:if (\$ip!=\$dhcp) do={\r\
    \n# jezeli nie to usuwa taki MAC w tablicy i dodaje prawidlowy wpis\r\
    \n\t\t\t\t\t\t\t\t:log info message=\"[dhcp][dodaje] \$ckk | \$mac --> \$i\
    p\"\r\
    \n\t\t\t\t\t\t\t\t:do {/ip dhcp-server lease remove numbers=[find mac-addr\
    ess=\$mac]} on-error={};\r\
    \n\t\t\t\t\t\t\t\t:do {/ip dhcp-server lease add address=\$ip comment=\"\$\
    nazwa\" mac-address=\$mac server=\$siec disabled=\$active} on-error={};\r\
    \n\t\t\t\t\t\t\t\t:local dhcp 0;\r\
    \n# jezeli jest to dodaje wpis to logu\r\
    \n\t\t\t\t\t\t\t\t} else={\r\
    \n\t\t\t\t\t\t\t\t\t\t:log info message=\"[dhcp][wpis_istnieje] \$ckk | \$\
    mac --> \$ip\"\r\
    \n\t\t\t\t\t\t\t\t\t\t:local dhcp 0;\r\
    \n\t\t\t\t\t\t\t\t\t\t}\r\
    \n\r\
    \n#\t\t:put \"->\$line<-\"\r\
    \n\r\
    \n\t}\r\
    \n} \r\
    \n} else={:log error message=\"[dhcp][blad] nie ma pliku dhcp\"}\r\
    \n:delay 1ms;\r\
    \n}"
set panel_routerow_wifi owner=\
    admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    \r\
    \n# Weryfikacja RouterOS i uruchomienie skryptu WIFI\r\
    \n#\r\
    \n:if ([:pick [[/system package update get installed-version] 0 1]] = \"6\
    \") do={/system script run panel_routerow_wifi_6_dodawanie}\r\
    \n:if ([:pick [[/system package update get installed-version] 0 1]] = \"7\
    \") do={/system script run panel_routerow_wifi_7_dodawanie}"
set panel_routerow_wifi_6_dodawanie owner=\
    admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    \r\
    \n# DODANIE wpisow WIFI na podstawie listy z Panelu Routerow - RouterOS v6\
    .x\r\
    \n#\r\
    \n\r\
    \n{\r\
    \n# POBIERANIE ZMIENNYCH\r\
    \n:global ckk [/system identity get name];\r\
    \n\r\
    \n# Weryfikacja instienia pliku z lista wifi\r\
    \n:if ( [ :len [ /file find name=\"wifi\" ] ] >0 ) do={\r\
    \n:local content [/file get [/file find name=\"wifi\"] contents] ;\r\
    \n:local contentLen [:len \$content];\r\
    \n:local lineEnd 0;\r\
    \n:local line \"\";\r\
    \n:local lastEnd 0;\r\
    \n\r\
    \n:while (\$lineEnd < (\$contentLen-1)) do={\r\
    \n# (kodowanie linux/windows) -> \",\\n\" / \",\\r\\n\"\r\
    \n\t:set lineEnd [:find \$content \",\\n\" \$lastEnd];\r\
    \n\t:if ([:len \$lineEnd] = 0) do={\r\
    \n\t\t:set lineEnd \$contentLen;\r\
    \n\t}\r\
    \n\t:set line [:pick \$content \$lastEnd \$lineEnd];\r\
    \n# \"\\n\" \\ \"\\r\\n\" -> 1 \\ 2 \r\
    \n\t:set lastEnd (\$lineEnd + 1);\r\
    \n# weryfikuje czy MAC i IP nalezy do swojego CKK\r\
    \n\t:if ([:find \$line \$ckk 0]) do={\r\
    \n\t\t:local wiersz [:pick \$line ([:find \$line \",\"]+1) [:len \$line]]\
    \r\
    \n\t\t:local wifi 0\r\
    \n# ckk z wiersza\r\
    \n\t\t:local ckk [:pick \$wiersz 0 ([:find \$wiersz \";\"] - 0)]\r\
    \n\t\t:local remaining [:pick \$wiersz ([:find \$wiersz \";\"] + 1) [:len \
    \$wiersz]]\r\
    \n# mac z wiersza\r\
    \n\t\t:local mac [:pick \$remaining 0 ([:find \$remaining \";\"] - 0)]\r\
    \n\t\t:set remaining [:pick \$remaining ([:find \$remaining \";\"] + 1) [:\
    len \$remaining]]\r\
    \n# nazwa (komentarz) z wiersza\r\
    \n\t\t:local nazwa [:pick \$remaining 0 ([:find \$remaining \";\"] - 0)]\r\
    \n        :set remaining [:pick \$remaining ([:find \$remaining \";\"] + 1\
    ) [:len \$remaining]]\r\
    \n# stan aktywnosci z wiersza\r\
    \n\t\t:local active \$remaining\r\
    \n# jezeli 1 to disabled=no\r\
    \n\t\tif (\$active = 1) do={:set active \"no\"}\r\
    \n# jezeli 2 to disabled=yes\r\
    \n\t\tif (\$active = 0) do={:set active \"yes\"}\r\
    \n#\t\t:put \"-wiersz>\$wiersz<-\"\r\
    \n#\t\t:put \"-ckk>\$ckk<-\"\r\
    \n#\t\t:put \"-mac>\$mac<-\"\r\
    \n#\t\t:put \"-nazwa>\$nazwa<-\"\r\
    \n#\t\t:put \"-active>\$active<-\" \r\
    \n\r\
    \n# proba zweryfikowania odczytanych parametrow z ustawieniami w routerze\
    \r\
    \n\t\t:do {:set wifi [/caps-man access-list get [find action=accept disabl\
    ed=\$active mac-address=\$mac comment=\"\$nazwa\"] mac-address];} on-error\
    ={};\r\
    \n# weryfikuje czy dane IP ma juz statyczny wpis dla podanego MAC\r\
    \n\t\t\t:if (\$mac!=\$wifi) do={\r\
    \n# jezeli nie to usuwa taki MAC w tablicy i dodaje prawidlowy wpis\r\
    \n\t\t\t\t\t\t\t\t:log info message=\"[wifi][dodaje] \$ckk | \$mac | \$naz\
    wa\"\r\
    \n                                        # WIFI CAPSMAN v6.x \r\
    \n                                        :do {/caps-man access-list remov\
    e numbers=[find mac-address=\$mac]} on-error={};\r\
    \n                                        :do {/caps-man access-list add a\
    ction=accept disabled=\$active mac-address=\$mac mac-address-mask=FF:FF:FF\
    :FF:FF:FF comment=\"\$nazwa\"} on-error={};\r\
    \n                                        :do {/caps-man access-list move \
    numbers=[find action=reject]} on-error={};\r\
    \n\r\
    \n                                        # WIFI v6.x\r\
    \n                                        :do {/interface wireless access-\
    list remove numbers=[find mac-address=\$mac]} on-error={};\r\
    \n                                        :do {/interface wireless access-\
    list add authentication=yes disabled=\$active mac-address=\$mac comment=\"\
    \$nazwa\"} on-error={};\r\
    \n                                        :do {/interface wireless access-\
    list move numbers=[find authentication=no]} on-error={};\r\
    \n\t\t\t\t\t\t\t\t        :local wifi 0;\r\
    \n# jezeli jest to dodaje wpis to logu\r\
    \n\t\t\t\t\t\t\t\t} else={\r\
    \n\t\t\t\t\t\t\t\t\t\t:log info message=\"[wifi][wpis_istnieje] \$ckk | \$\
    mac | \$nazwa\"\r\
    \n\t\t\t\t\t\t\t\t\t\t:local wifi 0;\r\
    \n\t\t\t\t\t\t\t\t\t\t}\r\
    \n\r\
    \n#\t\t:put \"->\$line<-\"\r\
    \n\r\
    \n\t}\r\
    \n} \r\
    \n} else={:log error message=\"[wifi][blad] nie ma pliku wifi\"}\r\
    \n:delay 1ms;\r\
    \n}\r\
    \n"
set panel_routerow_wifi_7_dodawanie owner=\
    admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    \r\
    \n# DODANIE wpisow WIFI na podstawie listy z Panelu Routerow - RouterOS v7\
    .x\r\
    \n#\r\
    \n\r\
    \n{\r\
    \n# POBIERANIE ZMIENNYCH\r\
    \n:global ckk [/system identity get name];\r\
    \n\r\
    \n# Weryfikacja instienia pliku z lista wifi\r\
    \n:if ( [ :len [ /file find name=\"wifi\" ] ] >0 ) do={\r\
    \n:local content [/file get [/file find name=\"wifi\"] contents] ;\r\
    \n:local contentLen [:len \$content];\r\
    \n:local lineEnd 0;\r\
    \n:local line \"\";\r\
    \n:local lastEnd 0;\r\
    \n\r\
    \n:while (\$lineEnd < (\$contentLen-1)) do={\r\
    \n# (kodowanie linux/windows) -> \",\\n\" / \",\\r\\n\"\r\
    \n\t:set lineEnd [:find \$content \",\\n\" \$lastEnd];\r\
    \n\t:if ([:len \$lineEnd] = 0) do={\r\
    \n\t\t:set lineEnd \$contentLen;\r\
    \n\t}\r\
    \n\t:set line [:pick \$content \$lastEnd \$lineEnd];\r\
    \n# \"\\n\" \\ \"\\r\\n\" -> 1 \\ 2 \r\
    \n\t:set lastEnd (\$lineEnd + 1);\r\
    \n# weryfikuje czy MAC i IP nalezy do swojego CKK\r\
    \n\t:if ([:find \$line \$ckk 0]) do={\r\
    \n\t\t:local wiersz [:pick \$line ([:find \$line \",\"]+1) [:len \$line]]\
    \r\
    \n\t\t:local wifi 0\r\
    \n# ckk z wiersza\r\
    \n\t\t:local ckk [:pick \$wiersz 0 ([:find \$wiersz \";\"] - 0)]\r\
    \n\t\t:local remaining [:pick \$wiersz ([:find \$wiersz \";\"] + 1) [:len \
    \$wiersz]]\r\
    \n# mac z wiersza\r\
    \n\t\t:local mac [:pick \$remaining 0 ([:find \$remaining \";\"] - 0)]\r\
    \n\t\t:set remaining [:pick \$remaining ([:find \$remaining \";\"] + 1) [:\
    len \$remaining]]\r\
    \n# nazwa (komentarz) z wiersza\r\
    \n\t\t:local nazwa [:pick \$remaining 0 ([:find \$remaining \";\"] - 0)]\r\
    \n        :set remaining [:pick \$remaining ([:find \$remaining \";\"] + 1\
    ) [:len \$remaining]]\r\
    \n# stan aktywnosci z wiersza\r\
    \n\t\t:local active \$remaining\r\
    \n# jezeli 1 to disabled=no\r\
    \n\t\tif (\$active = 1) do={:set active \"no\"}\r\
    \n# jezeli 2 to disabled=yes\r\
    \n\t\tif (\$active = 0) do={:set active \"yes\"}\r\
    \n#\t\t:put \"-wiersz>\$wiersz<-\"\r\
    \n#\t\t:put \"-ckk>\$ckk<-\"\r\
    \n#\t\t:put \"-mac>\$mac<-\"\r\
    \n#\t\t:put \"-nazwa>\$nazwa<-\"\r\
    \n#\t\t:put \"-active>\$active<-\" \r\
    \n\r\
    \n# proba zweryfikowania odczytanych parametrow z ustawieniami w routerze\
    \r\
    \n\t\t:do {:set wifi [/caps-man access-list get [find action=accept disabl\
    ed=\$active mac-address=\$mac comment=\"\$nazwa\"] mac-address];} on-error\
    ={};\r\
    \n# weryfikuje czy dane IP ma juz statyczny wpis dla podanego MAC\r\
    \n\t\t\t:if (\$mac!=\$wifi) do={\r\
    \n# jezeli nie to usuwa taki MAC w tablicy i dodaje prawidlowy wpis\r\
    \n\t\t\t\t\t\t\t\t:log info message=\"[wifi][dodaje] \$ckk | \$mac | \$naz\
    wa\"\r\
    \n                                        # WIFI v7.x\r\
    \n                                        :do {/interface wifi access-list\
    \_remove numbers=[find mac-address=\$mac]} on-error={};\r\
    \n                                        :do {/interface wifi access-list\
    \_add action=accept disabled=\$active mac-address=\$mac mac-address-mask=F\
    F:FF:FF:FF:FF:FF comment=\"\$nazwa\"} on-error={};\r\
    \n                                        :do {/interface wifi access-list\
    \_move numbers=[find action=reject]} on-error={};\r\
    \n\t\t\t\t\t\t\t\t        :local wifi 0;\r\
    \n# jezeli jest to dodaje wpis to logu\r\
    \n\t\t\t\t\t\t\t\t} else={\r\
    \n\t\t\t\t\t\t\t\t\t\t:log info message=\"[wifi][wpis_istnieje] \$ckk | \$\
    mac | \$nazwa\"\r\
    \n\t\t\t\t\t\t\t\t\t\t:local wifi 0;\r\
    \n\t\t\t\t\t\t\t\t\t\t}\r\
    \n\r\
    \n#\t\t:put \"->\$line<-\"\r\
    \n\r\
    \n\t}\r\
    \n} \r\
    \n} else={:log error message=\"[wifi][blad] nie ma pliku wifi\"}\r\
    \n:delay 1ms;\r\
    \n}"

# DODAJE Harmonogramy
{
:local randmin [:pick [/system clock get time] 6 8];
:local randsek (59-$randmin);
/system scheduler add interval=1d name=panel_routerow_24h on-event=panel_routerow_wifi policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-date=dec/28/2023 start-time=04:00:00
/system scheduler add interval=1d name=panel_routerow_6h_losowo on-event=panel_routerow_dhcp_wifi_pobieranie policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-date=dec/28/2023 start-time="03:$randmin:$randsek"
/system scheduler add interval=6h name=panel_routerow_6h on-event=panel_routerow_dhcp_dodawanie policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-date=dec/28/2023 start-time=12:00:00
}
