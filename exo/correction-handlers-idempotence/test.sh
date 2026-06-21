#!/usr/bin/env bash
# Validate the handlers + idempotence solution against docker-compose-lab.yml.
# Prerequisites: from repo root → docker compose -f docker-compose-lab.yml up -d
# Then: cd exo/correction-handlers-idempotence && ./test.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$(dirname "$0")"

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

die() { echo -e "${RED}✗${NC} $*" >&2; exit 1; }
ok() { echo -e "${GREEN}✓${NC} $*"; }
step() { echo -e "${BLUE}==>${NC} $*"; }

step "Checking Docker..."
docker info >/dev/null 2>&1 || die "Docker unavailable"

CONTAINER="ansible-lab-web01"
docker ps --format '{{.Names}}' | grep -Fxq "$CONTAINER" || die "Container $CONTAINER missing — run: docker compose -f $ROOT/docker-compose-lab.yml up -d"
ok "Container $CONTAINER present"

INV="inventory.yml"
PB="playbook.yml"

step "Resetting test files inside the container..."
ansible -i "$INV" handler_lab -m ansible.builtin.file -a "path=/tmp/lab_handler_audit.log state=absent" >/dev/null
ansible -i "$INV" handler_lab -m ansible.builtin.file -a "path=/etc/lab-handlers-test.conf state=absent" >/dev/null
ok "Test files cleaned up"

step "1st ansible-playbook (expect changed task + handler run)..."
OUT1="$(mktemp)"
ansible-playbook -i "$INV" "$PB" 2>&1 | tee "$OUT1"
grep -q "RUNNING HANDLER \[Log handler execution\]" "$OUT1" || die "Handler did not run on 1st run"
grep -E 'lab01\s+:\s+.*\bchanged=[1-9][0-9]*\b' "$OUT1" | head -1 | grep -q . || die "1st run: expected changed > 0 for lab01 in PLAY RECAP"

LINES1="$(docker exec "$CONTAINER" sh -c 'wc -l < /tmp/lab_handler_audit.log' | tr -d '[:space:]')"
[[ "$LINES1" == "1" ]] || die "After 1st run: expected 1 line in /tmp/lab_handler_audit.log, got: $LINES1"
ok "1st run OK (handler once, audit log at 1 line)"

step "2nd ansible-playbook (expect idempotence, no handler)..."
OUT2="$(mktemp)"
ansible-playbook -i "$INV" "$PB" 2>&1 | tee "$OUT2"
grep -q "RUNNING HANDLER \[Log handler execution\]" "$OUT2" && die "Handler should not run on 2nd run"
grep -E 'lab01\s+:\s+.*\bchanged=0\b' "$OUT2" | head -1 | grep -q . || die "2nd run: expected changed=0 for lab01 in PLAY RECAP"

LINES2="$(docker exec "$CONTAINER" sh -c 'wc -l < /tmp/lab_handler_audit.log' | tr -d '[:space:]')"
[[ "$LINES2" == "1" ]] || die "After 2nd run: expected still 1 line in audit log, got: $LINES2"
ok "2nd run OK (idempotence, handler not rerun)"

step "3rd run with changed variable (expect re-changed + handler again)..."
OUT3="$(mktemp)"
ansible-playbook -i "$INV" "$PB" -e 'lab_banner=lab-handlers-v2-trigger' 2>&1 | tee "$OUT3"
grep -q "RUNNING HANDLER \[Log handler execution\]" "$OUT3" || die "Handler should run when config changes (3rd run)"
grep -E 'lab01\s+:\s+.*\bchanged=[1-9][0-9]*\b' "$OUT3" | head -1 | grep -q . || die "3rd run: expected changed > 0 for lab01"

LINES3="$(docker exec "$CONTAINER" sh -c 'wc -l < /tmp/lab_handler_audit.log' | tr -d '[:space:]')"
[[ "$LINES3" == "2" ]] || die "After 3rd run: expected 2 lines in audit log, got: $LINES3"
ok "3rd run OK (variable change → handler rerun)"

rm -f "$OUT1" "$OUT2" "$OUT3"
echo -e "${GREEN}All tests passed.${NC}"
