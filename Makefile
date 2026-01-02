# Makefile for Payment Contracts

# Default target
.PHONY: default
default: build test

# All target including installation
.PHONY: all
all: install build test

# Install dependencies
.PHONY: install
install:
	forge install

# Build target
.PHONY: build
build:
	forge build

# Test target
.PHONY: test
test:
	forge test -vv

# Helper: Ensure relevant scripts are executable
.PHONY: chmod-deploy
chmod-deploy:
	chmod +x ./tools/deploy.sh

# Deployment targets
.PHONY: deploy-calibnet
deploy-calibnet: chmod-deploy
	./tools/deploy.sh 314159

.PHONY: deploy-devnet
deploy-devnet: chmod-deploy
	./tools/deploy.sh 1414

.PHONY: deploy-mainnet
deploy-mainnet: chmod-deploy
	./tools/deploy.sh 314

# Extract just the ABI arrays into abi/ContractName.abi.json
.PHONY: extract-abis
extract-abis:
	mkdir -p abi
	@find out -type f -name '*.json' | while read file; do \
	  name=$$(basename "$${file%.*}"); \
	  jq '.abi' "$${file}" > "abi/$${name}.abi.json"; \
	done
