# Variables and Types Translation Notes

## Translation Patterns

### Integer Types

**C Pattern:**
```c
int x = 42;
unsigned int count = 10;
```

**SPARK Pattern:**
```ada
X     : Integer := 42;
Count : Natural := 10;  -- Natural is 0 .. Integer'Last
```

### Floating Point

**C Pattern:**
```c
float temperature = 98.6;
double precise_value = 3.14159265359;
```

**SPARK Pattern:**
```ada
Temperature    : Float := 98.6;
Precise_Value  : Long_Float := 3.14159265359;
```

### Boolean

**C Pattern:**
```c
_Bool is_valid = 1;  // C99
```

**SPARK Pattern:**
```ada
Is_Valid : Boolean := True;
```

## Key Differences

1. **Type Safety**
   - C: Implicit conversions between numeric types
   - SPARK: Explicit conversions required, strong typing

2. **Boolean Type**
   - C: Uses integer values (0 = false, non-zero = true)
   - SPARK: Proper Boolean type with True/False literals

3. **Unsigned Types**
   - C: `unsigned int` explicit keyword
   - SPARK: Use `Natural` (0 .. Integer'Last) or define subtypes

4. **Initialization**
   - C: Variables can be uninitialized
   - SPARK: Best practice to initialize (required for proof in many cases)

5. **Naming Convention**
   - C: snake_case or camelCase
   - SPARK: Capitalize_Each_Word (Ada convention)

6. **Printing**
   - C: `printf` with format specifiers (`%d`, `%f`, etc.)
   - SPARK: `Put_Line` with string concatenation and `'Image` attribute

## SPARK Enhancements

### Add Range Constraints

```ada
--  Better: Define constrained subtypes
subtype Temperature_F is Float range -459.67 .. 1000.0;  -- Fahrenheit
subtype Count_Type is Integer range 0 .. 1000;

Temperature : Temperature_F := 98.6;
Count       : Count_Type := 10;
```

Benefits:
- Compiler checks assignments at runtime
- SPARK can prove values stay in range
- Makes assumptions explicit

## Verification Status

✓ Trivially provable with no contracts

Could add assertions:
```ada
pragma Assert (Count >= 0);
pragma Assert (Is_Valid in Boolean);
```

## Compilation

**C:**
```bash
gcc -std=c99 example.c -o example
./example
```

**Ada:**
```bash
gnatmake example.adb
./example
```

## Learning Points

- SPARK has built-in Boolean type (not integer-based)
- Use `Natural` for non-negative integers instead of `unsigned`
- `'Image` attribute converts values to strings
- Ada requires `:` between name and type, `:=` for initialization
- String concatenation uses `&` operator
- Strong typing prevents accidental type mixing
