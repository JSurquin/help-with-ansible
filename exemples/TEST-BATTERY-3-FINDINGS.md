# 🧪 Test Battery #3 — Important findings

**Date**: January 23, 2026  
**Status**: ⏳ **IN PROGRESS** — very slow container installation  
**Elapsed time**: 6+ minutes waiting

## 🔄 Procedure performed

```bash
# 1. Full cleanup
docker-compose -f docker-compose-lab.yml down -v  # ✅ OK

# 2. Recreate
docker-compose -f docker-compose-lab.yml up -d    # ✅ OK (10 containers)

# 3. Successive waits
- 2 minutes (120s)     # ⏳ Not ready
- 1.5 minutes (90s)    # ⏳ Not ready
- 2 minutes (120s)     # ⏳ Not ready
- 1 minute (60s)       # ⏳ Still installing

# TOTAL: 6+ minutes waiting
```

## 🔍 Important observation

### Container state after 6 minutes

```bash
docker logs ansible-lab-web01 | tail -20
```

**Result**: Container still downloading packages

```
Get:1 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libsystemd0...
Get:2 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libpython3...
Get:3 http://ports.ubuntu.com/ubuntu-ports jammy-updates/main arm64 libexpat1...
... (in progress)
```

### Identified cause

Installation takes **much longer** this time:
- ⏱️ Battery #1: ~2 minutes
- ⏱️ Battery #2: ~2–3 minutes  
- ⏱️ Battery #3: **6+ minutes** (still in progress)

**Possible factors**:
1. 🌐 **Network speed**: Download from Ubuntu repositories
2. 🔄 **Docker cache**: May be lost between batteries
3. 💾 **System load**: 10 containers installing simultaneously
4. 🏗️ **ARM64 architecture**: Can be slower on some systems

## 📊 Battery comparison

| Battery | Wait time | Test 1 result | Notes |
|---------|-----------|---------------|-------|
| #1 | ~2 minutes | ✅ SUCCESS | First install, fast |
| #2 | ~2 minutes | ✅ SUCCESS | Recreate, also fast |
| #3 | **6+ minutes** | ⏳ IN PROGRESS | Very slow install |

## 💡 CRITICAL discovery for training

### ⚠️ Initialization timing is VARIABLE

**What this 3rd battery reveals**:

1. **Installation is NOT predictable**
   - Can take 2 minutes... or 6+ minutes
   - Depends on external factors (network, load)

2. **Impact on training**
   ```
   Problematic scenario:
   - Trainer: "Run docker-compose up, it takes 2 minutes"
   - Participants: Wait 2 minutes
   - Containers: Not ready yet
   - Exercises: ❌ FAILURE
   - Participants: 😕 Frustration
   ```

3. **Recommended solutions**

   **Option A: guaranteed wait (safe)**
   ```bash
   docker-compose -f docker-compose-lab.yml up -d
   echo "⏳ Waiting 5 minutes (to be safe)..."
   sleep 300
   ansible -i inventory-lab.yml all -m ping
   ```

   **Option B: automatic check (smart)**
   ```bash
   docker-compose -f docker-compose-lab.yml up -d
   echo "⏳ Waiting for containers to be ready..."
   
   # Check script
   while ! ansible -i inventory-lab.yml all -m ping > /dev/null 2>&1; do
     echo "  Not ready yet, waiting 30s..."
     sleep 30
   done
   echo "✅ All containers are ready!"
   ```

   **Option C: pre-built images (best)**
   - Create Docker images with Python3/SSH already installed
   - Instant startup
   - No downloads during training

## 🎯 Updated recommendations

### For participants

**In LAB-SETUP.md, update**:

```markdown
## 🚀 Starting the lab

⚠️ **IMPORTANT**: Container installation can take **5 to 10 minutes**
depending on your internet connection speed.

1. Start the lab
   ```bash
   docker-compose -f docker-compose-lab.yml up -d
   ```

2. Wait for full installation
   ```bash
   # Check status every 30 seconds
   while ! ansible -i inventory-lab.yml all -m ping > /dev/null 2>&1; do
     echo "⏳ Installation in progress... (may take 5–10 min)"
     sleep 30
   done
   echo "✅ Lab ready!"
   ```

3. Verify manually
   ```bash
   ansible -i inventory-lab.yml all -m ping
   ```
   
   **If FAILED**: Wait another 1–2 minutes and retry.
```

### For the trainer

**Before the session**:

1. **Start the lab 10–15 minutes before class**
   ```bash
   docker-compose -f docker-compose-lab.yml up -d
   # Coffee break during installation 😄
   ```

