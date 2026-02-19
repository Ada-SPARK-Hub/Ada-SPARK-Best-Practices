# Arithmetic Operations Translation Notes

## Translation Patterns

### Basic Operators

**C Pattern:**
```c
int sum = a + b;
int difference = a - b;
int product = a * b;
int quotient = a / b;
int remainder = a % b;
```

**SPARK Pattern:**
```ada
Sum        : Integer := A + B;
Difference : Integer := A - B;
Product    : Integer := A * B;
Quotient   : Integer := A / B;
Remainder  : Integer := A rem B;  -- Note: rem not %
```

### Compound Assignment

**C Pattern:**
```c
x += 2;
x *= 3;
```

**SPARK Pattern:**
```ada
X := X + 2;
X := X * 3;
```

## Key Differences

1. **Modulo Operator**
   - C: `%` (modulo)
   - SPARK: `rem` (remainder) or `mod` (modulus)
   - Important: `rem` and `mod` differ for negative numbers!

2. **Compound Assignment**
   - C: Has `+=`, `-=`, `*=`, `/=`, etc.
   - SPARK: No compound assignment operators
   - Must write `X := X + 2` explicitly

3. **Integer Division**
   - Both: Truncate toward zero
   - SPARK: Can use `/` for integer or float types (type-safe)

4. **Operator Precedence**
   - Generally similar, but SPARK requires parentheses in some cases
   - Use parentheses liberally for clarity

## SPARK Enhancements

### Overflow Protection

```ada
--  Add overflow checks with preconditions
function Safe_Add (A, B : Integer) return Integer
   with Pre  => (if A > 0 and B > 0 then A <= Integer'Last - B else True)
                and then
                (if A < 0 and B < 0 then A >= Integer'First - B else True),
        Post => Safe_Add'Result = A + B
is
begin
   return A + B;
end Safe_Add;
```

### Range-Constrained Results

```ada
--  Use subtypes to constrain results
subtype Small_Int is Integer range -100 .. 100;

A : Small_Int := 10;
B : Small_Int := 3;
Sum : Small_Int := A + B;  -- Compiler checks range
```

## Verification Status

✓ Basic arithmetic is provable

With contracts, can prove:
- No overflow
- Division by non-zero
- Results within expected ranges

## Important Notes

### rem vs mod

```ada
--  rem: Remainder (matches C's %)
10 rem 3 = 1
-10 rem 3 = -1

--  mod: Modulus (mathematical modulo)
10 mod 3 = 1
-10 mod 3 = 2
```

Choose `rem` for C translation, `mod` for mathematical correctness.

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

- Ada uses `rem` instead of `%` for remainder
- No `+=` style operators in Ada
- Strong typing prevents mixing integer and float operations
- SPARK can prove absence of overflow with proper contracts
- Explicit is better than implicit (Ada philosophy)
