# Buffer Safety - Preventing Buffer Overflows

Buffer overflows are one of the most dangerous classes of bugs in C, responsible for countless security vulnerabilities. SPARK makes them nearly impossible through strong typing, bounds checking, and formal verification.

## Why Buffer Overflows are Dangerous

- **Memory corruption** - Overwrite adjacent data
- **Code execution** - Attacker can inject and execute code
- **Information disclosure** - Read beyond intended bounds
- **Crashes** - Unpredictable program behavior
- **Security breaches** - Most exploited vulnerability type

---

## Vulnerability 1: Unchecked Array Indexing

### C Code (Vulnerable)

```c
void set_score(int scores[], int index, int value) {
    scores[index] = value;  // ⚠️ No bounds checking!
}

int scores[5] = {0};
set_score(scores, 10, 100);  // ⚠️ BUFFER OVERFLOW!
```

**Problems:**
- Array decays to pointer - loses size information
- No way to check if `index` is valid
- Writing to `scores[10]` overwrites random memory
- Could crash, corrupt data, or worse - execute arbitrary code

**Why This is Exploitable:**
```c
int scores[5];
char password[] = "secret";

set_score(scores, 10, 0x41414141);  // Overwrites password!
```

### SPARK Code (Safe)

```ada
procedure Set_Score
   (Scores : in out Score_Array;
    Index  : Positive;
    Value  : Integer)
   with Pre => Index in Scores'Range  -- MUST be valid!
is
begin
   Scores (Index) := Value;  -- Automatic bounds check
end Set_Score;

Scores : Score_Array (1 .. 5) := (others => 0);
Set_Score (Scores, 10, 100);  -- Precondition fails OR runtime error
```

**Protection Mechanisms:**
1. **Compile-time**: Precondition violation detected
2. **Runtime**: `Constraint_Error` raised if index invalid
3. **Proof**: SPARK can prove all calls use valid indices

---

## Vulnerability 2: String Copy Without Bounds Check

### C Code (Vulnerable)

```c
void copy_name(char *dest, const char *src) {
    strcpy(dest, src);  // ⚠️ No length checking!
}

char name[64];
char *long_name = "This is a very long string that exceeds 64 characters...";
copy_name(name, long_name);  // ⚠️ BUFFER OVERFLOW!
```

**Problems:**
- `strcpy` doesn't check destination size
- Writes past end of `name` buffer
- Classic buffer overflow vulnerability
- Used in countless exploits

**Real-World Impact:**
- Morris Worm (1988) - first internet worm
- Code Red (2001) - infected 350,000 servers
- Heartbleed (2014) - OpenSSL vulnerability

### SPARK Code (Safe)

```ada
procedure Copy_Name
   (Dest : out String;
    Src  : String)
   with Pre => Src'Length <= Dest'Length  -- Destination big enough!
is
begin
   for I in 1 .. Src'Length loop
      Dest (Dest'First + I - 1) := Src (Src'First + I - 1);
   end loop;
   --  Fill rest with spaces
   for I in Dest'First + Src'Length .. Dest'Last loop
      Dest (I) := ' ';
   end loop;
end Copy_Name;
```

**Protection Mechanisms:**
1. **Precondition**: Verifies destination is large enough
2. **Bounds checking**: Each array access is checked
3. **Type system**: String includes its bounds
4. **Proof**: SPARK proves no overflow possible

---

## Vulnerability 3: Off-By-One Error

### C Code (Vulnerable)

```c
void fill_buffer(char *buf, int size, char value) {
    for (int i = 0; i <= size; i++) {  // ⚠️ Should be i < size
        buf[i] = value;
    }
}

char buffer[10];
fill_buffer(buffer, 10, 'A');  // ⚠️ Writes 11 bytes into 10-byte buffer!
```

**Problems:**
- Loop condition uses `<=` instead of `<`
- Writes one past end of buffer
- Very common mistake
- Hard to spot in code review

**Why Off-By-One Errors Happen:**
- C arrays are 0-indexed: `arr[0]` to `arr[size-1]`
- Easy to confuse `<` vs `<=`, `0` vs `1`, `size` vs `size-1`
- Loop conditions are error-prone

### SPARK Code (Safe)

```ada
procedure Fill_Buffer
   (Buf   : out Buffer_Array;
    Value : Character)
   with Post => (for all I in Buf'Range => Buf (I) = Value)
is
begin
   for I in Buf'Range loop  -- Correct by construction!
      Buf (I) := Value;
   end loop;
end Fill_Buffer;
```

**Protection Mechanisms:**
1. **`Buf'Range`**: Automatically correct range
2. **No separate size parameter**: Can't mismatch
3. **Impossible to get wrong**: Language prevents off-by-one
4. **Postcondition**: Proves all elements filled

---

## Vulnerability 4: Unchecked User Input

### C Code (Vulnerable)

```c
void read_into_buffer(char *buf, int max_size) {
    printf("Enter data: ");
    scanf("%s", buf);  // ⚠️ No limit on input size!
}
```

**Problems:**
- `scanf("%s")` reads until whitespace - no length limit
- User can input > `max_size` characters
- Direct path to buffer overflow exploit
- `gets()` is even worse (removed from C11)

**Exploit Scenario:**
```c
char username[32];
char password[32];

read_into_buffer(username, 32);
// Attacker enters 64 'A's - overwrites password!
```

### SPARK Code (Safe)

