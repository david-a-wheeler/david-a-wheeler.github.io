--
-- Copyright (C) 1996 Ada Resource Association (ARA), Columbus, Ohio.
-- Author: David A. Wheeler
--
 
with Ada.Strings.Unbounded;
use  Ada.Strings.Unbounded;

package Parser is
 procedure Execute(Command : in Unbounded_String; Quit : out Boolean);
   -- Executes the given command.
   -- Sets Quit to False if the user may run additional commands.
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
