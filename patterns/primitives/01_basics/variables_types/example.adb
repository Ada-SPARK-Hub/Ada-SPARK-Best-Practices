--  Variable declarations and basic types
--  Demonstrates type declarations and initialization

with Ada.Text_IO; use Ada.Text_IO;

procedure Example is
   --  Integer types
   X     : Integer := 42;
   Count : Natural := 10;  -- Natural is 0 .. Integer'Last

   --  Floating point
   Temperature    : Float := 98.6;
   Precise_Value  : Long_Float := 3.14159265359;

   --  Character
   Letter : Character := 'A';

   --  Boolean
   Is_Valid : Boolean := True;

begin
   --  Print values
   Put_Line ("Integer: " & Integer'Image (X));
   Put_Line ("Natural: " & Natural'Image (Count));
   Put_Line ("Float: " & Float'Image (Temperature));
   Put_Line ("Long_Float: " & Long_Float'Image (Precise_Value));
   Put_Line ("Char: " & Letter);
   Put_Line ("Boolean: " & Boolean'Image (Is_Valid));
end Example;
