# C to Ada SPARK Quick Reference

A concise mapping of common C constructs to their Ada SPARK equivalents.

## Basic Syntax

| C | SPARK | Notes |
|---|-------|-------|
| `#include <stdio.h>` | `with Ada.Text_IO;` | Library imports |
| `int main()` | `procedure Main` | Entry point |
| `return 0;` | *(none)* | Procedures don't return values |
| `/* comment */` | `--  comment` | Comments |
| `// comment` | `--  comment` | Single-line comments |

## Types

| C | SPARK | Notes |
|---|-------|-------|
| `int` | `Integer` | Signed integer |
| `unsigned int` | `Natural` or `Positive` | Natural = 0.., Positive = 1.. |
| `float` | `Float` | Single precision |
| `double` | `Long_Float` | Double precision |
| `char` | `Character` | Single character |
| `_Bool` / `bool` | `Boolean` | True/False (proper type) |
| `void` | *(use procedure)* | No return type |

## Type Definitions

| C | SPARK | Notes |
|---|-------|-------|
| `typedef int MyInt;` | `type My_Int is new Integer;` | New type |
| `typedef struct { int x; } Point;` | `type Point is record X : Integer; end record;` | Record type |
| `enum Color {RED, GREEN};` | `type Color is (Red, Green);` | Enumeration |

## Variables

| C | SPARK | Notes |
|---|-------|-------|
| `int x = 42;` | `X : Integer := 42;` | Variable declaration |
| `const int x = 42;` | `X : constant Integer := 42;` | Constant |
| `int x;` | `X : Integer;` | Uninitialized (avoid in SPARK) |

## Operators

| C | SPARK | Notes |
|---|-------|-------|
| `+`, `-`, `*`, `/` | `+`, `-`, `*`, `/` | Same |
| `%` | `rem` or `mod` | rem = remainder, mod = modulus |
| `++`, `--` | *(none)* | Use `X := X + 1` |
| `+=`, `-=`, etc. | *(none)* | Use `X := X + 1` |
| `&&` | `and` | Logical AND |
| `||` | `or` | Logical OR |
| `!` | `not` | Logical NOT |
| `==` | `=` | Equality |
| `!=` | `/=` | Inequality |
| `<`, `>`, `<=`, `>=` | `<`, `>`, `<=`, `>=` | Same |

## Control Flow

| C | SPARK | Notes |
|---|-------|-------|
| `if (x > 0) { }` | `if X > 0 then end if;` | If statement |
| `else { }` | `else` | Else clause |
| `else if { }` | `elsif` | Else-if (note spelling) |
| `while (cond) { }` | `while Cond loop end loop;` | While loop |
| `for (i=0; i<n; i++)` | `for I in 0 .. N-1 loop` | For loop |
| `break;` | `exit;` | Exit loop |
| `continue;` | *(use if/then)* | No direct equivalent |
| `switch/case` | `case ... when` | Case statement |

## Functions

| C | SPARK | Notes |
|---|-------|-------|
| `int add(int a, int b)` | `function Add(A,B:Integer) return Integer` | Function |
| `void foo()` | `procedure Foo` | Procedure (no return) |
| `return x;` | `return X;` | Return statement |

## Function Parameters

| C | SPARK | Notes |
|---|-------|-------|
| `int x` | `X : in Integer` | Input parameter (default) |
| `int *x` (output) | `X : out Integer` | Output parameter |
| `int *x` (modify) | `X : in out Integer` | Input/output parameter |

## Arrays

| C | SPARK | Notes |
|---|-------|-------|
| `int arr[10];` | `Arr : array (1..10) of Integer;` | Fixed array |
| `arr[0]` | `Arr(1)` | Indexing (Ada often 1-based) |
| `int arr[] = {1,2,3};` | `Arr : array (1..3) of Integer := (1,2,3);` | Initialization |
| *(none)* | `Arr'First` | First index |
| *(none)* | `Arr'Last` | Last index |
| *(none)* | `Arr'Length` | Array length |
| *(none)* | `Arr'Range` | Full range for iteration |

## Pointers

