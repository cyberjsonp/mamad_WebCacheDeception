#!/bin/bash

clear

# ASCII Logo and Header
echo "==============================================="
echo " ██████╗ ██╗   ██╗███████╗██████╗              "
echo "██╔═══██╗██║   ██║██╔════╝██╔══██╗             "
echo "██║   ██║██║   ██║█████╗  ██████╔╝             "
echo "██║   ██║██║   ██║██╔══╝  ██╔═══╝              "
echo "╚██████╔╝╚██████╔╝███████╗██║                  "
echo " ╚═════╝  ╚═════╝ ╚══════╝╚═╝                  "
echo "              CyberJson                        "
echo "      Web Cache Deception Tester               "
echo "  Twitter/X: https://x.com/m0x_mw4_d           "
echo "==============================================="
echo

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

# Custom headers (45+)
header_names=( ... )  # keep your original list
header_values=( ... ) # keep your original list

# User-Agents
user_agents=(
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/124.0.0.0"
"Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) Chrome/124.0.0.0"
"Mozilla/5.0 (X11; Ubuntu; Linux x86_64) Firefox/125.0"
"Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) Safari/605.1.15"
"Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) Safari/605.1.15"
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) Edge/124.0.2478.80"
"Mozilla/5.0 (Linux; Android 14; Pixel 7) Chrome/124.0.0.0"
"Mozilla/5.0 (X11; Linux x86_64) Opera/108.0.0.0"
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
