##############################################################
#  PENTEST LAB — Makefile
#  Shortcuts for managing the Docker lab environment
#
#  Usage:
#    make up          — Start the full lab
#    make down        — Stop everything
#    make kali        — Drop into Kali shell
#    make status      — Show container health
##############################################################

.PHONY: up down restart kali status logs clean reset web-only help

# ── Lab Lifecycle ──────────────────────────────────────────
up:
	@echo "🚀 Starting full pentest lab..."
	docker compose --profile full up -d
	@echo ""
	@echo "✅ Lab started! Access points:"
	@echo "   DVWA       → http://localhost:8080   (admin / password)"
	@echo "   Juice Shop → http://localhost:3000   (admin@juice-sh.op / admin123)"
	@echo "   Metasploit → ssh msfadmin@localhost -p 2222"
	@echo "   Portainer  → https://localhost:9443"
	@echo ""
	@echo "🐚 Drop into Kali: make kali"

web-only:
	@echo "🌐 Starting web targets only (DVWA + Juice Shop)..."
	docker compose --profile web up -d

down:
	@echo "🛑 Stopping lab..."
	docker compose --profile full down

restart:
	docker compose --profile full restart

# ── Attacker Shell ─────────────────────────────────────────
kali:
	@echo "🐉 Entering Kali Linux shell..."
	docker exec -it kali-attacker bash

setup:
	docker exec -it kali-attacker bash /setup.sh

# ── Monitoring ─────────────────────────────────────────────
status:
	@echo "📊 Lab Container Status:"
	@docker compose ps
	@echo ""
	@echo "📡 Network:"
	@docker network ls | grep lab_net || true

logs:
	docker compose logs -f --tail=50

logs-kali:
	docker logs -f kali-attacker

logs-dvwa:
	docker logs -f dvwa-target

# ── Snapshots (save student progress) ──────────────────────
snapshot:
	@read -p "Snapshot name: " name; \
	docker commit kali-attacker kali-student-$$name && \
	echo "✅ Saved snapshot: kali-student-$$name"

restore:
	@docker images | grep kali-student
	@read -p "Restore which snapshot? " name; \
	docker run -it --network pentest-lab_lab_net \
	  --ip 10.10.0.10 kali-student-$$name bash

# ── Cleanup ────────────────────────────────────────────────
clean:
	@echo "🧹 Removing containers and networks (keeping volumes)..."
	docker compose --profile full down --remove-orphans

reset:
	@echo "⚠️  This will DELETE all lab data. Ctrl+C to cancel..."
	@sleep 3
	docker compose --profile full down -v --remove-orphans
	@echo "Lab reset complete."

# ── Help ───────────────────────────────────────────────────
help:
	@echo ""
	@echo "╔════════════════════════════════════════╗"
	@echo "║   🧪 PENTEST LAB — MAKE COMMANDS      ║"
	@echo "╠════════════════════════════════════════╣"
	@echo "║  make up          Start full lab       ║"
	@echo "║  make web-only    DVWA + JuiceShop     ║"
	@echo "║  make down        Stop all services    ║"
	@echo "║  make kali        Open Kali shell      ║"
	@echo "║  make setup       Install Kali tools   ║"
	@echo "║  make status      Container status     ║"
	@echo "║  make logs        Stream all logs      ║"
	@echo "║  make snapshot    Save student state   ║"
	@echo "║  make clean       Remove containers    ║"
	@echo "║  make reset       ⚠ Full reset+wipe   ║"
	@echo "╚════════════════════════════════════════╝"
	@echo ""
