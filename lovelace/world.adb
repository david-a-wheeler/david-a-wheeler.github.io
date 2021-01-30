--
-- Copyright (C) 1996 Ada Resource Association (ARA), Columbus, Ohio.
-- Author: David A. Wheeler
--

with Text_IO, Ada.Strings.Unbounded, Ustrings;
use  Text_IO, Ada.Strings.Unbounded, Ustrings;

with Things, Players, Items, Rooms, Directions;
use  Things, Players, Items, Rooms, Directions;

package body World is

 The_Player : Player_Access;    -- This is the object representing the
                                -- current player.


 procedure Setup is
   Starting_Room : Room_Access := new Room;
   Box           : Item_Access := new Item;
   Knife         : Item_Access := new Item;
   Living_Room   : Room_Access := new Room;
 begin
   Set_Name(Starting_Room, The, "Hallway");
   Set_Description(Starting_Room, "in the hallway. There is a living room " &
                   "to the west");

   Set_Name(Box, A, "box");
   Set_Description(Box, "a red box");
   Place(T => Box, Into => Thing_Access(Starting_Room));

   Set_Name(Knife, A, "knife");
   Set_Description(Box, "a black knife");
   Place(T => Knife, Into => Thing_Access(Starting_Room));

   Set_Name(Living_Room, The, "Living Room");
   Set_Description(Living_Room, "in the living room. " &
                                "A hallway is to your east");
   Connect(Starting_Room, West, Living_Room);

   -- Setup player.
   The_Player := new Player; 
   Set_Name(The_Player, None, "Fred");
   Set_Description(The_Player, Name(The_Player));
   Place(T => Me,  Into => Thing_Access(Starting_Room));
   Look(Me);

 end Setup;


 function Me return Occupant_Access is
  -- Return access value to current player.
 begin
  return Occupant_Access(The_Player);
 end Me;

end World;

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
