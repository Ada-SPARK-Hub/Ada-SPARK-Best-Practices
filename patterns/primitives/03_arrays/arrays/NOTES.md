# Array Operations Translation Notes

## Translation Patterns

### Array Declaration

**C Pattern:**
```c
#define ARRAY_SIZE 5
int numbers[ARRAY_SIZE] = {10, 25, 3, 47, 15};
```

**SPARK Pattern:**
```ada
type Index_Type is range 1 .. 5;
type Number_Array is array (Index_Type) of Integer;

Numbers : Number_Array := (10, 25, 3, 47, 15);
```

### Array Iteration

**C Pattern:**
```c
for (int i = 0; i < size; i++) {
    sum += arr[i];
}
```

**SPARK Pattern:**
```ada
for I in Arr'Range loop
   Sum := Sum + Arr (I);
end loop;
```

### Array as Function Parameter

**C Pattern:**
```c
int sum_array(int arr[], int size) {
    // Need size parameter
}
```

**SPARK Pattern:**
```ada
function Sum_Array (Arr : Number_Array) return Integer is
   --  Size is implicit in array type!
begin
   for I in Arr'Range loop  -- 'Range gives bounds
      ...
   end loop;
end Sum_Array;
```

## Key Differences

### Array Indexing

**C:**
- Arrays always start at 0
- Size is separate from type
- No built-in bounds checking

**SPARK:**
- Arrays can start at any value (commonly 1)
- Bounds are part of the type
- Automatic bounds checking at runtime
- Compile-time checking when provable

### Array Bounds

**C Issues:**
```c
int arr[5];
arr[10] = 42;  // Buffer overflow! No compile or runtime error
```

**SPARK Safety:**
```ada
Numbers : Number_Array;  -- Index_Type is 1 .. 5
Numbers (10) := 42;      -- Compile error: 10 not in Index_Type
```

### Array Attributes

**C:**
- Must track size separately
- Easy to pass wrong size

**SPARK:**
- `Arr'First` - First index
- `Arr'Last` - Last index
- `Arr'Range` - Full range
- `Arr'Length` - Number of elements
- Size is part of the type!

### Initialization

**C:**
```c
int arr[5];  // Uninitialized (undefined values)
int brr[5] = {1, 2, 3};  // Partially initialized (rest are 0)
```

**SPARK:**
```ada
Numbers : Number_Array;  -- Uninitialized (warning in SPARK)
Numbers : Number_Array := (others => 0);  -- All zeros
Numbers : Number_Array := (1, 2, 3, 4, 5);  -- Fully specified
Numbers : Number_Array := (1, 2, 3, others => 0);  -- Mixed
```

## SPARK Enhancements

### Postconditions with Quantifiers

```ada
function Find_Max (Arr : Number_Array) return Integer
   with Post => (for all I in Arr'Range => Find_Max'Result >= Arr (I))
is
   --  Postcondition proves result is actually the maximum
```

The `for all` quantifier expresses "for every index I in the array range..."

### Loop Invariants for Proof

```ada
function Find_Max (Arr : Number_Array) return Integer
   with Post => (for all I in Arr'Range => Find_Max'Result >= Arr (I))
is
   Max : Integer := Arr (Arr'First);
begin
   for I in Arr'Range loop
      if Arr (I) > Max then
         Max := Arr (I);
      end if;
      pragma Loop_Invariant
         (for all J in Arr'First .. I => Max >= Arr (J));
   end loop;
   return Max;
end Find_Max;
```

Loop invariant helps SPARK prove:
1. Max is always >= all elements seen so far
2. After loop, Max is >= all elements
3. Therefore, postcondition holds

### Unconstrained Arrays

For generic array functions:

```ada
type Integer_Array is array (Positive range <>) of Integer;

function Sum_Array (Arr : Integer_Array) return Integer is
   Sum : Integer := 0;
begin
   for I in Arr'Range loop
      Sum := Sum + Arr (I);
   end loop;
   return Sum;
end Sum_Array;

--  Can now use with any size array:
Arr1 : Integer_Array (1 .. 5);
Arr2 : Integer_Array (1 .. 100);
S1 := Sum_Array (Arr1);
S2 := Sum_Array (Arr2);
```

The `range <>` means "constrained at declaration time."

## Common Patterns

### Safe Array Access

**C (unsafe):**
```c
int get_element(int arr[], int size, int index) {
    return arr[index];  // No bounds check
}
```

**SPARK (safe):**
```ada
function Get_Element
   (Arr   : Number_Array;
    Index : Index_Type) return Integer
is
begin
   return Arr (Index);  -- Bounds automatically checked
end Get_Element;
```

### Array Bounds in Contracts

```ada
procedure Update_Element
   (Arr   : in out Number_Array;
    Index : Index_Type;
    Value : Integer)
   with Pre  => Index in Arr'Range,  -- Redundant but explicit
        Post => Arr (Index) = Value
              and (for all I in Arr'Range =>
                   (if I /= Index then Arr (I) = Arr'Old (I)))
is
begin
   Arr (Index) := Value;
end Update_Element;
```

## Verification Status

✓ Provable with contracts and loop invariants

Key verification points:
- Array bounds checked automatically
- Loop invariants prove algorithm correctness
- Postconditions specify functional requirements
- SPARK proves no buffer overflows

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

**SPARK Verification:**
```bash
gnatprove -P project.gpr --level=2
```

## Learning Points

- SPARK arrays have bounds as part of their type
- Use `'Range`, `'First`, `'Last`, `'Length` attributes
- No separate size parameter needed
- Bounds checking is automatic (compile-time when possible)
- Loop invariants help prove correctness
- Quantified expressions (`for all`) express properties over arrays
- Unconstrained arrays (`range <>`) provide genericity
- Much safer than C arrays by design
