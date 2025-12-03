.PHONY: install install-mac install-omarchy check-git

# Default entrypoint
install: check-git
	@echo "=== Supplement Installer (Make) ==="
	@echo "Repository Root: $(CURDIR)"
	@OS=$$(uname -s); \
	case "$$OS" in \
	  Darwin*) echo "Detected OS: macOS"; $(MAKE) install-mac ;; \
	  Linux*)  echo "Detected OS: Linux"; $(MAKE) install-omarchy ;; \
	  *) echo "Error: Unsupported OS type: $$OS"; exit 1 ;; \
	esac
	@echo "=== All Installation Scripts Completed Successfully ==="

install-mac:
	@echo ">>> Starting macOS Setup..."
	@chmod +x mac/install.sh || true
	@./mac/install.sh

install-omarchy:
	@echo ">>> Starting Omarchy (Linux) Setup..."
	@if [ -f /etc/arch-release ]; then \
	  echo "Arch Linux detected."; \
	else \
	  echo "Warning: This script is optimized for Omarchy (Arch Linux)."; \
	fi
	@chmod +x omarchy/install.sh || true
	@./omarchy/install.sh

check-git:
	@# Skip if not inside a git repo
	@if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then \
	  if [ -n "$$(git status --porcelain)" ]; then \
	    echo "---------------------------------------"; \
	    echo "[ERROR] Repository is dirty (uncommitted changes)."; \
	    echo "Gitリポジトリに未コミットの変更があります。"; \
	    echo "再現性を保つため、commit または stash してから実行してください。"; \
	    echo "---------------------------------------"; \
	    git status --short; \
	    exit 1; \
	  fi; \
	fi
