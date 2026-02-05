# Build and verify all SPARK examples
#
# Usage:
#   make build   - compile all examples with gprbuild
#   make prove   - run gnatprove on all examples
#   make all     - build + prove
#   make clean   - remove all build artifacts
#
# Requires: GNAT and GNATprove on PATH (via Alire toolchain or system install)

# Auto-detect Alire toolchain paths if gprbuild isn't already on PATH.
# Override with: make build GPRBUILD_BIN=/path/to/bin GNAT_BIN=/path/to/bin
ALIRE_TOOLCHAINS ?= $(HOME)/.local/share/alire/toolchains
GPRBUILD_BIN     ?= $(lastword $(wildcard $(ALIRE_TOOLCHAINS)/gprbuild_*/bin))
GNAT_BIN         ?= $(lastword $(wildcard $(ALIRE_TOOLCHAINS)/gnat_native_*/bin))
SPARK_BIN        ?= $(lastword $(wildcard $(HOME)/.local/share/alire/releases/gnatprove_*/libexec/spark/bin))
export PATH      := $(GPRBUILD_BIN):$(GNAT_BIN):$(SPARK_BIN):$(PATH)

GPR_FILES := $(shell find patterns -name '*.gpr' | sort)

.PHONY: all build prove clean

all: build prove

build:
	@echo "=== Building all examples ==="
	@failed=0; \
	for gpr in $(GPR_FILES); do \
		dir=$$(dirname $$gpr); \
		name=$$(basename $$gpr .gpr); \
		echo "--- Building $$name ($$gpr) ---"; \
		mkdir -p $$dir/obj; \
		gprbuild -P $$gpr -q -c 2>&1 || { echo "FAILED: $$gpr"; failed=$$((failed + 1)); }; \
	done; \
	echo ""; \
	if [ $$failed -gt 0 ]; then \
		echo "=== $$failed example(s) failed to build ==="; \
		exit 1; \
	else \
		echo "=== All examples built successfully ==="; \
	fi

prove:
	@echo "=== Proving all examples ==="
	@failed=0; \
	for gpr in $(GPR_FILES); do \
		dir=$$(dirname $$gpr); \
		name=$$(basename $$gpr .gpr); \
		echo ""; \
		echo "--- Proving $$name ($$gpr) ---"; \
		gnatprove -P $$gpr --level=0 --report=statistics -j0 2>&1 || { echo "FAILED: $$gpr"; failed=$$((failed + 1)); }; \
	done; \
	echo ""; \
	if [ $$failed -gt 0 ]; then \
		echo "=== $$failed example(s) had proof failures ==="; \
		exit 1; \
	else \
		echo "=== All examples proved successfully ==="; \
	fi

clean:
	@echo "=== Cleaning all examples ==="
	@for gpr in $(GPR_FILES); do \
		dir=$$(dirname $$gpr); \
		name=$$(basename $$gpr .gpr); \
		echo "--- Cleaning $$name ---"; \
		gnatprove -P $$gpr --clean 2>/dev/null; \
		rm -rf $$dir/obj; \
	done
	@echo "=== Clean complete ==="
