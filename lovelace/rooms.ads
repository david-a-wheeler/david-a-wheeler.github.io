--
-- Copyright (C) 1996 Ada Resource Association (ARA), Columbus, Ohio.
-- Author: David A. Wheeler
--

with Things, Directions;
use  Things, Directions;

package Rooms is
 type Room     is new Thing with private;
 type Room_Access       is access all Room'Class;

 procedure Put_View(T : access Room; Agent : access Thing'Class);

 procedure Connect(Source : access Room; Dir : in Direction; 
                   Destination : access Thing'Class;
                   Bidirectional : in Boolean := True);
  -- Create a connection from Source to Destination in Direction Dir.
  -- If it's bidirectional, create another connection the reverse way.

 procedure Disconnect(Source : access Room; Dir : in Direction; 
                      Bidirectional : in Boolean := True);
 -- Reverse of connect; disconnects an existing connection, if any.

 function What_Is(From : access Room; Dir : in Direction) return Thing_Access;
 -- Returns what is at direction "Dir" from "From".
 -- Returns null if nothing connected in that direction.

private

 type Destination_Array is array(Direction) of Thing_Access;

 type Room     is new Thing with
  record
    Destinations : Destination_Array;
  end record;

end Rooms;

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
