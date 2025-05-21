#!/bin/bash

clear





echo "
__        _______ ____     ____    _    ____ _   _ _____ 
\ \      / / ____| __ )   / ___|  / \  / ___| | | | ____|
 \ \ /\ / /|  _| |  _ \  | |     / _ \| |   | |_| |  _|  
  \ V  V / | |___| |_) | | |___ / ___ \ |___|  _  | |___ 
   \_/\_/  |_____|____/   \____/_/   \_\____|_| |_|_____|
"

echo "                                     _        "
echo " _ __ ___   __ _ _ __ ___   __ _  __| |       "
echo "| '_ \` _ \ / _\` | '_ \` _ \ / _\` |/ _\` |       "
echo "| | | | | | (_| | | | | | | (_| | (_| |       "
echo "|_| |_| |_|\\__,_|_| |_| |_|\\__,_|\\__,_|       "
echo "  ___ _   _| |__   ___ _ __(_)___  ___  _ __  "
echo " / __| | | | '_ \ / _ \ '__| / __|/ _ \| '_ \ "
echo "| (__| |_| | |_) |  __/ |  | \__ \ (_) | | | |"
echo " \___|\__, |_.__/ \___|_|  |_|___/\___/|_| |_|"
echo "      |___/                                    "
echo "             MamadDeception                    "




                                                                 


# Check Bash version
bash_major_version=$(bash --version | head -n1 | awk '{print $4}' | cut -d'.' -f1)
if [[ "$bash_major_version" -lt 4 ]]; then
  echo "[!] WARNING: Your Bash version is $bash_major_version.x. This script requires Bash 4 or higher."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "[*] macOS detected."
    if ! command -v brew &> /dev/null; then
      echo "[!] Homebrew not found. Please install it first: https://brew.sh/"
      exit 1
    fi
    echo "[*] Installing Bash via Homebrew..."
    brew install bash
    echo "[*] Bash installed. Please re-run this script using the new bash:"
    echo "    /usr/local/bin/bash $0"
    exit 0
  else
    echo "[!] Please upgrade your Bash to version 4.x or higher."
    exit 1
  fi
fi

# Check and install GNU parallel if missing
if ! command -v parallel &> /dev/null; then
    echo "[*] GNU parallel not found. Installing..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y parallel
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null; then
            echo "[!] Homebrew not found. Please install it first: https://brew.sh/"
            exit 1
        fi
        brew install parallel
    else
        echo "[!] Unsupported OS. Please install GNU parallel manually."
        exit 1
    fi
fi

logfile="cyberjson_wcd_results.log"
vuln_flag_file="/tmp/cyberjson_wcd_vuln_flag"
> "$vuln_flag_file"

echo -e "\n[+] Results will be saved to $logfile\n"
echo "==== Web Cache Deception Test Results ====" > "$logfile"

# Extensions to test (45+)
extensions=(
".jpg" ".jpeg" ".png" ".gif" ".css" ".js" ".html" ".htm"
".php" ".asp" ".aspx" ".pdf" ".doc" ".docx" ".xls" ".xlsx"
".zip" ".tar" ".gz" ".rar" ".7z" ".bak" ".old" ".swp" ".sql"
".json" ".xml" ".txt" ".log" ".conf" ".config" ".env" ".db"
".bak.php" ".tmp" ".lock" ".ico" ".csv" ".ini" ".dat" ".bak.old"
"/admin.php" "/random.php" "/index.php" "/sitemap.xml" "/robots.txt"
)

# Query parameters to test (45+)
params=(
"?cb=123" "?user=admin" "?session=deadbeef" "?test=true" "?debug=true"
"?lang=en" "?cache=false" "?no_cache=1" "?download=1" "?format=json"
"?q=cachetest" "?redirect=1" "?file=secret" "?include=../../etc/passwd"
"?callback=alert" "?token=123456" "?access=private" "?preview=true"
"?backup=1" "?raw=1" "?view=source" "?type=public" "?status=1"
"?id=1" "?uuid=xyz" "?filetype=log" "?d=now" "?page=1"
"?action=edit" "?dir=/" "?path=home" "?cachebuster=123" "?nocache=true"
"?source=internal" "?open=true" "?debug=1" "?print=1" "?mode=debug"
"?mobile=true" "?desktop=false" "?version=1" "?old=1" "?test=deception"
)

