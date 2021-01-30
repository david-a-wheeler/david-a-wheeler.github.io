--
-- Copyright (C) 1996 Ada Resource Association (ARA), Columbus, Ohio.
-- Author: David A. Wheeler
--

with Ada.Characters.Handling;
use  Ada.Characters.Handling;

package body Directions is

 Abbreviations : constant String := "nsewud";

 procedure To_Direction(Text : in Unbounded_String;
                        Is_Direction : out Boolean;
                        Dir  : out Direction) is
  Lower_Text : String := To_Lower(To_String(Text));
  -- Attempt to turn "Text" into a direction.
  -- If successful, set "Is_Direction" True and "Dir" to the value.
  -- If not successful, set "Is_Direction" False and "Dir" to arbitrary value.
 begin
   if Length(Text) = 1 then
     -- Check if it's a one-letter abbreviation.
     for D in Direction'Range loop
       if Lower_Text(1) = Abbreviations(Direction'Pos(D) + 1) then
         Is_Direction := True;
         Dir := D;
         return;
       end if;
     end loop;
     Is_Direction := False;
     Dir := North;
     return;

   else
     -- Not a one-letter abbreviation, try a full name.
     for D in Direction'Range loop
       if Lower_Text = To_Lower(Direction'Image(D)) then
         Is_Direction := True;
         Dir := D;
         return;
       end if;
     end loop;
     Is_Direction := False;
     Dir := North;
     return;
   end if;
 end To_Direction;

 function To_Direction(Text : in Unbounded_String) return Direction is
   Is_Direction : Boolean;
   Dir          : Direction;
 begin
   To_Direction(Text, Is_Direction, Dir);
   if Is_Direction then
      return Dir;
   else
      raise Constraint_Error;
   end if;
 end To_Direction;

 function Is_Direction(Text : in Unbounded_String) return Boolean is
   Is_Direction : Boolean;
   Dir          : Direction;
 begin
   To_Direction(Text, Is_Direction, Dir);
   return Is_Direction;
 end Is_Direction;

end Directions;

--
-- Permission to use, copy, modify, and distribute this software and its
-- documentation for any purpose and without fee is hereby granted,
-- provided that the above copyright and authorship notice appear in all
-- copies and that both that copyright notice and this permission notice
-- appear in supporting documentation.
-- 
-- The ARA makes no representations about the suitability of this software
-- for any purpose.  It is provided "as is" without express
-- or implied warranty.
-- 
