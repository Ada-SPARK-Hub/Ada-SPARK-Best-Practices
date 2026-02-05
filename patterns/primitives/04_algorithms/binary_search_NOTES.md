# Binary Search with Loop Invariants

Binary search is a classic algorithm that perfectly demonstrates the power of loop invariants and formal verification. While the C version relies on testing to build confidence, the SPARK version can be **mathematically proven correct**.

## The Algorithm

Binary search finds a target in a sorted array by repeatedly dividing the search space in half.

**Time Complexity:** O(log n)
**Space Complexity:** O(1)

---

## C Version: Testing-Based Confidence

### C Code

```c
int binary_search(int arr[], int size, int target) {
    int left = 0;
    int right = size - 1;

    while (left <= right) {
        int mid = left + (right - left) / 2;  // Avoid overflow

        if (arr[mid] == target) {
            return mid;  // Found
        }
        else if (arr[mid] < target) {
            left = mid + 1;  // Search right half
        }
        else {
            right = mid - 1;  // Search left half
        }
    }

    return -1;  // Not found
}
```

### C Limitations

**Cannot Prove:**
1. Algorithm terminates
2. Algorithm is correct (finds target if present)
3. Algorithm is complete (returns not-found if absent)
4. No array out-of-bounds access
5. No integer overflow

**Must Rely On:**
- Unit tests (finite cases)
- Code review (human judgment)
- Hope (fingers crossed!)

### Common C Bugs

```c
// Bug 1: Integer overflow in mid calculation
int mid = (left + right) / 2;  // ⚠️ Overflows if left + right > INT_MAX
// Famous bug found in Java's binary search after 9 years!

// Bug 2: Off-by-one in loop condition
while (left < right)  // ⚠️ Should be <=
// Misses single-element case

// Bug 3: Wrong range update
left = mid;  // ⚠️ Should be mid + 1
// Infinite loop!
```

---

## SPARK Version: Proven Correct

### Key Contract: Precondition

```ada
with Pre => (for all I in Arr'First .. Arr'Last - 1 =>
               Arr (I) <= Arr (I + 1))  -- Array is sorted
```

**Meaning:** Binary search only works on sorted arrays. This makes that requirement explicit and checkable.

### Key Contract: Postcondition

```ada
with Post =>
   (if Binary_Search_Verified'Result in Arr'Range then
       --  If found, result points to target
       Arr (Binary_Search_Verified'Result) = Target
    else
       --  If not found, target is not in array
       (for all I in Arr'Range => Arr (I) /= Target))
```

**Meaning:** This specifies exactly what the function guarantees:
1. If it returns an index, that index contains the target
2. If it returns 0 (not found), the target is nowhere in the array

This is the **complete functional specification**!

---

## Loop Invariants: The Key to Proof

Loop invariants are properties that hold:
1. Before the loop starts
2. After each iteration
3. When the loop exits

They're how we prove loops are correct.

### Invariant 1: Bounds Stay Valid

```ada
pragma Loop_Invariant (Left in Arr'Range);
pragma Loop_Invariant (Right in Arr'Range);
pragma Loop_Invariant (Left <= Right + 1);
pragma Loop_Invariant (Mid in Left .. Right);
```

**Why This Matters:**
- Proves `Left` and `Right` never go out of bounds
- Proves `Mid` is always a valid index
- Guarantees no `Constraint_Error` from array access

### Invariant 2: Search Space Shrinks

```ada
pragma Loop_Invariant (Left <= Right + 1);
```

**Why This Matters:**
- Search space = `Right - Left + 1`
- Each iteration either finds target or reduces space
- Eventually `Left > Right` and loop exits
- Proves **termination**

### Invariant 3: Target Not in Excluded Ranges (CRITICAL)

```ada
pragma Loop_Invariant
   (for all I in Arr'First .. Left - 1 => Arr (I) < Target);
pragma Loop_Invariant
   (for all I in Right + 1 .. Arr'Last => Arr (I) > Target);
```

**Why This is THE Key Invariant:**

This proves correctness! Here's why:

**At loop start:**
- `Left = Arr'First`, so range `Arr'First .. Left - 1` is empty → trivially true
- `Right = Arr'Last`, so range `Right + 1 .. Arr'Last` is empty → trivially true

**During iteration:**
- If `Arr (Mid) < Target`: We know target must be in right half (because array is sorted)
  - Set `Left := Mid + 1`
  - Now all elements `Arr'First .. Mid` are `< Target`
  - Invariant still holds!

- If `Arr (Mid) > Target`: We know target must be in left half (because array is sorted)
  - Set `Right := Mid - 1`
  - Now all elements `Mid .. Arr'Last` are `> Target`
  - Invariant still holds!

**At loop exit:**
- `Left > Right` (loop condition false)
- All elements `< Left` are `< Target`
- All elements `> Right` are `> Target`
- But `Left > Right`, so the entire array is covered!
- Therefore, target is not in array
- Postcondition proven!

---

## Proof Flow

