--  Basic arithmetic operations
--  Demonstrates operators and integer arithmetic

with Ada.Text_IO; use Ada.Text_IO;

procedure Example is
   A : Integer := 10;
   B : Integer := 3;

   --  Basic operations
   Sum        : Integer := A + B;
   Difference : Integer := A - B;
   Product    : Integer := A * B;
   Quotient   : Integer := A / B;      --  Integer division
   Remainder  : Integer := A rem B;    --  Remainder (rem)

   --  Variable for compound operations
   X : Integer := 5;

begin
   --  Compound operations (Ada doesn't have += syntax)
   X := X + 2;
   X := X * 3;

   --  Print results
   Put_Line ("a = " & Integer'Image (A) & ", b = " & Integer'Image (B));
   Put_Line ("Sum: " & Integer'Image (Sum));
   Put_Line ("Difference: " & Integer'Image (Difference));
   Put_Line ("Product: " & Integer'Image (Product));
   Put_Line ("Quotient: " & Integer'Image (Quotient));
   Put_Line ("Remainder: " & Integer'Image (Remainder));
   Put_Line ("x after operations: " & Integer'Image (X));
end Example;