| C | SPARK | Notes |
|---|-------|-------|
| `int *ptr;` | *(avoid)* | Use parameter modes instead |
| `*ptr` | *(N/A)* | Dereference not needed |
| `&var` | *(N/A)* | Address-of not needed |
| `ptr == NULL` | `Ptr = null` (if needed) | Null check for access types |

## Strings

| C | SPARK | Notes |
|---|-------|-------|
| `char str[] = "hello";` | `Str : String := "hello";` | String literal |
| `printf("%s", str);` | `Put_Line(Str);` | String output |
| `strlen(str)` | `Str'Length` | String length |

## I/O

| C | SPARK | Notes |
|---|-------|-------|
| `printf("text\n");` | `Put_Line("text");` | Print with newline |
| `printf("%d", x);` | `Put_Line(Integer'Image(X));` | Print integer |
| `scanf("%d", &x);` | `Get(X);` | Input integer |

## Memory

| C | SPARK | Notes |
|---|-------|-------|
| `malloc()` / `free()` | *(avoid)* | Use stack allocation |
| `sizeof(x)` | `X'Size` | Size in bits |

## Preprocessor

| C | SPARK | Notes |
|---|-------|-------|
| `#define MAX 100` | `Max : constant := 100;` | Named constant |
| `#ifdef` / `#ifndef` | *(use configuration)* | Conditional compilation |

## SPARK-Specific Features

| Feature | Syntax | Purpose |
|---------|--------|---------|
| Precondition | `with Pre => X > 0` | Function requirements |
| Postcondition | `with Post => Result > 0` | Function guarantees |
| Loop invariant | `pragma Loop_Invariant(...)` | Prove loop correctness |
| Type constraint | `type T is range 0..100;` | Constrained type |
| Subtype | `subtype Nat is Integer range 0..Integer'Last;` | Constrained subtype |
| Quantifier | `for all I in 1..N => Arr(I) > 0` | Universal property |

## Case Differences

| C Convention | SPARK Convention |
|--------------|------------------|
| `snake_case` | `Capitalize_Each_Word` |
| `camelCase` | `Capitalize_Each_Word` |
| `0`-based arrays | `1`-based arrays (commonly) |
| Implicit conversions | Explicit conversions |
| `{` `}` for blocks | `begin` `end` |

## Common Idioms

### C Idiom → SPARK Idiom

**Swap:**
```c
// C
int temp = a;
a = b;
b = temp;
```
```ada
-- SPARK
Temp : constant Integer := A;
A := B;
B := Temp;
```

**Max of two values:**
```c
// C
int max = (a > b) ? a : b;
```
```ada
-- SPARK
Max : Integer := (if A > B then A else B);
```

**Loop through array:**
```c
// C
for (int i = 0; i < size; i++) {
    process(arr[i]);
}
```
```ada
-- SPARK
for I in Arr'Range loop
   Process(Arr(I));
end loop;
```

**Initialize array:**
```c
// C
int arr[10];
for (int i = 0; i < 10; i++) {
    arr[i] = 0;
}
```
```ada
-- SPARK
Arr : array (1 .. 10) of Integer := (others => 0);
```

## Key Philosophy Differences

| C | SPARK |
|---|-------|
| Performance first | Safety first |
| Implicit is convenient | Explicit is clear |
| Trust the programmer | Verify the program |
| Flexible types | Strong types |
| Manual memory management | Automatic memory management |
| Runtime errors | Compile-time + proof |

---

## Quick Translation Checklist

When translating C to SPARK:

1. ✓ Change `int` to `Integer`, consider `Natural`/`Positive`
2. ✓ Replace `%` with `rem` (or `mod` for true modulus)
3. ✓ Convert `++`/`--` to explicit assignment
4. ✓ Change array indexing from 0-based to 1-based (usually)
5. ✓ Replace pointer parameters with `in`, `out`, or `in out` modes
6. ✓ Use `'Range`, `'First`, `'Last` for array iteration
7. ✓ Add range constraints to types
8. ✓ Consider adding preconditions/postconditions
9. ✓ Use `Boolean` instead of integer for flags
10. ✓ Replace `printf` with `Put_Line` and `'Image`

---

For detailed explanations, see [TRANSLATION_GUIDE.md](../TRANSLATION_GUIDE.md)