header_names=(
"Cache-Control" "Cache-Control" "Pragma" "Expires" "Accept-Encoding"
"X-Requested-With" "Referer" "Origin" "X-Forwarded-For" "Forwarded"
"Via" "Connection" "Upgrade-Insecure-Requests" "If-Modified-Since"
"If-None-Match" "TE" "Accept-Language" "DNT" "Keep-Alive"
"Authorization" "Range" "User-Agent" "X-Forwarded-Proto"
"Accept" "Sec-Fetch-Dest" "Sec-Fetch-Mode" "Sec-Fetch-Site"
"Sec-Fetch-User" "X-CSRF-Token" "X-Frame-Options" "Cookie"
"X-Real-IP" "X-Original-URL" "X-Rewrite-URL" "Content-Type"
"Content-Length" "Access-Control-Allow-Origin" "Access-Control-Allow-Headers"
"Host" "X-Api-Version" "X-Powered-By" "X-Cache-Status" "X-Cache"
"X-Source" "X-Debug"
)
header_values=(
"no-cache" "max-age=0" "no-cache" "-1" "gzip, deflate"
"XMLHttpRequest" "https://google.com" "https://evil.com"
"127.0.0.1" "for=127.0.0.1" "1.1 localhost" "close" "1"
"Thu, 01 Jan 1970 00:00:00 GMT" "W/\"etag123\"" "trailers"
"en-US,en;q=0.9" "1" "timeout=5, max=1000"
"Bearer deadbeef" "bytes=0-100" "Mozilla/5.0"
"https" "*/*" "document" "navigate" "same-origin" "?1"
"deadbeef" "DENY" "PHPSESSID=deadbeef" "127.0.0.1"
"/secret/index.php" "/hidden/file.php" "application/json"
"0" "*" "Authorization, Content-Type" "example.com"
"2.0" "PHP/8.2.0" "MISS" "MISS" "scanner" "true"
)

# User-Agents
user_agents=(
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/124.0.0.0"
"Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) Chrome/124.0.0.0"
"Mozilla/5.0 (X11; Ubuntu; Linux x86_64) Firefox/125.0"
"Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) Safari/605.1.15"
"Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) Safari/605.1.15"
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) Edge/124.0.2478.80"
"Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) Safari/605.1.15"
"Mozilla/5.0 (Linux; Android 14; Pixel 7) Chrome/124.0.0.0"
"Mozilla/5.0 (Linux; Android 14; Pixel 7 Pro) Chrome/124.0.0.0"
"Mozilla/5.0 (X11; Linux x86_64) Chrome/124.0.0.0"
"Mozilla/5.0 (Windows NT 11.0; Win64; x64) Firefox/125.0"
"Mozilla/5.0 (Macintosh; Intel Mac OS X 13_6) Chrome/123.0.0.0"
"Mozilla/5.0 (Linux; Android 14; SM-G998B) Chrome/124.0.0.0"
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) Opera/108.0.0.0"
"Mozilla/5.0 (iPhone; CPU iPhone OS 16_7 like Mac OS X) Chrome/124.0.0.0"
"Mozilla/5.0 (Linux; Android 14; Pixel 8) Firefox/125.0"
"Mozilla/5.0 (iPad; CPU OS 16_7 like Mac OS X) Chrome/124.0.0.0"
"Mozilla/5.0 (X11; Linux x86_64) Opera/108.0.0.0"
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) Vivaldi/6.7.3329.39"
"Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) Vivaldi/6.7.3329.39"
)

user_agents_str="${user_agents[*]}"
threads=10

test_url() {
  url="$1"
  IFS=' ' read -r -a user_agents <<< "$user_agents_str"
  ua="${user_agents[$((RANDOM % ${#user_agents[@]}))]}"

  echo "[+] Testing: $url"

  resp_headers=$(curl -s -I -A "$ua" "$url")
  echo -e "\n[+] URL: $url" >> "$logfile"
  echo "$resp_headers" >> "$logfile"

  vulnerable=0

  if echo "$resp_headers" | grep -iq "Cache-Control: public"; then
    echo "[!!] Public caching detected at $url" >> "$logfile"
    vulnerable=1
  fi

  if echo "$resp_headers" | grep -iqE "X-Cache: HIT|CF-Cache-Status: HIT"; then
    echo "[!!] Cached Response (HIT) detected at $url" >> "$logfile"
    vulnerable=1
  fi

  if [[ $vulnerable -eq 1 ]]; then
    echo "[!!!] $url is VULNERABLE to Web Cache Deception!" >> "$logfile"
    echo "vulnerable" >> "$vuln_flag_file"
  fi

  for i in "${!header_names[@]}"; do
    header="${header_names[$i]}"
    value="${header_values[$i]}"
    resp_custom=$(curl -s -I -A "$ua" -H "$header: $value" "$url")
    echo -e "\n[+] $url with header $header: $value" >> "$logfile"
    echo "$resp_custom" >> "$logfile"
  done
}

export -f test_url
export logfile
export user_agents_str
export vuln_flag_file

while read baseurl; do
  for ext in "${extensions[@]}"; do
    echo "${baseurl}${ext}"
  done
  for param in "${params[@]}"; do
    echo "${baseurl}${param}"
  done
done | parallel -j "$threads" test_url {}

echo -e "\n==============================================="
if grep -q "vulnerable" "$vuln_flag_file"; then
  echo -e "[!!!] One or more endpoints appear VULNERABLE to Web Cache Deception. Check $logfile for details."
else
  echo -e "[+] No vulnerable endpoints detected."
fi
echo "==============================================="
