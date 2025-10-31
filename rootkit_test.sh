#!/bin/bash
#
# Rootkit Test Script
# Just for testing not the main file
# Main file is coming soon idk when
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== Kernel Rootkit Test Suite ===${NC}\n"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] Please run as root${NC}"
    exit 1
fi

if ! lsmod | grep -q rootkit; then
    echo -e "${RED}[!] Rootkit module not loaded${NC}"
    echo -e "Load it with: sudo insmod rootkit.ko"
    exit 1
fi

echo -e "${GREEN}[+] Rootkit module is loaded${NC}\n"

echo -e "${YELLOW}[*] Test 1: Hide process by PID${NC}"
echo "[+] Starting background process..."
sleep 300 &
TEST_PID=$!
echo "[+] Test PID: $TEST_PID"
sleep 1

echo "[+] Process visible before hiding:"
ps aux | grep $TEST_PID | grep -v grep

echo "[+] Hiding process with kill -31..."
kill -31 $TEST_PID
sleep 1

echo "[+] Checking if process is hidden:"
if ps aux | grep $TEST_PID | grep -v grep > /dev/null; then
    echo -e "${RED}[-] FAIL: Process still visible${NC}"
else
    echo -e "${GREEN}[+] SUCCESS: Process is hidden${NC}"
fi

echo "[+] Process still exists in /proc:"
ls -la /proc/$TEST_PID > /dev/null 2>&1 && echo "  Yes, /proc/$TEST_PID exists"

echo "[+] Unhiding process with kill -32..."
kill -32 $TEST_PID
sleep 1

echo "[+] Process visible after unhiding:"
ps aux | grep $TEST_PID | grep -v grep

kill $TEST_PID 2>/dev/null
echo ""

echo -e "${YELLOW}[*] Test 2: Hide process by name${NC}"
echo "[+] Creating evil_process..."

cat > /tmp/evil_test.sh << 'EOF'
#!/bin/bash
while true; do
    sleep 1
done
EOF

chmod +x /tmp/evil_test.sh

cp /tmp/evil_test.sh /tmp/evil_daemon
/tmp/evil_daemon &
EVIL_PID=$!

sleep 1

echo "[+] Evil process PID: $EVIL_PID"
echo "[+] Checking if process is auto-hidden (name starts with 'evil_'):"
if ps aux | grep evil_daemon | grep -v grep > /dev/null; then
    echo -e "${RED}[-] FAIL: Process still visible${NC}"
else
    echo -e "${GREEN}[+] SUCCESS: Process is auto-hidden by name${NC}"
fi

kill $EVIL_PID 2>/dev/null
rm -f /tmp/evil_test.sh /tmp/evil_daemon
echo ""

echo -e "${YELLOW}[*] Test 3: Rootkit control interface${NC}"
if [ -f /proc/rootkit_control ]; then
    echo -e "${GREEN}[+] Control interface found at /proc/rootkit_control${NC}"
    echo "[+] Current status:"
    cat /proc/rootkit_control
else
    echo -e "${RED}[-] FAIL: Control interface not found${NC}"
fi
echo ""

echo -e "${YELLOW}[*] Test 4: Multiple hidden processes${NC}"
echo "[+] Starting 5 test processes..."

PIDS=()
for i in {1..5}; do
    sleep 300 &
    PIDS+=($!)
done

echo "[+] Hiding all processes..."
for pid in "${PIDS[@]}"; do
    kill -31 $pid
done
sleep 1

echo "[+] Checking visibility:"
HIDDEN_COUNT=0
for pid in "${PIDS[@]}"; do
    if ! ps aux | grep $pid | grep -v grep > /dev/null; then
        ((HIDDEN_COUNT++))
    fi
done

echo -e "${GREEN}[+] Hidden: $HIDDEN_COUNT/5 processes${NC}"

for pid in "${PIDS[@]}"; do
    kill $pid 2>/dev/null
done
echo ""

echo -e "${YELLOW}[*] Test 5: Kernel messages${NC}"
echo "[+] Recent rootkit kernel messages:"
dmesg | grep -i rootkit | tail -10
echo ""

echo -e "${YELLOW}=== Test Summary ===${NC}"
echo "[+] All tests completed"
echo "[+] Check /proc/rootkit_control for hidden PIDs"
echo "[+] Use 'dmesg | grep rootkit' for kernel logs"
echo ""
echo -e "${YELLOW}Commands:${NC}"
echo "  kill -31 <PID>  - Hide process"
echo "  kill -32 <PID>  - Unhide process"
echo "  cat /proc/rootkit_control - Show status"
echo ""
echo -e "${RED}[!] Remember: This is for educational purposes only${NC}"
echo -e "${RED}[!] Use only in authorized test environments${NC}"
