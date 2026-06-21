#!/bin/bash
# Test the group exercise solution against docker-compose-lab.yml (repository root).
# Prerequisites: from repo root → docker compose -f docker-compose-lab.yml up -d
# Then: cd correction && ./test-lab.sh

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() { echo -e "${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

LAB_CONTAINERS=(
  "ansible-lab-web01"
  "ansible-lab-web02"
  "ansible-lab-web03"
  "ansible-lab-app01"
)

print_step "Checking Docker..."
if ! docker info > /dev/null 2>&1; then
  print_error "Docker is not running"
  exit 1
fi
print_success "Docker is active"

print_step "Checking the 4 lab containers (compose-lab)..."
for c in "${LAB_CONTAINERS[@]}"; do
  if docker ps --format '{{.Names}}' | grep -Fxq "$c"; then
    print_success "$c is running"
  else
    print_error "$c is missing or stopped — from repo root run: docker compose -f docker-compose-lab.yml up -d"
    exit 1
  fi
done

INV_A="inventories/lab/apache2.yml"
INV_N="inventories/lab/nginx.yml"

print_step "Ansible ping (lab inventories)..."
if ansible -i "$INV_A" all -m ping > /dev/null 2>&1; then
  print_success "Apache (lab): ping OK"
else
  print_error "Apache ping failed (lab)"
  exit 1
fi

if ansible -i "$INV_N" all -m ping > /dev/null 2>&1; then
  print_success "Nginx (lab): ping OK"
else
  print_error "Nginx ping failed (lab)"
  exit 1
fi

print_step "Apache2 playbook..."
ansible-playbook -i "$INV_A" playbooks/play-apache2.yml
print_success "Apache2 playbook OK"

print_step "Nginx playbook..."
ansible-playbook -i "$INV_N" playbooks/play-nginx.yml
print_success "Nginx playbook OK"

print_step "Checking services inside containers..."
for c in ansible-lab-web01 ansible-lab-web02; do
  if docker exec "$c" sh -c 'service apache2 status 2>/dev/null | grep -q "apache2 is running"'; then
    print_success "apache2 service active in $c"
  elif docker exec "$c" sh -c 'curl -sf http://127.0.0.1:80 | grep -qi "Apache2 Server"'; then
    print_success "Apache2 Server page served on $c (confirm apache2 holds port 80 on a fresh lab)"
  else
    print_warning "Apache: no running service or expected page on $c — try: docker compose -f docker-compose-lab.yml down && up -d then rerun this script"
  fi
done

for c in ansible-lab-web03 ansible-lab-app01; do
  if docker exec "$c" service nginx status 2>/dev/null | grep -q "nginx is running"; then
    print_success "Nginx active in $c"
  else
    print_warning "Nginx may be inactive in $c"
  fi
done

print_step "HTTP pages (from inside containers)..."
if docker exec ansible-lab-web01 sh -c 'curl -sf http://127.0.0.1:80 | grep -qi apache'; then
  print_success "Apache page (web01)"
else
  print_warning "Apache page (web01) — check port 80 / content"
fi
if docker exec ansible-lab-web03 sh -c 'curl -sf http://127.0.0.1:8080 | grep -qi nginx || curl -sf http://127.0.0.1:80 | grep -qi nginx'; then
  print_success "Nginx page (web03)"
else
  print_warning "Nginx page (web03) — try curl on :8080 or :80"
fi

echo ""
echo -e "${GREEN}Lab tests finished.${NC}"
echo "Note: the lab does not expose HTTP ports on the host; test with docker exec curl as above."
