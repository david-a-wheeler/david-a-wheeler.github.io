--
-- Copyright (C) 1996 Ada Resource Association (ARA), Columbus, Ohio.
-- Author: David A. Wheeler
--

with Text_IO, Ustrings;
use  Text_IO, Ustrings;

package body Rooms is

 procedure Connect(Source : access Room; Dir : in Direction; 
                   Destination : access Thing'Class;
                   Bidirectional : in Boolean := True) is
 begin
   Source.Destinations(Dir) := Thing_Access(Destination);
   if Bidirectional then  -- Connect in reverse direction.
     Room_Access(Destination).Destinations(Reverse_Direction(Dir)) := 
              Thing_Access(Source);
   end if;
 end Connect;

 procedure Disconnect(Source : access Room; Dir : in Direction; 
                      Bidirectional : in Boolean := True) is
 begin
   if Bidirectional then
     -- If it's bidirectional, remove the other direction. The following "if"
     -- statement, if uncommented, checks to make sure that
     -- disconnecting a bidirectional link only happens to a Room.
     -- if (Source.Destinations(Dir).all'Tag in Room'Class) then
       Room_Access(Source.Destinations(Dir)).
                   Destinations(Reverse_Direction(Dir)) := null;
     -- end if;
   end if;
   Source.Destinations(Dir) := null;
 end Disconnect;

 function What_Is(From : access Room; Dir : in Direction) return Thing_Access is
 begin
  return From.Destinations(Dir);
 end What_Is;

 procedure Put_View(T : access Room; Agent : access Thing'Class) is
 begin
  Put("You are ");
  Put(Long_Description(T));
  Put_Line(".");
  Put_Contents(T, Agent, "You see:");
 end Put_View;

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
