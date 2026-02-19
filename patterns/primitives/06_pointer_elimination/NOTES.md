# Pointer Elimination Patterns

This example demonstrates how to translate C code that relies heavily on pointers to safe, pointer-free SPARK code.

## Why Eliminate Pointers?

Pointers are a major source of bugs in C:
- **Null pointer dereferences** - Crashes when accessing null
- **Dangling pointers** - Use-after-free bugs
- **Buffer overflows** - Pointer arithmetic going out of bounds
- **Memory leaks** - Forgetting to free
- **Aliasing bugs** - Multiple pointers to same memory
- **Type safety violations** - Casting to wrong type

SPARK eliminates most pointer usage, making these bugs impossible.

---

## Pattern 1: Output Parameters

### C Pattern: Pointers for Output

**C Code:**
```c
void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

int x = 5, y = 10;
swap(&x, &y);  // Must use & operator
```

**Problems:**
- Can pass `NULL` pointer → crash
- Easy to forget `&` operator
- Confusing: looks like pass-by-value but isn't
- No compile-time checking of pointer validity

### SPARK Pattern: `in out` Mode

**SPARK Code:**
```ada
procedure Swap (A : in out Integer; B : in out Integer)
   with Post => A = B'Old and B = A'Old
is
   Temp : constant Integer := A;
begin
   A := B;
   B := Temp;
end Swap;

X, Y : Integer := (5, 10);
Swap (X, Y);  -- Direct call, no operators needed
```

**Advantages:**
- Cannot pass null - compile error
- No `&` operator needed - cleaner syntax
- Parameter mode makes intent explicit
- Postcondition proves correctness
- SPARK can verify swap is correct

---

## Pattern 2: Multiple Return Values

### C Pattern: Pointers for Multiple Outputs

**C Code:**
```c
void div_mod(int dividend, int divisor, int *quotient, int *remainder) {
    *quotient = dividend / divisor;
    *remainder = dividend % divisor;
}

int q, r;
div_mod(17, 5, &q, &r);
```

**Problems:**
- Can pass `NULL` for any output parameter
- No way to return error without another output parameter
- Must pre-declare output variables
- No compile-time checking

### SPARK Pattern Option 1: `out` Parameters

**SPARK Code:**
```ada
procedure Div_Mod
   (Dividend  : in Integer;
    Divisor   : in Integer;
    Quotient  : out Integer;
    Remainder : out Integer)
   with Pre  => Divisor /= 0,
        Post => Quotient = Dividend / Divisor
            and Remainder = Dividend rem Divisor
is
begin
   Quotient  := Dividend / Divisor;
   Remainder := Dividend rem Divisor;
end Div_Mod;

Q, R : Integer;
Div_Mod (17, 5, Q, R);
```

**Advantages:**
- `out` mode makes output explicit
- Cannot pass null
- Precondition prevents division by zero
- Postcondition specifies behavior
- SPARK proves both outputs are assigned

### SPARK Pattern Option 2: Return Record

**SPARK Code:**
```ada
type Div_Result is record
   Quotient  : Integer;
   Remainder : Integer;
end record;

function Div_Mod_Func (Dividend, Divisor : Integer) return Div_Result
   with Pre  => Divisor /= 0,
        Post => Div_Mod_Func'Result.Quotient = Dividend / Divisor
            and Div_Mod_Func'Result.Remainder = Dividend rem Divisor
is
begin
   return (Quotient  => Dividend / Divisor,
           Remainder => Dividend rem Divisor);
end Div_Mod_Func;

Result : constant Div_Result := Div_Mod_Func (17, 5);
```

**When to Use Each:**
- **`out` parameters**: When outputs are independent concepts
- **Record return**: When outputs form a cohesive result
- **Record return**: Generally preferred for functional style

---

## Pattern 3: Array Modification

### C Pattern: Pointer to Array

**C Code:**
```c
void increment_all(int *arr, int size) {
    for (int i = 0; i < size; i++) {
        arr[i]++;  // ⚠️ No bounds checking
    }
}

int arr[] = {1, 2, 3, 4, 5};
increment_all(arr, 5);  // Must pass size separately
```

**Problems:**
- Array decays to pointer - loses size information
- Must pass size separately (easy to get wrong)
- No bounds checking - buffer overflow possible
- Pointer could be `NULL`

### SPARK Pattern: Array Parameter

**SPARK Code:**
```ada
procedure Increment_All (Arr : in out Integer_Array)
   with Post => (for all I in Arr'Range => Arr (I) = Arr'Old (I) + 1)
is
begin
   for I in Arr'Range loop
      Arr (I) := Arr (I) + 1;
   end loop;
end Increment_All;

Arr : Integer_Array (1 .. 5) := (1, 2, 3, 4, 5);
Increment_All (Arr);  -- Size is part of the type!
```

**Advantages:**
- Array size is part of the type - cannot be wrong
- Automatic bounds checking
- `Arr'Range` works regardless of array size
- Postcondition proves all elements incremented
- Generic over any array size (using unconstrained arrays)

---

## Pattern 4: Pointer Arithmetic

### C Pattern: Pointer Arithmetic for Traversal

**C Code:**
```c
int sum_range(int *arr, int start, int end) {
    int sum = 0;
    int *ptr = arr + start;      // ⚠️ Could go out of bounds
    int *end_ptr = arr + end;

    while (ptr <= end_ptr) {
        sum += *ptr;
        ptr++;  // ⚠️ No bounds checking
    }
    return sum;
}

int total = sum_range(arr, 1, 3);
```

**Problems:**
- Pointer arithmetic can go out of bounds
- Easy to make off-by-one errors
- `ptr <= end_ptr` is error-prone
- No way to verify bounds at compile time

