--
-- Copyright (C) 1996 Ada Resource Association (ARA), Columbus, Ohio.
-- Author: David A. Wheeler
--

with Things, Directions;
use  Things, Directions;

package Occupants is

 -- An "Occupant" is a Thing that can be inside a Room or another Occupant.

 type Occupant is abstract new Thing with private;
 type Occupant_Access   is access all Occupant'Class;

 -- Dispatching subprograms:

 procedure Look(T : access Occupant);      -- Ask Occupant T to "look".

 procedure Get(Agent : access Occupant; Direct_Object : access Occupant'Class);
           -- Ask Agent to get Direct_Object.  This assumes that Agent can
           -- somehow access Direct_Object (i.e. is in the same room).
           -- If the agent decides that it can get the object, it will
           -- call May_I_Get to ask the object if that's okay.

 procedure Drop(Agent : access Occupant; Direct_Object : access Occupant'Class);
           -- Ask Agent to drop Direct_Object.

 procedure Inventory(Agent : access Occupant);
           -- Ask Agent to print a list of what Agent is carrying.

 procedure Go(Agent : access Occupant; Dir : in Direction);
            -- Ask Agent to go the given Direction Dir (North, South, etc.)

 procedure Put_View(T : access Occupant; Agent : access Thing'Class);
            -- Override Thing's Put_View.
 
 function May_I_Get(Direct_Object : access Occupant;
                    Agent : access Occupant'Class) return Boolean;
           -- Ask Direct_Object if "Agent" can get this object.
           -- Returns True if it's okay, else False.
           -- If the object does something while being gotten (or an attempt
           -- to do so) it does it in this call.

 function  May_I_Drop(Direct_Object : access Occupant;
                      Agent         : access Occupant'Class) return Boolean;
           -- Ask Direct_Object if "Agent" can drop this object;
           -- returns True if it's okay.

private

 type Occupant is abstract new Thing with
  record
    null;  -- Nothing here for now.
  end record;

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
