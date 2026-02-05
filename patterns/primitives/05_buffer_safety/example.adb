--  Buffer safety in SPARK - preventing all buffer overflows
--  This code prevents all the vulnerabilities shown in the C version

with Ada.Text_IO; use Ada.Text_IO;

procedure Example is

   Max_Name_Len : constant := 64;
   Max_Buffer   : constant := 128;

   type Score_Array is array (Positive range <>) of Integer;
   type Buffer_Array is array (Positive range <>) of Character;

   --  Safe version 1: Array indexing with bounds checking
   procedure Set_Score
      (Scores : in out Score_Array;
       Index  : Positive;
       Value  : Integer)
      with Pre  => Index in Scores'Range,  -- Precondition ensures valid index
           Post => Scores (Index) = Value
               and (for all I in Scores'Range =>
                      (if I /= Index then Scores (I) = Scores'Old (I)))
   is
   begin
      Scores (Index) := Value;
      --  Runtime bounds check automatic even without precondition!
   end Set_Score;

   --  Safe version 2: String copy with compile-time size checking
   --  Uses bounded subtypes to prevent index overflow
   subtype Name_Index is Positive range 1 .. Max_Name_Len;
   subtype Name_String is String (Name_Index);

   --  in out mode: SPARK flow analysis can track initialization
   procedure Copy_Name
      (Dest : in out Name_String;
       Src  : String)
      with Pre => Src'Length <= Dest'Length
   is
   begin
      --  Single loop: copy source chars, then pad with spaces
      for I in Dest'Range loop
         if I - Dest'First < Src'Length then
            Dest (I) := Src (Src'First + (I - Dest'First));
         else
            Dest (I) := ' ';
         end if;
         pragma Loop_Invariant
            (for all J in Dest'First .. I =>
               (if J - Dest'First < Src'Length
                then Dest (J) = Src (Src'First + (J - Dest'First))
                else Dest (J) = ' '));
      end loop;
   end Copy_Name;

   --  Safe version 3: Fill buffer - impossible to have off-by-one
   subtype Buffer_Index is Positive range 1 .. Max_Buffer;
   subtype Bounded_Buffer is Buffer_Array (Buffer_Index);

   --  SPARK favors aggregate initialization - correct by construction!
   procedure Fill_Buffer
      (Buf   : out Bounded_Buffer;
       Value : Character)
      with Post => (for all I in Buf'Range => Buf (I) = Value)
   is
   begin
      Buf := (others => Value);  -- No loop needed - impossible to have off-by-one!
   end Fill_Buffer;

   --  Safe version 4: Bounded string input (simplified - no actual user input)
   --  Uses out mode since we initialize all elements.
   procedure Read_Into_Buffer
      (Buf      : out Name_String;
       Max_Size : Positive)
      with Pre => Max_Size <= Buf'Length
   is
      --  In real code, use Ada.Text_IO.Get_Line which is bounds-safe
      Simulated_Input : constant String := "User input here";
      Copy_Len        : constant Natural :=
         Natural'Min (Simulated_Input'Length, Max_Size);
   begin
      --  Copy what fits, pad the rest
      for I in Buf'Range loop
         if I - Buf'First < Copy_Len then
            Buf (I) := Simulated_Input (Simulated_Input'First + (I - Buf'First));
         else
            Buf (I) := ' ';
         end if;
      end loop;
   end Read_Into_Buffer;

   --  Safe version 5: Buffer shift with bounds checking
   --  Uses bounded buffer to prevent index overflow
   procedure Shift_Data
      (Buf    : in out Bounded_Buffer;
       Offset : Buffer_Index)
      with Pre  => Offset < Buf'Length,
           Post => (for all I in Buf'First .. Buf'Last - Offset =>
                      Buf (I) = Buf'Old (I + Offset))
   is
   begin
      for I in Buf'First .. Buf'Last - Offset loop
         Buf (I) := Buf (I + Offset);
         pragma Loop_Invariant
            (for all J in Buf'First .. I =>
               Buf (J) = Buf'Loop_Entry (J + Offset));
      end loop;
   end Shift_Data;

   --  Safe version 6: No integer overflow to buffer overflow
   --  SPARK uses static bounds; no dynamic allocation needed
   Max_Items : constant := 1000;
   type Item_Index is range 1 .. Max_Items;
   type Int_Array is array (Item_Index) of Integer;

   procedure Fill_Sequential (Buf : in out Int_Array; Count : Item_Index)
      with Post => (for all I in 1 .. Count => Buf (I) = Integer (I))
   is
   begin
      for I in Buf'Range loop
         if I <= Count then
            Buf (I) := Integer (I);
         else
            Buf (I) := 0;
         end if;
         pragma Loop_Invariant
            (for all J in 1 .. I =>
               (if J <= Count then Buf (J) = Integer (J)
                else Buf (J) = 0));
      end loop;
      --  No need to free - stack allocated
   end Fill_Sequential;

   --  Test procedures
   procedure Test_Array_Bounds is
      Scores : Score_Array (1 .. 5) := (others => 0);
   begin
      Put_Line ("Testing array bounds safety...");
      Set_Score (Scores, 3, 100);  -- ✓ Valid
      Put_Line ("Score at index 3: " & Integer'Image (Scores (3)));

      --  This would cause COMPILE ERROR if uncommented:
      --  Set_Score (Scores, 10, 100);  -- Precondition violation!

      --  Without precondition, this would raise Constraint_Error at runtime
   end Test_Array_Bounds;

   procedure Test_String_Copy is
      Name : Name_String := (others => ' ');
      Short_Name : constant String := "Ada SPARK";
   begin
      Put_Line ("Testing string copy safety...");

      --  Safe: source fits in destination
      Copy_Name (Name, Short_Name);

      Put_Line ("Safe copy: " & Name (1 .. 20) & "...");
   end Test_String_Copy;

   procedure Test_Fill is
      Buffer : Bounded_Buffer;
   begin
      Put_Line ("Testing fill buffer...");
      Fill_Buffer (Buffer, 'A');
      --  Impossible to have off-by-one error!
      Put ("Buffer: ");
      for I in 1 .. 10 loop
         Put (Buffer (I));
      end loop;
      New_Line;
   end Test_Fill;

   procedure Test_Shift is
      Buffer : Bounded_Buffer := (1 => 'A', 2 => 'B', 3 => 'C', 4 => 'D',
                                  5 => 'E', 6 => 'F', 7 => 'G', 8 => 'H',
                                  9 => 'I', 10 => 'J', others => '.');
   begin
      Put_Line ("Testing shift data...");
      Put ("Before: ");
      for I in 1 .. 10 loop
         Put (Buffer (I));
      end loop;
      New_Line;

      Shift_Data (Buffer, 3);  -- Shift left by 3

      Put ("After:  ");
      for I in 1 .. 7 loop
         Put (Buffer (I));
      end loop;
      New_Line;
   end Test_Shift;

begin
   Test_Array_Bounds;
   New_Line;

   Test_String_Copy;
   New_Line;

   Test_Fill;
   New_Line;

   Test_Shift;
   New_Line;

   Put_Line ("All buffer operations completed safely!");
   Put_Line ("No buffer overflows possible in SPARK!");
end Example;