```
                    Precondition
                         ↓
                Array is sorted
                         ↓
                  Loop starts
                         ↓
         ┌──── Loop Invariants Hold ────┐
         │                               │
         │   1. Bounds are valid        │
         │   2. Search space shrinks    │
         │   3. Target not in excluded  │
         │                               │
         │         Loop body:            │
         │    - Check arr[mid]          │
         │    - Update left/right       │
         │                               │
         └──── Invariants Still Hold ───┘
                         │
                   Loop exits
                  (left > right)
                         │
         ┌───────────────┴───────────────┐
         │                               │
    Found target                   Not found
    Return index                   Return 0
         │                               │
         └──────── Postcondition ────────┘
                         ↓
               Proven Correct!
```

---

## What SPARK Proves

Running `gnatprove`:

```bash
gnatprove -P project.gpr --level=2 binary_search.adb
```

**SPARK Proves:**

✓ **Termination** - Loop always exits (search space shrinks)
✓ **No crashes** - All array accesses are in bounds
✓ **No overflow** - Mid calculation cannot overflow
✓ **Correctness** - If target found, returned index is correct
✓ **Completeness** - If target not found, it's truly not in array
✓ **Precondition** - Caller must pass sorted array
✓ **Postcondition** - Function guarantees are met

**C Cannot Prove:** Any of these! Must rely on testing.

---

## Integer Overflow Bug

### C Bug (Real, Found in Java After 9 Years!)

```c
int mid = (left + right) / 2;  // ⚠️ OVERFLOW BUG
```

**Problem:**
- If `left = 0x50000000` and `right = 0x60000000`
- Then `left + right = 0xB0000000` (overflow on 32-bit!)
- Result is negative number
- `mid` becomes negative → array access crash!

**Fix:**
```c
int mid = left + (right - left) / 2;  // Safe from overflow
```

### SPARK: Overflow Proven Impossible

```ada
Mid := Left + (Right - Left) / 2;
```

**Why It's Safe:**
1. `Right - Left` is always in valid range (both are in `Arr'Range`)
2. `(Right - Left) / 2` is even smaller
3. `Left + small_value` stays in range
4. SPARK proves this mathematically!

---

## Loop Invariant Guidelines for Binary Search

### General Pattern for Binary Search

```ada
while Left <= Right loop
   Mid := Left + (Right - Left) / 2;

   --  Bounds invariants
   pragma Loop_Invariant (Left in Arr'Range);
   pragma Loop_Invariant (Right in Arr'Range);
   pragma Loop_Invariant (Mid in Left .. Right);

   --  Correctness invariants
   pragma Loop_Invariant
      (for all I in Arr'First .. Left - 1 => Arr (I) < Target);
   pragma Loop_Invariant
      (for all I in Right + 1 .. Arr'Last => Arr (I) > Target);

   --  Algorithm body
   if Arr (Mid) = Target then
      return Mid;
   elsif Arr (Mid) < Target then
      Left := Mid + 1;
   else
      Right := Mid - 1;
   end if;
end loop;
```

### Why These Invariants?

| Invariant | Purpose | What It Proves |
|-----------|---------|----------------|
| `Left in Arr'Range` | Safety | No out-of-bounds on left |
| `Right in Arr'Range` | Safety | No out-of-bounds on right |
| `Mid in Left .. Right` | Safety | Mid is always valid |
| `Left <= Right + 1` | Termination | Loop will exit |
| Elements `< Left` are `< Target` | Correctness | Target not in excluded range |
| Elements `> Right` are `> Target` | Correctness | Target not in excluded range |

---

## Comparison: C vs SPARK

| Aspect | C | SPARK |
|--------|---|-------|
| **Correctness** | Hope + Testing | Mathematical Proof |
| **Overflow** | Must remember to check | Proven safe |
| **Bounds** | Runtime errors possible | Proven safe |
| **Termination** | Assume it works | Proven |
| **Specification** | Comments (ignored) | Contracts (enforced) |
| **Confidence** | High after many tests | 100% certain |
| **Bug Discovery** | Runtime (production!) | Compile-time |

---

## Key Takeaways

1. **Loop invariants** are properties that hold before, during, and after each loop iteration

2. **Critical invariant** for binary search: target is not in the excluded ranges

3. **Precondition** (sorted array) is essential - algorithm breaks without it

4. **Postcondition** fully specifies behavior (found vs not found)

5. **SPARK proves** what C can only test

6. **Integer overflow** bugs are caught automatically

7. **Bounds errors** are impossible in proven code

8. **Mathematical certainty** vs statistical confidence

---

## Further Reading

- [SPARK by Example - Binary Search](https://github.com/AdaCore/spark-by-example)
- [Loop Invariants Guide](https://blog.adacore.com/loop-invariants-and-why-they-matter)
- [Famous Binary Search Bug](https://ai.googleblog.com/2006/06/extra-extra-read-all-about-it-nearly.html)

---

## Exercise: Add These Variants

Try adding loop invariants for:

1. **Linear search** - Find first occurrence
2. **Binary search** - Find first occurrence (not just any)
3. **Binary search** - Find last occurrence
4. **Binary search** - Count occurrences

Each requires different loop invariants!
