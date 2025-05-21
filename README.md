






# CyberJson Web Cache Deception Tester 


**Twitter/X:**  [@m0x_mw4_d](https://x.com/m0x_mw4_d)
**Instagram:** [@m0x_mw4_d](https://instagram.com/m0x_mw4_d)
---









<pre> ```
__        __   _        ____           _          
\ \      / /__| |__    / ___|__ _  ___| |__   ___ 
 \ \ /\ / / _ \ '_ \  | |   / _` |/ __| '_ \ / _ \
  \ V  V /  __/ |_) | | |__| (_| | (__| | | |  __/
   \_/\_/ \___|_.__/   \____\__,_|\___|_| |_|\___|
 ____                      _   _                  
|  _ \  ___  ___ ___ _ __ | |_(_) ___  _ __       
| | | |/ _ \/ __/ _ \ '_ \| __| |/ _ \| '_ \      
| |_| |  __/ (_|  __/ |_) | |_| | (_) | | | |     
|____/ \___|\___\___| .__/ \__|_|\___/|_| |_|     
                    |_|                                                             _        
  _ __ ___   __ _ _ __ ___   __ _  __| |       
 | '_ ` _ \ / _` | '_ ` _ \ / _` |/ _` |       
 | | | | | | (_| | | | | | | (_| | (_| |       
 |_| |_| |_|\__,_|_| |_| |_|\__,_|\__,_|       
   ___ _   _| |__   ___ _ __(_)___  ___  _ __  
  / __| | | | '_ \ / _ \ '__| / __|/ _ \| '_ \ 
 | (__| |_| | |_) |  __/ |  | \__ \ (_) | | | |
  \___|\__, |_.__/ \___|_| _/ |___/\___/|_| |_|
       |___/              |__/                 

</pre>





## Overview

This Bash script performs automated testing for **Web Cache Deception (WCD)** vulnerabilities on given URLs.  
It tests multiple URL extensions, query parameters, and custom headers to identify caching misconfigurations that could lead to sensitive data exposure.

The script supports multi-threaded execution using GNU Parallel and randomizes user-agents to mimic real browsing behavior.

---

## Features

- Tests 45+ common extensions and query parameters
- Tests 45+ custom HTTP headers with multiple values
- Randomized User-Agent header rotation (8+ popular user agents)
- Multi-threaded requests using GNU Parallel (default 10 threads)
- Auto-installs GNU Parallel and upgrades Bash (macOS/Linux support)
- Logs all HTTP response headers and highlights potential vulnerabilities
- Outputs concise vulnerability alerts with URL and caching details

---

## Installation & Requirements

- Bash 4.x or higher (script auto-installs on macOS with Homebrew)
- GNU Parallel (auto-installed if missing)
- curl (command line HTTP client)

---

## Usage

1. Clone the repository:

```bash
git clone https://github.com/yourusername/mamad_WebCacheDeception.git
cd mamad_WebCacheDeception

2. Prepare a text file (targets.txt) with one base URL per line:

https://example.com/page
https://targetsite.com/app


3:Run the script, feeding the URLs as input:


cat targets.txt | ./cyberjson_web_cache_tester.sh

OR

echo "https://example.com/admin/user/profile.php" |  ./cyberjson_web_cache_tester.sh


The script will:

    Display only the current Target URL being tested for clarity

    Save detailed results and headers to cyberjson_wcd_results.log

    Report if any endpoint is vulnerable to Web Cache Deception


Example Output:

[+] Testing URL: https://example.com/page.jpg
[+] Testing URL: https://example.com/page?cache=false
...

[!!!] One or more endpoints appear VULNERABLE to Web Cache Deception. Check cyberjson_wcd_results.log for details.



Contributing

Feel free to open issues or submit pull requests!
I welcome improvements, additional header tests, or enhanced detection logic.


License

MIT License © 2025 cyberjsonp
