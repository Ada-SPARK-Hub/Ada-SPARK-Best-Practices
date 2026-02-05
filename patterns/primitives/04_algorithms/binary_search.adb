--  Binary Search with Loop Invariants
--  Demonstrates how to prove algorithm correctness with SPARK

with Ada.Text_IO; use Ada.Text_IO;

procedure Binary_Search is

   --  Bounded index type prevents overflow in index arithmetic
   --  (e.g., Mid + 1 or Mid - 1 always fit in Natural/Positive)
   Max_Size : constant := 10_000;
   subtype Index_Type is Positive range 1 .. Max_Size;
   type Integer_Array is array (Index_Type range <>) of Integer;

   --  Helper: Check if array is sorted (expression function)
   --  Guard with Arr'Length > 1 to avoid overflow on Arr'Last - 1
   function Is_Sorted (Arr : Integer_Array) return Boolean is
     (Arr'Length <= 1
      or else (for all I in Arr'First .. Arr'Last - 1 =>
                 Arr (I) <= Arr (I + 1)));

   --  Binary search with full verification
   --  Returns index of Target if found, or 0 if not found.
   --  Uses Natural for Right so it can go below Arr'First (to 0)
   --  when the search space is exhausted.
   function Search
      (Arr    : Integer_Array;
       Target : Integer) return Natural
      with
         Pre  => Arr'Length >= 1
                 and then Is_Sorted (Arr),
         Post => (if Search'Result in Arr'Range then
                     Arr (Search'Result) = Target
                  else
                     Search'Result = 0)
   is
      Left  : Positive := Arr'First;
      Right : Natural  := Arr'Last;
      Mid   : Index_Type;
   begin
      while Left <= Right loop
         --  Loop variant proves termination: search space shrinks each iteration
         pragma Loop_Variant (Decreases => Right - Left);

         --  Left and Right stay within array bounds while loop runs
         pragma Loop_Invariant (Left in Arr'Range);
         pragma Loop_Invariant (Right in Arr'Range);

         --  Calculate midpoint avoiding overflow
         Mid := Left + (Right - Left) / 2;

         if Arr (Mid) = Target then
            return Mid;  -- Found!

         elsif Arr (Mid) < Target then
            --  Target must be in right half
            Left := Mid + 1;

         else  -- Arr (Mid) > Target
            --  Target must be in left half
            Right := Mid - 1;
         end if;
      end loop;

      --  Not found
      return 0;
   end Search;

   --  Test procedure
   procedure Test_Binary_Search is
      Arr : constant Integer_Array := (1, 3, 5, 7, 9, 11, 13, 15, 17, 19);
      Targets : constant array (1 .. 6) of Integer := (7, 19, 1, 10, 20, -5);
      Index : Natural;
   begin
      Put ("Array: ");
      for I in Arr'Range loop
         Put (Integer'Image (Arr (I)) & " ");
      end loop;
      New_Line;

      Put_Line ("Is sorted: " & Boolean'Image (Is_Sorted (Arr)));
      New_Line;

      for T of Targets loop
         Index := Search (Arr, T);

         if Index in Arr'Range then
            Put_Line ("Found" & Integer'Image (T) &
                     " at index" & Integer'Image (Index));
         else
            Put_Line (Integer'Image (T) & " not found");
         end if;
      end loop;
   end Test_Binary_Search;

begin
   Test_Binary_Search;
end Binary_Search;
