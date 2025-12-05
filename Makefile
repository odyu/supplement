# --- Targets ---

# Default entrypoint
install: status ## Omarchy と macOS 用の supplement をインストール
	@OS=$$(uname -s); \
	case "$$OS" in \
	  Darwin*) $(MAKE) install-mac ;; \
	  Linux*)  if [ -f /etc/arch-release ]; then echo "Detected OS: Omarchy"; $(MAKE) install-omarchy; else echo "Error: Unsupported OS"; exit 1; fi ;; \
	  *) echo "Error: Unsupported OS"; exit 1 ;; \
	esac

status: ## OSを表示し、git statusを確認
	@chmod +x bin/status
	@bin/status

help: ## 利用可能なターゲット一覧を表示
	@echo "Usage: make <target>"; \
	echo "\nTargets:"; \
	awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_.-]+:.*## / {printf "  %-24s %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

# --- Private / Internal Targets ---

install-mac:
	@chmod +x mac/install
	@./mac/install

install-omarchy:
	@chmod +x omarchy/install
	@./omarchy/install

.PHONY: install status help install-mac install-omarchy