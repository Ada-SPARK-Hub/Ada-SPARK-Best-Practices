# C to Ada SPARK Translation Guide

This guide provides core patterns for translating C code to Ada SPARK, with emphasis on leveraging SPARK's formal verification capabilities.

## Philosophy

Ada SPARK translation is not just syntax conversion—it's about:
1. **Making implicit assumptions explicit** (via contracts)
2. **Using strong typing** to prevent entire classes of errors
3. **Enabling formal verification** to prove correctness

## Core Translation Patterns

### 1. Program Structure

#### C Pattern
```c
#include <stdio.h>

int main() {
    printf("Hello, World!\n");
    return 0;
}
```

#### SPARK Pattern
```ada
with Ada.Text_IO;

procedure Hello is
begin
   Ada.Text_IO.Put_Line("Hello, World!");
end Hello;
```

**Key Differences:**
- C uses `#include`, SPARK uses `with` clauses
- C's `main()` returns int, SPARK procedures don't return values
- SPARK has no implicit includes

---

### 2. Variable Declarations

#### C Pattern
```c
int x = 42;
unsigned int count = 0;
float temperature = 98.6;
```

#### SPARK Pattern
```ada
X : Integer := 42;
Count : Natural := 0;  -- Natural is 0 .. Integer'Last
Temperature : Float := 98.6;
```

**Improvements:**
```ada
-- Add range constraints for better verification
subtype Temperature_Type is Float range -273.15 .. 1000.0;
Temperature : Temperature_Type := 98.6;
```

---

### 3. Type Definitions

#### C Pattern
```c
typedef struct {
    int x;
    int y;
} Point;
```

#### SPARK Pattern
```ada
type Point is record
   X : Integer;
   Y : Integer;
end record;
```

**With Constraints:**
```ada
type Coordinate is range -1000 .. 1000;

type Point is record
   X : Coordinate;
   Y : Coordinate;
end record;
```

---

### 4. Functions

#### C Pattern
```c
int add(int a, int b) {
    return a + b;
}
```

#### SPARK Pattern (Basic)
```ada
function Add (A : Integer; B : Integer) return Integer is
begin
   return A + B;
end Add;
```

#### SPARK Pattern (With Contracts)
```ada
function Add (A : Integer; B : Integer) return Integer
   with Pre  => A + B in Integer'Range,  -- No overflow
        Post => Add'Result = A + B
is
begin
   return A + B;
end Add;
```

---

### 5. Arrays

#### C Pattern
```c
int numbers[10];
numbers[0] = 42;
```

#### SPARK Pattern
```ada
type Number_Array is array (1 .. 10) of Integer;
Numbers : Number_Array;
begin
   Numbers(1) := 42;  -- Ada arrays typically start at 1
```

**With Safety:**
```ada
subtype Index is Integer range 1 .. 10;
type Number_Array is array (Index) of Integer;

Numbers : Number_Array := (others => 0);  -- Initialize all elements
```

---

### 6. Loops

#### C Pattern
```c
for (int i = 0; i < n; i++) {
    array[i] = i * 2;
}
```

#### SPARK Pattern
```ada
for I in Array_Type'Range loop
   My_Array(I) := I * 2;
end loop;
```

**With Loop Invariant:**
```ada
for I in My_Array'Range loop
   My_Array(I) := I * 2;
   pragma Loop_Invariant
      (for all J in My_Array'First .. I => My_Array(J) = J * 2);
end loop;
```

---

### 7. Conditionals

#### C Pattern
```c
if (x > 0) {
    result = x;
} else {
    result = -x;
}
```

#### SPARK Pattern
```ada
if X > 0 then
   Result := X;
else
   Result := -X;
end if;
```

---

### 8. Pointers → Access Types (or Avoidance)

#### C Pattern
```c
void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}
```

#### SPARK Pattern (No Pointers Needed)
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

**Key Insight:** Ada's `in out` parameters eliminate most pointer needs!

---

### 9. NULL Handling

#### C Pattern
```c
if (ptr != NULL) {
    process(*ptr);
}
```

#### SPARK Pattern (When Access Types Needed)
```ada
if Ptr /= null then
   Process (Ptr.all);
end if;
```

---

### 10. Enumerations

#### C Pattern
```c
enum Color { RED, GREEN, BLUE };
```

#### SPARK Pattern
```ada
type Color is (Red, Green, Blue);
```

---

## SPARK-Specific Enhancements

### Preconditions
Document function requirements:
```ada
function Divide (X, Y : Integer) return Integer
   with Pre => Y /= 0
is
begin
   return X / Y;
end Divide;
```

### Postconditions
Specify function guarantees:
```ada
function Abs_Value (X : Integer) return Natural
   with Post => (if X >= 0 then Abs_Value'Result = X
                 else Abs_Value'Result = -X)
is
begin
   if X >= 0 then
      return X;
   else
      return -X;
   end if;
end Abs_Value;
```

### Loop Invariants
Help proof tools understand loops:
```ada
Sum := 0;
for I in 1 .. N loop
   Sum := Sum + I;
   pragma Loop_Invariant (Sum = I * (I + 1) / 2);
end loop;
```

### Type Invariants
Ensure data structure consistency:
```ada
type Stack is private
   with Type_Invariant => Is_Valid (Stack);
```

---

## Common Pitfalls

### Array Indexing
- **C**: Arrays start at 0
- **SPARK**: Arrays can start at any value, commonly 1
- Always use `'First` and `'Last` attributes for portability

### Integer Types
- **C**: `int` size is platform-dependent
- **SPARK**: `Integer` is well-defined, use specific types when needed

### Pass by Value vs Reference
- **C**: Default pass by value, use `*` for pass by reference
- **SPARK**: Use `in`, `out`, or `in out` modes explicitly

### Type Conversions
- **C**: Implicit conversions everywhere
- **SPARK**: Explicit conversions required, use `Type_Name(value)`

---

## Translation Workflow

1. **Direct Translation** - Convert syntax C → Ada
2. **Add Type Constraints** - Use subtypes, ranges, and strong typing
3. **Add Contracts** - Document preconditions and postconditions
4. **Add Verification** - Include loop invariants for complex loops
5. **Prove** - Run `gnatprove` and refine contracts as needed

---

## Resources

- Ada Reference Manual: http://www.ada-auth.org/standards/rm12_w_tc1/html/RM-TOC.html
- SPARK User Guide: https://docs.adacore.com/spark2014-docs/html/ug/
- Loop Invariants: https://blog.adacore.com/loop-invariants
