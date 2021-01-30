--
-- Copyright (C) 1996 Ada Resource Association (ARA), Columbus, Ohio.
-- Author: David A. Wheeler
--

with Ada.Strings.Unbounded;
use  Ada.Strings.Unbounded;

package Directions is

 type Direction is (North, South, East, West, Up, Down);

 Reverse_Direction : constant array(Direction) of Direction :=
                    (North => South, South => North,
                     East =>West, West => East,
                     Up => Down, Down => Up);

 function To_Direction(Text : Unbounded_String) return Direction;
 -- Converts Text to Direction; raises Constraint_Error if it's not
 -- a legal direction.

 function Is_Direction(Text : Unbounded_String) return Boolean;
 -- Returns TRUE if Text is a direction, else false.

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
