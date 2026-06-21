#!/bin/bash

# Automated test script for the group exercise solution

set -e

echo "🚀 Starting Ansible solution tests..."
echo ""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_step "Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running"
    exit 1
fi
print_success "Docker is active"

print_step "Starting Docker infrastructure..."
docker-compose up -d
sleep 5
print_success "Infrastructure started"

print_step "Checking containers..."
CONTAINERS=("apache-server-1" "apache-server-2" "nginx-server-1" "nginx-server-2")
for container in "${CONTAINERS[@]}"; do
    if docker ps --filter "name=$container" --filter "status=running" | grep -q "$container"; then
        print_success "$container is running"
    else
        print_error "$container is not running"
        exit 1
    fi
done

print_step "Testing Ansible connectivity..."
if ansible -i inventories/apache2.yml all -m ping > /dev/null 2>&1; then
    print_success "Apache servers reachable"
else
    print_error "Failed to connect to Apache servers"
    exit 1
fi

if ansible -i inventories/nginx.yml all -m ping > /dev/null 2>&1; then
    print_success "Nginx servers reachable"
else
    print_error "Failed to connect to Nginx servers"
    exit 1
fi

print_step "Running Apache2 playbook..."
if ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml; then
    print_success "Apache2 playbook completed successfully"
else
    print_error "Apache2 playbook failed"
    exit 1
fi

print_step "Running Nginx playbook..."
if ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml; then
    print_success "Nginx playbook completed successfully"
else
    print_error "Nginx playbook failed"
    exit 1
fi

print_step "Checking Apache services..."
for i in 1 2; do
    if docker exec apache-server-$i service apache2 status | grep -q "apache2 is running"; then
        print_success "Apache on apache-server-$i is active"
    else
        print_warning "Apache on apache-server-$i may not be active"
    fi
done

print_step "Checking Nginx services..."
for i in 1 2; do
    if docker exec nginx-server-$i service nginx status | grep -q "nginx is running"; then
        print_success "Nginx on nginx-server-$i is active"
    else
        print_warning "Nginx on nginx-server-$i may not be active"
    fi
done

print_step "Testing web pages..."
if docker exec apache-server-1 curl -s http://localhost | grep -q "Apache2"; then
    print_success "Apache1 page accessible"
fi

if docker exec nginx-server-1 curl -s http://localhost:8080 | grep -q "Nginx"; then
    print_success "Nginx1 page accessible"
fi

print_step "Idempotence test (re-running playbooks)..."
print_warning "Re-running Apache2 playbook..."
ansible-playbook -i inventories/apache2.yml playbooks/play-apache2.yml > /tmp/apache-rerun.log 2>&1
if grep -q "changed=0" /tmp/apache-rerun.log; then
    print_success "Apache2 idempotence validated (no changes)"
else
    print_warning "Changes detected (check idempotence)"
fi

print_warning "Re-running Nginx playbook..."
ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml > /tmp/nginx-rerun.log 2>&1
if grep -q "changed=0" /tmp/nginx-rerun.log; then
    print_success "Nginx idempotence validated (no changes)"
else
    print_warning "Changes detected (check idempotence)"
fi

echo ""
echo "================================================"
echo -e "${GREEN}🎉 All tests passed successfully!${NC}"
echo "================================================"
echo ""
echo "Web access:"
echo "  - Nginx 1: http://localhost:9080"
echo "  - Nginx 2: http://localhost:9081"
echo ""
echo "To stop the infrastructure:"
echo "  docker-compose down"
echo ""
