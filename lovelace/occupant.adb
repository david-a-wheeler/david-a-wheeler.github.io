--
-- Copyright (C) 1996 Ada Resource Association (ARA), Columbus, Ohio.
-- Author: David A. Wheeler
--

with Text_IO, Ada.Strings.Unbounded, Ustrings, Rooms;
use  Text_IO, Ada.Strings.Unbounded, Ustrings, Rooms;

package body Occupants is


 procedure Put_View(T : access Occupant; Agent : access Thing'Class) is
 begin
  Put("You are inside ");
  Put_Line(Short_Description(T));
  Put_Line(".");
  Put_Contents(T, Agent, "You see:");
 end Put_View;

 procedure Look(T : access Occupant) is
 -- T is running a "look" command; tell T what he views.
 begin
  if Container(T) = null then
    Put("You are inside nothing at all.");
  else
    Put_View(Container(T), T);
  end if;
 end Look;


 procedure Get(Agent : access Occupant; Direct_Object : access Occupant'Class)
 is
 begin
   if May_I_Get(Direct_Object, Agent) then
     Place(T => Direct_Object, Into => Thing_Access(Agent));
   end if;
 end Get;
 
 function May_I_Get(Direct_Object : access Occupant;
                    Agent : access Occupant'Class)
          return Boolean is
 begin
   Sorry("get", Name(Direct_Object));  -- Tell the getter sorry, can't get it
   return False;
 end May_I_Get;
 
 procedure Drop(Agent : access Occupant;
                Direct_Object : access Occupant'Class) is
 begin
   if May_I_Drop(Direct_Object, Agent) then
     Place(T => Direct_Object, Into => Container(Agent));
   end if;
 end Drop;

 function  May_I_Drop(Direct_Object : access Occupant;
                      Agent : access Occupant'Class)
           return Boolean is
 begin
   return True;
 end May_I_Drop;
 

 procedure Inventory(Agent : access Occupant) is
 begin
  Put_Contents(Agent, Agent,
               "You're carrying:",
               "You aren't carrying anything.");
 end Inventory;

 procedure Go(Agent : access Occupant; Dir : in Direction) is
 begin
  if Container(Agent) = null then
    Put_Line("Sorry, you're not in a room!");
  else
    declare
      Destination : Thing_Access := What_Is(Container(Agent), Dir);
    begin
     if Destination = null then
       Put_Line("Sorry, you can't go that way.");
     else
       Place(Agent, Destination);
     end if;
    end;
  end if;
 end Go;
 
end Occupants;

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
