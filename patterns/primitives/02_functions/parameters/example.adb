--  Function parameter modes
--  Demonstrates in, out, and in out parameter modes

with Ada.Text_IO; use Ada.Text_IO;

procedure Example is

   --  Pass by value (in mode - Ada default)
   function Increment (X : in Integer) return Integer
      with Pre => X < Integer'Last  --  Prevent overflow
   is
   begin
      --  Cannot modify X (in mode is read-only)
      return X + 1;
   end Increment;

   --  Pass by reference for modification (in out mode)
   procedure Swap (A : in out Integer; B : in out Integer)
      with Post => A = B'Old and B = A'Old
   is
      Temp : constant Integer := A;
   begin
      A := B;
      B := Temp;
   end Swap;

   --  Multiple output values using out mode
   procedure Divide_With_Remainder
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
   end Divide_With_Remainder;

   X      : Integer := 5;
   Result : Integer;
   A, B   : Integer;
   Quot, Rmdr : Integer;

begin
   --  Test increment (in mode)
   Result := Increment (X);
   Put_Line ("Original x: " & Integer'Image (X) &
             ", Result: " & Integer'Image (Result));

   --  Test swap (in out mode)
   A := 10;
   B := 20;
   Put_Line ("Before swap: a=" & Integer'Image (A) &
             ", b=" & Integer'Image (B));
   Swap (A, B);
   Put_Line ("After swap: a=" & Integer'Image (A) &
             ", b=" & Integer'Image (B));

   --  Test multiple outputs (out mode)
   Divide_With_Remainder (17, 5, Quot, Rmdr);
   Put_Line ("17 / 5 = " & Integer'Image (Quot) &
             " remainder " & Integer'Image (Rmdr));
end Example;
