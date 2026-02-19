# Simple Functions Translation Notes

## Translation Patterns

### Function with Return Value

**C Pattern:**
```c
int add(int a, int b) {
    return a + b;
}
```

**SPARK Pattern:**
```ada
function Add (A : Integer; B : Integer) return Integer is
begin
   return A + B;
end Add;
```

### Function with No Return (void)

**C Pattern:**
```c
void print_greeting(void) {
    printf("Hello!\n");
}
```

**SPARK Pattern:**
```ada
procedure Print_Greeting is
begin
   Put_Line ("Hello!");
end Print_Greeting;
```

## Key Differences

1. **Function vs Procedure**
   - C: All are "functions", use `void` for no return
   - SPARK: `function` returns value, `procedure` doesn't

2. **Parameter Syntax**
   - C: `type name` format, comma-separated
   - SPARK: `name : type` format, semicolon-separated
   - Multiple params of same type: `A, B : Integer`

3. **Function Declaration**
   - C: Return type comes first
   - SPARK: `return` keyword comes after parameters

4. **Nested Subprograms**
   - C: Functions cannot be nested (except with extensions)
   - SPARK: Functions and procedures can be nested in other subprograms

5. **Parameter Names**
   - C: Lowercase convention
   - SPARK: Capitalize_Each_Word convention

## SPARK Enhancements

### Add Contracts

```ada
--  Function with precondition and postcondition
function Add (A : Integer; B : Integer) return Integer
   with Pre  => A in Integer'First / 2 .. Integer'Last / 2
                and then B in Integer'First / 2 .. Integer'Last / 2,
        Post => Add'Result = A + B
is
begin
   return A + B;
end Add;
```

### Better Type Safety

```ada
--  Return Natural (non-negative) for absolute value
function Abs_Value (X : Integer) return Natural
   with Post => (if X >= 0 then Abs_Value'Result = X
                 else Abs_Value'Result = -X)
is
begin
   if X < 0 then
      return -X;
   end if;
   return X;
end Abs_Value;
```

Benefits:
- `Natural` return type makes non-negative guarantee explicit
- Postcondition documents the behavior formally
- SPARK can prove the postcondition holds

## Verification Status

✓ Provable with contracts

Key verification points:
- Function always returns a value (SPARK enforces this)
- Return type matches declaration
- With contracts: behavior matches specification

## Important Notes

### Expression Functions (Ada 2012+)

Simple functions can use expression syntax:

```ada
function Add (A, B : Integer) return Integer is
   (A + B);

function Abs_Value (X : Integer) return Natural is
   (if X < 0 then -X else X);
```

This is more concise for simple functions.

### Forward Declarations

C requires forward declarations; SPARK ordering matters:

**C:**
```c
int add(int, int);  // Forward declaration

int main() { add(1, 2); }

int add(int a, int b) { return a + b; }
```

**SPARK:**
```ada
--  Define before use, or use package specs
procedure Example is
   function Add (A, B : Integer) return Integer;  -- Declaration

   function Add (A, B : Integer) return Integer is -- Body
   begin
      return A + B;
   end Add;
begin
   Put_Line (Integer'Image (Add (1, 2)));
end Example;
```

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

- Use `function` for return values, `procedure` for void
- Parameters use `Name : Type` syntax
- Functions can be nested inside procedures
- Expression functions provide concise syntax for simple cases
- Return type can be constrained (like `Natural`) for safety
- SPARK enforces that all paths return a value
