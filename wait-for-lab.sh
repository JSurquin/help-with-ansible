#!/bin/bash

# Start the Ansible Docker lab and wait until it is ready
# Usage: ./wait-for-lab.sh

set -e

echo "🚀 Starting the Ansible Docker lab..."
echo ""

# Start containers
docker-compose -f docker-compose-lab.yml up -d

echo "✅ 10 containers started"
echo ""
echo "⏳ Waiting for all containers to be ready..."
echo "   📝 This may take 5-10 minutes depending on your internet connection"
echo "   💡 Containers install SSH, Python3, and sudo on first boot"
echo ""

SECONDS=0
LAST_CHECK=0

# Wait until all containers respond to Ansible ping
while true; do
  # Test Ansible every 30 seconds
  if ansible -i inventory-lab.yml all -m ping > /dev/null 2>&1; then
    break
  fi
  
  ELAPSED=$((SECONDS))
  MINUTES=$((ELAPSED / 60))
  SECS=$((ELAPSED % 60))
  
  # Print a message every 30 seconds
  if [ $((ELAPSED - LAST_CHECK)) -ge 30 ]; then
    echo "   ⏱️  ${MINUTES}m ${SECS}s - Installation in progress..."
    LAST_CHECK=$ELAPSED
  fi
  
  sleep 5
done

TOTAL_MINUTES=$((SECONDS / 60))
TOTAL_SECS=$((SECONDS % 60))

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All containers are ready!"
echo "⏱️  Total time: ${TOTAL_MINUTES}m ${TOTAL_SECS}s"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎉 You can now start the exercises!"
echo ""
echo "📋 Useful commands:"
echo "   ansible -i inventory-lab.yml all -m ping        # Test connectivity"
echo "   docker ps                                        # List containers"
echo "   docker logs ansible-lab-web01                    # View logs"
echo ""