```ada
procedure Read_Into_Buffer
   (Buf      : out String;
    Max_Size : Positive)
   with Pre => Max_Size <= Buf'Length
is
begin
   --  Ada.Text_IO.Get_Line is bounds-safe
   declare
      Input : String := Ada.Text_IO.Get_Line;
   begin
      if Input'Length <= Max_Size then
         Buf (Buf'First .. Buf'First + Input'Length - 1) := Input;
      else
         --  Truncate to fit
         Buf (Buf'First .. Buf'First + Max_Size - 1) :=
            Input (Input'First .. Input'First + Max_Size - 1);
      end if;
   end;
end Read_Into_Buffer;
```

**Protection Mechanisms:**
1. **`Get_Line`**: Returns bounded String
2. **Length checking**: Explicit truncation if needed
3. **Bounds checking**: All slicing is checked
4. **Type safety**: String includes its size

---

## Vulnerability 5: Buffer Overlap

### C Code (Vulnerable)

```c
void shift_data(char *buf, int size, int offset) {
    for (int i = 0; i < size - offset; i++) {
        buf[i] = buf[i + offset];  // ⚠️ Could access past end
    }
}
```

**Problems:**
- If `offset > size`, then `size - offset` wraps around (unsigned)
- `buf[i + offset]` could read past end of buffer
- Overlapping memory regions can cause corruption

### SPARK Code (Safe)

```ada
procedure Shift_Data
   (Buf    : in out Buffer_Array;
    Offset : Natural)
   with Pre => Offset <= Buf'Length
is
begin
   for I in Buf'First .. Buf'Last - Offset loop
      Buf (I) := Buf (I + Offset);
      pragma Loop_Invariant
         (for all J in Buf'First .. I =>
            Buf (J) = Buf'Old (J + Offset));
   end loop;
end Shift_Data;
```

**Protection Mechanisms:**
1. **Precondition**: `Offset <= Buf'Length`
2. **Loop range**: `Buf'Last - Offset` is safe
3. **Bounds checking**: `Buf (I + Offset)` verified
4. **Loop invariant**: Proves correctness

---

## Vulnerability 6: Integer Overflow → Buffer Overflow

### C Code (Vulnerable)

```c
void allocate_and_fill(int count) {
    int buffer_size = count * sizeof(int);  // ⚠️ Could overflow!

    if (buffer_size > 0) {  // Won't catch overflow
        int *buf = (int *)malloc(buffer_size);
        for (int i = 0; i < count; i++) {
            buf[i] = i;  // ⚠️ Writing past allocation!
        }
        free(buf);
    }
}

allocate_and_fill(0x40000000);  // Overflows to small allocation
```

**Problems:**
- `count * sizeof(int)` can overflow
- Overflow wraps to small positive number
- `malloc` allocates small buffer
- Loop writes way past allocation

**Example:**
```
count = 0x40000000 (1,073,741,824)
sizeof(int) = 4
buffer_size = 0x40000000 * 4 = 0x100000000 (overflow!)
             = 0 (on 32-bit) or small value
malloc(0) or malloc(small) succeeds
Loop writes 4GB of data - HUGE overflow!
```

### SPARK Code (Safe)

```ada
procedure Allocate_And_Fill (Count : Positive)
   with Pre => Count <= 1000  -- Reasonable bound
is
   type Int_Array is array (1 .. Count) of Integer;
   Buf : Int_Array;  -- Stack allocated
begin
   for I in Buf'Range loop
      Buf (I) := I;
   end loop;
   --  Automatic deallocation
end Allocate_And_Fill;
```

**Protection Mechanisms:**
1. **Precondition**: Bounds `Count` to reasonable value
2. **Stack allocation**: No overflow in size calculation
3. **Type system**: Array size is part of type
4. **Bounds checking**: All accesses verified

---

## Summary: C Vulnerabilities → SPARK Protections

| C Vulnerability | SPARK Protection | How It's Prevented |
|----------------|------------------|-------------------|
| Unchecked array index | Preconditions + runtime checks | `Pre => I in Arr'Range` |
| `strcpy` overflow | String type includes bounds | `Pre => Src'Length <= Dest'Length` |
| Off-by-one errors | `Arr'Range` iteration | Correct by construction |
| `scanf` overflow | Bounded `Get_Line` | Returns bounded String |
| Buffer overlap | Preconditions on offset | `Pre => Offset <= Buf'Length` |
| Integer overflow → buffer | Preconditions + type system | `Pre => Count <= Max` |

---

## Verification with SPARK

All SPARK versions can be formally proven safe:

```bash
gnatprove -P project.gpr --level=2
```

**SPARK will prove:**
- ✓ All array accesses are in bounds
- ✓ All preconditions hold at call sites
- ✓ All postconditions hold on return
- ✓ No integer overflow
- ✓ All out parameters are initialized
- ✓ Loop invariants hold

**C cannot provide these guarantees** - even with static analysis tools.

---

## Real-World Impact

### C Buffer Overflow Vulnerabilities (Examples)

- **Heartbleed (2014)** - OpenSSL, read beyond buffer bounds
- **Stagefright (2015)** - Android, 950M devices vulnerable
- **WannaCry (2017)** - Windows SMB buffer overflow
- **BlueKeep (2019)** - Windows RDP buffer overflow

### SPARK Success Stories

- **Tokeneer** - Secure entry system, formally verified
- **iFACTS** - Air traffic control, zero defects
- **NVIDIA GPU drivers** - Security-critical components
- **Arm TrustZone** - Secure world firmware

---

## Key Takeaways

1. **C buffer overflows** are one of the most exploited vulnerability types
2. **SPARK prevents them** through type system, bounds checking, and verification
3. **Automatic protection** - don't need to remember to check
4. **Formal proof** - mathematically certain no overflow can occur
5. **No performance penalty** - bounds checks can be optimized away when proven safe
6. **Security by design** - vulnerabilities prevented at language level

Buffer overflows in SPARK are **not just unlikely - they're impossible** (in verified code).
