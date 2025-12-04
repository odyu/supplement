
# Default entrypoint
install: check-git ## OSを自動判定してインストールを実行
	@echo "=== Supplement Installer (Make) ==="
	@echo "Repository Root: $(CURDIR)"
	@OS=$$(uname -s); \
	case "$$OS" in \
	  Darwin*) echo "Detected OS: macOS"; $(MAKE) install-mac ;; \
	  Linux*)  if [ -f /etc/arch-release ]; then echo "Detected OS: Omarchy"; $(MAKE) install-omarchy; else echo "Error: Unsupported OS type for this installer"; exit 1; fi ;; \
	  *) echo "Error: Unsupported OS"; exit 1 ;; \
	esac
	@$(MAKE) status
	@echo "=== All Installation Scripts Completed Successfully ==="

install-mac: ## macOS向けセットアップを実行
	@echo ">>> Starting macOS Setup..."
	@chmod +x mac/install.sh || true
	@./mac/install.sh

install-omarchy: ## Omarchy向けセットアップを実行
	@echo ">>> Starting Omarchy Setup..."
	@if [ -f /etc/arch-release ]; then \
	  echo "Arch detected."; \
	else \
	  echo "Warning: This script is optimized for Omarchy (Arch)."; \
	fi
	@chmod +x omarchy/install.sh || true
	@./omarchy/install.sh

status: ## OSを表示し、git statusを確認。未コミット変更があれば警告を出す
	@OS=$$(uname -s); if [ "$$OS" = "Darwin" ]; then echo "OS: macOS"; elif [ -f /etc/arch-release ]; then echo "OS: Omarchy"; else echo "OS: Unknown"; fi
	@if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then \
	  if [ -n "$$(git status --porcelain)" ]; then \
	    echo "Change supplement files:"; \
	    git status --short; \
	  fi; \
	fi

check-git: ## make実行前に未コミット変更があればエラー終了（再現性担保）
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
help: ## 利用可能なターゲット一覧を表示
	@echo "Usage: make <target>"; \
	echo "\nTargets:"; \
	awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_.-]+:.*## / {printf "  %-24s %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.PHONY: install install-mac install-omarchy check-git status help