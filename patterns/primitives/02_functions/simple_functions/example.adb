--  Simple function definitions and calls
--  Demonstrates basic function and procedure syntax

with Ada.Text_IO; use Ada.Text_IO;

procedure Example is

   --  Constrained subtype to prevent overflow in addition
   subtype Small_Int is Integer range -1_000_000 .. 1_000_000;

   --  Function to add two integers (returns a value)
   function Add (A : Small_Int; B : Small_Int) return Integer is
   begin
      return A + B;
   end Add;

   --  Function to compute absolute value
   --  Pre: X > Integer'First because -Integer'First overflows
   function Abs_Value (X : Integer) return Natural
      with Pre => X > Integer'First
   is
   begin
      if X < 0 then
         return -X;
      else
         return X;
      end if;
   end Abs_Value;

   --  Procedure with no return value (like void in C)
   procedure Print_Greeting is
   begin
      Put_Line ("Hello from a procedure!");
   end Print_Greeting;

   Result1 : Integer;
   Result2 : Natural;

begin
   Result1 := Add (5, 3);
   Result2 := Abs_Value (-42);

   Put_Line ("5 + 3 = " & Integer'Image (Result1));
   Put_Line ("abs(-42) = " & Natural'Image (Result2));

   Print_Greeting;
end Example;
