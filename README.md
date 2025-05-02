**FortiOS Symlink Backdoor Hunter
**
A shell script to detect symlink-based backdoors targeting Fortinet FortiGate devices. It scans known FortiOS directories for malicious symbolic links and offers an optional full filesystem scan for additional threats.

🚀 Features

Scans Fortinet-specific directories:

/data/etc/tls/locallang/

/data/lib/webssl/

/data/etc/tls/

Detects symbolic links pointing to sensitive paths like /etc/, /root/, ../, etc.

Verbose output for full visibility into each step

Optional full filesystem symlink scan (Y/N prompt)

Generates a timestamped report with findings and remediation steps

Colorful ASCII banner for visibility

📦 Requirements

FortiGate with shell access (CLI > execute shell)

sh shell available

Basic UNIX utilities like find, readlink, grep, awk

🛠 Usage

Upload the script to your FortiGate device.

From the CLI:

execute shell
sh /path/to/symlink_backdoor_hunt.sh

Follow the prompt when asked whether to scan the full filesystem.

Check the generated report file (e.g., symlink_backdoor_report_20250503_145812.txt) for findings.

📄 Output Example

🚨 Malicious symlink spotted:
    Link: /data/etc/tls/locallang/en -> /etc/shadow
    Remove: rm -f "/data/etc/tls/locallang/en"

🧹 Remediation

If any malicious links are detected:

Remove them manually with rm -f

Upgrade to FortiOS 7.6.3 or later

Rotate all credentials and API keys

Audit and limit web/SSL VPN access

🔐 Disclaimer

This script is provided for forensic and security operations purposes. Run it at your own risk in production environments. Always test in staging before deployment.
