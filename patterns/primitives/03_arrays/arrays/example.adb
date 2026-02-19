--  Array operations with bounds checking
--  Demonstrates array declaration, initialization, and access

with Ada.Text_IO; use Ada.Text_IO;

procedure Example is

   --  Define array type with explicit bounds
   --  Constrained element range prevents overflow when summing:
   --  5 elements * 10_000 max = 50_000, well within Integer range
   type Index_Type is range 1 .. 5;
   subtype Element is Integer range -10_000 .. 10_000;
   type Number_Array is array (Index_Type) of Element;

   --  Function to sum array elements
   function Sum_Array (Arr : Number_Array) return Integer is
      Sum : Integer := 0;
   begin
      for I in Arr'Range loop
         Sum := Sum + Arr (I);
         --  Track cumulative bounds: after I iterations, |Sum| <= I * 10_000
         pragma Loop_Invariant
            (Sum in -10_000 * Index_Type'Pos (I) ..
                     10_000 * Index_Type'Pos (I));
      end loop;
      return Sum;
   end Sum_Array;

   --  Function to find maximum element
   function Find_Max (Arr : Number_Array) return Integer
      with Post => (for all I in Arr'Range => Find_Max'Result >= Arr (I))
   is
      Max : Integer := Arr (Arr'First);
   begin
      for I in Arr'Range loop
         if Arr (I) > Max then
            Max := Arr (I);
         end if;
         pragma Loop_Invariant
            (for all J in Arr'First .. I => Max >= Arr (J));
      end loop;
      return Max;
   end Find_Max;

   --  Array declaration and initialization
   Numbers : Number_Array := (10, 25, 3, 47, 15);

   Total   : Integer;
   Maximum : Integer;

begin
   --  Access elements (Ada arrays typically start at 1)
   Put_Line ("First element: " & Integer'Image (Numbers (Numbers'First)));
   Put_Line ("Last element: " & Integer'Image (Numbers (Numbers'Last)));

   --  Iterate and print
   Put ("All elements: ");
   for I in Numbers'Range loop
      Put (Integer'Image (Numbers (I)) & " ");
   end loop;
   New_Line;

   --  Use functions
   Total   := Sum_Array (Numbers);
   Maximum := Find_Max (Numbers);

   Put_Line ("Sum: " & Integer'Image (Total));
   Put_Line ("Maximum: " & Integer'Image (Maximum));
end Example;
