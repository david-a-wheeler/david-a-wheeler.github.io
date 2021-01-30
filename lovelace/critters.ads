 package Critters is
   type Monster is tagged
      record
        Size_In_Meters : Integer;
      end record;
   type Dragon is new Monster with null record;
   type Red_Dragon is new Dragon with null record;
   type Person is tagged
      record
        Age : Integer;
      end record;
 end Critters;
