# Hello World Translation Notes

## Translation Pattern

**C Pattern:**
```c
#include <stdio.h>
int main(void) { ... }
```

**SPARK Pattern:**
```ada
with Ada.Text_IO;
procedure Example is ... end Example;
```

## Key Differences

1. **Include vs With**
   - C: `#include <stdio.h>` (preprocessor directive)
   - SPARK: `with Ada.Text_IO;` (compile-time dependency)

2. **Main Entry Point**
   - C: `main()` function that returns `int`
   - SPARK: Any procedure name (compiled with gnatmake/gprbuild)

3. **Output Function**
   - C: `printf()` from stdio
   - SPARK: `Ada.Text_IO.Put_Line()` from standard library

4. **Return Value**
   - C: `return 0;` to indicate success
   - SPARK: Procedures don't return values; exceptions indicate errors

## SPARK-Specific Features

None needed for this simple example. This is pure Ada (SPARK subset).

## Verification Status

✓ Trivially provable - no contracts needed

## Compilation

**C:**
```bash
gcc example.c -o example
./example
```

**Ada:**
```bash
gnatmake example.adb
./example
```

## Learning Points

- SPARK programs are procedures, not functions returning int
- SPARK uses `with` clauses instead of preprocessor includes
- Ada.Text_IO is the standard text I/O package
- String literals use double quotes in both languages
