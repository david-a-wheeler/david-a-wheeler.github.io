--
-- Copyright (C) 1996 Ada Resource Association (ARA), Columbus, Ohio.
-- Author: David A. Wheeler
--

with Text_IO, Ustrings;
use  Text_IO, Ustrings;


package body Things is

 -- Define basic types for the world and their operations.


 -- Supporting Subprograms:

 procedure Sorry(Prohibited_Operation : String;
                 Prohibited_Direct_Object : Unbounded_String) is
 begin
  Put_Line("Sorry, you may not " & Prohibited_Operation & " the " &
           S(Prohibited_Direct_Object));
 end Sorry;


 -- Routines to manipulate First_Containee, Next_Sibling, Container:

 function Previous_Sibling(Containee : access Thing'Class)
          return Thing_Access is
  -- Find the previous sibling of containee.  It's an error to call
  -- this if Containee has no previous sibling.
    Current : Thing_Access := Containee.Container.First_Containee;
 begin
    while Current.Next_Sibling /= Thing_Access(Containee) loop
      Current := Current.Next_Sibling;
    end loop;
    return Current;
 end Previous_Sibling;

 function Last_Containee(Container : access Thing'Class)
          return Thing_Access is
   -- Return an access value of the last contained Thing in container.
   -- It's an error to call this routine if there are no containees.
    Current : Thing_Access := Container.First_Containee;
 begin
    while Current.Next_Sibling /= null loop
      Current := Current.Next_Sibling;
    end loop;
    return Current;
 end Last_Containee;

 procedure Remove(Containee : access Thing'Class) is
 -- Remove Containee from its current Container.
  Previous_Thing : Thing_Access;
 begin
  if Containee.Container /= null then
    if Containee.Container.First_Containee = Thing_Access(Containee) then
       -- Containee is the first Thing in its container.
       Containee.Container.First_Containee := Containee.Next_Sibling;
    else
       Previous_Thing := Previous_Sibling(Containee);
       Previous_Thing.Next_Sibling := Containee.Next_Sibling;
    end if;
    Containee.Next_Sibling := null;
    Containee.Container    := null;
  end if;
 end Remove;


 procedure Place(T : access Thing'Class; Into : Thing_Access) is
 -- Place "T" inside "Into".
  Last : Thing_Access;
 begin
  if (Thing_Access(T) = Into) then
    Put_Line("Sorry, that can't be done.");
    return;
  end if;
  Remove(T); -- Remove Thing from where it is now.
  if Into /= null then
    if Into.First_Containee = null then
      Into.First_Containee := Thing_Access(T);
    else
      Last := Last_Containee(Into);
      Last.all.Next_Sibling := Thing_Access(T);
    end if;
  end if;
  T.Container := Into;
 end Place;

 procedure Put_Contents(T : access Thing'Class;
                        Ignore : access Thing'Class;
                        Heading_With_Contents : in String;
                        Heading_Without_Contents : in String := "") is
   -- Put a description of the contents of T.
   -- If there is something, print Heading_With_Contents;
   -- If there isn't something, print Heading_Without_Contents.
   -- Ignore The_Player, since presumably the player already knows about
   -- him/herself.
   Current : Thing_Access := T.First_Containee;
   Have_Put_Something : Boolean := False;
 begin
  while Current /= null loop
    if Current /= Thing_Access(Ignore) then
      -- This what we're to ignore, print it out.
      if Have_Put_Something then
        Put(", ");
      else
        -- We're about to print the first item; print the heading.
        Put_Line(Heading_With_Contents);
      end if;
      Put(Short_Description(Current));
      Have_Put_Something := True;
    end if;
    Current := Current.Next_Sibling;
  end loop;
  if Have_Put_Something then
    Put_Line(".");
  elsif Heading_With_Contents'Length > 0 then
    Put_Line(Heading_Without_Contents);
  end if;
 end Put_Contents;


 -- Dispatching Operations:

 function What_Is(From : access Thing; Dir : in Direction)
          return Thing_Access is
 begin
   return null; -- As a default, you can't go ANY direction from "here".
 end What_Is;


 -- Non-dispatching public operations:

 procedure Set_Name(T : access Thing'Class; Article : in Article_Type;
                    Name : in Unbounded_String) is
 begin
   T.Article := Article;
   T.Name    := Name;
 end Set_Name;

 procedure Set_Name(T : access Thing'Class; Article : in Article_Type;
                    Name : in String) is
 begin
   T.Article := Article;
   T.Name    := To_Unbounded_String(Name);
 end Set_Name;

 function Name(T : access Thing'Class) return Unbounded_String is
 begin
  return T.Name;
 end Name;

 procedure Set_Description(T : access Thing'Class;
                           Description : in Unbounded_String) is
 begin
  T.Description := Description;
 end Set_Description;

 procedure Set_Description(T : access Thing'Class;
                           Description : in String) is
 begin
  T.Description := To_Unbounded_String(Description);
 end Set_Description;

 function Long_Description(T : access Thing'Class) return Unbounded_String is
 begin
   return T.Description;
 end Long_Description;
 

 -- Eventually we'll use an array for the article, but a minor GNAT 2.7.0 bug
 -- will cause this to raise a Segmentation Fault when the program quits:
 -- Article_Text : constant array(Article_Type) of Unbounded_String :=
 --     (A => U("a "), An => U("an "), The => U("the "), Some => U("some "),
 --      None => U(""));

 function Short_Description(T : access Thing'Class) return Unbounded_String is
 begin
  case T.Article is
   when A    => return "a "    & T.Name;
   when An   => return "an "   & T.Name;
   when The  => return "the "  & T.Name;
   when Some => return "some " & T.Name;
   when None => return           T.Name;
  end case;
  -- Should become return Article_Text(T.Article) & T.Name;
 end Short_Description;

 function Find(Agent : access Thing'Class;
               Object_Name : in Unbounded_String) return Thing_Access is
 begin
   if Agent.Container = null then
     Put_Line("You aren't in anything.");
     return null;
   else
     return Find_Inside(Agent.Container, Object_Name);
   end if;
 end Find;

 function Find_Inside(Agent : access Thing'Class;
                      Object_Name : in Unbounded_String)
          return Thing_Access is
   Current : Thing_Access := Agent.First_Containee;
 begin
   if Empty(Object_Name) then
     Put_Line("Sorry, you need to name an object.");
     return null;
   end if;
   while Current /= null loop
     if Current.Name = Object_Name then
       return Current;
     end if;
     Current := Current.Next_Sibling;
   end loop;
   Put("Sorry, I don't see a ");
   Put_Line(Object_Name);
   return null;
 end Find_Inside;

 function Container(T : access Thing'Class) return Thing_Access is
 begin
   return T.Container;
 end Container;

 function Has_Contents(T : access Thing'Class) return Boolean is
 begin
   if T.First_Containee = null then
     return False;
   else
     return True;
   end if;
 end Has_Contents;

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
