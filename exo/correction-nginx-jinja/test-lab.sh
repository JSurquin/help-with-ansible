#!/usr/bin/env bash
# Test the solution against docker-compose-lab.yml (repository root).
# Usage: from repo root → docker compose -f docker-compose-lab.yml up -d
#        then: cd exo/correction-nginx-jinja && ./test-lab.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$(dirname "$0")"

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==>${NC} Checking Docker..."
docker info >/dev/null 2>&1 || { echo -e "${RED}Docker unavailable${NC}"; exit 1; }

for c in ansible-lab-web01 ansible-lab-web02 ansible-lab-web03; do
  if ! docker ps --format '{{.Names}}' | grep -Fxq "$c"; then
    echo -e "${RED}Container $c missing. Run: docker compose -f $ROOT/docker-compose-lab.yml up -d${NC}"
    exit 1
  fi
done
echo -e "${GREEN}✓${NC} Lab web containers present"

echo -e "${BLUE}==>${NC} ansible-playbook..."
ansible-playbook -i inventory.yml playbook.yml

echo -e "${BLUE}==>${NC} Checks inside containers..."
for c in ansible-lab-web01 ansible-lab-web02 ansible-lab-web03; do
  docker exec "$c" nginx -t
  code="$(docker exec "$c" python3 -c "import urllib.request; r=urllib.request.urlopen('http://127.0.0.1:8080'); print(r.status)")"
  if [[ "$code" != "200" ]]; then
    echo -e "${RED}HTTP $code on $c${NC}"
    exit 1
  fi
  echo -e "${GREEN}✓${NC} $c : nginx -t OK, HTTP 200"
done

echo -e "${GREEN}All tests passed.${NC}"
