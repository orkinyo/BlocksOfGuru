#variables to set if you are annoying
$SHOOSHX_PATH = ".\corewars8086_js"
$PORT = 8000
#from this point back off
$URL = "http://localhost:$($PORT)/war/page.html"
"[+] starting shooshx, running at $($URL)"
cd $SHOOSHX_PATH
Start-Process python "-m http.server $($PORT)"
cd ".."
Start-Process chrome "$($URL)"
"[+] Opened Chrome"
Exit