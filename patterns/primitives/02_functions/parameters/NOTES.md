# Function Parameters Translation Notes

## Translation Patterns

### Pass by Value

**C Pattern:**
```c
int increment(int x) {
    x = x + 1;  // Modifies local copy
    return x;
}
```

**SPARK Pattern:**
```ada
function Increment (X : in Integer) return Integer is
begin
   --  Cannot modify X (in mode is read-only)
   return X + 1;
end Increment;
```

### Pass by Reference

**C Pattern:**
```c
void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}
```

**SPARK Pattern:**
```ada
procedure Swap (A : in out Integer; B : in out Integer) is
   Temp : constant Integer := A;
begin
   A := B;
   B := Temp;
end Swap;
```

### Multiple Output Parameters

**C Pattern:**
```c
void divide_with_remainder(int dividend, int divisor,
                          int *quotient, int *remainder) {
    *quotient = dividend / divisor;
    *remainder = dividend % divisor;
}
```

**SPARK Pattern:**
```ada
procedure Divide_With_Remainder
   (Dividend  : in Integer;
    Divisor   : in Integer;
    Quotient  : out Integer;
    Remainder : out Integer)
is
begin
   Quotient  := Dividend / Divisor;
   Remainder := Dividend rem Divisor;
end Divide_With_Remainder;
```

## Key Differences

### Parameter Modes

**C:**
- Default: Pass by value (copy)
- Pointers: Pass by reference

**SPARK:**
- `in` - Read-only (default for functions)
- `out` - Write-only, uninitialized on entry
- `in out` - Read and write, initialized on entry

### No Pointer Syntax

**C:**
```c
void foo(int *x) {
    *x = 42;  // Dereference to modify
}
int y;
foo(&y);  // Address-of to pass
```

**SPARK:**
```ada
procedure Foo (X : out Integer) is
begin
   X := 42;  -- Direct access, no dereferencing
end Foo;

Y : Integer;
Foo (Y);  -- Direct call, no address-of operator
```

### Safety

**C Issues:**
- Null pointer dereferences possible
- Can pass wrong pointer type
- No protection against dangling pointers

**SPARK Advantages:**
- No null issues with parameter modes
- Type checking enforced
- Cannot forget to initialize `out` parameters

## SPARK Enhancements

### Add Contracts

```ada
procedure Swap (A : in out Integer; B : in out Integer)
   with Post => A = B'Old and B = A'Old
is
   Temp : constant Integer := A;
begin
   A := B;
   B := Temp;
end Swap;
```

The `'Old` attribute refers to the value on entry.

### Preconditions for Safety

```ada
procedure Divide_With_Remainder
   (Dividend  : in Integer;
    Divisor   : in Integer;
    Quotient  : out Integer;
    Remainder : out Integer)
   with Pre  => Divisor /= 0,
        Post => Quotient * Divisor + Remainder = Dividend
                and Remainder in 0 .. abs Divisor - 1
is
begin
   Quotient  := Dividend / Divisor;
   Remainder := Dividend rem Divisor;
end Divide_With_Remainder;
```

Benefits:
- Prevents division by zero
- Documents mathematical relationship
- SPARK can prove correctness

## Parameter Mode Guidelines

### When to Use Each Mode

**`in` (default for functions):**
- Input-only parameters
- No modification needed
- Efficient (compiler can optimize)

**`out`:**
- Pure output parameters
- Don't need input value
- Must be assigned before return

**`in out`:**
- Need to read AND modify
- Most similar to C pointers
- Use for updates

### Common Pattern: Return vs Out

**C Style (pointers for outputs):**
```c
void get_bounds(int *min, int *max) {
    *min = 0;
    *max = 100;
}
```

**SPARK Option 1 (out parameters):**
```ada
procedure Get_Bounds (Min : out Integer; Max : out Integer) is
begin
   Min := 0;
   Max := 100;
end Get_Bounds;
```

**SPARK Option 2 (return record):**
```ada
type Bounds is record
   Min : Integer;
   Max : Integer;
end record;

function Get_Bounds return Bounds is
begin
   return (Min => 0, Max => 100);
end Get_Bounds;
```

Option 2 is often cleaner for multiple related outputs!

## Verification Status

✓ Provable with contracts

Key verification:
- `in` parameters cannot be modified (compile-time)
- `out` parameters must be assigned (compile-time)
- Postconditions can prove functional correctness (with gnatprove)

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

- SPARK has three parameter modes: `in`, `out`, `in out`
- No pointer syntax needed for pass-by-reference
- `in` mode prevents accidental modification
- `out` mode must initialize before return
- Use `'Old` attribute in postconditions to refer to entry values
- Parameter modes eliminate most pointer usage
- More explicit, safer, and clearer than C pointers
