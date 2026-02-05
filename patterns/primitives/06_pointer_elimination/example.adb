--  Pointer pattern elimination in SPARK
--  Shows how to avoid pointers using parameter modes and better design

with Ada.Text_IO; use Ada.Text_IO;

procedure Example is

   --  Pattern 1: Output parameters - use "in out" mode instead of pointers
   procedure Swap (A : in out Integer; B : in out Integer)
      with Post => A = B'Old and B = A'Old
   is
      Temp : constant Integer := A;
   begin
      A := B;
      B := Temp;
   end Swap;

   --  Pattern 2: Multiple return values - use "out" mode or return record
   procedure Div_Mod
      (Dividend  : in Integer;
       Divisor   : in Integer;
       Quotient  : out Integer;
       Remainder : out Integer)
      with Pre  => Divisor /= 0
                   and then not (Dividend = Integer'First and Divisor = -1),
           Post => Quotient = Dividend / Divisor
               and Remainder = Dividend rem Divisor
   is
   begin
      Quotient  := Dividend / Divisor;
      Remainder := Dividend rem Divisor;
   end Div_Mod;

   --  Alternative: Return record for multiple values
   type Div_Result is record
      Quotient  : Integer;
      Remainder : Integer;
   end record;

   function Div_Mod_Func (Dividend, Divisor : Integer) return Div_Result
      with Pre  => Divisor /= 0
                   and then not (Dividend = Integer'First and Divisor = -1),
           Post => Div_Mod_Func'Result.Quotient = Dividend / Divisor
               and Div_Mod_Func'Result.Remainder = Dividend rem Divisor
   is
   begin
      return (Quotient  => Dividend / Divisor,
              Remainder => Dividend rem Divisor);
   end Div_Mod_Func;

   --  Pattern 3: Array modification - no pointer needed, array is implicit reference
   --  Constrained element type prevents overflow on +1
   subtype Small_Int is Integer range -1_000_000 .. 1_000_000;
   type Integer_Array is array (Positive range <>) of Small_Int;

   procedure Increment_All (Arr : in out Integer_Array)
      with Pre  => (for all I in Arr'Range => Arr (I) < Small_Int'Last),
           Post => (for all I in Arr'Range => Arr (I) = Arr'Old (I) + 1)
   is
   begin
      for I in Arr'Range loop
         Arr (I) := Arr (I) + 1;
         pragma Loop_Invariant
            (for all J in Arr'First .. I => Arr (J) = Arr'Loop_Entry (J) + 1);
         pragma Loop_Invariant
            (for all J in Arr'Range =>
               (if J > I then Arr (J) = Arr'Loop_Entry (J)));
      end loop;
   end Increment_All;

   --  Pattern 4: Range sum - no pointer arithmetic, use array slicing/indexing
   --  With Small_Int elements and max 1000 elements, sum fits in Integer
   function Sum_Range
      (Arr   : Integer_Array;
       Start : Positive;
       Stop  : Positive) return Integer
      with Pre  => Start in Arr'Range
               and Stop in Arr'Range
               and Start <= Stop
               and Stop - Start < 1000
   is
      Sum : Integer := 0;
   begin
      for I in Start .. Stop loop
         Sum := Sum + Arr (I);
         pragma Loop_Invariant
            (Sum in -1_000_000 * (I - Start + 1) ..
                     1_000_000 * (I - Start + 1));
      end loop;
      return Sum;
   end Sum_Range;

   --  Pattern 5: String operations - use String type, no pointer arithmetic
   function String_Length (Str : String) return Natural
      with Post => String_Length'Result = Str'Length
   is
   begin
      return Str'Length;  -- Built-in attribute, no manual counting!
   end String_Length;

   --  Pattern 6: Struct passing - use "in" mode for read-only access
   --  No pointer needed; compiler optimizes to pass by reference for large types
   --  Constrained coordinates prevent overflow in subtraction and abs
   subtype Coordinate is Integer range -1_000_000 .. 1_000_000;
   type Point is record
      X : Coordinate;
      Y : Coordinate;
   end record;

   function Manhattan_Distance (P1, P2 : Point) return Natural is
      DX : constant Integer := P1.X - P2.X;
      DY : constant Integer := P1.Y - P2.Y;
   begin
      return abs (DX) + abs (DY);
   end Manhattan_Distance;

   --  Test variables
   A, B      : Integer;
   Quot, Rmdr : Integer;
   Arr       : Integer_Array (1 .. 5) := (100, 200, 300, 400, 500);
   Total     : Integer;
   Str       : constant String := "Hello";
   P1        : constant Point := (X => 0, Y => 0);
   P2        : constant Point := (X => 3, Y => 4);
   Result    : Div_Result;

begin
   --  Test swap
   A := 5;
   B := 10;
   Put_Line ("Before swap: a=" & Integer'Image (A) &
             ", b=" & Integer'Image (B));
   Swap (A, B);
   Put_Line ("After swap: a=" & Integer'Image (A) &
             ", b=" & Integer'Image (B));

   --  Test div_mod (procedure version)
   Div_Mod (17, 5, Quot, Rmdr);
   Put_Line ("17 / 5 = " & Integer'Image (Quot) &
             " remainder " & Integer'Image (Rmdr));

   --  Test div_mod (function version)
   Result := Div_Mod_Func (17, 5);
   Put_Line ("Using function: 17 / 5 = " & Integer'Image (Result.Quotient) &
             " remainder " & Integer'Image (Result.Remainder));

   --  Test increment_all
   Increment_All (Arr);
   Put ("After increment: ");
   for I in Arr'Range loop
      Put (Integer'Image (Arr (I)) & " ");
   end loop;
   New_Line;

   --  Test sum_range
   Total := Sum_Range (Arr, 2, 4);  -- Sum indices 2-4
   Put_Line ("Sum of indices 2-4: " & Integer'Image (Total));

   --  Test string_length
   Put_Line ("Length of '" & Str & "': " &
             Natural'Image (String_Length (Str)));

   --  Test manhattan_distance
   Put_Line ("Manhattan distance: " &
             Natural'Image (Manhattan_Distance (P1, P2)));
end Example;
