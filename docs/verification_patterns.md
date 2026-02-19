# SPARK Verification Patterns

A comprehensive guide for extracting contracts from C code and creating provable SPARK implementations.

## Table of Contents
1. [Assumption Mining](#assumption-mining)
2. [Precondition Patterns](#precondition-patterns)
3. [Postcondition Patterns](#postcondition-patterns)
4. [Loop Invariant Construction](#loop-invariant-construction)
5. [Quantified Expressions](#quantified-expressions)
6. [Common Algorithm Patterns](#common-algorithm-patterns)
7. [C Code Smells → Verification Targets](#c-code-smells--verification-targets)
8. [Incremental Verification Strategy](#incremental-verification-strategy)

---

## Assumption Mining

The first step in C→SPARK translation is finding **implicit assumptions** in C code and making them **explicit contracts** in SPARK.

### Pattern: Finding Hidden Preconditions

#### Questions to Ask About C Code

1. **Can parameters cause crashes?**
   - Division by zero?
   - Null pointer dereference?
   - Out-of-bounds array access?
   - Integer overflow?

2. **What ranges are valid?**
   - Array indices must be within bounds
   - Size parameters must be non-negative
   - Values must be within sensible ranges

3. **What relationships must hold?**
   - Source buffer smaller than destination?
   - Parameters in specific order?
   - Global state assumptions?

4. **What's the function's purpose?**
   - What does it guarantee on exit?
   - What does it modify?
   - What does it preserve?

#### Example: Mining Assumptions

**C Code:**
```c
int divide(int a, int b) {
    return a / b;
}

void process_array(int arr[], int size) {
    for (int i = 0; i < size; i++) {
        arr[i] = arr[i] * 2;
    }
}

int buffer_copy(char *dest, char *src, int n) {
    for (int i = 0; i < n; i++) {
        dest[i] = src[i];
    }
    return n;
}
```

**Hidden Assumptions:**
1. `divide`: `b != 0`
2. `process_array`: `size >= 0`, `arr` has at least `size` elements
3. `buffer_copy`: `dest` and `src` are non-null, both have at least `n` elements, no overlap

**SPARK with Contracts:**
```ada
function Divide (A, B : Integer) return Integer
   with Pre => B /= 0;

procedure Process_Array (Arr : in out Integer_Array);
--  Array bounds built into type, no size needed!

procedure Buffer_Copy
   (Dest : out Character_Array;
    Src  : in Character_Array;
    N    : Natural)
   with Pre => N <= Dest'Length and N <= Src'Length;
```

---

## Precondition Patterns

Preconditions specify what must be true when the function is called.

### Pattern Catalog

| C Code Pattern | Hidden Assumption | SPARK Precondition |
|----------------|-------------------|-------------------|
| `x / y` | y is not zero | `Pre => Y /= 0` |
| `x % y` | y is not zero | `Pre => Y /= 0` |
| `arr[i]` | i is valid index | `Pre => I in Arr'Range` |
| `*ptr` | ptr is not null | Use parameter modes, avoid pointers |
| `arr[n]` where n is param | n is valid | `Pre => N in Arr'Range` |
| `x + y` | No overflow | `Pre => X <= Integer'Last - Y` |
| `x - y` | No underflow | `Pre => X >= Integer'First + Y` |
| `x * y` | No overflow | `Pre => abs X <= Integer'Last / abs Y` |
| `-x` | Can negate | `Pre => X /= Integer'First` |
| `arr[start..end]` | Valid range | `Pre => Start <= End and End <= N` |
| `memcpy(d, s, n)` | No overlap | `Pre => Src'Last < Dest'First or Dest'Last < Src'First` |
| Array parameter + size | Size matches | `Pre => Size = Arr'Length` |
| Buffer operations | Dest big enough | `Pre => Src'Length <= Dest'Length` |

### Arithmetic Safety Patterns

#### Division
```ada
function Divide (X, Y : Integer) return Integer
   with Pre => Y /= 0;
```

#### Overflow Prevention
```ada
function Safe_Add (X, Y : Integer) return Integer
   with Pre => (if X > 0 and Y > 0 then X <= Integer'Last - Y else True)
           and (if X < 0 and Y < 0 then X >= Integer'First - Y else True);
```

#### Safe Negation
```ada
function Negate (X : Integer) return Integer
   with Pre  => X /= Integer'First,
        Post => Negate'Result = -X;
```

### Array Safety Patterns

#### Single Index
```ada
function Get_Element (Arr : Integer_Array; Index : Integer) return Integer
   with Pre => Index in Arr'Range;
```

#### Range Access
```ada
procedure Process_Range
   (Arr   : in out Integer_Array;
    Start : Positive;
    Stop  : Positive)
   with Pre => Start in Arr'Range
           and Stop in Arr'Range
           and Start <= Stop;
```

#### Size Relationships
```ada
procedure Copy_Array
   (Source : Integer_Array;
    Dest   : out Integer_Array;
    Count  : Natural)
   with Pre => Count <= Source'Length
           and Count <= Dest'Length;
```

---

## Postcondition Patterns

Postconditions specify what must be true when the function returns.

### Pattern Catalog

| What to Specify | SPARK Pattern |
|----------------|---------------|
| Return value property | `Post => Result >= 0` |
| Return value computation | `Post => Result = A + B` |
| Parameter modified | `Post => Arr(Index) = Value` |
| Parameter unchanged | `Post => X = X'Old` |
| Relationship preserved | `Post => A = B'Old and B = A'Old` |
| Array element changed | `Post => Arr(I) = New_Value` |
| Other elements unchanged | `Post => (for all J in Arr'Range => (if J /= I then Arr(J) = Arr'Old(J)))` |
| All elements modified | `Post => (for all I in Arr'Range => Arr(I) = Arr'Old(I) * 2)` |
| Return in range | `Post => Result in 0 .. Max` |
| Maximum found | `Post => (for all I in Arr'Range => Result >= Arr(I))` |

### Simple Postconditions

#### Return Value Property
```ada
function Absolute_Value (X : Integer) return Natural
   with Post => (if X >= 0 then Absolute_Value'Result = X
                 else Absolute_Value'Result = -X);
```

#### Computation Result
```ada
function Add (A, B : Integer) return Integer
   with Pre  => A + B in Integer'Range,
        Post => Add'Result = A + B;
```

#### Parameter Swap
```ada
procedure Swap (A : in out Integer; B : in out Integer)
   with Post => A = B'Old and B = A'Old;
```

### Array Postconditions

#### Single Element Update
```ada
procedure Update_Element
   (Arr   : in out Integer_Array;
    Index : Index_Type;
    Value : Integer)
   with Pre  => Index in Arr'Range,
        Post => Arr(Index) = Value
            and (for all I in Arr'Range =>
                   (if I /= Index then Arr(I) = Arr'Old(I)));
```

#### All Elements Modified
```ada
procedure Double_All (Arr : in out Integer_Array)
   with Post => (for all I in Arr'Range => Arr(I) = Arr'Old(I) * 2);
```

#### Search Result
```ada
procedure Find
   (Arr    : Integer_Array;
    Target : Integer;
    Found  : out Boolean;
    Index  : out Natural)
   with Post => (if Found then
                    Index in Arr'Range and Arr(Index) = Target
                 else
                    (for all I in Arr'Range => Arr(I) /= Target));
```

---

## Loop Invariant Construction

Loop invariants are the key to proving loops correct. They specify what's true after each iteration.

### Strategy 1: "What's True After Each Iteration"

**Pattern:** State the property that holds after processing elements 0..i

#### Example: Find Maximum

**C Code:**
```c
int max = arr[0];
for (int i = 1; i < n; i++) {
    if (arr[i] > max) {
        max = arr[i];
    }
}
```

**Question:** After iteration i, what's always true?
**Answer:** `max` is >= all elements seen so far (0 through i)

**SPARK:**
```ada
Max := Arr(Arr'First);
for I in Arr'First + 1 .. Arr'Last loop
   if Arr(I) > Max then
      Max := Arr(I);
   end if;
   pragma Loop_Invariant
      (for all J in Arr'First .. I => Max >= Arr(J));
end loop;
```

### Strategy 2: "Partial Result So Far"

**Pattern:** Express accumulator/result in terms of elements processed

#### Example: Sum Array

**C Code:**
```c
int sum = 0;
for (int i = 0; i < n; i++) {
    sum += arr[i];
}
```

**Question:** What does `sum` represent at iteration i?
**Answer:** Sum of all elements from 0 to i-1

**SPARK:**
```ada
Sum := 0;
for I in Arr'Range loop
   Sum := Sum + Arr(I);
   pragma Loop_Invariant
      (Sum = Sum'Loop_Entry +
       (for some K in Arr'First .. I => Arr(K)));
   --  Note: Actual sum requires more complex expression or ghost code
end loop;
```

Better with quantified expression:
```ada
pragma Loop_Invariant
   ((for all J in Arr'First .. I =>
       --  All elements up to I contributed to Sum
       True));  -- Simplified; full proof needs additional ghost variables
```

### Strategy 3: "Preservation and Progress"

**Pattern:** What stays the same AND what moves forward

#### Example: Array Copy

**C Code:**
```c
for (int i = 0; i < n; i++) {
    dest[i] = src[i];
}
```

**Question:** What's preserved and what progresses?
**Answer:** Elements copied so far are equal; elements not yet copied are unchanged

**SPARK:**
```ada
for I in Src'Range loop
   Dest(I) := Src(I);
   pragma Loop_Invariant
      (for all J in Src'First .. I => Dest(J) = Src(J));
   pragma Loop_Invariant
      (for all J in I + 1 .. Dest'Last => Dest(J) = Dest'Loop_Entry(J));
end loop;
```

### Strategy 4: "Bounds and Progress"

**Pattern:** Loop variable stays in bounds and makes progress

#### Example: Linear Search

**C Code:**
```c
int i = 0;
while (i < n && arr[i] != target) {
    i++;
}
```

**SPARK:**
```ada
I := Arr'First;
while I <= Arr'Last and then Arr(I) /= Target loop
   pragma Loop_Invariant (I in Arr'Range);
   pragma Loop_Invariant (for all J in Arr'First .. I - 1 => Arr(J) /= Target);
   I := I + 1;
end loop;
```

### Common Loop Invariant Patterns

#### Counter in Range
```ada
pragma Loop_Invariant (Count in 0 .. Arr'Length);
```

#### No Element Found Yet
```ada
pragma Loop_Invariant
   (for all J in Arr'First .. I - 1 => Arr(J) /= Target);
```

#### Array Sorted Up To Point
```ada
pragma Loop_Invariant
   (for all J in Arr'First .. I - 1 =>
      (for all K in Arr'First .. I - 1 =>
         (if J < K then Arr(J) <= Arr(K))));
```

#### Accumulator Property
```ada
pragma Loop_Invariant (Sum >= 0);
pragma Loop_Invariant (Count <= I - Arr'First + 1);
```

---

## Quantified Expressions

Quantified expressions let you express properties over collections.

### Universal Quantifier: "for all"

**Pattern:** Property holds for every element

#### All Elements Positive
```ada
(for all I in Arr'Range => Arr(I) > 0)
```

#### Array is Sorted
```ada
(for all I in Arr'First .. Arr'Last - 1 => Arr(I) <= Arr(I + 1))
```

#### No Duplicates
```ada
(for all I in Arr'Range =>
   (for all J in Arr'Range =>
      (if I /= J then Arr(I) /= Arr(J))))
```

#### All Elements in Range
```ada
(for all I in Arr'Range => Arr(I) in 0 .. 100)
```

#### Partition Property (QuickSort)
```ada
(for all I in Arr'First .. Pivot => Arr(I) <= Pivot_Value)
and
(for all I in Pivot + 1 .. Arr'Last => Arr(I) >= Pivot_Value)
```

### Existential Quantifier: "for some"

**Pattern:** Property holds for at least one element

#### Contains Zero
```ada
(for some I in Arr'Range => Arr(I) = 0)
```

#### Found Target
```ada
(for some I in Arr'Range => Arr(I) = Target and Result = I)
```

#### Has Duplicate
```ada
(for some I in Arr'Range =>
   (for some J in Arr'Range => I /= J and Arr(I) = Arr(J)))
```

### Conditional Quantifiers

**Pattern:** If-then relationships over elements

#### Search Result Correctness
```ada
(if Found then
    Index in Arr'Range and Arr(Index) = Target
 else
    (for all I in Arr'Range => Arr(I) /= Target))
```

#### Conditional Preservation
```ada
(for all I in Arr'Range =>
   (if Arr'Old(I) > Threshold then Arr(I) = Arr'Old(I) else Arr(I) = 0))
```

#### Maximum Property
```ada
(for all I in Arr'Range => Max_Value >= Arr(I))
and
(for some I in Arr'Range => Max_Value = Arr(I))
```

---

## Common Algorithm Patterns

Standard algorithms and their typical contracts.

### Binary Search

```ada
function Binary_Search
   (Arr    : Integer_Array;
    Target : Integer) return Extended_Index
   with Pre  => (for all I in Arr'First .. Arr'Last - 1 =>
                   Arr(I) <= Arr(I + 1)),  -- Array is sorted
        Post => (if Binary_Search'Result in Arr'Range then
                    Arr(Binary_Search'Result) = Target
                 else
                    (for all I in Arr'Range => Arr(I) /= Target));
```

### Swap Elements

```ada
procedure Swap (A : in out Integer; B : in out Integer)
   with Post => A = B'Old and B = A'Old;
```

### Reverse Array In-Place

```ada
procedure Reverse_Array (Arr : in out Integer_Array)
   with Post => (for all I in Arr'Range =>
                   Arr(I) = Arr'Old(Arr'Last - I + Arr'First));
```

### Partition (QuickSort)

```ada
function Partition
   (Arr : in out Integer_Array;
    Low, High : Index_Type) return Index_Type
   with Pre  => Low <= High and High in Arr'Range,
        Post => Partition'Result in Low .. High
            and (for all I in Low .. Partition'Result - 1 =>
                   Arr(I) <= Arr(Partition'Result))
            and (for all I in Partition'Result + 1 .. High =>
                   Arr(I) >= Arr(Partition'Result));
```

### Count Occurrences

```ada
function Count_If
   (Arr       : Integer_Array;
    Predicate : Integer) return Natural
   with Post => Count_If'Result <= Arr'Length
            and Count_If'Result =
                (for quantified I in Arr'Range =>
                   (if Arr(I) = Predicate then 1 else 0));
```

### Fill Array

```ada
procedure Fill (Arr : out Integer_Array; Value : Integer)
   with Post => (for all I in Arr'Range => Arr(I) = Value);
```

### Is Sorted Check

```ada
function Is_Sorted (Arr : Integer_Array) return Boolean
   with Post => Is_Sorted'Result =
                (for all I in Arr'First .. Arr'Last - 1 =>
                   Arr(I) <= Arr(I + 1));
```

### Remove Duplicates (returns new length)

```ada
procedure Remove_Duplicates
   (Arr : in out Integer_Array;
    Len : out Natural)
   with Post => Len <= Arr'Length
            and (for all I in Arr'First .. Arr'First + Len - 1 =>
                   (for all J in Arr'First .. Arr'First + Len - 1 =>
                      (if I /= J then Arr(I) /= Arr(J))));
```

---

## C Code Smells → Verification Targets

Patterns in C code that indicate verification opportunities.

### 1. Unchecked Array Access

**C Smell:**
```c
void fill(int arr[], int size, int value) {
    for (int i = 0; i < size; i++) {
        arr[i] = value;  // ⚠️ No bounds checking
    }
}
```

**Verification Needed:**
- Prove `i` is always in valid range
- Prove `arr` has at least `size` elements

**SPARK Solution:**
```ada
procedure Fill (Arr : out Integer_Array; Value : Integer)
   with Post => (for all I in Arr'Range => Arr(I) = Value);
--  Bounds checking automatic, no separate size parameter needed
```

### 2. Pointer Arithmetic

**C Smell:**
```c
char *find_char(char *str, char c, int max_len) {
    for (int i = 0; i < max_len; i++) {
        if (str[i] == c) {
            return str + i;  // ⚠️ Pointer arithmetic
        }
    }
    return NULL;
}
```

**Verification Needed:**
- Prove `i` doesn't go past string end
- Prove returned pointer is valid or NULL

**SPARK Solution:**
```ada
function Find_Char
   (Str : String;
    C   : Character) return Natural
   with Post => (if Find_Char'Result in Str'Range then
                    Str(Find_Char'Result) = C
                 else
                    (for all I in Str'Range => Str(I) /= C));
--  Return index instead of pointer; 0 means not found
```

### 3. Integer Overflow

**C Smell:**
```c
int multiply_and_add(int a, int b, int c) {
    return a * b + c;  // ⚠️ Two overflow points
}
```

**Verification Needed:**
- Prove `a * b` doesn't overflow
- Prove `(a * b) + c` doesn't overflow

**SPARK Solution:**
```ada
function Multiply_And_Add (A, B, C : Integer) return Integer
   with Pre => abs A <= Integer'Last / abs B  -- Multiplication safe
           and then abs (A * B) <= Integer'Last - abs C,  -- Addition safe
        Post => Multiply_And_Add'Result = A * B + C;
```

### 4. Buffer Operations

**C Smell:**
```c
void copy_buffer(char *dest, char *src, int n) {
    for (int i = 0; i < n; i++) {
        dest[i] = src[i];  // ⚠️ No size checking
    }
}
```

**Verification Needed:**
- Prove `dest` has space for `n` elements
- Prove `src` has at least `n` elements
- Prove no overlap if used with memcpy semantics

**SPARK Solution:**
```ada
procedure Copy_Buffer
   (Dest : out Character_Array;
    Src  : Character_Array;
    N    : Natural)
   with Pre => N <= Dest'Length and N <= Src'Length,
        Post => (for all I in 0 .. N - 1 =>
                   Dest(Dest'First + I) = Src(Src'First + I));
```

### 5. State Invariants in Structures

**C Smell:**
```c
typedef struct {
    int *data;
    int size;
    int capacity;
} Vector;

void push(Vector *v, int value) {
    v->data[v->size] = value;  // ⚠️ Assumes size < capacity
    v->size++;
}
```

**Verification Needed:**
- Prove `size < capacity` before access
- Prove `data` is valid
- Maintain invariant: `0 <= size <= capacity`

**SPARK Solution:**
```ada
type Vector (Capacity : Positive) is record
   Data : Integer_Array (1 .. Capacity);
   Size : Natural := 0;
end record
   with Type_Invariant => Size <= Capacity;

procedure Push (V : in out Vector; Value : Integer)
   with Pre  => V.Size < V.Capacity,
        Post => V.Size = V.Size'Old + 1
            and V.Data(V.Size) = Value
            and (for all I in 1 .. V.Size'Old =>
                   V.Data(I) = V.Data'Old(I));
```

### 6. Division Without Check

**C Smell:**
```c
float average(int sum, int count) {
    return (float)sum / count;  // ⚠️ No zero check
}
```

**Verification Needed:**
- Prove `count /= 0`

**SPARK Solution:**
```ada
function Average (Sum : Integer; Count : Positive) return Float
   with Post => Average'Result = Float(Sum) / Float(Count);
--  Positive type ensures Count > 0
```

---

## Incremental Verification Strategy

Build up contracts progressively, from simple safety to full functional correctness.

### Level 1: Safety Contracts

**Goal:** Prevent crashes and undefined behavior

```ada
--  Prevent division by zero
function Divide (X, Y : Integer) return Integer
   with Pre => Y /= 0;

--  Prevent buffer overflow
procedure Update (Arr : in out Integer_Array; I : Index_Type)
   with Pre => I in Arr'Range;

--  Prevent null dereference
--  (Use parameter modes instead of access types)
```

### Level 2: Type Correctness

**Goal:** Ensure proper types and ranges

```ada
--  Return type constrains result
function Abs_Value (X : Integer) return Natural
   with Pre => X /= Integer'First;

--  Subtype constraints
subtype Percentage is Integer range 0 .. 100;
function Calculate_Percentage (Part, Whole : Natural) return Percentage
   with Pre => Whole /= 0 and Part <= Whole;
```

### Level 3: Functional Correctness

**Goal:** Specify what the function computes

```ada
--  Mathematical relationship
function GCD (A, B : Positive) return Positive
   with Post => A rem GCD'Result = 0
            and B rem GCD'Result = 0;

--  Transformation
procedure Double_All (Arr : in out Integer_Array)
   with Post => (for all I in Arr'Range => Arr(I) = Arr'Old(I) * 2);
```

### Level 4: Relational Properties

**Goal:** Express relationships between inputs and outputs

```ada
--  Maximum property
function Max (A, B : Integer) return Integer
   with Post => Max'Result >= A
            and Max'Result >= B
            and (Max'Result = A or Max'Result = B);

--  Preservation
procedure Swap (A : in out Integer; B : in out Integer)
   with Post => A = B'Old and B = A'Old;
```

### Level 5: Non-Interference

**Goal:** Specify what doesn't change

```ada
--  Single element update
procedure Set_Element
   (Arr   : in out Integer_Array;
    Index : Index_Type;
    Value : Integer)
   with Pre  => Index in Arr'Range,
        Post => Arr(Index) = Value
            and (for all I in Arr'Range =>
                   (if I /= Index then Arr(I) = Arr'Old(I)));
```

### Level 6: Complete Specification

**Goal:** Full functional specification with all properties

```ada
function Binary_Search
   (Arr    : Integer_Array;
    Target : Integer) return Extended_Index_Type
   with
      --  Precondition: array must be sorted
      Pre => (for all I in Arr'First .. Arr'Last - 1 =>
                Arr(I) <= Arr(I + 1)),
      --  Postcondition: result correctness
      Post => (if Binary_Search'Result in Arr'Range then
                  --  Found: index points to target
                  Arr(Binary_Search'Result) = Target
               else
                  --  Not found: target not in array
                  (for all I in Arr'Range => Arr(I) /= Target));
```

---

## Tips for Writing Good Contracts

### 1. Start Simple, Add Complexity

Begin with basic safety, then add functional properties:
```ada
--  Level 1: Safety
with Pre => Divisor /= 0

--  Level 2: Add result property
with Pre  => Divisor /= 0,
     Post => Divide'Result = Dividend / Divisor
```

### 2. Use Meaningful Names

```ada
--  Bad: unclear
with Pre => X /= 0 and Y > Z

--  Good: self-documenting
with Pre => Divisor /= 0 and Max_Size > Current_Size
```

### 3. Separate Concerns

```ada
--  Multiple preconditions for clarity
with Pre => Index in Arr'Range          -- Bounds
        and Value >= 0                  -- Domain
        and Arr(Index) /= Locked_Value  -- State
```

### 4. Document Complex Expressions

```ada
with Pre =>
   --  Ensure multiplication won't overflow
   abs A <= Integer'Last / abs B
   --  Ensure addition won't overflow
   and then abs (A * B) <= Integer'Last - abs C
```

### 5. Test Contracts Early

Run `gnatprove` frequently to catch issues:
```bash
gnatprove -P project.gpr --level=0  # Fast, basic checks
gnatprove -P project.gpr --level=2  # Thorough proving
```

---

## Resources

- **SPARK User Guide**: https://docs.adacore.com/spark2014-docs/html/ug/
- **SPARK by Example**: https://github.com/AdaCore/spark-by-example
- **AdaCore Blog - Proof**: https://blog.adacore.com/tag/proof
- **Loop Invariants**: https://blog.adacore.com/loop-invariants-and-why-they-matter

---

For practical examples applying these patterns, see the `examples/` directory.
