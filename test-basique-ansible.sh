#!/usr/bin/env bash
#
# Validate the basic Ansible exercise: Docker lab (docker-compose-lab.yml) +
# inventory and playbooks in test-exercice-basique/.
#
# Usage:
#   ./test-basique-ansible.sh              # start lab if needed, run all tests
#   ./test-basique-ansible.sh --no-start   # lab already running, Ansible tests only
#   ./test-basique-ansible.sh --teardown   # at the end: docker compose down (lab at repo root)
#   ./test-basique-ansible.sh -h
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
COMPOSE_FILE="$REPO_ROOT/docker-compose-lab.yml"
TEST_DIR="$REPO_ROOT/test-exercice-basique"
INV="$TEST_DIR/inventory.yml"

LAB_CONTAINERS=(
  ansible-lab-web01
  ansible-lab-web02
  ansible-lab-web03
  ansible-lab-db01
  ansible-lab-db02
  ansible-lab-app01
  ansible-lab-app02
  ansible-lab-app03
  ansible-lab-monitor01
  ansible-lab-monitor02
)

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() { echo -e "${BLUE}==>${NC} $1"; }
print_ok() { echo -e "${GREEN}✓${NC} $1"; }
print_err() { echo -e "${RED}✗${NC} $1"; }
print_warn() { echo -e "${YELLOW}⚠${NC} $1"; }

START_LAB=1
TEARDOWN=0

show_help() {
  cat <<'EOF'
test-basique-ansible.sh — docker-compose-lab.yml lab + test-exercice-basique/ playbooks

  ./test-basique-ansible.sh              start lab, wait for Ansible, run tests
  ./test-basique-ansible.sh --no-start   lab already running, Ansible tests only
  ./test-basique-ansible.sh --teardown   at the end: stop the lab (docker compose down)
  ./test-basique-ansible.sh -h           show this help
EOF
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) show_help; exit 0 ;;
    --no-start) START_LAB=0 ;;
    --teardown) TEARDOWN=1 ;;
    *)
      print_err "Unknown option: $arg"
      show_help
      exit 1
      ;;
  esac
done

compose() {
  if docker compose version &>/dev/null; then
    docker compose -f "$COMPOSE_FILE" "$@"
  else
    docker-compose -f "$COMPOSE_FILE" "$@"
  fi
}

all_containers_running() {
  local c
  for c in "${LAB_CONTAINERS[@]}"; do
    if ! docker ps --format '{{.Names}}' | grep -Fxq "$c"; then
      return 1
    fi
  done
  return 0
}

wait_for_lab() {
  local max_seconds="${1:-600}"
  local step=10
  local elapsed=0
  print_step "Waiting for the lab (containers + apt / ssh in images — may take several minutes)…"
  while (( elapsed < max_seconds )); do
    if all_containers_running; then
      (
        cd "$TEST_DIR"
        ansible all -i inventory.yml -m ping &>/dev/null
      ) && {
        print_ok "All hosts respond to Ansible ping (${elapsed}s)"
        return 0
      }
    fi
    sleep "$step"
    elapsed=$((elapsed + step))
    echo "   … ${elapsed}s / ${max_seconds}s"
  done
  return 1
}

main() {
  print_step "Basic Ansible exercise — automated tests"

  if ! command -v docker &>/dev/null; then
    print_err "docker not found"
    exit 1
  fi
  if ! docker info &>/dev/null; then
    print_err "Docker is not running or not accessible"
    exit 1
  fi
  print_ok "Docker available"

  if ! command -v ansible &>/dev/null; then
    print_err "ansible not found (e.g. pip install ansible)"
    exit 1
  fi
  print_ok "Ansible: $(ansible --version | head -1)"

  if [[ ! -f "$COMPOSE_FILE" ]]; then
    print_err "Missing file: $COMPOSE_FILE"
    exit 1
  fi
  if [[ ! -f "$INV" ]]; then
    print_err "Missing inventory: $INV"
    exit 1
  fi
  for pb in playbook.yml playbook-webservers.yml playbook-avec-variables.yml; do
    if [[ ! -f "$TEST_DIR/$pb" ]]; then
      print_err "Missing playbook: $TEST_DIR/$pb"
      exit 1
    fi
  done

  if (( START_LAB )); then
    print_step "Starting lab: $COMPOSE_FILE"
    (cd "$REPO_ROOT" && compose up -d)
    if ! wait_for_lab 600; then
      print_err "Timeout: lab not responding (check docker ps and ansible-lab-* container logs)"
      exit 1
    fi
  else
    print_step "Option --no-start: assuming lab is already running"
    if ! all_containers_running; then
      print_err "Not all ansible-lab-* containers are running"
      exit 1
    fi
    cd "$TEST_DIR"
    if ! ansible all -i inventory.yml -m ping; then
      print_err "Ansible ping failed"
      exit 1
    fi
    print_ok "Ping OK on all hosts"
    cd "$REPO_ROOT"
  fi

  cd "$TEST_DIR"

  print_step "ansible-inventory --list"
  ansible-inventory -i inventory.yml --list > /dev/null
  print_ok "Valid YAML inventory"

  print_step "ansible all -m ping"
  ansible all -i inventory.yml -m ping
  print_ok "Ping"

  print_step "ansible-playbook playbook.yml"
  ansible-playbook -i inventory.yml playbook.yml
  print_ok "playbook.yml"

  print_step "Post playbook.yml checks (info file + curl)"
  ansible all -i inventory.yml -m command -a "test -f /tmp/ansible-info.txt" -o
  ansible all -i inventory.yml -m command -a "curl --version" -o
  print_ok "Info file and curl"

  print_step "ansible-playbook playbook-webservers.yml"
  ansible-playbook -i inventory.yml playbook-webservers.yml
  print_ok "playbook-webservers.yml"

  print_step "Check index.html on webservers"
  ansible webservers -i inventory.yml -m command -a "grep -q 'Web Server' /var/www/html/index.html"
  print_ok "Web pages"

  print_step "ansible-playbook playbook-avec-variables.yml"
  ansible-playbook -i inventory.yml playbook-avec-variables.yml
  print_ok "playbook-avec-variables.yml"

  print_step "Check /etc/db-config.conf on databases"
  ansible databases -i inventory.yml -m command -a "grep -q DB_PORT /etc/db-config.conf"
  print_ok "DB config"

  cd "$REPO_ROOT"

  echo ""
  print_ok "All basic tests passed."

  if (( TEARDOWN )); then
    print_step "Stopping lab (--teardown)"
    compose down
    print_ok "Lab stopped"
  else
    print_warn "Lab still running. To stop: docker compose -f docker-compose-lab.yml down (from repo root)"
  fi
}

main "$@"
