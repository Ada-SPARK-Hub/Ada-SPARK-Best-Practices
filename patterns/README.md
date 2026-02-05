# C to Ada SPARK Translation Examples

A comprehensive repository of parallel C and Ada SPARK code examples designed to teach LLMs (and humans) how to translate C code to Ada SPARK with formal verification contracts.

## Purpose

This repository serves three key purposes:

1. **Fine-tuning Dataset** - Structured examples for training LLMs on C-to-SPARK translation
2. **Few-shot Learning** - Reference examples to include in prompts for translation tasks
3. **Documentation** - Educational resource showing idiomatic SPARK code with verification

## Repository Structure

```
Ada-SPARK-Best-Practices/
├── patterns/
    ├── primitives           # programming primitives
    │   ├── 01_basic         # types, conditional, loops
    │   ├── 02_functions     # functions
    │   ├── 03_arrays        # arrays
    │   ├── 04_pointers      # pointers
    │   └── ...
    ├── programs.            # complete programs or functions
    │   ├── 01_binary_search # binary search
    │   ├── 02_bubble_sort   # bubble sort
    │   └── ...
    └── ...
├── docs/
│   ├── mapping_reference.md      # Quick C↔SPARK syntax mappings
│   └── verification_patterns.md  # SPARK contract patterns
└── test/                    # Compilation verification scripts
```

## Example Structure

Each example directory contains:
- `example.c` - C implementation
- `example.adb` / `example.ads` - Ada SPARK implementation
- `NOTES.md` - Translation rationale and SPARK-specific enhancements


## Progressive Complexity

Examples are organized in four levels:

1. **Syntactic Translation** - Direct C constructs → Ada equivalents
2. **Idiomatic Ada** - Using Ada's type system and safety features
3. **SPARK Contracts** - Adding preconditions, postconditions, invariants
4. **Provable Code** - Fully verified code passing SPARK proof tools

## Quick Start

### For LLM Training

Extract parallel examples:
```bash
# Get all C files
find examples -name "*.c"

# Get corresponding SPARK files
find examples -name "*.adb" -o -name "*.ads"
```

### For Few-Shot Prompting

Select examples relevant to your translation task from the appropriate complexity level. Each NOTES.md file explains the translation patterns used.

### For Learning

Start with `01_basics/hello_world` and progress through numbered directories. Read NOTES.md files to understand translation decisions.

## Key Translation Principles

### Type Safety
- C's implicit conversions → Ada's explicit type conversions
- C's unconstrained integers → Ada's range-constrained types
- C's pointers → Ada's access types (or better: avoid them)

### Memory Safety
- C's manual memory management → Ada's automatic memory management
- C's buffer overflows → Ada's array bounds checking
- C's null pointer dereferences → Ada's controlled access

### Verification
- C's comments about assumptions → SPARK's preconditions
- C's assertions → SPARK's postconditions and loop invariants
- C's testing → SPARK's formal proof

## Contributing

When adding examples:
1. Keep C and SPARK versions functionally equivalent
2. Add NOTES.md explaining translation decisions
3. Include manifest.json with metadata
4. Start simple, then show SPARK enhancements
5. Ensure SPARK code can be proven when possible

## Tools

- **C Compiler**: GCC or Clang
- **SPARK Tools**: GNAT Community Edition with SPARK Pro
- **Verification**: `gnatprove` for formal verification

## Documentation

- [Translation Guide](TRANSLATION_GUIDE.md) - Core translation patterns
- [Mapping Reference](docs/mapping_reference.md) - Quick syntax lookup
- [Verification Patterns](docs/verification_patterns.md) - SPARK contract examples


## Resources

- [Ada Programming Language](https://www.adaic.org/)
- [SPARK Documentation](https://www.adacore.com/about-spark)
- [Learn Ada Course](https://learn.adacore.com/)
