# Default entrypoint
install: status
	@OS=$$(uname -s); \
	case "$$OS" in \
	  Darwin*) $(MAKE) install-mac ;; \
	  Linux*)  if [ -f /etc/arch-release ]; then echo "Detected OS: Omarchy"; $(MAKE) install-omarchy; else echo "Error: Unsupported OS"; exit 1; fi ;; \
	  *) echo "Error: Unsupported OS"; exit 1 ;; \
	esac

install-mac: ## macOS向けセットアップを実行
	@chmod +x mac/install || true
	@./mac/install

install-omarchy: ## Omarchy向けセットアップを実行
	@chmod +x omarchy/install || true
	@./omarchy/install

status: ## OSを表示し、git statusを確認。未コミット変更があれば警告を出す
	@bin/status

help: ## 利用可能なターゲット一覧を表示
	@echo "Usage: make <target>"; \
	echo "\nTargets:"; \
	awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_.-]+:.*## / {printf "  %-24s %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.PHONY: install install-mac install-omarchy status help