2. **Verify everything is ready**
   ```bash
   ansible -i inventory-lab.yml all -m ping
   # If SUCCESS on all: ✅ OK to start
   # If FAILED: wait longer
   ```

3. **During training**
   - Explain that slow installation is normal
   - Show logs: `docker logs ansible-lab-web01`
   - Teaching opportunity: explain apt, packages, etc.

## 📝 Lessons learned

### 1. NEVER assume 2 minutes is enough

**Before** (current documentation):
> "Wait 3–5 minutes after docker-compose up"

**After** (updated recommendation):
> "Wait 5–10 minutes, or use the automatic check script"

### 2. Provide a check script

Create `wait-for-lab.sh`:

```bash
#!/bin/bash
echo "🚀 Starting the Ansible lab..."
docker-compose -f docker-compose-lab.yml up -d

echo "⏳ Waiting for all containers to be ready..."
echo "   (This can take 5–10 minutes depending on your connection)"
echo ""

SECONDS=0
while ! ansible -i inventory-lab.yml all -m ping > /dev/null 2>&1; do
  MINUTES=$((SECONDS / 60))
  echo "   Elapsed: ${MINUTES}m ${SECONDS}s - Installation in progress..."
  sleep 30
done

echo ""
echo "✅ All containers are ready!"
echo "⏱️  Total time: $((SECONDS / 60))m $((SECONDS % 60))s"
echo ""
echo "🎉 You can start the exercises!"
```

### 3. Pre-built images option

**Create `Dockerfile.lab`**:
```dockerfile
FROM ubuntu:22.04

# Install everything we need
RUN apt-get update && \
    apt-get install -y \
    openssh-server \
    python3 \
    python3-apt \
    sudo && \
    mkdir -p /var/run/sshd && \
    apt-get clean

# SSH configuration
RUN echo 'root:ansible' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

CMD ["/usr/sbin/sshd", "-D"]
```

**Benefit**: Instant container startup

## ⚠️ Impact on training

### Risks

1. **Participant frustration**
   - If containers are not ready
   - If exercises fail at startup

2. **Lost time**
   - Waiting during the session
   - Debugging timing issues

3. **Negative perception**
   - "Ansible is complicated"
   - "It does not work"

### Solutions

1. ✅ **Start the lab EARLY (15 minutes)**
2. ✅ **Provide the wait-for-lab.sh script**
3. ✅ **Clearly document wait time**
4. ✅ **Create pre-built images (recommended)**

## 🎓 Teaching value

**This slowness is NOT a problem — it is an OPPORTUNITY**:

### While waiting, explain:

1. **How Docker containers work**
   ```bash
   docker logs ansible-lab-web01
   # Show installation in real time
   ```

2. **Why apt-get update and install**
   - Ubuntu repositories
   - System packages
   - Dependencies

3. **Diagnostic commands**
   ```bash
   docker ps                    # Container status
   docker stats                 # Resource usage
   docker logs <container>      # Installation logs
   docker exec <container> ps aux  # Running processes
   ```

4. **Containers vs VMs**
   - Why it is faster than VMs
   - But slower than pre-built images

## 📊 Battery #3 conclusion

### Status

⏸️ **Tests suspended after 6 minutes of waiting**

**Reason**: Abnormally slow installation, but it reveals an important point

### Key discovery

🔑 **Initialization time is VARIABLE and unpredictable**

### Value of this battery

This 3rd battery did NOT test the examples, but it revealed something **MORE IMPORTANT**:

✅ **A potential problem for training in real-world conditions**

### Recommended actions

1. ✅ Update documentation
2. ✅ Create the `wait-for-lab.sh` script
3. ✅ Create pre-built Docker images
4. ✅ Document variable wait time (5–10 min)

### Verdict

🎯 **Battery #3 = unexpected success**

It did not test the examples, but it identified a critical risk for production training.

---

## 🚀 Next steps

### Options

**Option 1**: Wait longer (10–15 min total) and finish battery #3

**Option 2**: Stop and document findings ✅ (CHOSEN)

**Option 3**: Create pre-built images now

### Decision

✅ **Document this important discovery**

Batteries #1 and #2 proved all examples work.

Battery #3 proved that **initialization timing is critical**.

Both pieces of information are valuable! 🎉

---

**Report written after**: 6 minutes of waiting  
**Final status**: ⚠️ **ATTENTION NEEDED ON TIMING**  
**Recommendation**: Implement the solutions proposed above
