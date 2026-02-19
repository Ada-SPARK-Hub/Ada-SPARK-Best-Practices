# Build and verify all SPARK examples
#
# Usage:
#   make build   - compile all examples with gprbuild
#   make prove   - run gnatprove on all examples
#   make all     - build + prove
#   make clean   - remove all build artifacts
#
# Requires: GNAT and GNATprove on PATH (via Alire toolchain or system install)

GPR_FILES := $(shell find patterns -name '*.gpr' | sort)

.PHONY: all build prove clean check-tools
.DEFAULT_GOAL := all

check-tools:
	@missing=""; \
	command -v gcc >/dev/null 2>&1       || missing="$$missing gcc"; \
	command -v gprbuild >/dev/null 2>&1  || missing="$$missing gprbuild"; \
	command -v gnatprove >/dev/null 2>&1 || missing="$$missing gnatprove"; \
	if [ -n "$$missing" ]; then \
		echo "Error: the following required tools were not found in PATH:$$missing"; \
		echo "Install them via Alire (https://alire.ada.dev) or add them to your PATH."; \
		echo "  Current PATH: $$PATH"; \
		exit 1; \
	fi

all: build prove

build: check-tools
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

prove: check-tools
	@echo "=== Proving all examples ==="
	@failed=0; \
	for gpr in $(GPR_FILES); do \
		dir=$$(dirname $$gpr); \
		name=$$(basename $$gpr .gpr); \
		echo ""; \
		echo "--- Proving $$name ($$gpr) ---"; \
		output=$$(gnatprove -P $$gpr --level=0 --report=statistics -j0 2>&1); \
		echo "$$output"; \
		if [ $$? -ne 0 ] || echo "$$output" | grep -qE "(medium:|high:|warning:)"; then \
			echo "FAILED: $$gpr (errors or warnings detected)"; \
			failed=$$((failed + 1)); \
		fi; \
	done; \
	echo ""; \
	if [ $$failed -gt 0 ]; then \
		echo "=== $$failed example(s) had proof failures ==="; \
		exit 1; \
	else \
		echo "=== All examples proved successfully ==="; \
	fi

clean: check-tools
	@echo "=== Cleaning all examples ==="
	@for gpr in $(GPR_FILES); do \
		dir=$$(dirname $$gpr); \
		name=$$(basename $$gpr .gpr); \
		echo "--- Cleaning $$name ---"; \
		gnatprove -P $$gpr --clean 2>/dev/null; \
		rm -rf $$dir/obj; \
	done
	@echo "=== Clean complete ==="
