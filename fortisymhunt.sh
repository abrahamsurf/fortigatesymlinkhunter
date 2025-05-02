#!/bin/sh
#
# FortiGate Symlink Backdoor Hunter (v6 - Verbose with Optional Full Scan)
# ----------------------------------------------------
# Scans specific FortiOS web/VPN folders for symlinks
# pointing to sensitive system paths, with verbose output,
# a colorful ASCII banner, and an optional full filesystem scan.
#
# Usage (from the FortiGate CLI):
#   execute shell
#   sh /path/to/fortisymhunt.sh
#

# Color codes for banner
RED="\e[1;31m"
GREEN="\e[1;32m"
BLUE="\e[1;34m"
RESET="\e[0m"

# Intro Banner
echo -e "${BLUE}==============================================${RESET}"
echo -e "${GREEN}   FortiOS Symlink Backdoor Hunter           ${RESET}"
echo -e "${GREEN}           Abraham-Surf                      ${RESET}"
echo -e "${BLUE}==============================================${RESET}\n"

# Report file with timestamp
REPORT="symlink_backdoor_report_$(date +%Y%m%d_%H%M%S).txt"
# Regex for sensitive targets
SENSITIVE="(/etc/|/root/|/config/|\.\./)"
FOUND=0

# Start logging
echo "🔍 FortiGate Symlink Backdoor Hunt" > "$REPORT"
echo "   Date: $(date)" >> "$REPORT"
echo "----------------------------------------------------" >> "$REPORT"

# Verbose start message
echo "Starting scan of known FortiOS web/VPN folders..."

# Scan known directories
echo "Scanning known FortiOS web/VPN folders..."
echo "Scanning known FortiOS web/VPN folders..." >> "$REPORT"
for DIR in \
  "/data/etc/tls/locallang/" \
  "/data/lib/webssl/" \
  "/data/etc/tls/"; do
  if [ -d "$DIR" ]; then
    echo "[VERBOSE] Scanning $DIR ..."
    echo "Scanning $DIR ..." >> "$REPORT"
    find "$DIR" -type l 2>/dev/null | while read -r LINK; do
      TARGET=$(readlink "$LINK")
      echo "$TARGET" | grep -Eq "$SENSITIVE"
      if [ $? -eq 0 ]; then
        FOUND=1
        echo "[!] Malicious symlink spotted: $LINK -> $TARGET"
        echo "🚨 Malicious symlink spotted:" >> "$REPORT"
        echo "    Link:      $LINK" >> "$REPORT"
        echo "    Points to: $TARGET" >> "$REPORT"
        echo "    Remove:    rm -f \"$LINK\"" >> "$REPORT"
      fi
    done
  else
    echo "[WARN] Directory missing: $DIR"
    echo "⚠️  Directory missing: $DIR" >> "$REPORT"
  fi
done

# Prompt for full filesystem scan
printf "\n[?] Would you like to scan the entire filesystem for suspicious symlinks? (Y/N): "
read choice
case "$choice" in
  [Yy]*)
    echo "Scanning entire filesystem (this may take a while)..."
    echo "Scanning entire filesystem for suspicious symlinks..." >> "$REPORT"
    find / -type l -ls 2>/dev/null | grep -E "\.\./|/etc/|/root/" | while read -r LINE; do
      FOUND=1
      LINK_PATH=$(echo "$LINE" | awk '{print $(NF-1)}')
      echo "[!] Suspicious symlink in FS: $LINE"
      echo "🚨 Suspicious symlink found in FS scan:" >> "$REPORT"
      echo "    $LINE" >> "$REPORT"
      echo "    Remove with: rm -f \"$LINK_PATH\"" >> "$REPORT"
    done
    ;;
  *)
    echo "Skipping full filesystem scan."
    echo "Skipped full filesystem scan." >> "$REPORT"
    ;;
esac

# Summary
if [ "$FOUND" -eq 1 ]; then
  echo -e "\n[RESULT] Backdoor or suspicious symlinks detected! Check $REPORT for details."
  echo "‼️  Backdoor or suspicious symlinks detected! ‼️" >> "$REPORT"
  echo "Next steps:" >> "$REPORT"
  echo "  1. Execute the above rm commands to delete symlinks." >> "$REPORT"
  echo "  2. Update FortiOS to 7.6.3 or later." >> "$REPORT"
  echo "  3. Reset all admin passwords & keys." >> "$REPORT"
  echo "  4. Disable unused SSL‑VPN/web interfaces if possible." >> "$REPORT"
else
  echo -e "\n[RESULT] No suspicious symlinks found. Your device appears clean." 
  echo "✅  No suspicious symlinks found. Your device appears clean." >> "$REPORT"
fi

echo "----------------------------------------------------" >> "$REPORT"
echo "Report saved to: $REPORT"
echo -e "\n${GREEN}Scan complete.${RESET}"
