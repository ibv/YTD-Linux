YTD (YouTube Downloader) pro Linux
==================================

Co to je
----------

Linux verze free Windows YouTube Downloaderu (http://www.pepak.net/ytd/ytd/), klient pro stahování videa nejen z YouTube, ale i z dalších serverů.

Stav
-----

Stabilní funkce: 
 * přidání URL ze schránky
 * načtení seznamu URL ze souboru (txt,html)
 * uložení seznamu URL do souboru
 * start, stop stahování
 * nastavení konfigurace
 * protokoly http, https
 
 
Netestované (nestabilní) funkce: 
 * stahování RTMP
 * podpora MSDL (mmst,mmsh,real-rtsp,wms-rtsp)
 

Požadavky
----------
 * Lazarus (FPC) kompilátor
 * Linux prostředí
 * knihovna libpcre.so
 * knihovna librtmp.so.1
 * knihovny libssl.so, libcrypto.so 


Jak zkompilovat
---------------
 * nainstalovat Lazarus (1.6 a vyšší) dle návodu - http://wiki.freepascal.org/Installing_Lazarus
 * získat zdrojový kod z https://github.com/ibv/YTD
 * v Lazarus IDE, menu - File -> Open -> "/cesta/k/YTD.lpi"
 * v Lazarus IDE, menu - Run -> F9 (run) or Ctrl+F9 (compile) or Shift+F9 (link)


