#!/bin/bash
# Resource Usage Monitoring Script
# This script displays resource usage for all containers

set -e

echo "=== Container Resource Usage ==="
echo "Timestamp: $(date)"
echo ""

# Docker stats
echo "Container Statistics:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"

echo ""
echo "=== Volume Usage ==="
docker system df -v | grep -A 20 "VOLUME NAME"

echo ""
echo "=== Image Usage ==="
docker system df | grep -A 5 "Images"

echo ""
echo "=== Network Usage ==="
docker network ls
docker network inspect self-hosted-ai-starter-kit_demo 2>/dev/null | grep -A 10 "Containers" || echo "Network not found"

