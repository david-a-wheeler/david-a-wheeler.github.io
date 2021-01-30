--
-- Copyright (C) 1996 Ada Resource Association (ARA), Columbus, Ohio.
-- Author: David A. Wheeler
--

with Ada.Strings.Unbounded, Ada.Finalization, Directions;
use  Ada.Strings.Unbounded, Ada.Finalization, Directions;

package Things is

 -- "Thing" is the root class for all things in this small world.
 -- Rooms, Players, Items, and Monsters are derived from Thing.

 
 type Thing is abstract new Limited_Controlled with private;
 type Thing_Access is access all Thing'Class;

 type Article_Type is (A, An, The, Some, None);

 -- Public Dispatching operations.

 procedure Put_View(T : access Thing; Agent : access Thing'Class) is abstract;
  -- Put what Agents sees inside T.

 function What_Is(From : access Thing; Dir : in Direction) return Thing_Access;
 -- Returns what is at direction "Dir" from "From".
 -- Returns null if nothing connected in that direction.

 -- Public non-Dispatching operations:

 procedure Set_Name(T : access Thing'Class; Article : in Article_Type;
                    Name : in Unbounded_String);
 procedure Set_Name(T : access Thing'Class; Article : in Article_Type;
                    Name : in String);
 function Name(T : access Thing'Class) return Unbounded_String;
 pragma Inline(Name);

 function Short_Description(T : access Thing'Class) return Unbounded_String;
 -- Returns Article + Name, i.e. "the box", "a car", "some horses".
 
 procedure Set_Description(T : access Thing'Class;
                           Description : in Unbounded_String);
 procedure Set_Description(T : access Thing'Class;
                           Description : in String);
 function Long_Description(T : access Thing'Class) return Unbounded_String;
 
 procedure Place(T : access Thing'Class; Into : Thing_Access);
   -- Place T inside "Into" (removing it from wherever it was).
   -- Attempting to place T into itself will print an error message
   -- and fail.
   -- The second parameter is Thing_Access, not Thing'Class, because
   -- "null" is a valid value for "Into".
 function Container(T : access Thing'Class) return Thing_Access;
   -- Return access value to the container of T.
 function Has_Contents(T : access Thing'Class) return Boolean;
   -- Does T have anything in it?

 function Find(Agent : access Thing'Class;
               Object_Name : in Unbounded_String) return Thing_Access;
          -- Find the given Object_Name in the same container as the agent.
          -- Prints and error message and returns null if not found.

 function Find_Inside(Agent       : access Thing'Class;
                      Object_Name : in Unbounded_String)
          return Thing_Access;
          -- Find the given Object_Name inside the agent.
          -- Prints and error message and returns null if not found.

 procedure Put_Contents(T : access Thing'Class;
                        Ignore : access Thing'Class;
                        Heading_With_Contents : in String;
                        Heading_Without_Contents : in String := "");
   -- Put a description of the contents of T.
   -- Act as though "Ignore" isn't there.
   -- If there is something, print Heading_With_Contents;
   -- If there isn't something, print Heading_Without_Contents.

 procedure Sorry(Prohibited_Operation : String;
                 Prohibited_Direct_Object : Unbounded_String);
   -- Put "Sorry, you may not XXX the YYY".


private

 type Thing is abstract new Limited_Controlled with
  record
   Name, Description : Unbounded_String;
   Article           : Article_Type := A;
   Container         : Thing_Access; -- what Thing contains me?
   Next_Sibling      : Thing_Access; -- next Thing in my container.
   First_Containee   : Thing_Access; -- first Thing inside me.
  end record;

end Things;

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