### SPARK Pattern: Index-Based Iteration

**SPARK Code:**
```ada
function Sum_Range
   (Arr   : Integer_Array;
    Start : Positive;
    Stop  : Positive) return Integer
   with Pre  => Start in Arr'Range
            and Stop in Arr'Range
            and Start <= Stop,
        Post => Sum_Range'Result >= Integer'First
            and Sum_Range'Result <= Integer'Last
is
   Sum : Integer := 0;
begin
   for I in Start .. Stop loop
      Sum := Sum + Arr (I);
      pragma Loop_Invariant (Sum >= Integer'First);
   end loop;
   return Sum;
end Sum_Range;

Total := Sum_Range (Arr, 2, 4);
```

**Advantages:**
- No pointer arithmetic - use indices directly
- Precondition ensures indices are valid
- Bounds checking automatic
- Loop range is clear and correct
- Cannot have off-by-one errors with `..` syntax

---

## Pattern 5: String Pointer Arithmetic

### C Pattern: Pointer-Based String Traversal

**C Code:**
```c
int string_length(const char *str) {
    const char *p = str;
    while (*p != '\0') {
        p++;  // ⚠️ Pointer arithmetic
    }
    return p - str;  // ⚠️ Pointer subtraction
}
```

**Problems:**
- Assumes `str` is null-terminated
- No bounds checking - could read past buffer
- Pointer subtraction is confusing
- If string not null-terminated → undefined behavior

### SPARK Pattern: Built-in String Support

**SPARK Code:**
```ada
function String_Length (Str : String) return Natural
   with Post => String_Length'Result = Str'Length
is
begin
   return Str'Length;  -- Built-in attribute!
end String_Length;
```

**Advantages:**
- `String` type has built-in length
- No manual counting needed
- No null-terminator confusion
- Bounds are always known
- Much simpler and safer

**Note:** In practice, you'd just use `Str'Length` directly rather than wrapping it in a function. This example shows the pattern.

---

## Pattern 6: Struct Passing by Pointer

### C Pattern: Pointer for Efficiency

**C Code:**
```c
typedef struct {
    int x;
    int y;
} Point;

int manhattan_distance(const Point *p1, const Point *p2) {
    int dx = p1->x - p2->x;  // -> for pointer dereferencing
    int dy = p1->y - p2->y;
    return abs(dx) + abs(dy);
}

Point p1 = {0, 0};
Point p2 = {3, 4};
int dist = manhattan_distance(&p1, &p2);  // Must use &
```

**Reason for Pointers:**
- Avoid copying large structs
- More efficient to pass pointer

**Problems:**
- Can pass `NULL` pointer
- `->` vs `.` confusion
- Must use `&` at call site
- Const-correctness not enforced

### SPARK Pattern: `in` Mode

**SPARK Code:**
```ada
type Point is record
   X : Integer;
   Y : Integer;
end record;

function Manhattan_Distance (P1, P2 : Point) return Natural
   with Post => Manhattan_Distance'Result >= 0
is
   DX : constant Integer := P1.X - P2.X;
   DY : constant Integer := P1.Y - P2.Y;
begin
   return abs (DX) + abs (DY);
end Manhattan_Distance;

P1 : constant Point := (X => 0, Y => 0);
P2 : constant Point := (X => 3, Y => 4);
Dist : constant Natural := Manhattan_Distance (P1, P2);
```

**Advantages:**
- `in` mode for read-only access
- Compiler automatically passes by reference for efficiency
- Cannot pass null - compile error
- No `&` or `->` operators needed
- Simpler, cleaner syntax
- `constant` enforces read-only

**Key Insight:** Ada compiler is smart enough to pass large types by reference automatically when using `in` mode. You get the efficiency of C pointers without the unsafety!

---

## Summary: C Pointers → SPARK Alternatives

| C Pointer Usage | SPARK Alternative | Benefits |
|----------------|-------------------|----------|
| `int *out` (output) | `X : out Integer` | No null, explicit intent |
| `int *inout` (modify) | `X : in out Integer` | No null, clear semantics |
| `const T *` (read-only) | `X : in T` | Pass by reference automatically |
| `T *` (optional) | `X : access T` (rare) | Still need null checks |
| Array pointer + size | Array type | Size is part of type |
| Pointer arithmetic | Index-based iteration | Bounds checked |
| `char *` (string) | `String` | Built-in bounds |
| Multiple outputs | `out` params or record | Type-safe |
| Null checks | Not needed | Type system prevents |

---

## When You Still Need Access Types

SPARK has `access` types (similar to C pointers) for rare cases:
- **Linked data structures** (can be avoided with bounded alternatives)
- **Optional parameters** (better to use variants/discriminants)
- **Dynamic allocation** (should be minimized in safety-critical code)

But for 90% of C pointer usage, parameter modes are better!

---

## Verification Benefits

All SPARK versions are fully provable:

```bash
gnatprove -P project.gpr --level=2
```

SPARK will prove:
- No null pointer dereferences (because no pointers!)
- No buffer overflows (array bounds checked)
- All parameters assigned (for `out` mode)
- Postconditions hold (functional correctness)
- No integer overflow (with appropriate preconditions)

C version: These are all potential runtime crashes that cannot be caught at compile time.

---

## Key Takeaways

1. **`out` and `in out` modes** replace most C pointer usage
2. **Array types** include bounds - no separate size parameter
3. **`in` mode** gives pointer efficiency without unsafety
4. **Records** for multiple return values instead of output pointers
5. **No pointer arithmetic** - use index-based iteration
6. **Built-in string support** eliminates char pointer tricks
7. **Provable safety** - SPARK can verify all pointer bugs are impossible

The SPARK code is not just safer - it's also clearer, more maintainable, and provably correct!
