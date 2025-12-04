# Default entrypoint
install: status
	@OS=$$(uname -s); \
	case "$$OS" in \
	  Darwin*) $(MAKE) install-mac ;; \
	  Linux*)  if [ -f /etc/arch-release ]; then echo "Detected OS: Omarchy"; $(MAKE) install-omarchy; else echo "Error: Unsupported OS"; exit 1; fi ;; \
	  *) echo "Error: Unsupported OS"; exit 1 ;; \
	esac

status: prepare ## OSを表示し、git statusを確認
	@bin/status

help: ## 利用可能なターゲット一覧を表示
	@echo "Usage: make <target>"; \
	echo "\nTargets:"; \
	awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_.-]+:.*## / {printf "  %-24s %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

# --- Private / Internal Targets ---
# (## を書かないことで help に表示させない)

prepare:
	@# Bundlerチェック
	@gem list -i bundler >/dev/null 2>&1 || (echo "Installing bundler..." && gem install bundler --no-document)
	@# 実行権限を一括付与
	@chmod +x bin/status mac/install omarchy/install || true

install-mac: prepare
	@./mac/install

install-omarchy: prepare
	@./omarchy/install

.PHONY: install status help prepare install-mac install-omarchy