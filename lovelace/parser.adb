--
-- Copyright (C) 1996 Ada Resource Association (ARA), Columbus, Ohio.
-- Author: David A. Wheeler
--

with Text_IO, Ada.Strings.Maps.Constants, Ustrings, Things, Occupants, World;
use  Text_IO, Ada.Strings.Maps.Constants, Ustrings, Things, Occupants, World;
use  Ada.Strings, Ada.Strings.Maps;

with Directions;
use  Directions;

package body Parser is

 Spaces : constant Character_Set := To_Set(' ');

 procedure Split(Source     : in  Unbounded_String;
                 First_Word : out Unbounded_String;
                 Rest       : out Unbounded_String) is
  First : Positive; -- Index values of first word.
  Last  : Natural;
 -- Puts first word of Source into First_Word, the rest of the words in Rest
 -- (without leading spaces); words are separated by one or more spaces;
 -- if there are no spaces, Rest returns empty.
 begin
  Find_Token(Source, Spaces, Outside, First, Last);
  First_Word := U(Slice(Source, First, Last));
  Rest       := Trim(U(Slice(Source, Last + 1, Length(Source))), Left);
 end Split;



 procedure Execute(Command : in Unbounded_String; Quit : out Boolean) is
  Trimmed_Command : Unbounded_String := Trim(Command, Both);
  Verb, Arguments, First_Argument, Rest_Of_Arguments : Unbounded_String;
  Direct_Object : Occupant_Access;
 begin
  Quit := False; -- By default assume we won't quit.
  if (Empty(Trimmed_Command)) then
    return;      -- Ignore blank lines.
  end if;

  -- Extract Verb and First_Argument and force them to lower case.
  Split(Trimmed_Command, Verb, Arguments);
  Translate(Verb, Lower_Case_Map);
  Split(Arguments, First_Argument, Rest_Of_Arguments);
  Translate(First_Argument, Lower_Case_Map);


  -- Try to execute "Verb".

  if    Verb = "look" then
    Look(Me);
  elsif Verb = "get" then
    Direct_Object := Occupant_Access(Find(Me, First_Argument));
    if Direct_Object /= null then
      Get(Me, Direct_Object);
    end if;
  elsif Verb = "drop" then
    Direct_Object := Occupant_Access(Find_Inside(Me, First_Argument));
    if Direct_Object /= null then
      Drop(Me, Direct_Object);
    end if;
  elsif Verb = "inventory" or Verb = "inv" then
    Inventory(Me);
  elsif Verb = "quit" then
    Quit := True;
  elsif Verb = "go" and then Is_Direction(First_Argument) then
    Go(Me, To_Direction(First_Argument));
    Look(Me);
  elsif Is_Direction(Verb) then  -- Is the verb a direction (north, etc)?
    Go(Me, To_Direction(Verb));
    Look(Me);
  elsif Verb = "help" then
    Put_Line("Please type in one or two word commands, beginning with a verb");
    Put_Line("or direction. Directions are north, south, east, west, etc.");
    Put_Line("Here are some sample commands:");
    Put_Line("look, get box, drop box, inventory, go west, west, w, quit.");
  else
   Put_Line("Sorry, I don't recognize that verb. Try 'help'.");
  end if;
  
 end Execute;
end Parser;

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
